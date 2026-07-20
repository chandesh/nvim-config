-- ~/.config/nvim/lua/config/git.lua
-- =============================================================================
-- Git Integration
-- High-performance git workflows using Gitsigns and Fugitive.
-- =============================================================================

local M = {}

function M.setup()
  local icons = require('config.icons')
  require('gitsigns').setup({
    current_line_blame = true, 
    current_line_blame_opts = {
      'virtual_text',
      { 'end' },
    },
    signs = {
      add          = { text = icons.git.add },
      change       = { text = icons.git.change },
      delete       = { text = icons.git.delete },
      topdelete    = { text = icons.git.topdelete },
      changedelete = { text = icons.git.changedelete },
      untracked    = { text = icons.git.untracked },
    },
  })

  -- Diffview is loaded via packadd if needed, or simply handled by Fugitive
end

return M
