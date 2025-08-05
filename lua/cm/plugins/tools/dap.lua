return {
	"mfussenegger/nvim-dap",
	dependencies = {
		"mfussenegger/nvim-dap-python",
		"rcarriga/nvim-dap-ui", -- Ensure dap-ui is included if you want a UI for DAP
	},
	config = function()
		-- Import dap plugins safely
		local status_dap, dap = pcall(require, "dap")

		local status_dap_python, dap_python = pcall(require, "dap-python")
		local status_pyenv, pyenv = pcall(require, "cm.core.pyenv")

		if not status_dap or not status_dap_python or not status_pyenv then
			vim.notify("Failed to load required modules for DAP", vim.log.levels.ERROR)
			return
		end

		local function get_python_executable()
			local path = pyenv.get_python_executable()
			if not path then
				vim.notify("Failed to get Python executable path from pyenv", vim.log.levels.ERROR)
				return "/usr/bin/python" -- Fallback Python executable
			end
			return path
		end

		-- Set up dap for Python
		dap.adapters.python = {
			type = "executable",
			command = get_python_executable(),
			args = { "-m", "debugpy.adapter" },
		}

		-- Set up dap configurations
		dap.configurations.python = {
			{
				type = "python",
				request = "launch",
				name = "Launch File",
				program = "${file}",
				console = "integratedTerminal",
				pythonPath = function()
					return get_python_executable()
				end,
			},
			{
				name = "Launch Django Debugger",
				type = "python",
				request = "launch",
				program = "${workspaceFolder}/manage.py",
				args = { "runserver", "--noreload" },
				django = true,
				console = "integratedTerminal",
				pythonPath = function()
					return get_python_executable()
				end,
				justMyCode = false,
			},
		}

		-- Configure dap-python
		dap_python.setup(get_python_executable())

		-- Note: Keymaps are now managed in lua/cm/core/keymaps.lua for better organization
	end,
}
