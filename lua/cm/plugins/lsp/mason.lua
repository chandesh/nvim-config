return {
	"williamboman/mason.nvim",
	dependencies = {
		"williamboman/mason-lspconfig.nvim",
		"WhoIsSethDaniel/mason-tool-installer.nvim",
	},
	config = function()
		-- import mason
		local mason = require("mason")

		require("cm.core.pyenv") -- Import the global pyenv module

		-- enable mason and configure icons
		mason.setup({
			ui = {
				icons = {
					package_installed = "✓",
					package_pending = "➜",
					package_uninstalled = "✗",
				},
			},
		})

		-- import mason-lspconfig after mason setup
		local mason_lspconfig = require("mason-lspconfig")

	mason_lspconfig.setup({
		-- LSP servers for your tech stack: Python, Django, JS/TS, CSS, Bash, SQL
	ensure_installed = {
			-- JavaScript/TypeScript stack
			"ts_ls",           -- TypeScript/JavaScript LSP
			"html",            -- HTML support for Django templates
			"cssls",           -- CSS LSP
			"tailwindcss",     -- Tailwind CSS
			"emmet_ls",        -- HTML/CSS snippets
			
			-- Python/Django stack
			"pyright",         -- Python type checking
			"ruff",            -- Python linting/formatting
			
			-- Shell scripting
			"bashls",          -- Bash LSP
			
			-- Database/SQL
			"sqlls",           -- SQL LSP
			
			-- Configuration files
			"jsonls",          -- JSON files
			"yamlls",          -- YAML files
			
			-- Lua (for Neovim config)
			"lua_ls",
		},
	})

		local mason_tool_installer = require("mason-tool-installer")

	mason_tool_installer.setup({
		ensure_installed = {
			-- JavaScript/TypeScript tools
			"prettier", -- prettier formatter
			"eslint_d", -- js linter
			
			-- CSS tools
			"stylelint", -- CSS/SCSS/SASS linter
			
			-- Python/Django tools
			"ruff", -- python formatter and linter (replaces isort, black, flake8, pylint)
			"mypy", -- python type checker
			"debugpy", -- python debugger
			"djlint", -- django template linter/formatter
			
			-- Shell scripting tools
			"shfmt", -- shell formatter
			"shellcheck", -- shell linter
			
			-- SQL tools
			"sqlfluff", -- SQL formatter and linter
			"sql-formatter", -- Alternative SQL formatter
			
			-- Configuration and other tools
			"stylua", -- lua formatter
			"checkmake", -- makefile linter
			"hadolint", -- Dockerfile linter
		},
		automatic_installation = true,
	})
	end,
}
