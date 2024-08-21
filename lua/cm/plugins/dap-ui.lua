return {
	"rcarriga/nvim-dap-ui",
	dependencies = {
		"mfussenegger/nvim-dap", -- Ensure that dap is installed as a dependency
		"nvim-lua/plenary.nvim", -- `nvim-dap-ui` requires `plenary.nvim`
		"nvim-lua/popup.nvim", -- `nvim-dap-ui` requires `popup.nvim`
		"nvim-neotest/nvim-nio", -- Ensure `nvim-nio` is installed
	},
	config = function()
		-- Import dap-ui and dap plugins safely
		local status_dap_ui, dap_ui = pcall(require, "dapui")
		local status_dap, dap = pcall(require, "dap")

		if not status_dap_ui or not status_dap then
			vim.notify("Failed to load required modules for DAP UI", vim.log.levels.ERROR)
			return
		end

		-- Set up dap-ui
		dap_ui.setup({
			icons = {
				expanded = "▾",
				collapsed = "▸",
				current_frame = "*",
			},
			mappings = {
				expand = { "o", "<CR>" },
				open = "o",
				remove = "d",
				edit = "e",
				repl = "r",
				toggle = "t",
			},
			sidebar = {
				elements = {
					{ id = "scopes", size = 0.25 },
					{ id = "breakpoints", size = 0.25 },
					{ id = "stacks", size = 0.25 },
					{ id = "watches", size = 0.25 },
				},
				size = 40, -- Width of the sidebar
				position = "left", -- Sidebar position
			},
			tray = {
				elements = {
					{ id = "repl", size = 0.5 },
					{ id = "console", size = 0.5 },
				},
				size = 10, -- Height of the tray
				position = "bottom", -- Tray position
			},
			float = {
				border = "rounded", -- Border style for floating windows
				mappings = {
					close = { "q", "<Esc>" }, -- Key mappings to close floating windows
				},
			},
			-- Required fields
			element_mappings = {}, -- Custom key mappings for UI elements
			expand_lines = true, -- Expand lines to fill available space
			force_buffers = true, -- Force using buffers for windows
			layouts = {
				{
					elements = {
						{ id = "scopes", size = 0.25 },
						{ id = "breakpoints", size = 0.25 },
						{ id = "stacks", size = 0.25 },
						{ id = "watches", size = 0.25 },
					},
					size = 40,
					position = "left",
				},
				{
					elements = {
						{ id = "repl", size = 0.5 },
						{ id = "console", size = 0.5 },
					},
					size = 10,
					position = "bottom",
				},
			},
			floating = {
				border = "rounded", -- Border style for floating windows
				mappings = {
					close = { "q", "<Esc>" }, -- Key mappings to close floating windows
				},
			},
			controls = {
				enabled = true,
				element = "controls",
				icons = {
					pause = "⏸️",
					play = "▶️",
					step_back = "◁",
					step_into = "▶️",
					step_over = "▷",
					step_out = "⏹️",
					terminate = "⏹️",
					run_last = "▶️",
				},
			},
			render = {
				max_type_length = 20, -- Max length for type rendering
				max_value_length = 50, -- Max length for value rendering
				indent = 4, -- Indentation level for rendering
			},
		})

		-- Ensure dap-ui opens and closes correctly with dap
		dap.listeners.after.event_initialized["dapui_config"] = function()
			dap_ui.open()
		end
		dap.listeners.before.event_terminated["dapui_config"] = function()
			dap_ui.close()
		end
		dap.listeners.before.event_exited["dapui_config"] = function()
			dap_ui.close()
		end
	end,
}
