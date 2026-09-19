-- ~/.config/nvim/lua/config/env_bridge.lua
-- =============================================================================
-- Environment Bridge — Synchronizes container Python env to host for LSP/DAP
-- =============================================================================

local M = {}

local ENV_FILE = ".nvim-env.json"

local DEFAULT_DEBUG = {
  port = 5678,
  app_port = 8585,
  compose_dir = "..",
  base_compose = "docker-compose.yml",
  command = "manage.py",
  default_args = "",
}

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

-- Debug env state, mirrored to vim.g.env_debug so a statusline indicator can
-- be added later. Same pkg_manager pattern as `state` above: vim.g hands out
-- COPIES, so internal logic mutates M.debug_state and mirrors via
-- debug_state_sync().
M.debug_state = { active = false, action = "" }

local function debug_state_sync()
  vim.g.env_debug = M.debug_state
end

debug_state_sync()

local function set_debug_action(action)
  M.debug_state.action = action or ""
  M.debug_state.active = action ~= ""
  debug_state_sync()
  vim.cmd('redrawstatus')
end

local function clear_debug_action()
  set_debug_action("")
end

local function is_dry_run()
  return vim.g.env_bridge_dry_run == true
end

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

-- Resolve the compose directory for the debug env. Relative paths resolve
-- against the project root; falls back to walking up the tree for the base
-- compose file so a missing/odd compose_dir still finds the stack.
local function resolve_compose_dir(root, compose_dir, base_compose)
  local dir = vim.fn.fnamemodify(compose_dir, ":p")
  if vim.fn.filereadable(dir .. "/" .. base_compose) ~= 1 then
    local p = root
    while true do
      if vim.fn.filereadable(p .. "/" .. base_compose) == 1 then return p end
      local parent = vim.fn.fnamemodify(p, ":h")
      if parent == p then break end
      p = parent
    end
  end
  return dir
end

-- Merged debug config: DEFAULT_DEBUG overlaid with config.debug, with the
-- compose_dir resolved to an absolute path. Returns nil when the project has
-- no env bridge config.
function M.get_debug_config()
  local config = M.get_config()
  if not config then return nil end
  local debug = vim.tbl_deep_extend("force", vim.deepcopy(DEFAULT_DEBUG), config.debug or {})
  debug.compose_dir = resolve_compose_dir(get_project_root(), debug.compose_dir, debug.base_compose)
  return debug
end

function M.get_debug_port()
  local debug = M.get_debug_config()
  if not debug then return DEFAULT_DEBUG.port end
  return debug.port
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

  local venv_path = vim.env.VIRTUAL_ENV
  if not venv_path or venv_path == "" then
    venv_path = vim.env.PYENV_VIRTUAL_ENV
  end
  if not venv_path or venv_path == "" then
    vim.notify("No active virtual environment detected. Please activate your venv (e.g. webapp-env) first.", vim.log.levels.ERROR)
    return false
  end

  local container = config.container
  if not container or container == "" then
    vim.notify("Environment bridge config is missing a container name. Run <leader>eC to reconfigure.", vim.log.levels.ERROR)
    return false
  end
  local root = get_project_root()
  local temp_dest = root .. "/.nvim-env-tmp"

  -- Local (fast) lookup of the venv site-packages path, run async below
  local venv_py = venv_path .. "/bin/python"
  if vim.fn.executable(venv_py) ~= 1 then
    vim.notify("venv python not found: " .. venv_py, vim.log.levels.ERROR)
    return false
  end
  local local_site_packages = ""

  -- All docker/filesystem work below is async (jobstart) so nvim stays
  -- responsive while the statusline shows the running phase.
  local function cleanup_temp()
    vim.fn.delete(temp_dest, "rf")
  end

  local active_job = nil
  local watchdog_timer = nil
  local WATCHDOG_TIMEOUT_MS = 600000

  local function start_job(args, opts)
    local job = vim.fn.jobstart(args, opts)
    if job > 0 then active_job = job end
    return job > 0
  end

  local function stop_watchdog()
    if watchdog_timer then
      vim.fn.timer_stop(watchdog_timer)
      watchdog_timer = nil
    end
  end

  local function start_watchdog()
    stop_watchdog()
    watchdog_timer = vim.fn.timer_start(WATCHDOG_TIMEOUT_MS, function()
      if not state.active then return end
      if active_job then
        vim.fn.jobstop(active_job)
        active_job = nil
      end
      cleanup_temp()
      finish_sync("Env sync timed out after " .. (WATCHDOG_TIMEOUT_MS / 1000) .. "s and was aborted.", vim.log.levels.ERROR)
    end, { ['repeat'] = 1 })
  end
  set_phase("exec")
  start_spinner()
  start_watchdog()
  vim.notify("🔄 Syncing container libs into venv: " .. vim.fn.fnamemodify(venv_path, ":t"), vim.log.levels.INFO)
  vim.fn.mkdir(temp_dest, "p")

  local remote_sp = ""

  local function run_docker_chain()
    -- Phase 1: exec — resolve site-packages path inside the container
    if not start_job({ "docker", "exec", container, "python",
      "-c", "import site; print(site.getsitepackages()[0])" }, {
      stdout_buffered = true,
      on_stdout = function(_, data)
        remote_sp = table.concat(data or {}, "")
      end,
      on_exit = function(_, exit_code)
        vim.schedule(function()
          remote_sp = vim.trim(remote_sp)
          if exit_code ~= 0 then
            cleanup_temp()
            finish_sync("docker exec failed for container (" .. container .. ") with exit code " .. exit_code, vim.log.levels.ERROR)
            return
          end
          if remote_sp == "" then
            cleanup_temp()
            finish_sync("Could not find site-packages in container (" .. container .. ")", vim.log.levels.ERROR)
            return
          end

          -- Phase 2: copy — docker cp the remote site-packages to temp
          set_phase("copy")
          if not start_job({ "docker", "cp", container .. ":" .. remote_sp, temp_dest }, {
            on_exit = function(_, copy_code)
              vim.schedule(function()
                if copy_code ~= 0 then
                  cleanup_temp()
                  finish_sync("Failed to copy libraries from container. Error code: " .. copy_code, vim.log.levels.ERROR)
                  return
                end

                -- Phase 3: merge — merge copied packages into the venv without
                -- overwriting critical existing venv files (cp -rn)
                local copied_dir = temp_dest .. "/" .. vim.fn.fnamemodify(remote_sp, ":t")
                if vim.fn.isdirectory(copied_dir) ~= 1 then
                  cleanup_temp()
                  finish_sync("Copied path missing site-packages subdirectory", vim.log.levels.ERROR)
                  return
                end
                set_phase("merge")
                -- Note: macOS BSD cp returns exit code 1 (silently, empty stderr)
                -- whenever `-n` skips an existing destination file — the intended
                -- no-overwrite merge behavior. exit 1 with no stderr is only
                -- treated as success after verifying the copy actually landed.
                local merge_stderr = {}
                if not start_job({ "cp", "-rn", copied_dir .. "/.", local_site_packages }, {
                  stderr_buffered = true,
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

                      if merge_code ~= 0 then
                        local merged_any = false
                        for _, entry in ipairs(vim.fn.glob(copied_dir .. "/*", false, true)) do
                          local dest = local_site_packages .. "/" .. vim.fn.fnamemodify(entry, ":t")
                          if vim.fn.filereadable(dest) == 1 or vim.fn.isdirectory(dest) == 1 then
                            merged_any = true
                            break
                          end
                        end
                        if not merged_any then
                          cleanup_temp()
                          finish_sync("Failed to merge libraries into venv. Error code: " .. merge_code, vim.log.levels.ERROR)
                          return
                        end
                      end

                      -- Phase 4: cleanup — remove temp dir, then done
                      set_phase("cleanup")
                      local cleanup_job = vim.fn.jobstart({ "rm", "-rf", temp_dest }, {
                        on_exit = function(_, rm_code)
                          vim.schedule(function()
                            if rm_code ~= 0 then
                              vim.notify("⚠️ Sync succeeded but could not remove temp dir: " .. temp_dest, vim.log.levels.WARN)
                            end
                            finish_sync("✅ Successfully synced container libs to " .. venv_path, vim.log.levels.INFO)
                          end)
                        end,
                      })
                      if cleanup_job <= 0 then
                        finish_sync("✅ Successfully synced container libs to " .. venv_path, vim.log.levels.INFO)
                      end
                    end)
                  end,
                }) then
                  cleanup_temp()
                  finish_sync("Failed to start cp command for merging libraries into the venv", vim.log.levels.ERROR)
                  return
                end
              end)
            end,
          }) then
            cleanup_temp()
            finish_sync("Failed to start docker cp for container (" .. container .. ")", vim.log.levels.ERROR)
            return
          end
        end)
      end,
    }) then
      cleanup_temp()
      finish_sync("Failed to start docker exec for container (" .. container .. "). Is docker installed and running?", vim.log.levels.ERROR)
      return
    end
  end
  -- Local (fast) lookup of the venv site-packages path, run async as the
  -- first job in the chain so the UI stays responsive and the spinner
  -- covers it too. The docker chain starts once the path is resolved.
  if not start_job({ venv_py, "-c", "import site; print(site.getsitepackages()[0])" }, {
    stdout_buffered = true,
    on_stdout = function(_, data)
      local_site_packages = table.concat(data or {}, "")
    end,
    on_exit = function(_, code)
      vim.schedule(function()
        local_site_packages = vim.trim(local_site_packages)
        if code ~= 0 then
          finish_sync("Failed to resolve venv site-packages. Exit code: " .. code, vim.log.levels.ERROR)
          return
        end
        if local_site_packages == "" then
          finish_sync("Could not find site-packages in active venv: " .. venv_path, vim.log.levels.ERROR)
          return
        end
        run_docker_chain()
      end)
    end,
  }) then
    finish_sync("Failed to start venv site-packages lookup", vim.log.levels.ERROR)
    return
  end

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

-- ── Debug env driver ─────────────────────────────────────────────────────────
-- Runs the docker compose stack (which lives in the compose dir, NOT the
-- project root) directly, replacing the old `make startdebugmode`/`make stop`
-- calls. No Dockerfile changes: the debugpy command is injected as a generated
-- compose overlay, so --wait-for-client and the port are configurable.

local debug_overlay = nil

local function start_debug_job(args, opts)
  return vim.fn.jobstart(args, opts) > 0
end

local function debug_compose_args(base_compose, sub_args)
  local args = { "docker", "compose", "-f", base_compose }
  for _, a in ipairs(sub_args) do args[#args + 1] = a end
  return args
end

-- Write a compose overlay that swaps the container command for a debugpy
-- runserver (--wait-for-client so nvim can attach before any code runs).
local function write_debug_overlay(container, port, app_port, command)
  local lines = {
    "services:",
    "  " .. container .. ":",
    "    command: >",
    "      python -m debugpy",
    "        --wait-for-client",
    "        --listen 0.0.0.0:" .. port,
    "        " .. command .. " runserver 0.0.0.0:" .. app_port .. " --noreload",
  }
  local path = vim.fn.tempname()
  vim.fn.writefile(lines, path)
  return path
end

local function clean_debug_overlay()
  if debug_overlay then
    vim.fn.delete(debug_overlay, "rf")
    debug_overlay = nil
  end
end

local function require_debug_env()
  local config = M.get_config()
  if not config then
    vim.notify("No environment bridge configured. Run <leader>eC first.", vim.log.levels.WARN)
    return nil
  end
  local debug = M.get_debug_config()
  if not debug then return nil end
  local container = config.container
  if not container or container == "" then
    vim.notify("Environment bridge config is missing a container name. Run <leader>eC to reconfigure.", vim.log.levels.ERROR)
    return nil
  end
  return config, debug, container
end

-- Guarded async docker compose runner: collects stderr, notifies via the
-- provided callbacks, and always resets the debug state mirror on exit. In
-- dry-run mode prints the exact command instead of executing it.
local function run_debug_job(args, opts)
  if is_dry_run() then
    vim.notify("[dry-run] " .. table.concat(args, " "), vim.log.levels.INFO)
    return true
  end
  set_debug_action(opts.action)
  local stderr = {}
  if not start_debug_job(args, {
    cwd = opts.cwd,
    stderr_buffered = true,
    on_stderr = function(_, data)
      for _, line in ipairs(data or {}) do
        if line ~= "" then table.insert(stderr, line) end
      end
    end,
    on_exit = function(_, code)
      vim.schedule(function()
        clear_debug_action()
        if code ~= 0 and opts.on_fail then opts.on_fail() end
        vim.notify(opts.on_exit(code, table.concat(stderr, " ")), code == 0 and vim.log.levels.INFO or vim.log.levels.ERROR)
      end)
    end,
  }) then
    clear_debug_action()
    vim.notify(opts.spawn_fail, vim.log.levels.ERROR)
    return false
  end
  return true
end

function M.start_debug_environment()
  local config, debug, container = require_debug_env()
  if not config then return false end
  if M.debug_state.active then
    vim.notify("Debug env action already in progress: " .. M.debug_state.action, vim.log.levels.WARN)
    return false
  end

  local overlay = write_debug_overlay(container, debug.port, debug.app_port, debug.command)
  local args = debug_compose_args(debug.base_compose, {
    "-f", overlay,
    "up", "-d", "--force-recreate", container,
  })
  if is_dry_run() then
    vim.notify("[dry-run] overlay " .. overlay .. ":", vim.log.levels.INFO)
    vim.notify(table.concat(vim.fn.readfile(overlay), "\n"), vim.log.levels.INFO)
    vim.fn.delete(overlay, "rf")
  else
    debug_overlay = overlay
  end

  return run_debug_job(args, {
    action = "start",
    cwd = debug.compose_dir,
    on_fail = clean_debug_overlay,
    spawn_fail = "Failed to start docker compose for debug env. Is docker installed and running?",
    on_exit = function(code, err)
      if code == 0 then
        return "✅ Debug env up: debugpy on :" .. debug.port
      end
      return "❌ Failed to start debug env. Exit " .. code .. ": " .. err
    end,
  })
end

function M.stop_debug_environment()
  local config, debug, container = require_debug_env()
  if not config then return false end
  if M.debug_state.active then
    vim.notify("Debug env action already in progress: " .. M.debug_state.action, vim.log.levels.WARN)
    return false
  end

  local args = debug_compose_args(debug.base_compose, {
    "up", "-d", "--no-build", "--force-recreate", container,
  })
  return run_debug_job(args, {
    action = "stop",
    cwd = debug.compose_dir,
    spawn_fail = "Failed to start docker compose to restore the container. Is docker installed and running?",
    on_exit = function(code, err)
      if code == 0 then
        clean_debug_overlay()
        return "✅ Container restored to normal mode."
      end
      return "❌ Failed to restore container to normal mode. Exit " .. code .. ": " .. err
    end,
  })
end

function M.debug_run_command()
  local config, debug, container = require_debug_env()
  if not config then return false end
  if M.debug_state.active then
    vim.notify("Debug env action already in progress: " .. M.debug_state.action, vim.log.levels.WARN)
    return false
  end

  vim.ui.input({
    prompt = "Management command args: ",
    default = debug.default_args,
  }, function(input)
    if not input then
      vim.notify("Run command cancelled.", vim.log.levels.WARN)
      return
    end
    local cmd_args = vim.split(input ~= "" and input or debug.default_args, "%s+", { trimempty = true })
    local args = debug_compose_args(debug.base_compose, {
      "exec", "-T",
      "-w", config.app_path,
      container,
      "python", "-m", "debugpy",
      "--wait-for-client",
      "--listen", "0.0.0.0:" .. debug.port,
      debug.command,
    })
    for _, a in ipairs(cmd_args) do args[#args + 1] = a end

    run_debug_job(args, {
      action = "run",
      cwd = debug.compose_dir,
      spawn_fail = "Failed to start docker compose exec. Is docker installed and running?",
      on_exit = function(code, err)
        if code == 0 then
          return "✅ Management command finished."
        end
        return "❌ Management command exited " .. code .. ": " .. err
      end,
    })
  end)
  return true
end

return M
