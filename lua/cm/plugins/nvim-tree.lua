return {
	"nvim-tree/nvim-tree.lua",
	dependencies = "nvim-tree/nvim-web-devicons",
	config = function()
		local nvimtree = require("nvim-tree")

		-- recommended settings from nvim-tree documentation
		vim.g.loaded_netrw = 1
		vim.g.loaded_netrwPlugin = 1

		nvimtree.setup({
			view = {
				width = 30,
				relativenumber = false,
			},
			renderer = {
				indent_markers = {
					enable = true,
				},
				icons = {
					glyphs = {
						folder = {
							arrow_closed = "", -- arrow when folder is closed
							arrow_open = "", -- arrow when folder is open
						},
					},
				},
			},
			actions = {
				open_file = {
					window_picker = {
						enable = false,
					},
				},
			},
			filters = {
				custom = {
					".DS_Store",
					"*.pyc",
					"__pycache__",
					".python-version",
					".pytest_cache",
					".ruff_cache",
					"logs",
				},
				dotfiles = false,
			},
			git = {
				ignore = false,
			},
			-- Ensure nvim-tree opens at the correct starting directory
			update_cwd = true, -- updates the current working directory when opening a file
			respect_buf_cwd = true, -- respect buffer’s current working directory
		})

		-- Keymaps are now managed in lua/cm/core/keymaps.lua
	end,
}
