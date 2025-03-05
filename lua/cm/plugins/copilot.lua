return {
	"github/copilot.vim",
	config = function()
		-- Enable GitHub Copilot
		vim.g.copilot_enabled = true

		-- Map Copilot completion to tab
		vim.api.nvim_set_keymap("i", "<Tab>", 'copilot#Accept("<CR>")', { expr = true, silent = true })
	end,
}
