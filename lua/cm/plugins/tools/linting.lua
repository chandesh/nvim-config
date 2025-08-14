return {
	"mfussenegger/nvim-lint",
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		local lint = require("lint")

		-- Helper function to check if a command exists
		local function cmd_exists(cmd)
			return vim.fn.executable(cmd) == 1
		end

		-- Helper function to get available linters for a filetype
		local function get_linters(preferred_linters)
			local available = {}
			for _, linter in ipairs(preferred_linters) do
				local cmd = linter == "eslint_d" and "eslint_d" or
						linter == "stylelint" and "stylelint" or
						linter == "shellcheck" and "shellcheck" or
						linter == "sqlfluff" and "sqlfluff" or
						linter == "djlint" and "djlint" or linter
				
				if cmd_exists(cmd) then
					table.insert(available, linter)
				end
			end
			return available
		end

		lint.linters_by_ft = {
			-- JavaScript/TypeScript stack (fallback to eslint if eslint_d not available)
			javascript = get_linters({ "eslint_d", "eslint" }),
			typescript = get_linters({ "eslint_d", "eslint" }),
			javascriptreact = get_linters({ "eslint_d", "eslint" }),
			typescriptreact = get_linters({ "eslint_d", "eslint" }),
			
			-- CSS and related
			css = get_linters({ "stylelint" }),
			scss = get_linters({ "stylelint" }),
			sass = get_linters({ "stylelint" }),
			less = get_linters({ "stylelint" }),
			
			-- Shell scripting
			sh = get_linters({ "shellcheck" }),
			bash = get_linters({ "shellcheck" }),
			zsh = get_linters({ "shellcheck" }),
			
		-- Python/Django (handled by ruff through LSP, pyright is manual only)
			python = {}, -- Ruff handles linting through LSP, pyright is manual via <leader>tt
			
			-- SQL
			sql = get_linters({ "sqlfluff" }),
			
			-- Django templates
			htmldjango = get_linters({ "djlint" }),
		}

		-- Print info about available linters
		vim.defer_fn(function()
			local js_linters = lint.linters_by_ft.javascript or {}
			if #js_linters == 0 then
				vim.notify(
					"No JS/TS linters found. Install eslint_d for best performance: npm i -g eslint_d",
					vim.log.levels.INFO
				)
			end
		end, 1000)

		local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })

	vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
		group = lint_augroup,
		callback = function()
			-- Skip linting for Python files to avoid triggering Pyright diagnostics
			if vim.bo.filetype ~= "python" then
				lint.try_lint()
			end
		end,
	})

	-- Keymaps are now managed in lua/cm/core/keymaps.lua
	end,
}
