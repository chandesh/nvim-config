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
			-- list of servers for mason to install (using correct server names)
			ensure_installed = {
				"ts_ls", -- TypeScript server
				"html", -- HTML server
				"cssls", -- CSS server
				"tailwindcss", -- Tailwind CSS server
				"lua_ls", -- Lua server
				"emmet_ls", -- Emmet server
				"pyright", -- Python server
				"ruff", -- Ruff server
			},
		})

		local mason_tool_installer = require("mason-tool-installer")

	mason_tool_installer.setup({
		ensure_installed = {
			-- JavaScript/TypeScript tools
			"prettier", -- prettier formatter
			"eslint_d", -- js linter
			
			-- Python/Django tools
			"ruff", -- python formatter and linter (replaces isort, black, flake8, pylint)
			"mypy", -- python type checker
			"debugpy", -- python debugger
			"djlint", -- django template linter/formatter
			
			-- Other tools
			"stylua", -- lua formatter
			"checkmake", -- makefile linter
			"shfmt", -- shell formatter
			"shellcheck", -- shell linter
			"sqlfluff", -- SQL formatter and linter
			"hadolint", -- Dockerfile linter
		},
		automatic_installation = true,
	})
	end,
}
