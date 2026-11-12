-- ~/.config/nvim/lua/config/vellum.lua
-- =============================================================================
-- Markdown view. Default is Vellum's read-only side preview. <leader>mv
-- switches to the editable source with render-markdown, and back.
-- auto_open stays false; this module owns when the preview opens, so the
-- toggle cannot fight Vellum's own opener.
-- =============================================================================

local M = {}

local loaded = false
local mode = 'preview'
local markdown_fts = { markdown = true, md = true, mdx = true, quarto = true, rmd = true }

local function is_markdown(bufnr)
  return markdown_fts[vim.bo[bufnr].filetype] == true
end

local function preview_buf()
  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_valid(bufnr)
        and vim.api.nvim_buf_get_name(bufnr):find('vellum://preview', 1, true) then
      return bufnr
    end
  end
end

local function win_for(bufnr)
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_win_is_valid(win) and vim.api.nvim_win_get_buf(win) == bufnr then
      return win
    end
  end
end

local function markdown_buf()
  local current = vim.api.nvim_get_current_buf()
  if is_markdown(current) then
    return current
  end
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local bufnr = vim.api.nvim_win_get_buf(win)
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

local function show_preview()
  if package.loaded['render-markdown'] then
    require('render-markdown').disable()
  end
  local vellum = M.ensure()
  vellum.open()
  local preview = preview_buf()
  local win = preview and win_for(preview)
  if win then
    vim.api.nvim_set_current_win(win)
  end
end

local function show_edit(bufnr)
  if preview_buf() then
    M.ensure().close()
  end
  require('config.markdown').setup()
  require('render-markdown').enable()
  local win = win_for(bufnr)
  if win then
    vim.api.nvim_set_current_win(win)
  end
end

function M.apply(bufnr)
  bufnr = bufnr or markdown_buf()
  -- Hover and picker previews are also markdown. Only a real file buffer
  -- should open the side preview or steal focus.
  if not bufnr or not vim.api.nvim_buf_is_valid(bufnr) or not is_markdown(bufnr) then
    return
  end
  if vim.bo[bufnr].buftype ~= '' then
    return
  end
  if mode == 'preview' then
    show_preview()
  else
    show_edit(bufnr)
  end
end

function M.toggle_mode()
  local bufnr = markdown_buf()
  if not bufnr then
    vim.notify('Markdown view toggle works in a markdown buffer', vim.log.levels.INFO)
    return
  end
  mode = mode == 'preview' and 'edit' or 'preview'
  M.apply(bufnr)
end

function M.setup()
  vim.keymap.set('n', '<leader>mv', function()
    M.toggle_mode()
  end, { desc = 'Toggle markdown view' })
end

return M
