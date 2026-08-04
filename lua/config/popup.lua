local M = {}

M.config = {
  width_ratio  = 0.80,
  height_ratio = 0.60,
  border       = 'rounded',
  style        = 'minimal',
  zindex       = 50,
}

M.make_win_config = function(opts)
  opts = opts or {}

  local width_ratio  = opts.width_ratio  or M.config.width_ratio
  local height_ratio = opts.height_ratio or M.config.height_ratio
  local border       = opts.border       or M.config.border

  local total_w = vim.o.columns
  local total_h = vim.o.lines

  local width  = math.floor(total_w * width_ratio)
  local height = math.floor(total_h * height_ratio)
  local row    = math.floor((total_h - height) / 2)
  local col    = math.floor((total_w - width)  / 2)

  local cfg = {
    relative  = 'editor',
    border    = border,
    style     = M.config.style,
    width     = width,
    height    = height,
    row       = row,
    col       = col,
    zindex    = opts.zindex or M.config.zindex,
  }

  if opts.title and vim.fn.has('nvim-0.9') == 1 then
    cfg.title     = ' ' .. opts.title .. ' '
    cfg.title_pos = 'center'
  end

  return cfg
end

M._origin = {
  bufnr  = nil,
  winid  = nil,
  cursor = nil,
}

M.save_origin = function()
  M._origin.winid  = vim.api.nvim_get_current_win()
  M._origin.bufnr  = vim.api.nvim_get_current_buf()
  M._origin.cursor = vim.api.nvim_win_get_cursor(0)
end

M.return_to_origin = function()
  local o = M._origin
  if o.winid and vim.api.nvim_win_is_valid(o.winid) then
    vim.api.nvim_set_current_win(o.winid)
    if o.cursor then
      pcall(vim.api.nvim_win_set_cursor, o.winid, o.cursor)
    end
  end
end

M._open_popups = {}

M.register_popup = function(winid, name)
  if winid and vim.api.nvim_win_is_valid(winid) then
    table.insert(M._open_popups, { winid = winid, name = name or 'popup' })
  end
end

M.close_all = function()
  local closed = 0
  for _, popup in ipairs(M._open_popups) do
    if popup.winid and vim.api.nvim_win_is_valid(popup.winid) then
      pcall(vim.api.nvim_win_close, popup.winid, true)
      closed = closed + 1
    end
  end
  M._open_popups = {}

  pcall(function()
    for _, win in ipairs(vim.api.nvim_list_wins()) do
      local buf = vim.api.nvim_win_get_buf(win)
      local ft  = vim.api.nvim_buf_get_option(buf, 'filetype')
      if vim.tbl_contains({
        'fugitive', 'fugitiveblame', 'git',
      }, ft) then
        pcall(vim.api.nvim_win_close, win, true)
        closed = closed + 1
      end
    end
  end)

  M.return_to_origin()

  if closed > 0 then
    vim.notify(
      string.format('[popup] Closed %d popup(s)', closed),
      vim.log.levels.INFO
    )
  end
end

M.open_scratch = function(lines, opts)
  opts = opts or {}

  M.save_origin()

  local bufnr = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
  vim.api.nvim_buf_set_option(bufnr, 'modifiable', false)
  vim.api.nvim_buf_set_option(bufnr, 'bufhidden',  'wipe')
  if opts.filetype then
    vim.api.nvim_buf_set_option(bufnr, 'filetype', opts.filetype)
  end

  local win_config = M.make_win_config(opts)
  local winid = vim.api.nvim_open_win(bufnr, true, win_config)

  vim.api.nvim_win_set_option(winid, 'wrap',         false)
  vim.api.nvim_win_set_option(winid, 'cursorline',   true)
  vim.api.nvim_win_set_option(winid, 'signcolumn',   'no')
  vim.api.nvim_win_set_option(winid, 'winhighlight',
    'Normal:NormalFloat,FloatBorder:FloatBorder')

  M.register_popup(winid, opts.title or 'popup')

  local close_keys = { 'q', '<Esc>' }
  for _, key in ipairs(close_keys) do
    vim.keymap.set('n', key, function()
      M.close_all()
    end, { buffer = bufnr, noremap = true, silent = true,
           desc = 'Close popup and return to origin' })
  end

  if opts.keymaps then
    for _, km in ipairs(opts.keymaps) do
      vim.keymap.set(km.mode or 'n', km.key, km.action,
        { buffer = bufnr, noremap = true, silent = true, desc = km.desc })
    end
  end

  return winid, bufnr
end

return M
