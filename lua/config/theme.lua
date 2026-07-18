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
--   SIDEBARS         : {"qf", "help", "neo-tree", "Trouble"}
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
  sidebars = { 'qf', 'help', 'neo-tree', 'Trouble' },
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
    highlights.NeoTreeNormal = { bg = colors.bg_dark }
    highlights.NeoTreeNormalNC = { bg = colors.bg_dark }
    highlights.NvimTreeNormal = { bg = colors.bg_dark }
    highlights.NvimTreeNormalNC = { bg = colors.bg_dark }
    highlights.NvimTreeWinSeparator = {
      fg = colors.blue,
      bg = colors.bg_dark,
    }
    highlights.Normal = { bg = colors.bg_dark, fg = colors.fg }
    highlights.NormalNC = { bg = colors.bg_highlight, fg = colors.fg_dark }
  end,
})

-- Apply the colorscheme variant
vim.cmd.colorscheme('solarized-osaka')

-- Custom highlight overrides applied after the theme loads
local function apply_custom_highlights()
  local hl = vim.api.nvim_set_hl

  -- Dynamic background synchronization from backup
  local nvimtree_bg = vim.fn.synIDattr(vim.fn.hlID('NvimTreeNormal'), 'bg#')
  if nvimtree_bg and nvimtree_bg ~= '' then
    hl(0, 'Normal', { bg = nvimtree_bg })
    
    local telescope_fg = vim.fn.synIDattr(vim.fn.hlID('Normal'), 'fg#')
    local blue_fg = vim.fn.synIDattr(vim.fn.hlID('Function'), 'fg#') or '#7aa2f7'
    local green_fg = vim.fn.synIDattr(vim.fn.hlID('String'), 'fg#') or '#9ece6a'
    local cyan_fg = vim.fn.synIDattr(vim.fn.hlID('Special'), 'fg#') or '#73daca'
    
    hl(0, 'TelescopeNormal', { bg = nvimtree_bg, fg = telescope_fg })
    hl(0, 'TelescopeBorder', { bg = nvimtree_bg, fg = blue_fg })
    hl(0, 'TelescopePromptNormal', { bg = nvimtree_bg, fg = telescope_fg })
    hl(0, 'TelescopePromptBorder', { bg = nvimtree_bg, fg = blue_fg })
    hl(0, 'TelescopePromptTitle', { bg = blue_fg, fg = nvimtree_bg, bold = true })
    hl(0, 'TelescopePreviewNormal', { bg = nvimtree_bg, fg = telescope_fg })
    hl(0, 'TelescopePreviewBorder', { bg = nvimtree_bg, fg = blue_fg })
    hl(0, 'TelescopePreviewTitle', { bg = green_fg, fg = nvimtree_bg, bold = true })
    hl(0, 'TelescopeResultsNormal', { bg = nvimtree_bg, fg = telescope_fg })
    hl(0, 'TelescopeResultsBorder', { bg = nvimtree_bg, fg = blue_fg })
    hl(0, 'TelescopeResultsTitle', { bg = cyan_fg, fg = nvimtree_bg, bold = true })
  end
end

apply_custom_highlights()

-- Ensure overrides persist after theme changes
vim.api.nvim_create_autocmd('ColorScheme', {
  group = vim.api.nvim_create_augroup('SolarizedOsakaOverrides', { clear = true }),
  pattern = '*',
  callback = apply_custom_highlights,
})
