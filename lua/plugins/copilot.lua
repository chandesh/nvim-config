return {
  -- GitHub Copilot
  {
    "github/copilot.vim",
    config = function()
      -- Enable GitHub Copilot
      vim.g.copilot_enabled = true
      
      -- Explicitly set Node.js 22 path for Copilot compatibility
      vim.g.copilot_node_command = '/opt/homebrew/opt/node@22/bin/node'
      
      -- Additional Copilot configuration
      vim.g.copilot_assume_mapped = true
      vim.g.copilot_tab_fallback = ""

      -- Map Copilot completion to Ctrl+Y (common convention)
      vim.keymap.set('i', '<C-y>', 'copilot#Accept("\\<CR>")', {
        expr = true,
        replace_keycodes = false,
        silent = true,
      })

      -- Additional Copilot keymaps for better UX
      vim.keymap.set('i', '<C-l>', 'copilot#Accept("\\<CR>")', {
        expr = true,
        replace_keycodes = false,
        silent = true,
      })
      
      -- Next/previous suggestions
      vim.keymap.set('i', '<C-]>', 'copilot#Next()', {
        expr = true,
        replace_keycodes = false,
        silent = true,
      })
      
      vim.keymap.set('i', '<C-[>', 'copilot#Previous()', {
        expr = true,
        replace_keycodes = false,
        silent = true,
      })

      -- Disable copilot for certain filetypes
      vim.g.copilot_filetypes = {
        ['*'] = true,
        ['gitcommit'] = false,
        ['gitrebase'] = false,
        ['hgcommit'] = false,
        ['svn'] = false,
        ['cvs'] = false,
        ['TelescopePrompt'] = false,
      }
    end,
  },

  -- Copilot Chat
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    branch = "main",
    dependencies = {
      { "github/copilot.vim" },
      { "nvim-lua/plenary.nvim" },
    },
    config = function()
      require("CopilotChat").setup({
        debug = false,
        window = {
          layout = 'float',
          relative = 'cursor',
          width = 1,
          height = 0.4,
          row = 1
        },
      })

      -- Keymaps
      vim.keymap.set("n", "<leader>cc", "<cmd>CopilotChat<CR>", { desc = "Open Copilot Chat" })
      vim.keymap.set("n", "<leader>ce", "<cmd>CopilotChatExplain<CR>", { desc = "Explain code" })
      vim.keymap.set("n", "<leader>cr", "<cmd>CopilotChatReview<CR>", { desc = "Review code" })
      vim.keymap.set("n", "<leader>cf", "<cmd>CopilotChatFix<CR>", { desc = "Fix code" })
      vim.keymap.set("n", "<leader>co", "<cmd>CopilotChatOptimize<CR>", { desc = "Optimize code" })
      vim.keymap.set("n", "<leader>cd", "<cmd>CopilotChatDocs<CR>", { desc = "Generate docs" })
      vim.keymap.set("n", "<leader>ct", "<cmd>CopilotChatTests<CR>", { desc = "Generate tests" })
      vim.keymap.set("v", "<leader>ce", "<cmd>CopilotChatExplain<CR>", { desc = "Explain selection" })
      vim.keymap.set("v", "<leader>cr", "<cmd>CopilotChatReview<CR>", { desc = "Review selection" })
      vim.keymap.set("v", "<leader>cf", "<cmd>CopilotChatFix<CR>", { desc = "Fix selection" })
    end,
  },
}
