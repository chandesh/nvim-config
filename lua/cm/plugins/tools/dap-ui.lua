return {
	"rcarriga/nvim-dap-ui",
	dependencies = {
		"mfussenegger/nvim-dap",
		"nvim-lua/plenary.nvim",
		"nvim-lua/popup.nvim",
		"nvim-neotest/nvim-nio",
	},
	config = function()
		-- Import dap-ui and dap plugins safely
		local status_dap_ui, dap_ui = pcall(require, "dapui")
		local status_dap, dap = pcall(require, "dap")

		if not status_dap_ui or not status_dap then
			vim.notify("Failed to load required modules for DAP UI", vim.log.levels.ERROR)
			return
		end

		local api = vim.api
		local nvim_tree_win_id = nil
		local nvim_tree_width = 30 -- Default width, adjust if needed

		-- Function to hide NvimTree
		local function hide_nvim_tree()
			local windows = api.nvim_list_wins()
			for _, win in ipairs(windows) do
				local buf = api.nvim_win_get_buf(win)
				if api.nvim_buf_get_name(buf):match("NvimTree") then
					nvim_tree_win_id = win
					nvim_tree_width = api.nvim_win_get_width(win)
					api.nvim_win_hide(win)
					return
				end
			end
		end

		-- Function to restore NvimTree
		local function restore_nvim_tree()
			if nvim_tree_win_id and not api.nvim_win_is_valid(nvim_tree_win_id) then
				-- Reopen NvimTree
				api.nvim_command("NvimTreeOpen")
				-- Set width if needed
				local tree_win = api.nvim_list_wins()[1] -- Get the newly created window
				if tree_win then
					api.nvim_win_set_width(tree_win, nvim_tree_width)
				end
				nvim_tree_win_id = nil
			end
		end

		-- Function to set up terminal buffer behavior
		local function setup_terminal_behavior()
			for _, win in ipairs(api.nvim_list_wins()) do
				local buf = api.nvim_win_get_buf(win)
				local buf_type = api.nvim_buf_get_option(buf, "buftype")
				if buf_type == "terminal" then
					api.nvim_buf_set_keymap(buf, "t", "<Esc>", "<C-\\><C-n>", { noremap = true, silent = true })
					api.nvim_buf_set_keymap(buf, "t", "<C-w>", "<C-\\><C-n><C-w>", { noremap = true, silent = true })
					-- Ensure terminal key mappings are applied on every new terminal buffer
					api.nvim_buf_attach(buf, false, {
						on_lines = function(_, _, _, _)
							api.nvim_buf_set_keymap(buf, "t", "<Esc>", "<C-\\><C-n>", { noremap = true, silent = true })
							api.nvim_buf_set_keymap(
								buf,
								"t",
								"<C-w>",
								"<C-\\><C-n><C-w>",
								{ noremap = true, silent = true }
							)
						end,
					})
				end
			end
		end

		-- Call setup_terminal_behavior() after dap-ui setup
		local function post_dapui_setup()
			setup_terminal_behavior()
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
				size = 40,
				position = "left",
			},
			tray = {
				elements = {
					{ id = "repl", size = 0.5 },
					{ id = "console", size = 0.5 },
				},
				size = 10,
				position = "bottom",
			},
			float = {
				border = "rounded",
				mappings = {
					close = { "q", "<Esc>" },
				},
			},
			element_mappings = {},
			expand_lines = true,
			force_buffers = true,
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
				border = "rounded",
				mappings = {
					close = { "q", "<Esc>" },
				},
			},
			controls = {
				enabled = true,
				element = "repl", -- Controls will appear in the REPL window
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
				max_type_length = 20,
				max_value_length = 50,
				indent = 4,
			},
		})

		-- Set up dap listeners
		dap.listeners.after.event_initialized["dapui_config"] = function()
			vim.schedule(function()
				hide_nvim_tree()
				dap_ui.open()
				post_dapui_setup()
			end)
		end

		dap.listeners.before.event_terminated["dapui_config"] = function()
			vim.schedule(function()
				dap_ui.close()
				restore_nvim_tree()
			end)
		end

		dap.listeners.before.event_exited["dapui_config"] = function()
			vim.schedule(function()
				dap_ui.close()
				restore_nvim_tree()
			end)
		end
	end,
}
