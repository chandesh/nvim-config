return {
	"nvim-pack/nvim-spectre",
	config = function()
		local spectre = require("spectre")
		local keymap = vim.keymap

		-- Configure Spectre
		spectre.setup({
			color_devicons = true,
			-- Ensure that Spectre opens in a floating window
			open_cmd = "lua require('spectre').open()",
			-- Optionally, you can specify floating settings here if supported
			-- For custom floating configuration, please refer to Spectre documentation
		})

		-- Define a function to open Spectre in a floating window
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

			-- Open Spectre in the floating window
			vim.api.nvim_win_set_buf(win, buf)
			vim.cmd("silent! lua require('spectre').open()")
		end

		-- Key mappings for Spectre
		keymap.set("n", "<leader>sr", function()
			open_spectre_floating()
		end, { desc = "Open Spectre in floating window for search and replace" })

		keymap.set(
			"n",
			"<leader>sw",
			"<cmd>lua require('spectre').open_visual()<cr>",
			{ desc = "Search and replace word under cursor" }
		)
	end,
}
