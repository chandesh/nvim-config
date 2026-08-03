-- Git integration — gitsigns signs

local popup = require('config.popup')
local icons = require('config.icons')

local M = {}

local function register_floats(name)
  vim.defer_fn(function()
    for _, win in ipairs(vim.api.nvim_list_wins()) do
      if vim.api.nvim_win_get_config(win).relative ~= '' then
        popup.register_popup(win, name)
      end
    end
  end, 50)
end

function M.setup()
  local function safe_setup(mod, pack_name, setup_fn)
    pack_name = pack_name or mod
    local ok, m = pcall(require, mod)
    if not ok then
      pcall(vim.cmd, 'packadd ' .. pack_name)
      ok, m = pcall(require, mod)
    end
    if ok then
      setup_fn(m)
      return true
    end
    vim.notify('Plugin ' .. mod .. ' not found. Run install.sh', vim.log.levels.WARN)
    return false
  end

  safe_setup('gitsigns', 'gitsigns.nvim', function(gs)
    gs.setup({
      signs = {
        add          = { text = icons.git.add },
        change       = { text = icons.git.change },
        delete       = { text = icons.git.delete },
        topdelete    = { text = icons.git.topdelete },
        changedelete = { text = icons.git.changedelete },
        untracked    = { text = icons.git.untracked },
      },
      current_line_blame = true,
      current_line_blame_opts = {
        virt_text = true,
        virt_text_pos = 'eol',
      },
      preview_config = {
        border   = popup.config.border,
        style    = 'minimal',
        relative = 'cursor',
        row      = 1,
        col      = 0,
      },
      on_attach = function(bufnr)
        local gs = package.loaded.gitsigns
        local function bmap(mode, lhs, rhs, text)
          vim.keymap.set(mode, lhs, rhs,
            { buffer = bufnr, noremap = true, silent = true, desc = text })
        end

        bmap('n', ']h', function()
          if vim.wo.diff then return ']h' end
          vim.schedule(function() gs.next_hunk() end)
          return '<Ignore>'
        end, 'Next hunk')
        bmap('n', '[h', function()
          if vim.wo.diff then return '[h' end
          vim.schedule(function() gs.prev_hunk() end)
          return '<Ignore>'
        end, 'Prev hunk')

        bmap('n', '<leader>hp', function()
          popup.save_origin()
          gs.preview_hunk()
          register_floats('hunk-preview')
        end, 'Preview hunk')
        bmap('n', '<leader>hs', gs.stage_hunk, 'Stage hunk')
        bmap('n', '<leader>hu', gs.undo_stage_hunk, 'Undo stage hunk')
        bmap('n', '<leader>hr', gs.reset_hunk, 'Reset hunk')
        bmap('n', '<leader>hS', gs.stage_buffer, 'Stage buffer')
        bmap('n', '<leader>hR', gs.reset_buffer, 'Reset buffer')
        bmap('v', '<leader>hs', function()
          gs.stage_hunk({ vim.fn.line('.'), vim.fn.line('v') })
        end, 'Stage selection')
        bmap('v', '<leader>hr', function()
          gs.reset_hunk({ vim.fn.line('.'), vim.fn.line('v') })
        end, 'Reset selection')

        bmap('n', '<leader>hd', function()
          popup.save_origin()
          gs.diffthis()
        end, 'Diff file')
        bmap('n', '<leader>hD', function()
          popup.save_origin()
          gs.diffthis('~')
        end, 'Diff vs HEAD')

        bmap('n', '<leader>hq', function()
          gs.setqflist('all')
          vim.defer_fn(function()
            vim.cmd('copen')
            local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
            vim.cmd('cclose')
            popup.open_scratch(lines, {
              title        = ' Git Hunks ',
              width_ratio  = 0.70,
              height_ratio = 0.50,
              filetype     = 'qf',
            })
          end, 100)
        end, 'Hunks quickfix')

        bmap({ 'o', 'x' }, 'ih', ':<C-U>Gitsigns select_hunk<CR>', 'Select hunk')
      end,
    })
  end)
end

return M
