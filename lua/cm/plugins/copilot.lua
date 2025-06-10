return {
	"github/copilot.vim",
	config = function()
		-- Enable GitHub Copilot
		vim.g.copilot_enabled = false

		-- Map Copilot completion to tab
		vim.api.nvim_set_keymap("i", "<Tab>", 'copilot#Accept("<CR>")', { expr = true, silent = true })
	end,
}

-- use :Copilot setup
