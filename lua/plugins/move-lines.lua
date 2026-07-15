return {
  {
    "kobbikobb/move-lines.nvim",
    event = "VeryLazy",
    config = function()
      require("move-lines").setup()
    end,
  },
}
