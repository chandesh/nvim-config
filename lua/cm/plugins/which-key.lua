return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  init = function()
    vim.o.timeout = true
    vim.o.timeoutlen = 2000
  end,
  opts = {
    preset = "modern",
    delay = 200,
  },
  config = function(_, opts)
    local wk = require("which-key")
    wk.setup(opts)

    -- Register key groups for better organization
    wk.add({
      { "<leader>c",   group = "Code" },
      { "<leader>ca",  desc = "Code Actions" },
      { "<leader>d",   group = "Debug/Diagnostics" },
      { "<leader>dp",  group = "Debug Python" },
      { "<leader>f",   group = "Find/File" },
      { "<leader>g",   group = "Git" },
      { "<leader>l",   group = "LSP" },
      { "<leader>lc",  desc = "LSP Code Actions" },
      { "<leader>o",   group = "Organize" },
      { "<leader>r",   group = "Refactor" },
      { "<leader>rn",  desc = "Rename" },
      { "<leader>rf",  desc = "Format" },
      { "<leader>s",   group = "Split/Search" },
      { "<leader>t",   group = "Tab/Terminal" },
      { "<leader>p",   group = "Python/Pyenv" },
      { "<leader>pi",  desc = "Pyenv Info" },
      { "<leader>pr",  desc = "Reactivate Pyenv" },
      { "<leader>pl",  desc = "Install LSP Packages" },
      { "<leader>t",   group = "Type Checking/Tests" },
      { "<leader>tt",  desc = "Toggle Type Checking Diagnostics" },
      { "<leader>w",   group = "Workspace" },
      { "<leader>x",   group = "Trouble/Diagnostics" },

      -- LSP keymaps documentation
      { "g",           group = "Go to" },
      { "gd",          desc = "Go to Definition" },
      { "gD",          desc = "Go to Declaration" },
      { "gi",          desc = "Go to Implementation" },
      { "gr",          desc = "Show References" },
      { "gt",          desc = "Go to Type Definition" },
      { "K",           desc = "Hover Documentation" },

      -- Folding
      { "z",           group = "Fold" },
      { "za",          desc = "Toggle Fold" },
      { "zR",          desc = "Open All Folds" },
      { "zM",          desc = "Close All Folds" },
      { "zK",          desc = "Peek Fold" },

      -- Diagnostics
      { "[",           group = "Previous" },
      { "[d",          desc = "Previous Diagnostic" },
      { "[z",          desc = "Previous Fold" },
      { "]",           group = "Next" },
      { "]d",          desc = "Next Diagnostic" },
      { "]z",          desc = "Next Fold" },

      -- PyCharm-like bindings (macOS friendly)
      { "<M-CR>",      desc = "Code Actions (Option+Enter)" },
      { "<A-CR>",      desc = "Code Actions (Alt+Enter)" },
      { "<leader>.",   desc = "Code Actions (Quick Fix)" },
      { "<C-=>",       desc = "Toggle Fold" },
      { "<C-->",       desc = "Toggle Fold" },
    })
  end,
}
