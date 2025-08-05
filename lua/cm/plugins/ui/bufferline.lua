return {
	"akinsho/bufferline.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	version = "*",
	config = function()
		require("bufferline").setup({
			options = {
				mode = "tabs",
				-- separator_style = "slant",
				show_buffer_icons = true,
				show_buffer_close_icons = true,
				show_close_icon = true,
				show_tab_indicators = true,
				diagnostics = "nvim_lsp",
				diagnostics_update_in_insert = false,
			},
		})
		end,
}
