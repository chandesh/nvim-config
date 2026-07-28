-- ~/.config/nvim/lua/config/git.lua
-- =============================================================================
-- Git Integration
-- High-performance git workflows using Gitsigns and Fugitive.
-- =============================================================================

local M = {}

function M.setup()
  local icons = require('config.icons')
  
  local function safe_setup(mod, pack_name, setup_fn)
    pack_name = pack_name or mod
    local ok, m = pcall(require, mod)
    if not ok then
      -- Try packadd for opt plugins
      pcall(vim.cmd, "packadd " .. pack_name)
      ok, m = pcall(require, mod)
    end
    if ok then
      setup_fn(m)
      return true
    end
    vim.notify("Plugin " .. mod .. " not found. Please run install.sh", vim.log.levels.WARN)
    return false
  end

  -- Gitsigns: In-buffer indicators and hunk management
  safe_setup('gitsigns', 'gitsigns.nvim', function(gs)
    gs.setup({
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
  end)

  -- Neogit: Interactive status and commit UI
  safe_setup('neogit', 'neogit', function(ng)
    ng.setup({
      integrations = { diffview = true },
      wrapping_wrap = true,
      floating_window = { border = 'rounded' },
    })
  end)

  -- Diffview: Repository-wide visual diffs
  safe_setup('diffview', 'diffview.nvim', function(dv)
    dv.setup({
      view_options = {
        hide_sidebyside_diff_compass = false,
        zoom_level = 1,
      },
    })
  end)

  -- Git Conflict: Guided resolution UI
  safe_setup('git_conflict', 'git-conflict-nvim', function(gc)
    gc.setup()
  end)
end

return M
