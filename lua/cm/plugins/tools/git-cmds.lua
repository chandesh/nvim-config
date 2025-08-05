return {
  {
    "tpope/vim-fugitive",
  },
  {
    "lewis6991/gitsigns.nvim",
    config = function()
      require("gitsigns").setup()
      -- Keymaps are now managed in lua/cm/core/keymaps.lua
    end,
  },
}
