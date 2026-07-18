-- ~/.config/nvim/lua/config/editing.lua
-- =============================================================================
-- Editing & Workflow Tools
-- Integration of essential editing plugins for speed and efficiency.
-- =============================================================================

local M = {}

function M.setup()
  -- Auto-pairs integration
  require('nvim-autopairs').setup({
    check_ts = true,
  })

  -- Surround setup
  require('nvim-surround').setup({})

  -- Comment.nvim configuration
  require('Comment').setup()

  -- Flash.nvim for lightning fast jumps
  local ok_flash, flash = pcall(require, 'flash')
  if ok_flash then
    flash.setup({
      jump = { key = 's' },
    })
  end

  -- Harpoon for fast file jumping
  local ok_harpoon, harpoon = pcall(require, 'harpoon')
  if ok_harpoon then
    harpoon.setup()
  end

  -- Spectre for project-wide search and replace (floating window)
  require('spectre').setup({
    color_devicons = true,
    open_cmd = "call SpectreFloatingWindow()",
    live_update = false,
    line_sep_start = '┌-----------------------------------------',
    result_padding = '¦  ',
    line_sep       = '└-----------------------------------------',
    highlight = {
      ui = "String",
      search = "DiffChange",
      replace = "DiffDelete"
    },
    is_open_target_win = true,
    is_insert_mode = false,
  })

  -- Create floating window function for Spectre
  vim.cmd([[
    function! SpectreFloatingWindow()
      let width = float2nr(&columns * 0.8)
      let height = float2nr(&lines * 0.6)
      let row = float2nr(&lines * 0.2)
      let col = float2nr(&columns * 0.1)
      let opts = {
        \ 'relative': 'editor',
        \ 'width': width,
        \ 'height': height,
        \ 'row': row,
        \ 'col': col,
        \ 'style': 'minimal',
        \ 'border': 'rounded'
        \ }
      let buf = nvim_create_buf(v:false, v:true)
      let win = nvim_open_win(buf, v:true, opts)
      return buf
    endfunction
  ]])

  -- Conform.nvim — formatter (manual format only, no auto-format on save)
  require('conform').setup({
    formatters_by_ft = {
      python = { "black", "isort" },
      javascript = { "prettier" },
      typescript = { "prettier" },
      javascriptreact = { "prettier" },
      typescriptreact = { "prettier" },
      html = { "prettier" },
      css = { "prettier" },
      scss = { "prettier" },
      json = { "prettier" },
      jsonc = { "prettier" },
      yaml = { "prettier" },
      markdown = { "prettier" },
      lua = { "stylua" },
      sh = { "shfmt" },
      bash = { "shfmt" },
      htmldjango = { "djlint" },
    },
    formatters = {
      black = {
        prepend_args = { "--line-length", "88", "--skip-string-normalization", "--fast" },
      },
      stylua = {
        prepend_args = { "--column-width", "120", "--line-endings", "Unix", "--indent-type", "Spaces", "--indent-width", "2" },
      },
      shfmt = {
        prepend_args = { "-i", "2", "-ci", "-bn" },
      },
    },
  })
end

return M
