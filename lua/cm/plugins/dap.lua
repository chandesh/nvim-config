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
		}
		-- Configure dap-python
		dap_python.setup(get_python_executable())

		-- Key mappings for debugging
		-- Add Breakpoint
		vim.api.nvim_set_keymap(
			"n",
			"<Leader>db",
			[[<Cmd>lua require('dap').toggle_breakpoint()<CR>]],
			{ noremap = true, silent = true }
		)
		-- Run Debugger
		vim.api.nvim_set_keymap(
			"n",
			"<Leader>dpr", -- Open and Run Debugger
			-- [[<Cmd>lua require('dapui').open()<CR><Cmd>lua require('dap').continue()<CR>]],
			[[<Cmd>lua require('dap').continue()<CR>]],
			{ noremap = true, silent = true }
		)
		-- Step Over
		vim.api.nvim_set_keymap(
			"n",
			"<Leader>dso",
			[[<Cmd>lua require('dap').step_over()<CR>]],
			{ noremap = true, silent = true }
		)
		-- Step Into
		vim.api.nvim_set_keymap(
			"n",
			"<Leader>dsi",
			[[<Cmd>lua require('dap').step_into()<CR>]],
			{ noremap = true, silent = true }
		)
		-- Step Out/Exit
		vim.api.nvim_set_keymap(
			"n",
			"<Leader>dse",
			[[<Cmd>lua require('dap').step_out()<CR>]],
			{ noremap = true, silent = true }
		)
		-- Set Contitional Breakpoint
		vim.api.nvim_set_keymap(
			"n",
			"<Leader>dbc",
			[[<Cmd>lua require('dap').set_breakpoint(vim.fn.input('Breakpoint condition: '))<CR>]],
			{ noremap = true, silent = true }
		)
		-- List Breakpoint
		vim.api.nvim_set_keymap(
			"n",
			"<Leader>dbl",
			[[<Cmd>lua require('dap').list_breakpoints()<CR>]],
			{ noremap = true, silent = true }
		)
		-- Toggle REPL
		vim.api.nvim_set_keymap(
			"n",
			"<Leader>dre",
			[[<Cmd>lua require('dap').repl.toggle()<CR>]],
			{ noremap = true, silent = true }
		)
		-- Close/Quit Debugger window
		vim.api.nvim_set_keymap(
			"n",
			"<Leader>dbq", -- Debugger Close
			[[<Cmd>lua require('dapui').close()<CR>]],
			{ noremap = true, silent = true }
		)
	end,
}
