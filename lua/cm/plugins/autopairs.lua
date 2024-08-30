return {
	"windwp/nvim-autopairs",
	event = { "InsertEnter" },
	dependencies = {
		"hrsh7th/nvim-cmp",
	},
	config = function()
		-- import nvim-autopairs
		local autopairs = require("nvim-autopairs")

		-- configure autopairs
		autopairs.setup({
			check_ts = true, -- enable treesitter
			ts_config = {
				lua = { "string" }, -- don't add pairs in lua string treesitter nodes
				javascript = { "template_string" }, -- don't add pairs in javscript template_string treesitter nodes
				java = false, -- don't check treesitter on java
				python = { "string" }, -- handle strings in Python
			},
			fast_wrap = {
				map = "<M-e>",
				chars = { "{", "[", "(", '"', "'" },
				pattern = string.gsub([[ [%'%"%)%>%]%)%}]%s] ]], "%s+", ""), -- pattern to match
			},
		})

		-- import nvim-autopairs completion functionality
		local cmp_autopairs = require("nvim-autopairs.completion.cmp")

		-- import nvim-cmp plugin (completions plugin)
		local cmp = require("cmp")

		-- make autopairs and completion work together
		-- cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
		cmp.event:on(
			"confirm_done",
			cmp_autopairs.on_confirm_done({
				map_char = { tex = "" }, -- optional: customize mappings
			})
		)

		-- Custom function to handle Python triple quotes
		local function setup_python_triple_quotes()
			vim.api.nvim_create_autocmd("FileType", {
				pattern = "python",
				callback = function()
					vim.api.nvim_set_keymap("i", '"""', '"""<Esc>O', { noremap = true, silent = true })
					vim.api.nvim_set_keymap("i", "'''", "'''<Esc>O", { noremap = true, silent = true })
				end,
			})
		end

		-- Call custom setup for Python triple quotes
		setup_python_triple_quotes()
	end,
}
