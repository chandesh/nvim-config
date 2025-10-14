local M = {}

-- List of essential Neovim dependencies for Python environments
local NEOVIM_DEPENDENCIES = {
  -- Core Neovim integration
  "pynvim",                    -- Required for Python remote plugins
  
  -- Development tools
  "debugpy",                   -- Python debugging adapter
  "black",                     -- Code formatter
  "isort",                     -- Import sorter
  "ruff",                      -- Fast Python linter
  
  -- Optional but useful
  "flake8",                    -- Traditional linter
  "mypy",                      -- Type checker
}

-- Function to get the current Python executable (prioritize pyenv setup)
local function get_python_executable()
  -- First, try to get from pyenv configuration
  local success, pyenv = pcall(require, 'config.pyenv')
  if success then
    local python_exec = pyenv.get_python_executable()
    if python_exec and python_exec ~= "/bin/python" and vim.fn.executable(python_exec) == 1 then
      return python_exec, true -- return python_exec and is_venv flag
    end
  end
  
  -- Check for VIRTUAL_ENV environment variable
  local venv_path = os.getenv("VIRTUAL_ENV")
  if venv_path then
    local venv_python = venv_path .. "/bin/python"
    if vim.fn.executable(venv_python) == 1 then
      return venv_python, true
    end
  end
  
  -- Fallback to system python
  local python_cmd = vim.fn.executable("python3") == 1 and "python3" or "python"
  return python_cmd, false -- not in virtual environment
end

-- Function to check if a package is installed in the current Python environment
local function is_package_installed(package_name, python_executable)
  local cmd = string.format('%s -c "import %s" 2>/dev/null', python_executable, package_name)
  local success = os.execute(cmd) == 0
  return success
end

-- Function to install a package in the current Python environment
local function install_package(package_name, python_executable, is_venv)
  local env_type = is_venv and "virtual environment" or "system Python"
  vim.notify(string.format("Installing %s in %s...", package_name, env_type), vim.log.levels.INFO)
  
  -- Use --user flag only for system Python, not for virtual environments
  local user_flag = is_venv and "" or "--user"
  local install_cmd = string.format('%s -m pip install --quiet %s "%s"', python_executable, user_flag, package_name)
  
  -- Run installation in background to avoid blocking
  vim.fn.jobstart(install_cmd, {
    on_exit = function(_, exit_code)
      if exit_code == 0 then
        vim.notify(string.format("✓ Successfully installed %s in %s", package_name, env_type), vim.log.levels.INFO)
      else
        vim.notify(string.format("✗ Failed to install %s in %s", package_name, env_type), vim.log.levels.ERROR)
      end
    end,
    stdout_buffered = true,
    stderr_buffered = true,
  })
end

-- Function to check and install missing Neovim dependencies
function M.ensure_dependencies()
  local python_executable, is_venv = get_python_executable()
  
  if not python_executable then
    vim.notify("No Python executable found", vim.log.levels.WARN)
    return
  end
  
  local env_type = is_venv and "virtual environment" or "system Python"
  vim.notify(string.format("Using Python from %s: %s", env_type, python_executable), vim.log.levels.INFO)
  
  -- Check if pip is available
  local pip_check = string.format('%s -m pip --version 2>/dev/null', python_executable)
  if os.execute(pip_check) ~= 0 then
    vim.notify("pip is not available in the current Python environment", vim.log.levels.WARN)
    return
  end
  
  local missing_packages = {}
  
  -- Check each dependency
  for _, package in ipairs(NEOVIM_DEPENDENCIES) do
    local import_name = package
    
    -- Handle packages where import name differs from package name
    if package == "python-lsp-server" then
      import_name = "pylsp"
    elseif package == "debugpy" then
      import_name = "debugpy"
    end
    
    if not is_package_installed(import_name, python_executable) then
      table.insert(missing_packages, package)
    end
  end
  
  -- Install missing packages
  if #missing_packages > 0 then
    vim.notify(string.format("Installing %d missing Neovim dependencies in %s...", #missing_packages, env_type), vim.log.levels.INFO)
    
    for _, package in ipairs(missing_packages) do
      install_package(package, python_executable, is_venv)
    end
  else
    vim.notify(string.format("All Neovim dependencies are installed ✓ (%s)", env_type), vim.log.levels.INFO)
  end
end

-- Function to get dependency status
function M.check_status()
  local python_executable, is_venv = get_python_executable()
  
  if not python_executable then
    vim.notify("No Python executable found", vim.log.levels.WARN)
    return
  end
  
  local env_type = is_venv and "virtual environment" or "system Python"
  vim.notify(string.format("Python executable (%s): %s", env_type, python_executable), vim.log.levels.INFO)
  
  local installed = {}
  local missing = {}
  
  for _, package in ipairs(NEOVIM_DEPENDENCIES) do
    local import_name = package
    if package == "python-lsp-server" then
      import_name = "pylsp"
    end
    
    if is_package_installed(import_name, python_executable) then
      table.insert(installed, package)
    else
      table.insert(missing, package)
    end
  end
  
  vim.notify(string.format("Installed: %s", table.concat(installed, ", ")), vim.log.levels.INFO)
  if #missing > 0 then
    vim.notify(string.format("Missing: %s", table.concat(missing, ", ")), vim.log.levels.WARN)
  end
end

-- Function to install all dependencies (force)
function M.install_all()
  local python_executable, is_venv = get_python_executable()
  
  if not python_executable then
    vim.notify("No Python executable found", vim.log.levels.ERROR)
    return
  end
  
  local env_type = is_venv and "virtual environment" or "system Python"
  vim.notify(string.format("Installing all Neovim dependencies in %s...", env_type), vim.log.levels.INFO)
  
  for _, package in ipairs(NEOVIM_DEPENDENCIES) do
    install_package(package, python_executable, is_venv)
  end
end

-- Set up vim.g.python3_host_prog if pynvim is available
function M.setup_python_host()
  local python_executable, is_venv = get_python_executable()
  
  if python_executable and is_package_installed("pynvim", python_executable) then
    vim.g.python3_host_prog = python_executable
    local env_type = is_venv and "virtual environment" or "system Python"
    vim.notify(string.format("Set python3_host_prog to %s: %s", env_type, python_executable), vim.log.levels.DEBUG)
  end
end

return M