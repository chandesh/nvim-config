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
      { source = "rmagatti/goto-preview",             name = "goto-preview" },
      { source = "williamboman/mason.nvim",           name = "mason.nvim" },
      { source = "williamboman/mason-lspconfig.nvim", name = "mason-lspconfig.nvim" },
      { source = "nvimtools/none-ls.nvim",            name = "none-ls.nvim" },
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
      { source = "tpope/vim-fugitive",       name = "vim-fugitive" },
    },
    opt = {
      { source = "sindrets/diffview.nvim",   name = "diffview.nvim" },
      { source = "junegunn/gv.vim",          name = "gv.vim" },
    },
  },
  nav = {
    start = {
      { source = "nvim-telescope/telescope.nvim",            name = "telescope.nvim" },
      { source = "nvim-telescope/telescope-fzf-native.nvim", name = "telescope-fzf-native.nvim" },
      { source = "nvim-tree/nvim-tree.lua",                  name = "nvim-tree.lua" },
      { source = "stevearc/aerial.nvim",                     name = "aerial.nvim" },
    },
    opt = {
      { source = "ThePrimeagen/harpoon",                     name = "harpoon" },
      { source = "rmagatti/goto-preview",                    name = "goto-preview" },
      { source = "andrew-george/telescope-themes",           name = "telescope-themes" },
    },
  },
  ui = {
    start = {
      { source = "nvim-lualine/lualine.nvim",           name = "lualine.nvim" },
      { source = "akinsho/bufferline.nvim",             name = "bufferline.nvim" },
      { source = "lukas-reineke/indent-blankline.nvim", name = "indent-blankline.nvim" },
      { source = "folke/which-key.nvim",                name = "which-key.nvim" },
      { source = "folke/trouble.nvim",                  name = "trouble.nvim" },
      { source = "folke/todo-comments.nvim",            name = "todo-comments.nvim" },
      { source = "MunifTanjim/nui.nvim",                name = "nui.nvim" },
      { source = "folke/noice.nvim",                    name = "noice.nvim" },
      { source = "rcarriga/nvim-notify",                name = "nvim-notify" },
      { source = "goolord/alpha-nvim",                  name = "alpha-nvim" },
      { source = "norcalli/nvim-colorizer.lua",         name = "nvim-colorizer.lua" },
      { source = "stevearc/dressing.nvim",              name = "dressing.nvim" },
      { source = "smiteshp/nvim-navic",                 name = "nvim-navic" },
    },
    opt = {
      { source = "folke/zen-mode.nvim",                 name = "zen-mode.nvim" },
      { source = "MeanderingProgrammer/render-markdown.nvim", name = "render-markdown.nvim" },
      { source = "folke/twilight.nvim",                 name = "twilight.nvim" },
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
      { source = "mbbill/undotree",          name = "undotree" },
      { source = "karb94/neoscroll.nvim",    name = "neoscroll.nvim" },
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
