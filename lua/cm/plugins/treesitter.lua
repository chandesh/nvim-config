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
			-- Language parsers for your tech stack: Python, Django, JS/TS, CSS, Bash, SQL
			ensure_installed = {
				-- Python/Django stack
				"python",
				"htmldjango",    -- Django templates
				
				-- JavaScript/TypeScript stack
				"javascript",
				"typescript",
				"tsx",
				-- Note: jsx syntax is handled by javascript and tsx parsers
				
				-- HTML/CSS
				"html",
				"css",
				"scss",
				
				-- Shell scripting
				"bash",
				
				-- SQL
				"sql",
				
				-- Configuration files
				"json",
				"yaml",
				"toml",          -- pyproject.toml, ruff.toml
				"ini",           -- .ini files
				
				-- Development tools
				"dockerfile",
				"gitignore",
				"markdown",
				"markdown_inline",
				
				-- Editor support
				"lua",           -- Neovim config
				"vim",
				"vimdoc",
				"query",         -- Treesitter queries
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
