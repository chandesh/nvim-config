return {
	"numToStr/Comment.nvim",
	event = { "BufReadPre", "BufNewFile" },
	dependencies = {
		"JoosepAlviste/nvim-ts-context-commentstring",
	},
	config = function()
		-- Import comment plugin safely
		local comment = require("Comment")

		-- Import ts_context_commentstring integration
		local ts_context_commentstring = require("ts_context_commentstring.integrations.comment_nvim")

		-- Enable comment with all required fields
		comment.setup({
			-- Add padding around comment lines
			padding = true,

			-- Stick the comment text to the cursor
			sticky = true,

			-- Ignore specific filetypes for commenting
			ignore = "",

			-- Configuration for toggling comments
			toggler = {
				-- Line comment toggle
				line = "<leader>cl",
				-- Block comment toggle
				block = "<leader>cb",
			},

			-- Configuration for operator pending mode
			opleader = {
				-- Line comment operator
				line = "<leader>c",
				-- Block comment operator
				block = "<leader>cb",
			},

			-- Configuration for extra mappings
			extra = {
				-- Extra mappings for commenting
				above = "<leader>ca", -- Comment above current line
				below = "<leader>cb", -- Comment below current line
				eol = "<leader>ce", -- Comment at the end of line
			},

			-- Configuration for post-hook (provide an empty function)
			post_hook = function() end, -- Empty function if not needed

			-- Pre-hook for commenting in specific file types
			pre_hook = ts_context_commentstring.create_pre_hook(),

			-- Mappings configuration (required field)
			mappings = {
				-- Enable basic mappings
				basic = true, -- Adds basic key mappings like `gcc` for line comments
				-- Enable extra mappings
				extra = true, -- Adds extra mappings like `gco` for comment toggling in visual mode
				-- Disable extended mappings
				extended = false, -- Adds extended mappings like `gcb` for block comments
			},
		})
	end,
}
