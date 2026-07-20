-- ~/.config/nvim/lua/config/completion.lua
-- =============================================================================
-- Completion Configuration
-- Powered by blink.cmp for ultra-fast, asynchronous completion.
-- =============================================================================

local M = {}

function M.setup()
  local icons = require('config.icons')
  require('blink.cmp').setup({
    keymap = {
      preset = 'default',
      ['<C-space>'] = { 'show', 'show_documentation', 'hide_documentation' },
      ['<CR>'] = { 'accept', 'fallback' },
      ['<Tab>'] = { 'select_next', 'fallback' },
      ['<S-Tab>'] = { 'select_prev', 'fallback' },
    },

    completion = {
      menu = {
        border = 'rounded',
      },
      documentation = {
        window = { border = 'rounded' },
      },
    },

    sources = {
      default = { 'lsp', 'path', 'snippets', 'buffer', 'copilot' },

      providers = {
        copilot = {
          name = 'copilot',
          module = 'blink-copilot',
          score_offset = 100,
          async = true,
        },
      },
    },

    signature = {
      enabled = true,
      window = { border = 'rounded' },
    },

    snippets = {
      preset = 'luasnip',
    },

    appearance = {
      kind_icons = icons.kinds,
    },
  })
end

return M
