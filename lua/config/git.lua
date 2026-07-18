-- ~/.config/nvim/lua/config/git.lua
-- =============================================================================
-- Git Integration
-- High-performance git workflows using Gitsigns and Fugitive.
-- =============================================================================

local M = {}

function M.setup()
  require('gitsigns').setup({
    current_line_blame = true, 
    current_line_blame_opts = {
      'virtual_text',
      { 'end' },
    },
    signs = {
      add          = { text = '✚' },
      change       = { text = '▵' },
      delete       = { text = '▵' },
      top_delta    = { text = 'supseteq' },
      bottom_delta = { text = 'subseteq' },
    },
  })

  -- Diffview is loaded via packadd if needed, or simply handled by Fugitive
end

return M
