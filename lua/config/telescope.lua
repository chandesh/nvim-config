-- ~/.config/nvim/lua/config/telescope.lua
-- =============================================================================
-- Telescope Configuration
-- High-performance search and navigation with fzf-native.
-- =============================================================================

local M = {}

function M.setup()
  local telescope = require('telescope')
  local builtin = require('telescope.builtin')

  telescope.setup({
    defaults = {
      vimgrep_arguments = {
        'rg',
        '--color',
        '--smart-case',
        '--no-heading',
        '--with-filename',
        '--line-number',
        '--column',
        '--hidden',
        '--follow',
      },
      file_ignore_patterns = { 
        "node_modules()", ".git()", "__pycache__()", ".venv()", "dist()" 
      },
      layout_strategy = 'horizontal',
      path_display = { "smart" },
      sorting_strategy = "ascending",
    },
    pickers = {
      find_files = {
        hidden = true,
      },
    },
  })

  -- Load fzf-native extension for lightning fast sorting
  pcall(require('telescope').load_extension, 'fzf')
end

return M
