-- ~/.config/nvim/lua/config/snacks.lua
-- =============================================================================
-- Snacks.nvim — unified QoL modules (picker, dashboard, indent, terminal, ...)
-- Loaded synchronously in init.lua. Replaces telescope, alpha, which-key,
-- indent-blankline, noice, nvim-notify, dressing, trouble, neoscroll, undotree,
-- neogit/diffview/fugitive/gv/git-conflict, goto-preview, aerial, zen-mode, twilight.
-- =============================================================================

local M = {}

local icons = require('config.icons')

function M.setup()
  local Snacks = require('snacks')

  -- ── Dashboard footer (ported from former alpha.nvim) ─────────────────────
  local function dashboard_footer()
    local count = 0
    local pack_dir = vim.fn.stdpath("config") .. "/pack"
    for _, bundle in ipairs(vim.fn.readdir(pack_dir)) do
      for _, type in ipairs({ "start", "opt" }) do
        local type_dir = pack_dir .. "/" .. bundle .. "/" .. type
        if vim.fn.isdirectory(type_dir) == 1 then
          for _, plugin in ipairs(vim.fn.readdir(type_dir)) do
            if vim.fn.isdirectory(type_dir .. "/" .. plugin) == 1 then
              count = count + 1
            end
          end
        end
      end
    end
    local v = vim.version()
    local dt = os.date("%d-%m-%Y")
    return string.format(
      " %s   %d plugins   v%d.%d.%d   ⚡ Ready",
      dt, count, v.major, v.minor, v.patch
    )
  end

  local function restore_session()
    vim.cmd("packadd auto-session")
    local ok, as = pcall(require, "auto-session")
    if ok then
      as.setup({
        auto_restore = false,
        suppressed_dirs = { "~/", "~/Dev/", "~/Downloads", "~/Documents", "~/Desktop/" },
      })
      vim.cmd("AutoSession restore")
    end
  end

  -- ── Dashboard keys (using config.icons.dashboard) ─────────────────────────
  local dashboard_keys = {
    {
      icon = icons.dashboard.find_file .. " ",
      key = "f",
      desc = "Find File",
      action = function() Snacks.picker.files() end,
    },
    {
      icon = icons.dashboard.new_file .. " ",
      key = "n",
      desc = "New File",
      action = function() vim.cmd("ene") end,
    },
    {
      icon = icons.dashboard.recent_files .. " ",
      key = "r",
      desc = "Recent Files",
      action = function() Snacks.picker.recent() end,
    },
    {
      icon = icons.dashboard.live_grep .. " ",
      key = "g",
      desc = "Find Text",
      action = function() Snacks.picker.grep() end,
    },
    {
      icon = icons.dashboard.session .. " ",
      key = "w",
      desc = "Restore Session",
      action = restore_session,
    },
    {
      icon = icons.dashboard.config .. " ",
      key = "c",
      desc = "Config",
      action = function() vim.cmd("e $MYVIMRC") end,
    },
    {
      icon = icons.dashboard.quit .. " ",
      key = "q",
      desc = "Quit",
      action = function() vim.cmd("qa") end,
    },
  }

  -- ── Dashboard header (NEOVIM wordmark from former alpha.nvim) ─────────────
  local header = [[
  ███╗   ██╗███████╗ ██████╗  ██╗   ██╗ ██╗ ███╗   ███╗
  ████╗  ██║██╔════╝██╔═══██╗ ██║   ██║ ██║ ████╗ ████║
  ██╔██╗ ██║█████╗  ██║   ██║ ██║   ██║ ██║ ██╔████╔██║
  ██║╚██╗██║██╔══╝  ██║   ██║ ╚██╗ ██╔╝ ██║ ██║╚██╔╝██║
  ██║ ╚████║███████╗╚██████╔╝  ╚████╔╝  ██║ ██║ ╚═╝ ██║
  ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝   ╚═╝ ╚═╝     ╚═╝
            ⚡ Build • Test • Deploy
]]

  Snacks.setup({
    bigfile = { enabled = true },
    bufdelete = { enabled = true },
    dashboard = {
      enabled = true,
      preset = {
        header = header,
        keys = dashboard_keys,
      },
      sections = {
        { section = "header" },
        { section = "keys", gap = 1, padding = 1 },
        {
          align = "center",
          padding = { 1, 2 },
          text = { { dashboard_footer(), hl = "footer" } },
        },
      },
    },
    dim = { enabled = true },
    explorer = { enabled = true, replace_netrw = true },
    indent = { enabled = true },
    input = { enabled = true },
    lazygit = { enabled = true },
    notifier = { enabled = true, timeout = 3000 },
    picker = { enabled = true },
    quickfile = { enabled = true },
    rename = { enabled = true },
    scope = { enabled = true },
    scroll = { enabled = true },
    terminal = { enabled = true },
    toggle = { enabled = true },
    words = { enabled = true },
    zen = { enabled = true },
  })
end

return M
