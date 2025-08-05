return {
	"mfussenegger/nvim-lint",
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		local lint = require("lint")

		lint.linters_by_ft = {
			-- JavaScript/TypeScript stack
			javascript = { "eslint_d" },
			typescript = { "eslint_d" },
			javascriptreact = { "eslint_d" },
			typescriptreact = { "eslint_d" },
			
			-- CSS and related
			css = { "stylelint" },
			scss = { "stylelint" },
			sass = { "stylelint" },
			less = { "stylelint" },
			
			-- Shell scripting
			sh = { "shellcheck" },
			bash = { "shellcheck" },
			zsh = { "shellcheck" },
			
			-- Python/Django (handled by ruff through LSP)
			python = {}, -- Ruff handles linting through LSP
			
			-- SQL
			sql = { "sqlfluff" },
			
			-- Django templates
			htmldjango = { "djlint" },
		}

		local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })

		vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
			group = lint_augroup,
			callback = function()
				lint.try_lint()
			end,
		})

	-- Keymaps are now managed in lua/cm/core/keymaps.lua
	end,
}
