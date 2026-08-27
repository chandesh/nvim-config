-- ~/.config/nvim/lua/config/env_bridge.lua
-- =============================================================================
-- Environment Bridge — Synchronizes container Python env to host for LSP/DAP
-- =============================================================================

local M = {}

local ENV_FILE = ".nvim-env.json"

-- Shared sync state consumed by the lualine component in ui.lua.
-- Follows the pkg_manager pattern: vim.g hands out COPIES of tables on every
-- read, so internal logic mutates the canonical `state` table and mirrors it
-- to vim.g.env_sync via state_sync(). Lualine only ever reads the snapshot.
local state = {
  active = false,
  phase = "",
}

local spinner = require('config.icons').fidget.spinner
local spinner_idx = 0
local spinner_timer = nil

local function state_sync()
  vim.g.env_sync = state
end

state_sync()

local function set_phase(phase)
  state.phase = phase
  state.active = phase ~= ""
  state_sync()
  vim.cmd('redrawstatus')
end

local function start_spinner()
  if spinner_timer then return end
  spinner_idx = 0
  spinner_timer = vim.fn.timer_start(300, function()
    spinner_idx = (spinner_idx % #spinner) + 1
    state.spinner = spinner[spinner_idx]
    state_sync()
    vim.cmd('redrawstatus')
  end, { ['repeat'] = -1 })
end

local function stop_spinner()
  if spinner_timer then
    vim.fn.timer_stop(spinner_timer)
    spinner_timer = nil
  end
  state.spinner = nil
end

local function finish_sync(msg, level)
  stop_spinner()
  state.active = false
  state.phase = ""
  state.spinner = nil
  state_sync()
  vim.cmd('redrawstatus')
  if msg then
    vim.notify(msg, level or vim.log.levels.INFO)
  end
end

-- Helper to get project root
local function get_project_root()
  return vim.fn.getcwd()
end

-- Load bridge configuration
function M.get_config()
  local root = get_project_root()
  local path = root .. "/" .. ENV_FILE
  local file = io.open(path, "r")
  if not file then return nil end
  
  local content = file:read("*all")
  file:close()
  
  local ok, decode = pcall(vim.json.decode, content)
  if not ok then return nil end
  return decode
end

-- Save bridge configuration
function M.save_config(config)
  local root = get_project_root()
  local path = root .. "/" .. ENV_FILE
  
  local file = io.open(path, "w")
  if not file then
    vim.notify("Could not write to " .. path, vim.log.levels.ERROR)
    return false
  end
  
  file:write(vim.json.encode(config))
  file:close()
  
  -- Add to .gitignore if it exists
  local gitignore_path = root .. "/.gitignore"
  local gitignore = io.open(gitignore_path, "r")
  if gitignore then
    local content = gitignore:read("*all")
    gitignore:close()
    if not content:find(ENV_FILE) then
      local f = io.open(gitignore_path, "a")
      f:write("\n# Neovim Env Bridge\n" .. ENV_FILE .. "\n")
      f:close()
    end
  end
  
  return true
end

-- Sync site-packages from container directly to the active virtual environment
function M.sync_libs()
  if state.active then
    vim.notify("Env sync already running.", vim.log.levels.WARN)
    return false
  end

  local config = M.get_config()
  if not config then
    vim.notify("No environment bridge configured. Run <leader>eC first.", vim.log.levels.WARN)
    return false
  end

  local venv_path = vim.env.VIRTUAL_ENV or vim.env.PYENV_VIRTUAL_ENV
  if not venv_path or venv_path == "" then
    vim.notify("No active virtual environment detected. Please activate your venv (e.g. webapp-env) first.", vim.log.levels.ERROR)
    return false
  end

  local container = config.container
  local root = get_project_root()
  local temp_dest = root .. "/.nvim-env-tmp"

  -- Local (fast) lookup of the venv site-packages path
  local venv_py = venv_path .. "/bin/python"
  if vim.fn.executable(venv_py) ~= 1 then
    vim.notify("venv python not found: " .. venv_py, vim.log.levels.ERROR)
    return false
  end
  local local_site_packages = vim.fn.system(venv_py .. ' -c "import site; print(site.getsitepackages()[0])"'):gsub("%s+", "")
  if local_site_packages == "" then
    vim.notify("Could not find site-packages in active venv: " .. venv_path, vim.log.levels.ERROR)
    return false
  end

  -- All docker/filesystem work below is async (jobstart) so nvim stays
  -- responsive while the statusline shows the running phase.
  set_phase("exec")
  start_spinner()
  vim.notify("🔄 Syncing container libs into venv: " .. vim.fn.fnamemodify(venv_path, ":t"), vim.log.levels.INFO)
  vim.fn.mkdir(temp_dest, "p")

  local function cleanup_temp()
    vim.fn.jobstart({ "rm", "-rf", temp_dest })
  end

  local remote_sp = ""

  -- Phase 1: exec — resolve site-packages path inside the container
  vim.fn.jobstart({ "docker", "exec", container, "python",
    "-c", "import site; print(site.getsitepackages()[0])" }, {
    stdout_buffered = true,
    on_stdout = function(_, data)
      remote_sp = table.concat(data or {}, "")
    end,
    on_exit = function(_, exit_code)
      vim.schedule(function()
        remote_sp = remote_sp:gsub("%s+", "")
        if exit_code ~= 0 or remote_sp == "" then
          cleanup_temp()
          finish_sync("Could not find site-packages in container (" .. container .. ")", vim.log.levels.ERROR)
          return
        end

        -- Phase 2: copy — docker cp the remote site-packages to temp
        set_phase("copy")
        vim.fn.jobstart({ "docker", "cp", container .. ":" .. remote_sp, temp_dest }, {
          on_exit = function(_, copy_code)
            vim.schedule(function()
              if copy_code ~= 0 then
                cleanup_temp()
                finish_sync("Failed to copy libraries from container. Error code: " .. copy_code, vim.log.levels.ERROR)
                return
              end

              -- Phase 3: merge — merge copied packages into the venv without
              -- overwriting critical existing venv files (cp -rn)
              local copied_dir = temp_dest .. "/site-packages"
              if vim.fn.isdirectory(copied_dir) ~= 1 then
                cleanup_temp()
                finish_sync("Copied path missing site-packages subdirectory", vim.log.levels.ERROR)
                return
              end
              set_phase("merge")
              -- Note: macOS BSD cp returns exit code 1 (silently, empty stderr)
              -- whenever `-n` skips an existing destination file — the intended
              -- no-overwrite merge behavior. Real errors always print to stderr.
              -- So: exit 1 with no stderr = benign skips = success.
              local merge_stderr = {}
              vim.fn.jobstart({ "cp", "-rn", copied_dir .. "/.", local_site_packages }, {
                on_stderr = function(_, data)
                  for _, line in ipairs(data or {}) do
                    if line ~= "" then table.insert(merge_stderr, line) end
                  end
                end,
                on_exit = function(_, merge_code)
                  vim.schedule(function()
                    if merge_code ~= 0 and #merge_stderr > 0 then
                      cleanup_temp()
                      finish_sync("Failed to merge libraries into venv. Error code: " .. merge_code
                        .. ": " .. table.concat(merge_stderr, " "), vim.log.levels.ERROR)
                      return
                    end

                    -- Phase 4: cleanup — remove temp dir, then done
                    set_phase("cleanup")
                    vim.fn.jobstart({ "rm", "-rf", temp_dest }, {
                      on_exit = function()
                        vim.schedule(function()
                          finish_sync("✅ Successfully synced container libs to " .. venv_path, vim.log.levels.INFO)
                        end)
                      end,
                    })
                  end)
                end,
              })
            end)
          end,
        })
      end)
    end,
  })

  return true
end

-- Get the local path for Pyright extraPaths
function M.get_extra_paths()
  local config = M.get_config()
  if not config then return {} end
  
  local root = get_project_root()
  return { root .. "/" .. LIB_CACHE_DIR }
end

-- Get the local source directory that mirrors the container app_path.
-- /app/contifyadmin → <project root>/contifyadmin
-- If the current project root already *is* the app folder (root's basename
-- equals the app basename), return the root itself to avoid double-nesting.
function M.get_local_source_dir()
  local config = M.get_config()
  if not config or not config.app_path then return nil end
  local root = get_project_root()
  local app_name = vim.fn.fnamemodify(config.app_path, ":t")
  if vim.fn.fnamemodify(root, ":t") == app_name then
    return root
  end
  return root .. "/" .. app_name
end

-- Diagnostic tool to verify container paths vs host paths
function M.verify_debug_paths()
  local config = M.get_config()
  if not config then
    vim.notify("No environment bridge configured.", vim.log.levels.WARN)
    return
  end

  local container = config.container
  local app_path = config.app_path
  local host_path = M.get_local_source_dir() or get_project_root()

  vim.notify("🔍 Verifying Debug Paths...", vim.log.levels.INFO)

  -- Check if the path exists in the container
  local check_cmd = string.format('docker exec %s ls -d %s', container, app_path)
  local handle = io.popen(check_cmd)
  local result = handle:read("*l")
  handle:close()

  if result and result:find(app_path) then
    vim.notify(string.format("✅ Container Path Match: %s", app_path), vim.log.levels.INFO)
  else
    vim.notify(string.format("❌ Container Path NOT found: %s", app_path), vim.log.levels.ERROR)
  end

  vim.notify(string.format("🏠 Host Path: %s", host_path), vim.log.levels.INFO)
end

-- Simple prompt for config
function M.configure()
  vim.ui.input({ prompt = "Container Name: " }, function(container)
    if not container or container == "" then 
      vim.notify("Configuration cancelled: No container name provided", vim.log.levels.WARN)
      return 
    end
    
    vim.ui.input({ prompt = "Container App Path (e.g. /app/contifyadmin): " }, function(app_path)
      if not app_path or app_path == "" then 
        vim.notify("Configuration cancelled: No app path provided", vim.log.levels.WARN)
        return 
      end
      
      local config = {
        container = container,
        app_path = app_path,
        last_sync = os.date("%Y-%m-%d %H:%M:%S")
      }
      
      if M.save_config(config) then
        vim.notify("✅ Environment configured for " .. container .. ". Syncing libraries...", vim.log.levels.INFO)
        M.sync_libs()
      end
    end)
  end)
end

-- Start the debugpy server by relaunching the container in debug mode.
-- Relies on `make startdebugmode` (see docker-compose.debug.yml) so Gunicorn
-- is not competing for port 8585.
function M.start_debug_server()
  local root = get_project_root()
  vim.notify("🚀 Starting Debug Server (make startdebugmode)...", vim.log.levels.INFO)
  vim.fn.jobstart("make startdebugmode", {
    cwd = root,
    on_exit = function(_, code)
      if code == 0 then
        vim.notify("✅ Debug Server started (runserver + debugpy on 5678)", vim.log.levels.INFO)
      else
        vim.notify("❌ Failed to start Debug Server (make startdebugmode exit " .. code .. ")", vim.log.levels.ERROR)
      end
    end,
  })
end

-- Stop the debugpy server by stopping the container via `make stop`.
function M.stop_debug_server()
  local root = get_project_root()
  vim.notify("🛑 Stopping Debug Server (make stop)...", vim.log.levels.INFO)
  vim.fn.jobstart("make stop", {
    cwd = root,
    on_exit = function(_, code)
      if code == 0 then
        vim.notify("✅ Debug Server stopped", vim.log.levels.INFO)
      else
        vim.notify("Could not stop server (make stop exit " .. code .. ")", vim.log.levels.WARN)
      end
    end,
  })
end

return M
