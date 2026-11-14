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
local preview_win -- the window showing the preview buffer
local preview_id -- that buffer
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

-- A preview needs a real split. A hover or picker preview float can hold a
-- markdown buffer too, and splitting a float is not allowed.
local function real_win_for(bufnr)
  for _, win in ipairs(api.nvim_list_wins()) do
    if api.nvim_win_is_valid(win) and api.nvim_win_get_buf(win) == bufnr
        and api.nvim_win_get_config(win).relative == '' then
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

  -- Vellum centres its rendered text with a computed left margin. Start the
  -- text at column 0 instead, so copied lines have no centring indent.
  local render = require('vellum.render')
  if not render.__config_left_aligned then
    local original = render.render
    render.render = function(...)
      local text, rows, margin, anchors, shown = original(...)
      if margin and margin > 0 then
        for i = 1, #text do
          text[i] = text[i]:sub(margin + 1)
        end
        margin = 0
      end
      return text, rows, margin, anchors, shown
    end
    render.__config_left_aligned = true
  end

  -- Rendered wrap is visual only: keep each paragraph on one buffer line and
  -- let the window soft-wrap it, so a yank has no invented line breaks.
  local inline = require('vellum.inline')
  if not inline.__config_soft_wrap then
    local wrap_width -- the real content width, while a paragraph is unwrapped
    local original_wrap = inline.wrap
    inline.wrap = function(segs, width, key)
      if not key then return original_wrap(segs, width) end
      wrap_width = width
      local ok, out = pcall(original_wrap, segs, math.huge, key)
      wrap_width = nil
      if not ok then error(out) end
      return out
    end
    -- Pictures still size to the window, not to the unbroken line.
    local media = require('vellum.media')
    local original_image = media.image
    media.image = function(src, width)
      return original_image(src, math.min(width, wrap_width or width))
    end
    local original_display = inline.display
    inline.display = function(tex, width, key)
      return original_display(tex, math.min(width, wrap_width or width), key)
    end
    inline.__config_soft_wrap = true
  end

  -- Code panels hard-wrap long lines too. Render each source line unbroken and
  -- pad the shading back to the panel width, so a command copies as one line.
  local code = require('vellum.code')
  if not code.__config_soft_wrap then
    local original_panel = code.panel
    code.panel = function(text, lang, width, label, err)
      if err then return original_panel(text, lang, width, label, err) end
      local inner = math.max(1, width - 4)
      local widest = 0
      for _, line in ipairs(vim.split((text or ''):gsub('\t', '    '), '\n')) do
        widest = math.max(widest, api.nvim_strwidth(line))
      end
      if widest <= inner then return original_panel(text, lang, width, label, err) end
      local out = original_panel(text, lang, widest + 4, label, err)
      local bg = 'VellumCodeBg'
      local name = vim.fn.strcharpart(label or lang or '', 0, math.max(0, width - 4))
      out[1] = {
        { string.rep(' ', math.max(0, width - api.nvim_strwidth(name) - 2)), bg },
        { name, 'VellumCodeLabel' },
        { '  ', bg },
      }
      for i = 2, #out - 1 do
        local w = api.nvim_strwidth(out[i][2] and out[i][2][1] or '')
        out[i][3] = { string.rep(' ', math.max(0, inner - w) + 2), bg }
      end
      out[#out] = { { string.rep(' ', width), bg } }
      return out
    end
    code.__config_soft_wrap = true
  end

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
  preview_win, preview_id = nil, nil
  saved_opts, saved_view = nil, nil
  if package.loaded['vellum'] then
    pcall(require('vellum').close)
  end
end

-- A preview buffer left behind by an interrupted open keeps the
-- vellum://preview name busy, and the next open fails with E95. Such a buffer
-- has no window of its own, so it is safe to wipe.
local function drop_stale_preview()
  local stale = preview_buf()
  if stale and not win_for(stale) then
    pcall(api.nvim_buf_delete, stale, { force = true })
  end
end

-- Another buffer was opened in the preview window (explorer or picker jump).
-- Keep the new buffer, drop the preview, then apply the markdown view to it.
local show_preview -- defined below
local show_edit -- defined below

local function leave_preview_for(bufnr)
  local old_win = preview_win
  local target
  if old_win and api.nvim_win_is_valid(old_win) then
    -- Keep the new buffer in a real window before the preview window goes.
    target = api.nvim_open_win(bufnr, true, { split = 'left', win = old_win })
  end
  -- Close Vellum now, while old_win is still its window, so its own scheduled
  -- close cannot run after the next preview opens.
  if package.loaded['vellum'] then
    pcall(require('vellum').close)
  end
  if hidden_win and api.nvim_win_is_valid(hidden_win) then
    pcall(api.nvim_win_close, hidden_win, true)
  end
  if old_win and api.nvim_win_is_valid(old_win) then
    pcall(api.nvim_win_close, old_win, true)
  end
  hidden_win, src_buf, preview_win, preview_id = nil, nil, nil, nil
  saved_opts, saved_view = nil, nil
  if target and api.nvim_win_is_valid(target) then
    api.nvim_set_current_win(target)
  end
  if mode == 'preview' and api.nvim_buf_is_valid(bufnr)
      and vim.bo[bufnr].buftype == '' and is_markdown(bufnr) then
    vim.schedule(function()
      if api.nvim_buf_is_valid(bufnr) then
        show_preview(bufnr)
      end
    end)
  end
end

function show_preview(bufnr)
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
  -- Only a real split can be previewed. A markdown buffer shown in a hover or
  -- picker float must leave the current preview alone.
  if not real_win_for(bufnr) then
    return
  end
  if src_buf then
    if src_buf ~= bufnr and api.nvim_buf_is_valid(src_buf) and win_for(preview_buf()) then
      -- Another file is opening in a window of its own: return the old file to
      -- its window as the editable source, so the split layout stays as it is.
      show_edit(src_buf)
    else
      teardown()
    end
  end

  local src_win = real_win_for(bufnr)
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

  drop_stale_preview()
  if not pcall(M.ensure().open) then
    drop_stale_preview()
    if not pcall(M.ensure().open) then
      return
    end
  end
  local pbuf = preview_buf()
  local pwin = pbuf and win_for(pbuf)
  if not pwin then
    return
  end
  src_buf = bufnr
  preview_win, preview_id = pwin, pbuf
  -- Vellum pins the preview buffer. Allow :buffer/:e so an explorer or picker
  -- jump can replace it; the BufEnter autocmd below then leaves preview mode.
  vim.wo[pwin].winfixbuf = false
  -- One buffer line per rendered line: long lines wrap on screen only.
  vim.wo[pwin].wrap = true
  vim.wo[pwin].linebreak = true

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

function show_edit(bufnr)
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
  preview_win, preview_id = nil, nil
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

  -- A buffer opened from the explorer or picker replaces the preview in its
  -- window. Leave preview mode for that buffer instead of keeping it pinned.
  -- Entering an already-loaded markdown buffer (no FileType event) previews it.
  api.nvim_create_autocmd('BufEnter', {
    group = api.nvim_create_augroup('config_vellum', { clear = true }),
    callback = function(ev)
      if preview_win and ev.buf ~= preview_id and api.nvim_get_current_win() == preview_win then
        leave_preview_for(ev.buf)
        return
      end
      if ev.buf == preview_id then
        return
      end
      if mode ~= 'preview' or src_buf then
        return
      end
      if vim.bo[ev.buf].buftype ~= '' or not is_markdown(ev.buf) then
        return
      end
      if api.nvim_win_get_config(0).relative ~= '' then
        return
      end
      vim.schedule(function()
        if mode == 'preview' and not src_buf and api.nvim_buf_is_valid(ev.buf) then
          show_preview(ev.buf)
        end
      end)
    end,
  })
end

return M
