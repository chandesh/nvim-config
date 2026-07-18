-- ~/.config/nvim/lua/config/folding.lua
-- =============================================================================
-- Folding Configuration
-- Efficient folding using nvim-ufo and Treesitter.
-- =============================================================================

local M = {}

function M.setup()
  require('ufo').setup({
    provider_selector = function()
      return { "treesitter", "indent" }
    end,
  })
end

return M
