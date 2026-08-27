-- ~/.config/nvim/lua/config/env_bridge.lua
-- =============================================================================
-- Environment Bridge — Synchronizes container Python env to host for LSP/DAP
-- =============================================================================

local M = {}

local ENV_FILE = ".nvim-env.json"

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
  local config = M.get_config()
  if not config then
    vim.notify("No environment bridge configured. Run <leader>eC first.", vim.log.levels.WARN)
    return false
  end

  local venv_path = vim.env.VIRTUAL_ENV
  if not venv_path then
    vim.notify("No active virtual environment detected. Please activate your venv (e.g. webapp-env) first.", vim.log.levels.ERROR)
    return false
  end

  local container = config.container
  
  -- 1. Find site-packages path inside container
  local cmd = string.format('docker exec %s python -c "import site; print(site.getsitepackages()[0])"', container)
  local handle = io.popen(cmd)
  local remote_path = handle:read("*l")
  handle:close()

  if not remote_path or remote_path == "" then
    vim.notify("Could not find site-packages in container", vim.log.levels.ERROR)
    return false
  end

  -- 2. Find site-packages path in local venv
  -- We use python to find the exact path to avoid guessing python version (3.x)
  local venv_site_cmd = string.format('%s/bin/python -c "import site; print(site.getsitepackages()[0])"', venv_path)
  local venv_handle = io.popen(venv_site_cmd)
  local local_site_packages = venv_handle:read("*l")
  venv_handle:close()

  if not local_site_packages or local_site_packages == "" then
    vim.notify("Could not find site-packages in active venv: " .. venv_path, vim.log.levels.ERROR)
    return false
  end

  -- 3. Sync libraries directly to venv
  vim.notify("🔄 Syncing container libs directly into venv: " .. vim.fn.fnamemodify(venv_path, ":t"), vim.log.levels.INFO)
  
  local root = get_project_root()
  local temp_dest = root .. "/.nvim-env-tmp"
  vim.fn.mkdir(temp_dest, "p")
  
  local copy_cmd = string.format('docker cp %s:%s %s', container, remote_path, temp_dest)
  
  vim.fn.jobstart(copy_cmd, {
    on_exit = function(_, exit_code)
      if exit_code == 0 then
        local actual_folder = temp_dest .. "/site-packages"
        if vim.fn.isdirectory(actual_folder) == 1 then
          -- Use cp -rn to merge files into the existing venv site-packages without overwriting existing critical venv files
          vim.fn.system(string.format('cp -rn %s/* %s', vim.fn.shellescape(actual_folder), vim.fn.shellescape(local_site_packages)))
        end
        vim.fn.system('rm -rf ' .. vim.fn.shellescape(temp_dest))
        vim.notify("✅ Successfully synced container libs to " .. venv_path, vim.log.levels.INFO)
      else
        vim.fn.system('rm -rf ' .. vim.fn.shellescape(temp_dest))
        vim.notify("❌ Failed to sync libraries from container. Error code: " .. exit_code, vim.log.levels.ERROR)
      end
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
