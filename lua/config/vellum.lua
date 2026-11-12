-- ~/.config/nvim/lua/config/vellum.lua
-- =============================================================================
-- Markdown view. A markdown file opens as Vellum's read-only preview in its
-- own window. The source window is tucked away as a hidden float so the
-- preview fills the same place instead of sitting beside it. <leader>mv, q
-- and Esc return to the editable source with render-markdown, and back.
-- auto_open stays false: this module owns when the preview opens.
-- =============================================================================

local api = vim.api

local M = {}

local loaded = false
local mode = 'preview'
local src_buf -- the markdown buffer being previewed
local hidden_win -- its window, turned into a hidden float while previewing
local saved_opts -- the source window's local options, restored on the way back
local saved_view -- its cursor and scroll position
local markdown_fts = { markdown = true, md = true, mdx = true, quarto = true, rmd = true }

-- The preview window has its own window-local settings; a window split from
-- it would inherit them, so the source's settings are put back explicitly.
local WIN_OPTS = {
  'number', 'relativenumber', 'signcolumn', 'foldcolumn', 'foldenable',
  'wrap', 'linebreak', 'breakindent', 'list', 'spell', 'cursorline',
  'cursorcolumn', 'colorcolumn', 'winhighlight', 'winfixbuf', 'winbar',
  'statuscolumn', 'scrolloff', 'sidescrolloff', 'conceallevel', 'concealcursor',
}

local function save_window(win)
  local opts = {}
  for _, name in ipairs(WIN_OPTS) do
    local ok, value = pcall(api.nvim_get_option_value, name, { win = win })
    if ok then
      opts[name] = value
    end
  end
  return opts, {
    cursor = api.nvim_win_get_cursor(win),
    view = api.nvim_win_call(win, vim.fn.winsaveview),
  }
end

local function restore_window(win, opts, view)
  for name, value in pairs(opts or {}) do
    pcall(api.nvim_set_option_value, name, value, { win = win })
  end
  if view then
    pcall(api.nvim_win_set_cursor, win, view.cursor)
    pcall(api.nvim_win_call, win, function()
      vim.fn.winrestview(view.view)
    end)
  end
end

local function is_markdown(bufnr)
  return markdown_fts[vim.bo[bufnr].filetype] == true
end

local function preview_buf()
  for _, bufnr in ipairs(api.nvim_list_bufs()) do
    if api.nvim_buf_is_valid(bufnr)
        and api.nvim_buf_get_name(bufnr):find('vellum://preview', 1, true) then
      return bufnr
    end
  end
end

local function win_for(bufnr)
  for _, win in ipairs(api.nvim_list_wins()) do
    if api.nvim_win_is_valid(win) and api.nvim_win_get_buf(win) == bufnr then
      return win
    end
  end
end

local function current_markdown()
  local current = api.nvim_get_current_buf()
  if is_markdown(current) then
    return current
  end
  for _, win in ipairs(api.nvim_list_wins()) do
    local bufnr = api.nvim_win_get_buf(win)
    if is_markdown(bufnr) then
      return bufnr
    end
  end
end

function M.ensure()
  if loaded then
    return require('vellum')
  end

  vim.cmd('packadd vellum.nvim')
  local vellum = require('vellum')
  vellum.setup({
    split = 'right',
    max_width = 100,
    auto_open = false,
  })
  loaded = true
  return vellum
end

function M.mode()
  return mode
end

-- Drop the preview and the hidden source window without showing the source.
local function teardown()
  if hidden_win and api.nvim_win_is_valid(hidden_win) then
    pcall(api.nvim_win_close, hidden_win, true)
  end
  hidden_win = nil
  src_buf = nil
  saved_opts, saved_view = nil, nil
  if package.loaded['vellum'] then
    pcall(require('vellum').close)
  end
end

local function show_preview(bufnr)
  bufnr = bufnr or current_markdown()
  if not bufnr then
    return
  end
  if src_buf == bufnr then
    local win = win_for(preview_buf())
    if win then
      api.nvim_set_current_win(win)
    end
    return
  end
  if src_buf then
    teardown()
  end

  local src_win = win_for(bufnr)
  if not src_win then
    return
  end
  api.nvim_set_current_win(src_win)

  if package.loaded['render-markdown'] then
    local rm = require('render-markdown')
    if rm.get() then
      rm.disable()
    end
  end

  M.ensure().open()
  local pbuf = preview_buf()
  local pwin = pbuf and win_for(pbuf)
  if not pwin then
    return
  end
  src_buf = bufnr

  -- Turn the source window into a hidden float: win_findbuf still reports it,
  -- so Vellum keeps following it, but the preview gets the whole area.
  saved_opts, saved_view = save_window(src_win)
  local ok = pcall(api.nvim_win_set_config, src_win, {
    relative = 'editor',
    width = 1,
    height = 1,
    row = 0,
    col = 0,
    hide = true,
  })
  if ok then
    hidden_win = src_win
  end

  -- Vellum's own q map closes the preview; here q and Esc go back to edit.
  for _, lhs in ipairs({ 'q', '<Esc>' }) do
    vim.keymap.set('n', lhs, function()
      M.use_edit_mode()
    end, { buffer = pbuf, desc = 'Edit markdown source' })
  end

  api.nvim_set_current_win(pwin)
end

local function show_edit(bufnr)
  bufnr = bufnr or src_buf or current_markdown()
  if not bufnr or not api.nvim_buf_is_valid(bufnr) then
    return
  end

  local pwin = win_for(preview_buf())
  local target
  if pwin then
    -- Give the source a visible window before the hidden one goes away,
    -- otherwise Vellum closes the preview as an orphan.
    target = api.nvim_open_win(bufnr, true, { split = 'left', win = pwin })
  elseif hidden_win and api.nvim_win_is_valid(hidden_win) then
    target = api.nvim_open_win(bufnr, true, { split = 'left' })
  end
  if hidden_win and api.nvim_win_is_valid(hidden_win) then
    pcall(api.nvim_win_close, hidden_win, true)
  end
  hidden_win = nil
  src_buf = nil
  if pwin and package.loaded['vellum'] then
    pcall(require('vellum').close)
  end
  if target and api.nvim_win_is_valid(target) then
    restore_window(target, saved_opts, saved_view)
    api.nvim_set_current_win(target)
  end
  saved_opts, saved_view = nil, nil

  require('config.markdown').setup()
  require('render-markdown').enable()
end

function M.apply(bufnr)
  bufnr = bufnr or current_markdown()
  -- Hover and picker previews are also markdown. Only a real file buffer
  -- should open the preview or steal focus.
  if not bufnr or not api.nvim_buf_is_valid(bufnr) or not is_markdown(bufnr) then
    return
  end
  if vim.bo[bufnr].buftype ~= '' then
    return
  end
  if mode == 'preview' then
    show_preview(bufnr)
  else
    show_edit(bufnr)
  end
end

function M.use_preview_mode()
  local bufnr = src_buf or current_markdown()
  if not bufnr then
    vim.notify('Markdown view works in a markdown buffer', vim.log.levels.INFO)
    return
  end
  mode = 'preview'
  show_preview(bufnr)
end

function M.use_edit_mode()
  local bufnr = src_buf or current_markdown()
  if not bufnr then
    vim.notify('Markdown view works in a markdown buffer', vim.log.levels.INFO)
    return
  end
  mode = 'edit'
  show_edit(bufnr)
end

function M.toggle_mode()
  if mode == 'preview' then
    M.use_edit_mode()
  else
    M.use_preview_mode()
  end
end

function M.setup()
  vim.keymap.set('n', '<leader>mv', function()
    M.toggle_mode()
  end, { desc = 'Toggle markdown view' })
end

return M
