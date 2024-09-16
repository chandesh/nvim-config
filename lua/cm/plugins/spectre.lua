return {
	"nvim-pack/nvim-spectre",
	config = function()
		local spectre = require("spectre")
		local keymap = vim.keymap

		-- Configure Spectre
		spectre.setup({
			color_devicons = true,
			open_cmd = "lua require('spectre').open()",
		})

		-- Function to open Spectre in a floating window
		local function open_spectre_floating()
			local buf = vim.api.nvim_create_buf(false, true)
			local opts = {
				relative = "editor",
				width = math.floor(vim.o.columns * 0.8),
				height = math.floor(vim.o.lines * 0.6),
				row = math.floor(vim.o.lines * 0.2),
				col = math.floor(vim.o.columns * 0.1),
				border = "rounded",
			}
			local win = vim.api.nvim_open_win(buf, true, opts)
			vim.api.nvim_win_set_buf(win, buf)
			vim.cmd("silent! lua require('spectre').open()")
		end

		-- Key mapping for Spectre
		keymap.set(
			"n",
			"<leader>sr",
			open_spectre_floating,
			{ desc = "Open Spectre in floating window for search and replace" }
		)
		-- TODO: Need to check why Spectre open_visual is not working with floating window.
		-- TODO: Fix Spectre help options' window posisioning.
	end,
}
