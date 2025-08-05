return {
  -- JavaScript/TypeScript enhanced support using none-ls (maintained fork of null-ls)
  {
    "nvimtools/none-ls.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local null_ls = require("null-ls")

      null_ls.setup({
        sources = {
          -- JavaScript/TypeScript
          null_ls.builtins.formatting.prettier,
          null_ls.builtins.diagnostics.eslint_d,
        },
      })
    end,
  },
  
  -- Improved coding productivity with multicursor support
  {
    "mg979/vim-visual-multi",
    branch = "master",
    config = function()
      vim.g.VM_default_mappings = 1
      vim.g.VM_maps = {
        ["Find Under"] = "<A-n>",
        ["Select Cursor Down"] = "<C-Down>",
        ["Select Cursor Up"] = "<C-Up>",
        ["Visual All"] = "<C-S-L>",
        ["Visual Add"] = "<C-S-K>",
        ["Find All"] = "<A-Up>",
      }
    end,
  },
  
  -- Advanced searching features
  {
    "pechorin/any-jump.vim",
    config = function()
      vim.g.any_jump_window_width_ratio = 0.9
      vim.g.any_jump_window_height_ratio = 0.9
    end,
  },
}
