local M = {}

local popup = require('config.popup')

local HISTORY_DIR = vim.fn.stdpath('data') .. '/history'
local MAX_AGE_HOURS = 120

local function path_to_dir(abs_path)
  local safe = abs_path:gsub('[^%w./_-]', '_'):gsub('[/]', '%')
  return HISTORY_DIR .. '/' .. safe
end

local function now_ts()
  return os.date('%Y-%m-%d_%H%M%S')
end

local function fmt_ts(ts)
  return ts:gsub('_', ' '):gsub('(%d%d%d%d%-%d%d%-%d%d) (%d%d)(%d%d)(%d%d)', '%1 %2:%3:%4')
end

local function ts_to_unix(ts)
  local y, mo, d, h, mi, s = ts:match('(%d%d%d%d)-(%d%d)-(%d%d)_(%d%d)(%d%d)(%d%d)')
  if not y then return nil end
  return os.time({ year = y, month = mo, day = d, hour = h, min = mi, sec = s })
end

local function load_index(dir)
  local index_path = dir .. '/index.json'
  local f = io.open(index_path, 'r')
  if not f then return {} end
  local content = f:read('*a')
  f:close()
  if content == '' then return {} end
  local ok, data = pcall(vim.fn.json_decode, content)
  if ok and type(data) == 'table' and data.snapshots then
    return data.snapshots
  end
  return {}
end

local function save_index(dir, snapshots)
  if vim.fn.isdirectory(dir) == 0 then
    vim.fn.mkdir(dir, 'p')
  end
  local data = vim.fn.json_encode({ snapshots = snapshots })
  local f = io.open(dir .. '/index.json', 'w')
  if f then
    f:write(data)
    f:write('\n')
    f:close()
  end
end

local function expire_old(dir, snapshots)
  local cutoff = os.time() - (MAX_AGE_HOURS * 3600)
  local keep = {}
  local removed = {}
  for _, snap in ipairs(snapshots) do
    local t = ts_to_unix(snap.ts)
    if t and t >= cutoff then
      table.insert(keep, snap)
    else
      table.insert(removed, snap)
    end
  end
  for _, snap in ipairs(removed) do
    pcall(vim.fn.delete, dir .. '/' .. snap.ts)
  end
  return keep
end

function M.create_snapshot(bufnr, force)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  local path = vim.api.nvim_buf_get_name(bufnr)
  if path == '' then
    if force then
      vim.notify('Buffer must have a name to snapshot', vim.log.levels.WARN)
    end
    return
  end

  local dir = path_to_dir(path)
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local ts = now_ts()
  local snapshot_path = dir .. '/' .. ts

  if vim.fn.isdirectory(dir) == 0 then
    vim.fn.mkdir(dir, 'p')
  end

  local f_out = io.open(snapshot_path, 'w')
  if f_out then
    f_out:write(table.concat(lines, '\n'))
    if #lines > 0 then f_out:write('\n') end
    f_out:close()
  end

  local snapshots = load_index(dir)
  table.insert(snapshots, {
    ts = ts,
    size = vim.fn.getfsize(snapshot_path),
    lines = #lines,
  })

  snapshots = expire_old(dir, snapshots)
  save_index(dir, snapshots)
end

function M.create_manual_snapshot()
  M.create_snapshot(nil, true)
  vim.notify('Snapshot created at ' .. os.date('%H:%M:%S'), vim.log.levels.INFO)
end

local function read_file_text(path)
  local f = io.open(path, 'r')
  if not f then return '' end
  local content = f:read('*a')
  f:close()
  return content or ''
end

local function read_file_lines(path)
  local text = read_file_text(path)
  if text == '' then return {} end
  local lines = vim.split(text, '\n', { plain = true })
  if text:sub(-1) == '\n' and #lines > 0 then
    lines[#lines] = nil
  end
  return lines
end

local function render_diff(diff)
  if not diff or #diff == 0 then return nil end
  local result = {}
  for _, hunk in ipairs(diff) do
    if hunk.type == 'range' then
      table.insert(result, string.format('@@ -%d,%d +%d,%d @@', hunk.first_old_line or 0, hunk.old_count or 1, hunk.first_new_line or 0, hunk.new_count or 1))
    elseif hunk.type == 'delete' then
      for _, line in ipairs(hunk.lines or {}) do table.insert(result, '-' .. line) end
    elseif hunk.type == 'add' then
      for _, line in ipairs(hunk.lines or {}) do table.insert(result, '+' .. line) end
    elseif hunk.type == 'equal' then
      for _, line in ipairs(hunk.lines or {}) do table.insert(result, ' ' .. line) end
    end
  end
  return result
end

function M.show_history()
  local path = vim.api.nvim_buf_get_name(0)
  if path == '' then
    vim.notify('Buffer has no file path', vim.log.levels.WARN)
    return
  end

  local dir = path_to_dir(path)
  local snapshots = load_index(dir)

  if #snapshots == 0 then
    vim.notify('No snapshots for this file', vim.log.levels.INFO)
    return
  end

  local cur_wordcount = vim.fn.wordcount()
  local cur_bytes = cur_wordcount.bytes or 0

  local lines = {}
  for i, snap in ipairs(snapshots) do
    local label = string.format('%d: %s  |  %d lines  |  %d bytes',
      i, fmt_ts(snap.ts), snap.lines or 0, snap.size or 0)
    table.insert(lines, label)
  end

  local keymaps = {
    {
      key = '<CR>',
      action = function()
        local cursor = vim.api.nvim_win_get_cursor(0)
        local idx = cursor[1]
        if idx < 1 or idx > #snapshots then return end
        popup.close_all()
        local snap = snapshots[idx]
        local snapshot_path = dir .. '/' .. snap.ts
        local old_text = read_file_text(snapshot_path)
        local current_text = table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), '\n')
        local diff = render_diff(vim.diff(old_text, current_text, { result_type = 'lua' }))
        if not diff then
          vim.notify('No differences with current version', vim.log.levels.INFO)
          return
        end
        table.insert(diff, 1, string.rep('-', 60))
        table.insert(diff, 1, 'Diff: ' .. path)
        popup.open_scratch(diff, { title = ' Diff vs Current ', filetype = 'diff' })
      end,
      desc = 'Show diff vs current',
    },
    {
      key = 'r',
      action = function()
        local cursor = vim.api.nvim_win_get_cursor(0)
        local idx = cursor[1]
        if idx < 1 or idx > #snapshots then return end
        local snap = snapshots[idx]
        local snapshot_path = dir .. '/' .. snap.ts
        local lines = read_file_lines(snapshot_path)
        popup.close_all()
        vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
        vim.cmd('write')
        vim.notify('Restored snapshot from ' .. fmt_ts(snap.ts), vim.log.levels.INFO)
      end,
      desc = 'Restore this version',
    },
    {
      key = 'd',
      action = function()
        local cursor = vim.api.nvim_win_get_cursor(0)
        local idx = cursor[1]
        if idx < 2 or idx > #snapshots then
          vim.notify('Select a version after the first to compare', vim.log.levels.INFO)
          return
        end
        popup.close_all()
        local snap_old = snapshots[idx - 1]
        local snap_new = snapshots[idx]
        local old_text = read_file_text(dir .. '/' .. snap_old.ts)
        local new_text = read_file_text(dir .. '/' .. snap_new.ts)
        local diff = render_diff(vim.diff(old_text, new_text, { result_type = 'lua' }))
        if not diff then
          vim.notify('No differences', vim.log.levels.INFO)
          return
        end
        table.insert(diff, 1, string.rep('-', 60))
        table.insert(diff, 1, 'Diff: ' .. snap_old.ts .. ' -> ' .. snap_new.ts)
        popup.open_scratch(diff, { title = ' Snapshot Diff ', filetype = 'diff' })
      end,
      desc = 'Diff two adjacent snapshots',
    },
  }

  popup.open_scratch(lines, {
    title = ' Local History: ' .. vim.fn.expand('%:t'),
    filetype = 'lua',
    keymaps = keymaps,
  })
end

function M.list_files()
  if vim.fn.isdirectory(HISTORY_DIR) == 0 then
    vim.notify('No tracked files', vim.log.levels.INFO)
    return
  end

  local dirs = vim.fn.readdir(HISTORY_DIR)
  if #dirs == 0 then
    vim.notify('No tracked files', vim.log.levels.INFO)
    return
  end

  local lines = {}
  for _, d in ipairs(dirs) do
    local index_path = HISTORY_DIR .. '/' .. d .. '/index.json'
    if vim.fn.filereadable(index_path) == 1 then
      local snapshots = load_index(HISTORY_DIR .. '/' .. d)
      if #snapshots > 0 then
        local last_ts = snapshots[#snapshots].ts
        local path_name = d:gsub('%', '/'):gsub('_', ' ')
        table.insert(lines, string.format('  %3d snapshots  |  %s  |  %s',
          #snapshots, fmt_ts(last_ts), path_name))
      end
    end
  end

  if #lines == 0 then
    vim.notify('No tracked files', vim.log.levels.INFO)
    return
  end

  table.insert(lines, 1, '')
  table.insert(lines, 1, string.format('Tracked files with snapshots (max %dh retention):', MAX_AGE_HOURS))

  popup.open_scratch(lines, { title = ' All Tracked Files ', filetype = 'lua' })
end

function M.setup()
  local group = vim.api.nvim_create_augroup('LocalHistorySnapshot', { clear = true })
  vim.api.nvim_create_autocmd('BufWritePost', {
    group = group,
    pattern = '*',
    callback = function(args)
      if args.file and vim.fn.isdirectory(args.file) == 0 then
        pcall(M.create_snapshot, args.buf, false)
      end
    end,
  })

  _G.LocalHistory = {
    create_manual_snapshot = M.create_manual_snapshot,
    show_local_history = M.show_history,
    list_all_tracked_files = M.list_files,
  }
end

return M
