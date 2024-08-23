return {
	"stevearc/conform.nvim",
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		local conform = require("conform")

		conform.setup({
			formatters_by_ft = {
				javascript = { "prettier" },
				typescript = { "prettier" },
				javascriptreact = { "prettier" },
				typescriptreact = { "prettier" },
				svelte = { "prettier" },
				css = { "prettier" },
				html = { "prettier" },
				json = { "prettier" },
				yaml = { "prettier" },
				markdown = { "prettier" },
				graphql = { "prettier" },
				liquid = { "prettier" },
				lua = { "stylua" },
				python = { "isort", "black" }, -- order of isort and black is important.
			},
			format_on_save = {
				lsp_fallback = true,
				async = false,
				timeout_ms = 1000,
			},
		})

		vim.keymap.set({ "n", "v" }, "<leader>mp", function()
			conform.format({
				lsp_fallback = true,
				async = false,
				timeout_ms = 1000,
			})
		end, { desc = "Format file or range (in visual mode)" })

		-- Autocmd for setting textwidth
		vim.api.nvim_create_augroup("TextWidth", { clear = true })

		-- Set textwidth for .txt files
		vim.api.nvim_create_autocmd("FileType", {
			group = "TextWidth",
			pattern = "text",
			callback = function()
				vim.opt_local.textwidth = 130
			end,
		})

		-- Set textwidth for files with no extension
		vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
			group = "TextWidth",
			pattern = "*",
			callback = function()
				if vim.fn.expand("%:e") == "" then
					vim.opt_local.textwidth = 130
				end
			end,
		})
	end,
}
