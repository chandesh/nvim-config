return {
	"Shobhit-Nagpal/nvim-rafce",
	config = function()
		require("rafce")
		local keymap = vim.keymap

		-- Key mappings for generating React components
		keymap.set("n", "<leader>rf", ":Rafce<CR>", { desc = "Generate RAFCE Component" })
	end,
}
