-- ~/.config/nvim/lua/config/aerial.lua
-- =============================================================================
-- Aerial Configuration
-- Fast code structure navigation using LSP and Treesitter.
-- =============================================================================

local M = {}

function M.setup()
  require('aerial').setup({
    layout = {
      max_width = 30,
      max_height = 0.8,
    },
    backends = {
      -- Priority order for structure extraction
      "lsp",
      "treesitter",
      "markdown",
    },
  })
end

return M
