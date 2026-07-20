-- ~/.config/nvim/lua/config/telescope.lua
-- =============================================================================
-- Telescope Configuration
-- High-performance search and navigation with fzf-native.
-- =============================================================================

local M = {}

function M.setup()
  local telescope = require('telescope')
  local builtin = require('telescope.builtin')

  local icons = require('config.icons')
  telescope.setup({
    defaults = {
      prompt_prefix   = icons.telescope.prompt,
      selection_caret = icons.telescope.selection,
      multi_icon      = icons.telescope.multi,
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
        '--glob',
        '!.git',
        '--glob',
        '!node_modules',
        '--glob',
        '!__pycache__',
        '--glob',
        '!.venv',
        '--glob',
        '!.trash',
        '--glob',
        '!.opencode',
        '--glob',
        '!.graphify-out',
        '--glob',
        '!.understand-anything',
        '--glob',
        '!.graphify_detect.json',
      },
      file_ignore_patterns = {
        -- Directories
        "node_modules/",
        "__pycache__/",
        ".mypy_cache/",
        ".pytest_cache/",
        ".git/",
        "vendor/",
        "build/",
        "dist/",
        "target/",
        "coverage/",
        ".coverage/",
        ".nyc_output/",
        ".cache/",
        ".temp/",
        ".tmp/",
        "tmp/",
        ".trash/",
        ".trash%-",
        ".angular/",
        ".next/",
        ".nuxt/",
        "venv/",
        ".venv/",
        ".dart_tool/",
        "Pods/",
        "go.work/",
        ".opencode/",
        ".graphify%-out/",
        ".understand%-anything/",
        ".graphify_detect.json$",
        -- File extensions
        "%.pyc$",
        "%.pyo$",
        "%.pyd$",
        "%.so$",
        "%.dylib$",
        "%.dll$",
        "%.class$",
        "%.exe$",
        "%.o$",
        "%.obj$",
        -- Lock files (noise in search results)
        "package%-lock.json$",
        "yarn%.lock$",
        "pnpm%-lock.yaml$",
        "Cargo%.lock$",
        "Gemfile%.lock$",
        "poetry%.lock$",
        "composer%.lock$",
      },
      layout_strategy = 'horizontal',
      path_display = { "smart" },
      sorting_strategy = "ascending",
    },
    pickers = {
      find_files = {
        hidden = true,
        no_ignore = false,
      },
      git_files = {
        hidden = true,
        show_untracked = true,
      },
    },
  })

  -- Load fzf-native extension for lightning fast sorting
  pcall(require('telescope').load_extension, 'fzf')
end

return M
