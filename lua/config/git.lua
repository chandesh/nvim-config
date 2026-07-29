local popup = require('config.popup')
local icons = require('config.icons')

local M = {}

local function ensure(mod, pack_name)
  pack_name = pack_name or mod
  local ok, m = pcall(require, mod)
  if not ok then
    pcall(vim.cmd, 'packadd ' .. pack_name)
    ok, m = pcall(require, mod)
  end
  return m
end

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

  safe_setup('neogit', 'neogit', function(ng)
    ng.setup({
      integrations = { diffview = true },
      wrapping_wrap = true,
      floating_window = { border = 'rounded' },
    })
  end)

  safe_setup('diffview', 'diffview.nvim', function(dv)
    dv.setup({
      enhanced_diff_hl = true,
      use_icons        = true,
      signs = {
        fold_closed = ' ',
        fold_open   = ' ',
        done        = ' ',
      },
      view = {
        default = {
          layout = 'diff2_horizontal',
          winbar_info = true,
        },
        file_history = {
          layout = 'diff2_horizontal',
        },
      },
      hooks = {
        view_opened = function()
          vim.defer_fn(function()
            for _, win in ipairs(vim.api.nvim_list_wins()) do
              popup.register_popup(win, 'diffview')
            end
          end, 50)
        end,
      },
    })
  end)

  safe_setup('git_conflict', 'git-conflict-nvim', function(gc)
    gc.setup()
  end)

  if pcall(require, 'which-key') then
    local wk = require('which-key')
    wk.add({
      { '<leader>g', group = ' Git' },
    })
  end
end

-- ── EXPORTED WORKFLOW FUNCTIONS ─────────────────────────────────

function M.open_neogit_status()
  popup.save_origin()
  local ng = ensure('neogit', 'neogit')
  if ng then
    ng.open()
    vim.defer_fn(function()
      for _, win in ipairs(vim.api.nvim_list_wins()) do
        local ft = vim.api.nvim_buf_get_option(
          vim.api.nvim_win_get_buf(win), 'filetype')
        if ft and ft:find('Neogit') then
          popup.register_popup(win, 'neogit')
        end
      end
    end, 100)
  end
end

function M.open_neogit_commit()
  popup.save_origin()
  local ng = ensure('neogit', 'neogit')
  if ng then
    ng.commit()
    vim.defer_fn(function()
      for _, win in ipairs(vim.api.nvim_list_wins()) do
        popup.register_popup(win, 'neogit-commit')
      end
    end, 100)
  end
end

function M.open_diffview()
  popup.save_origin()
  local lines = vim.fn.systemlist('git diff 2>/dev/null')
  if vim.v.shell_error ~= 0 then
    vim.notify('[git] Not a git repository', vim.log.levels.WARN)
    return
  end
  if #lines == 0 then
    lines = { '  No changes in working tree' }
  end
  popup.open_scratch(lines, {
    title       = ' Git Diff ',
    width_ratio = 0.85,
    height_ratio = 0.80,
    filetype    = 'diff',
  })
end

function M.open_diffview_current()
  popup.save_origin()
  local file = vim.fn.expand('%')
  if file == '' then
    vim.notify('[git] No file to diff', vim.log.levels.WARN)
    return
  end
  local lines = vim.fn.systemlist('git diff HEAD -- ' .. file .. ' 2>/dev/null')
  if vim.v.shell_error ~= 0 then
    vim.notify('[git] Not a git repository', vim.log.levels.WARN)
    return
  end
  if #lines == 0 then
    lines = { '  No changes for ' .. vim.fn.fnamemodify(file, ':t') }
  end
  popup.open_scratch(lines, {
    title       = ' Diff: ' .. vim.fn.fnamemodify(file, ':t') .. ' ',
    width_ratio = 0.85,
    height_ratio = 0.80,
    filetype    = 'diff',
  })
end

function M.preview_hunk()
  popup.save_origin()
  if ensure('gitsigns', 'gitsigns.nvim') then
    require('gitsigns').preview_hunk()
    register_floats('hunk-preview')
  end
end

function M.blame_line()
  popup.save_origin()
  if ensure('gitsigns', 'gitsigns.nvim') then
    require('gitsigns').blame_line({ full = true })
    register_floats('blame')
  end
end

function M.stage_all_hunks()
  local gs = ensure('gitsigns', 'gitsigns.nvim')
  if gs then gs.stage_hunk({ 'all' }) end
end

function M.reset_hunk()
  local gs = ensure('gitsigns', 'gitsigns.nvim')
  if gs then gs.reset_hunk() end
end

function M.open_git_log()
  popup.save_origin()
  local lines = vim.fn.systemlist(
    'git log --oneline --graph --decorate --color=never '
    .. '--format="%C(auto)%h %d %s (%cr) <%an>" -50 2>/dev/null')
  if vim.v.shell_error ~= 0 or #lines == 0 then
    vim.notify('[git] Not a git repo or no commits', vim.log.levels.WARN)
    return
  end
  popup.open_scratch(lines, {
    title       = ' Git Log (last 50) ',
    width_ratio = 0.85,
    height_ratio = 0.80,
    filetype    = 'git',
    keymaps = {
      {
        key  = '<CR>',
        desc = 'Open commit diff',
        action = function()
          local line = vim.api.nvim_get_current_line()
          local hash = line:match('^[%*%| /\\]*([a-f0-9]+)')
          if hash then
            popup.close_all()
            vim.defer_fn(function()
              M.show_commit(hash)
            end, 50)
          end
        end,
      },
      {
        key  = 'y',
        desc = 'Yank commit hash',
        action = function()
          local line = vim.api.nvim_get_current_line()
          local hash = line:match('^[%*%| /\\]*([a-f0-9]+)')
          if hash then
            vim.fn.setreg('+', hash)
            vim.notify('Yanked: ' .. hash, vim.log.levels.INFO)
          end
        end,
      },
    },
  })
end

function M.open_git_stash()
  popup.save_origin()
  local lines = vim.fn.systemlist('git stash list 2>/dev/null')
  if #lines == 0 then
    lines = { '  No stashes found.' }
  end
  popup.open_scratch(lines, {
    title       = ' Git Stash List ',
    width_ratio = 0.65,
    height_ratio = 0.50,
    filetype    = 'git',
    keymaps = {
      {
        key  = '<CR>',
        desc = 'Show stash diff',
        action = function()
          local line  = vim.api.nvim_get_current_line()
          local stash = line:match('(stash@{%d+})')
          if stash then
            popup.close_all()
            vim.defer_fn(function()
              local diff = vim.fn.systemlist(
                'git stash show -p ' .. stash .. ' 2>/dev/null')
              popup.open_scratch(diff, {
                title    = ' Stash: ' .. stash .. ' ',
                filetype = 'diff',
              })
            end, 50)
          end
        end,
      },
      {
        key  = 'p',
        desc = 'Pop stash',
        action = function()
          local line  = vim.api.nvim_get_current_line()
          local stash = line:match('(stash@{%d+})')
          if stash then
            popup.close_all()
            vim.fn.system('git stash pop ' .. stash)
            vim.notify('Popped ' .. stash, vim.log.levels.INFO)
            popup.return_to_origin()
          end
        end,
      },
    },
  })
end

function M.git_push()
  popup.save_origin()
  vim.notify(' Pushing...', vim.log.levels.INFO)
  vim.fn.jobstart('git push', {
    stdout_buffered = true,
    stderr_buffered = true,
    on_stdout = function(_, data)
      local lines = vim.tbl_filter(function(l) return l ~= '' end, data or {})
      if #lines > 0 then
        vim.schedule(function()
          popup.open_scratch(lines, {
            title       = ' Git Push ',
            width_ratio = 0.60,
            height_ratio = 0.30,
          })
        end)
      end
    end,
    on_stderr = function(_, data)
      local lines = vim.tbl_filter(function(l) return l ~= '' end, data or {})
      if #lines > 0 then
        vim.schedule(function()
          popup.open_scratch(lines, {
            title       = ' Git Push Output ',
            width_ratio = 0.60,
            height_ratio = 0.35,
          })
        end)
      end
    end,
    on_exit = function(_, code)
      vim.schedule(function()
        if code == 0 then
          vim.notify(' Push successful', vim.log.levels.INFO)
        else
          vim.notify(' Push failed (exit ' .. code .. ')', vim.log.levels.ERROR)
        end
      end)
    end,
  })
end

function M.git_pull()
  popup.save_origin()
  vim.notify(' Pulling...', vim.log.levels.INFO)
  vim.fn.jobstart('git pull', {
    stdout_buffered = true,
    stderr_buffered = true,
    on_stdout = function(_, data)
      local lines = vim.tbl_filter(function(l) return l ~= '' end, data or {})
      if #lines > 0 then
        vim.schedule(function()
          popup.open_scratch(lines, {
            title       = ' Git Pull ',
            width_ratio = 0.60,
            height_ratio = 0.30,
          })
        end)
      end
    end,
    on_exit = function(_, code)
      vim.schedule(function()
        if code == 0 then
          vim.notify(' Pull successful', vim.log.levels.INFO)
        else
          vim.notify(' Pull failed (' .. code .. ')', vim.log.levels.ERROR)
        end
      end)
    end,
  })
end

function M.show_commit_for_line()
  popup.save_origin()
  local line = vim.fn.line('.')
  local file = vim.fn.expand('%')
  local result = vim.fn.systemlist(
    string.format('git log -1 --format="%%H" -L %d,%d:%s 2>/dev/null',
      line, line, file))
  local hash = result and result[1]
  if not hash or hash == '' then
    vim.notify('[git] No commit for this line', vim.log.levels.WARN)
    return
  end
  M.show_commit(hash)
end

function M.show_commit(hash)
  local lines = vim.fn.systemlist('git show --stat ' .. hash .. ' 2>/dev/null')
  popup.open_scratch(lines, {
    title       = ' Commit: ' .. hash:sub(1, 8) .. ' ',
    width_ratio = 0.82,
    height_ratio = 0.80,
    filetype    = 'git',
  })
end

function M.show_status_summary()
  popup.save_origin()
  local status = vim.fn.systemlist('git status --short 2>/dev/null')
  local branch = vim.fn.system(
    'git branch --show-current 2>/dev/null'):gsub('\n', '')
  local ahead = vim.fn.system(
    'git rev-list --count @{upstream}..HEAD 2>/dev/null'):gsub('\n', '')
  local behind = vim.fn.system(
    'git rev-list --count HEAD..@{upstream} 2>/dev/null'):gsub('\n', '')
  local lines = {
    '  Branch : ' .. branch,
    '  Ahead  : ' .. (ahead  ~= '' and ahead  or '0'),
    '  Behind : ' .. (behind ~= '' and behind or '0'),
    '', '  Changed files:', '',
  }
  for _, s in ipairs(status) do
    table.insert(lines, '  ' .. s)
  end
  if #status == 0 then
    table.insert(lines, '  Work tree clean')
  end
  popup.open_scratch(lines, {
    title       = ' Git Status ',
    width_ratio = 0.55,
    height_ratio = 0.60,
  })
end

function M.open_git_branches()
  popup.save_origin()
  local tel = ensure('telescope', 'telescope.nvim')
  if tel then
    require('telescope.builtin').git_branches({
      attach_mappings = function()
        local actions = require('telescope.actions')
        local orig = actions.close
        actions.close = function(bufnr)
          orig(bufnr)
          popup.return_to_origin()
        end
        return true
      end,
    })
  end
end

function M.open_git_commits()
  popup.save_origin()
  local tel = ensure('telescope', 'telescope.nvim')
  if tel then
    require('telescope.builtin').git_commits({
      attach_mappings = function()
        local actions = require('telescope.actions')
        local orig = actions.close
        actions.close = function(bufnr)
          orig(bufnr)
          popup.return_to_origin()
        end
        return true
      end,
    })
  end
end

function M.close_diffview()
  popup.close_all()
end

function M.open_gv_history(gv_cmd, title)
  return function()
    popup.save_origin()
    vim.cmd(gv_cmd)
    vim.defer_fn(function()
      local buf = vim.api.nvim_get_current_buf()
      if vim.bo[buf].filetype == 'gv' then
        local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
        vim.cmd('close!')
        popup.open_scratch(lines, {
          title    = title,
          filetype = 'git',
          keymaps = {
            {
              key  = '<CR>',
              desc = 'Show commit',
              action = function()
                local line = vim.api.nvim_get_current_line()
                local hash = line:match('%s(%x+)%s')
                    or line:match('[0-9a-f]{7,}')
                if hash then
                  popup.close_all()
                  vim.defer_fn(function()
                    M.show_commit(hash)
                  end, 50)
                end
              end,
            },
          },
        })
      end
    end, 200)
  end
end

return M
