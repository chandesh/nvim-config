-- ~/.config/nvim/lua/config/noice.lua
-- =============================================================================
-- Floating commandline (top-center) via noice.nvim — cmdline-only mode.
-- Snacks keeps input/notifier/dashboard/picker/explorer; noice handles only
-- `:` / `/` cmdline + popupmenu so there is no double-handling.
-- =============================================================================

local M = {}

function M.setup()
  local ok_cmd, _ = pcall(vim.cmd, "packadd noice.nvim")
  if not ok_cmd then
    return
  end
  pcall(vim.cmd, "packadd nui.nvim")

  local ok, noice = pcall(require, "noice")
  if not ok then
    return
  end

  noice.setup({
    cmdline = {
      enabled = true,
      view = "cmdline_popup",
    },
    popupmenu = {
      enabled = true,
      backend = "nui",
    },
    messages = {
      enabled = false,
    },
    notify = {
      enabled = false,
    },
    lsp = {
      progress = { enabled = false },
      hover = { enabled = false },
      signature = { enabled = false },
      override = {},
    },
    presets = {
      bottom_search = true,
      command_palette = true,
      long_message_to_split = false,
      inc_rename = false,
      lsp_doc_border = false,
    },
    views = {
      cmdline_popup = {
        position = { row = "15%", col = "50%" },
        size = { width = 60, height = "auto" },
        border = { style = "rounded" },
      },
    },
    routes = {
      -- Keep macro/search-count noise out of the float, same as backup
      {
        filter = {
          event = "msg_show",
          any = {
            { find = "%d+L, %d+B" },
            { find = "; after #%d+" },
            { find = "; before #%d+" },
          },
        },
        view = "mini",
      },
    },
  })
end

return M
