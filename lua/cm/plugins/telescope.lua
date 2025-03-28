return {
	"nvim-telescope/telescope.nvim",
	branch = "0.1.x",
	dependencies = {
		"nvim-lua/plenary.nvim",
		{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
		"nvim-tree/nvim-web-devicons",
		"folke/todo-comments.nvim",
		"nvim-telescope/telescope-ui-select.nvim",
	},
	config = function()
		local telescope = require("telescope")
		local actions = require("telescope.actions")

		telescope.setup({
			defaults = {
				path_display = { "smart" },
				mappings = {
					i = {
						["<C-k>"] = actions.move_selection_previous, -- move to prev result
						["<C-j>"] = actions.move_selection_next, -- move to next result
						["<C-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
					},
				},
				file_ignore_patterns = {
					"node_modules/",
					"__pycache__",
					".mypy_cache",
					".pytest_cache",
					".git/",
					"vendor/",
					"%.json",
					"%.jpg",
					"%.png",
					"%.gif",
					"%.pdf",
					"%.pyc",
					"%.log",
					"%.prof",
					"build/",
					"dist/",
					"LICENSE",
				},
				hidden = true, -- This ensures hidden files are shown
			},
			extensions = {
				["ui-select"] = {
					require("telescope.themes").get_dropdown({
						-- Additional options can be configured here
					}),
				},
			},
		})

		-- Load the extensions
		telescope.load_extension("fzf")
		telescope.load_extension("ui-select")

		-- Set keymaps
		local keymap = vim.keymap -- for conciseness

		keymap.set("n", "<leader>ff", function()
			require("telescope.builtin").find_files({ hidden = true, no_ignore = true }) -- Use the builtin directly
		end, { desc = "Fuzzy find files in cwd (including hidden)" })

		keymap.set("n", "<leader>fr", "<cmd>Telescope oldfiles<cr>", { desc = "Fuzzy find recent files" })
		keymap.set("n", "<leader>fs", "<cmd>Telescope live_grep<cr>", { desc = "Find string in cwd" })
		keymap.set("n", "<leader>fc", "<cmd>Telescope grep_string<cr>", { desc = "Find string under cursor in cwd" })
		keymap.set("n", "<leader>ft", "<cmd>TodoTelescope<cr>", { desc = "Find todos" })
	end,
}
