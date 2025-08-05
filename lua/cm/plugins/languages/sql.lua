return {
  -- SQL support and database connections
  {
    "tpope/vim-dadbod",
    dependencies = {
      "kristijanhusak/vim-dadbod-ui",
      "kristijanhusak/vim-dadbod-completion",
    },
    config = function()
      -- Keymaps are now managed in lua/cm/core/keymaps.lua
      
      -- Setup dadbod-completion for SQL files
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "sql", "mysql", "plsql" },
        callback = function()
          require("cmp").setup.buffer({
            sources = {
              { name = "vim-dadbod-completion" },
              { name = "buffer" },
            }
          })
        end,
      })
    end,
  },
  
  -- SQL formatting and linting
  {
    "joereynolds/SQHell.vim",
    ft = "sql",
  },
  
  -- Enhanced SQL syntax
  {
    "nanotee/sqls.nvim",
    ft = "sql",
    config = function()
      require("sqls").setup({})
    end,
  },
}
