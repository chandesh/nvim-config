-- ~/.config/nvim/lua/config/smear_cursor.lua
-- =============================================================================
-- Smear Cursor — animated cursor trail (sphamba/smear-cursor.nvim)
-- =============================================================================
local M = {}

function M.setup()
  local ok, smear = pcall(require, 'smear_cursor')
  if not ok then
    vim.notify('smear-cursor.nvim not found. Run install.sh / :PluginInstall', vim.log.levels.WARN)
    return
  end

  smear.setup({
    -- Smear cursor when switching buffers or windows.
    smear_between_buffers = true,

    -- Smear cursor when moving within line or to neighbor lines.
    smear_between_neighbor_lines = true,

    -- Draw the smear in buffer space instead of screen space when scrolling
    scroll_buffer_space = true,

    -- Set to `true` if your font supports legacy computing symbols (block unicode symbols).
    legacy_computing_symbols_support = false,

    -- Smear cursor in insert mode.
    smear_insert_mode = true,
  })
end

return M