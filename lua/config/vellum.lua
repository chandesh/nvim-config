-- ~/.config/nvim/lua/config/vellum.lua
-- =============================================================================
-- Vellum — read-only side preview for markdown.
-- Opt plugin: setup() only registers the keymap; the plugin is packadded on
-- first use. auto_open stays false so the existing inline render-markdown
-- flow is untouched.
-- =============================================================================

local M = {}

local loaded = false

function M.ensure()
  if loaded then
    return require('vellum')
  end

  vim.cmd('packadd vellum.nvim')
  local vellum = require('vellum')
  vellum.setup({
    split = 'right',
    max_width = 100,
    auto_open = false,
  })
  loaded = true
  return vellum
end

function M.setup()
  vim.keymap.set('n', '<leader>mv', function()
    M.ensure().toggle()
  end, { desc = 'Markdown preview (Vellum)' })
end

return M
