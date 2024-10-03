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
