-- ~/.config/nvim/lua/config/aerial.lua
-- =============================================================================
-- Aerial Configuration
-- Fast code structure navigation using LSP and Treesitter.
-- =============================================================================

local M = {}

function M.setup()
  local icons = require('config.icons')
  require('aerial').setup({
    layout = {
      max_width = 30,
      max_height = 0.8,
    },
    backends = {
      "lsp",
      "treesitter",
      "markdown",
    },
    icons = icons.aerial,
  })
end

return M
