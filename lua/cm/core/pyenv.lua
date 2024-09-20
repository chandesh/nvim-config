local M = {}

-- Helper function to execute a shell command and return its output
local function execute_command(command)
	local handle = io.popen(command)
	local output = handle and handle:read("*a") or nil
	if handle then
		handle:close()
	end
	return output
end

-- Function to get the current pyenv environment name
function M.get_env_name()
	local env_name = execute_command("pyenv version-name")
	if not env_name or env_name == "" then
		vim.notify("Failed to determine pyenv environment name", vim.log.levels.ERROR)
		return nil
	end
	return env_name:match("%S+") -- Trim whitespace
end

-- Function to get the Python environment directory
function M.get_python_env_dir()
	local env_name = M.get_env_name()
	if not env_name or env_name == "system" then
		return nil
	end

	-- Ensure no trailing slash in env_name
	env_name = env_name:gsub("/+$", "")

	local python_env_dir = string.format("%s/.pyenv/versions/%s", vim.fn.expand("$HOME"), env_name)
	if vim.fn.isdirectory(python_env_dir) == 0 then
		vim.notify("Python environment directory not found: " .. python_env_dir, vim.log.levels.ERROR)
		return nil
	end

	return python_env_dir
end

-- Function to get the Python executable path
function M.get_python_executable()
	local python_env_dir = M.get_python_env_dir()
	if not python_env_dir then
		-- return default system python path.
		return "/bin/python"
	end

	local python_executable = python_env_dir .. "/bin/python"
	if vim.fn.filereadable(python_executable) == 0 then
		vim.notify("Python executable not found: " .. python_executable, vim.log.levels.ERROR)
		return nil
	end

	return python_executable
end

-- Function to get the Python version
function M.get_python_version()
	local python_executable = M.get_python_executable()
	if not python_executable then
		return nil
	end

	local version_output = execute_command(python_executable .. " -V 2>&1")
	local python_version = version_output and version_output:match("Python (%d+%.%d+)") or nil
	if not python_version then
		vim.notify("Failed to determine Python version from: " .. version_output, vim.log.levels.ERROR)
	end
	return python_version
end

-- Function to get the site-packages path
function M.get_site_packages_path()
	local python_version = M.get_python_version()
	local python_env_dir = M.get_python_env_dir()
	if not python_version or not python_env_dir then
		return nil
	end

	local site_packages_path = string.format("%s/lib/python%s/site-packages", python_env_dir, python_version)
	if vim.fn.isdirectory(site_packages_path) == 0 then
		vim.notify("Python path not found: " .. site_packages_path, vim.log.levels.WARN)
		return nil
	end
	return site_packages_path
end

-- Function to activate the pyenv environment

local current_python_env = nil
function M.activate()
	local env_name = M.get_env_name()

	-- check if the required python environment is already activated.
	if env_name == current_python_env then
		return -- already activated required python environment
	end

	current_python_env = env_name -- update current_python_env

	local site_packages_path = M.get_site_packages_path()
	if not site_packages_path then
		local message = string.format("Using default /bin/python")
		vim.notify(message, vim.log.levels.INFO)
		return
	end

	vim.env.PYTHONPATH = site_packages_path
	local message = string.format("Activated pyenv environment: %s, env_path: %s", env_name, site_packages_path)
	vim.notify(message, vim.log.levels.INFO)
end

return M
