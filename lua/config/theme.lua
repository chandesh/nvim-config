-- ~/.config/nvim/lua/config/theme.lua
-- =============================================================================
-- SOLARIZED OSAKA CONFIGURATION
-- Extracted from backup to ensure pixel-perfect reproduction.
-- Plugin: craftzdog/solarized-osaka.nvim
-- =============================================================================

-- Extraction record for future maintenance:
--   VARIANT          : solarized-osaka
--   TRANSPARENT      : true
--   TERMINAL_COLORS  : true
--   DIM_INACTIVE     : false
--   LUALINE_BOLD     : false
--   DAY_BRIGHTNESS   : 0.3
--   SIDEBARS         : {"qf", "help"}
--   FLOATS           : "dark"
--   COMMENT_ITALIC   : true
--   KEYWORD_ITALIC   : true

require('solarized-osaka').setup({
  transparent = true,
  terminal_colors = true,
  styles = {
    comments = { italic = true },
    keywords = { italic = true },
    functions = {},
    variables = {},
    sidebars = 'dark',
    floats = 'dark',
  },
  sidebars = { 'qf', 'help' },
  day_brightness = 0.3,
  hide_inactive_statusline = false,
  dim_inactive = false,
  lualine_bold = false,
  cache = true,
  plugins = {
    all = true,
    auto = true,
  },
  on_colors = function(colors)
    colors.hint = colors.orange
    colors.error = '#ff0000'
  end,
  on_highlights = function(highlights, colors)
    highlights.CmpGhostText = { fg = colors.comment }
    highlights.GitSignsAdd = { fg = colors.green }
    highlights.GitSignsChange = { fg = colors.yellow }
    highlights.GitSignsDelete = { fg = colors.red }
    highlights.BlinkCmpKind = { fg = colors.blue }
    highlights.BlinkCmpMenu = { bg = colors.bg_dark }
    highlights.BufferLineIndicatorSelected = { fg = colors.blue }
    highlights.Normal = { bg = colors.bg_dark, fg = colors.fg }
    highlights.NormalNC = { bg = colors.bg_highlight, fg = colors.fg_dark }
  end,
})

-- Apply the colorscheme variant
vim.cmd.colorscheme('solarized-osaka')
