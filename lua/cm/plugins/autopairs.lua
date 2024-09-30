return {
	"windwp/nvim-autopairs",
	event = { "InsertEnter" },
	dependencies = {
		"hrsh7th/nvim-cmp",
		"windwp/nvim-ts-autotag",
	},
	config = function()
		local autopairs = require("nvim-autopairs")

		-- Configure autopairs
		autopairs.setup({
			check_ts = true,
			ts_config = {
				lua = { "string" },
				javascript = { "template_string" },
				java = false,
				python = { "string" },
			},
			fast_wrap = {
				map = "<M-e>",
				chars = { "{", "[", "(", '"', "'" },
				pattern = string.gsub([[ [%'%"%)%>%]%)%}]%s] ]], "%s+", ""),
			},
		})

		-- Function to handle triple quotes in Python
		local function setup_python_triple_quotes()
			vim.api.nvim_create_autocmd("FileType", {
				pattern = "python",
				callback = function()
					-- Set key mappings for triple quotes
					vim.api.nvim_set_keymap("i", '"""', '"""<C-o>O', { noremap = true, silent = true })
					vim.api.nvim_set_keymap("i", "'''", "'''<C-o>O", { noremap = true, silent = true })

					-- Prevent autopairing for triple quotes
					autopairs.get_rule('"'):with_pair(function(opts)
						local line = vim.fn.getline(".")
						local col = opts.col
						return not (line:sub(col - 1, col - 1) == '"' and line:sub(col - 2, col - 2) == '"')
					end)

					autopairs.get_rule("'"):with_pair(function(opts)
						local line = vim.fn.getline(".")
						local col = opts.col
						return not (line:sub(col - 1, col - 1) == "'" and line:sub(col - 2, col - 2) == "'")
					end)
				end,
			})
		end

		-- Call the function to set up triple quotes
		setup_python_triple_quotes()

		-- Setup completion with nvim-cmp
		local cmp_autopairs = require("nvim-autopairs.completion.cmp")
		local cmp = require("cmp")
		cmp.event:on(
			"confirm_done",
			cmp_autopairs.on_confirm_done({
				map_char = { tex = "" },
			})
		)

		-- Setup for nvim-ts-autotag
		local ts_autotag = require("nvim-ts-autotag")
		ts_autotag.setup({
			filetypes = { "html", "xml", "tsx", "jsx" },
		})
	end,
}
