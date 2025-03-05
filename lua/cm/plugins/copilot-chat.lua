return {
	{
		"CopilotC-Nvim/CopilotChat.nvim",
		dependencies = {
			{ "github/copilot.vim" }, -- or zbirenbaum/copilot.lua
			{ "nvim-lua/plenary.nvim", branch = "master" }, -- for curl, log and async functions
		},
		build = "make tiktoken", -- Only on MacOS or Linux
		opts = {
			-- Configuration section for options
		},
		keys = {
			{ "<leader>gc", "<cmd>CopilotChat<CR>", desc = "Open Copilot Chat" },
			{ "<leader>gx", "<cmd>CopilotChatClose<CR>", desc = "Close Copilot Chat" },
			{ "<leader>gr", "<cmd>CopilotChatReview<CR>", desc = "Review Code" },
			{ "<leader>gf", "<cmd>CopilotChatFix<CR>", desc = "Fix Code" },
			{ "<leader>go", "<cmd>CopilotChatOptimize<CR>", desc = "Optimize Code" },
			{ "<leader>gd", "<cmd>CopilotChatDoc<CR>", desc = "Generate documentation" },
		},
	},
}
