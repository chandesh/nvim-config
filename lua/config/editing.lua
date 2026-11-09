-- ~/.config/nvim/lua/config/editing.lua
-- =============================================================================
-- Editing & Workflow Tools
-- Integration of essential editing plugins for speed and efficiency.
-- =============================================================================

local M = {}

-- Spectre is an opt plugin. Load and configure it on first use so the first
-- tick no longer requires it. Keymaps call this before requiring `spectre`.
local spectre_loaded = false

function M.ensure_spectre()
  if spectre_loaded then return require('spectre') end
  vim.cmd('packadd nvim-spectre')
  local spectre = require('spectre')
  spectre.setup({
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

  spectre_loaded = true
  return spectre
end

local flash_loaded = false

-- Flash is opt. Load it only for <leader>js and disable the plugin's f/t
-- overrides so builtin motions keep working.
function M.ensure_flash()
  if flash_loaded then return require('flash') end
  vim.cmd('packadd flash.nvim')
  local flash = require('flash')
  flash.setup({
    modes = { char = { enabled = false } },
  })
  flash_loaded = true
  return flash
end

function M.setup()
  -- Auto-pairs integration
  require('nvim-autopairs').setup({
    check_ts = true,
  })

  -- Surround setup
  require('nvim-surround').setup({})

  -- Spectre is loaded lazily via M.ensure_spectre() from its keymaps.

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
      dart = { "dart_format" },
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
