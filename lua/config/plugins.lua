-- ~/.config/nvim/lua/config/plugins.lua
-- =============================================================================
-- Plugin Registry for Detached Management
-- Mirroring install.sh exactly to maintain vim.pack structure.
-- =============================================================================

return {
  theme = {
    start = {
      { source = "craftzdog/solarized-osaka.nvim", name = "solarized-osaka.nvim" },
      { source = "folke/tokyonight.nvim",           name = "tokyonight.nvim" },
      { source = "catppuccin/nvim",                 name = "catppuccin" },
    },
  },
  core = {
    start = {
      { source = "folke/snacks.nvim",             name = "snacks.nvim" },
      { source = "nvim-lua/plenary.nvim",        name = "plenary.nvim" },
      { source = "nvim-tree/nvim-web-devicons",  name = "nvim-web-devicons" },
    },
    opt = {
      { source = "rmagatti/auto-session",        name = "auto-session" },
    },
  },
  lsp = {
    start = {
      { source = "neovim/nvim-lspconfig",             name = "nvim-lspconfig" },
      { source = "williamboman/mason.nvim",           name = "mason.nvim" },
      { source = "williamboman/mason-lspconfig.nvim", name = "mason-lspconfig.nvim" },
      { source = "j-hui/fidget.nvim",                 name = "fidget.nvim" },
    },
    opt = {
      { source = "b0o/SchemaStore.nvim",              name = "SchemaStore.nvim" },
    },
  },
  completion = {
    start = {
      { source = "saghen/blink.cmp",             name = "blink.cmp" },
      { source = "fang2hou/blink-copilot",       name = "blink-copilot" },
      { source = "L3MON4D3/LuaSnip",             name = "LuaSnip" },
      { source = "rafamadriz/friendly-snippets", name = "friendly-snippets" },
    },
  },
  treesitter = {
    start = {
      { source = "nvim-treesitter/nvim-treesitter",             name = "nvim-treesitter" },
      { source = "nvim-treesitter/nvim-treesitter-textobjects", name = "nvim-treesitter-textobjects" },
    },
    opt = {
      { source = "windwp/nvim-ts-autotag",                      name = "nvim-ts-autotag" },
    },
  },
  debug = {
    opt = {
      { source = "mfussenegger/nvim-dap",            name = "nvim-dap" },
      { source = "mfussenegger/nvim-dap-python",     name = "nvim-dap-python" },
      { source = "leoluz/nvim-dap-go",               name = "nvim-dap-go" },
      { source = "rcarriga/nvim-dap-ui",             name = "nvim-dap-ui" },
      { source = "nvim-neotest/nvim-nio",            name = "nvim-nio" },
      { source = "theHamsta/nvim-dap-virtual-text",  name = "nvim-dap-virtual-text" },
    },
  },
  git = {
    start = {
      { source = "lewis6991/gitsigns.nvim",  name = "gitsigns.nvim" },
    },
    opt = {
    },
  },
  nav = {
    start = {
    },
    opt = {
    },
  },
  ui = {
    start = {
      { source = "nvim-lualine/lualine.nvim",           name = "lualine.nvim" },
      { source = "akinsho/bufferline.nvim",             name = "bufferline.nvim" },
    },
    opt = {
      { source = "MeanderingProgrammer/render-markdown.nvim", name = "render-markdown.nvim" },
    },
  },
  editing = {
    start = {
      { source = "stevearc/conform.nvim",     name = "conform.nvim" },
      { source = "windwp/nvim-autopairs",    name = "nvim-autopairs" },
      { source = "kylechui/nvim-surround",   name = "nvim-surround" },
      { source = "numToStr/Comment.nvim",    name = "Comment.nvim" },
      { source = "mg979/vim-visual-multi",   name = "vim-visual-multi" },
      { source = "kevinhwang91/nvim-ufo",    name = "nvim-ufo" },
      { source = "kevinhwang91/promise-async", name = "promise-async" },
      { source = "nvim-pack/nvim-spectre",   name = "nvim-spectre" },
    },
    opt = {
      { source = "folke/flash.nvim",         name = "flash.nvim" },
    },
  },
  lang = {
    opt = {
      { source = "linux-cultist/venv-selector.nvim",  name = "venv-selector.nvim" },
      { source = "mfussenegger/nvim-lint",            name = "nvim-lint" },
      { source = "pmizio/typescript-tools.nvim",      name = "typescript-tools.nvim" },
      { source = "dmmulroy/tsc.nvim",                 name = "tsc.nvim" },
      { source = "olexsmir/gopher.nvim",              name = "gopher.nvim" },
    },
  },
}
