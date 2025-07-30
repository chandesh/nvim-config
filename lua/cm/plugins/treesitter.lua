return {
	"nvim-treesitter/nvim-treesitter",
	event = { "BufReadPre", "BufNewFile" },
	build = ":TSUpdate",
	dependencies = {
		"windwp/nvim-ts-autotag",
	},
	config = function()
		local treesitter = require("nvim-treesitter.configs")

		-- Configure Treesitter
		treesitter.setup({
			-- Enable syntax highlighting
			highlight = {
				enable = true,
			},
			-- Enable indentation
			indent = { enable = true },
			-- Ensure these language parsers are installed
			ensure_installed = {
				"python",
				"json",
				"javascript",
				"typescript",
				"tsx",
				"yaml",
				"html",
				"css",
				"prisma",
				"markdown",
				"markdown_inline",
				"svelte",
				"graphql",
				"bash",
				"lua",
				"vim",
				"dockerfile",
				"gitignore",
				"query",
				"vimdoc",
				"c",
			},
			incremental_selection = {
				enable = true,
				keymaps = {
					init_selection = "<C-space>",
					node_incremental = "<C-space>",
					scope_incremental = false,
					node_decremental = "<bs>",
				},
			},
			modules = {},
			sync_install = false,
			ignore_install = {},
			auto_install = true, -- Automatically install missing parsers

			-- Enable Tree-sitter code folding (handled by nvim-ufo)
			fold = {
				enable = true,
			},
		})

		-- Setup nvim-ts-autotag
		require("nvim-ts-autotag").setup()

		-- Note: Folding is now handled by nvim-ufo plugin for better performance
	end,
}
