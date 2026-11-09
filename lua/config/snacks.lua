-- ~/.config/nvim/lua/config/snacks.lua
-- =============================================================================
-- Snacks.nvim — unified QoL modules (picker, dashboard, indent, terminal, ...)
-- Loaded synchronously in init.lua. Replaces telescope, alpha,
-- indent-blankline, noice, nvim-notify, dressing, trouble, neoscroll, undotree,
-- neogit/diffview/fugitive/gv/git-conflict, goto-preview, aerial, zen-mode, twilight.
-- which-key is kept as its own plugin (see ui.lua).
-- =============================================================================

local M = {}

local icons = require('config.icons')

local session_loaded = false

-- Auto-session is opt. Dashboard `w` and <leader>wr/<leader>ws all call this,
-- so the setup table lives in exactly one place.
function M.ensure_session()
  if session_loaded then return true end
  vim.cmd('packadd auto-session')
  local ok, auto_session = pcall(require, 'auto-session')
  if ok then
    auto_session.setup({
      auto_restore = false,
      suppressed_dirs = { "~/", "~/Dev/", "~/Downloads", "~/Documents", "~/Desktop/" },
    })
    session_loaded = true
  end
  return ok
end

function M.packadd_themes()
  vim.cmd('packadd tokyonight.nvim')
  vim.cmd('packadd catppuccin')
end

function M.setup()
  local Snacks = require('snacks')

  -- Keep smooth scrolling off; the scroll module itself stays enabled.
  vim.g.snacks_animate_scroll = false

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
    if M.ensure_session() then
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

  -- ── Dashboard header (centered Unicode art; equal-width pad is intentional) ─
  local header = [[

                        ⡀                       
                      ⣴⣿⣿⣷⡄                     
                      ⠹⢿⣿⠿⠁                     
                        ⡇                       
        ⢀⣤⣴⣶⣶⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⣶⣶⣤⣄        
      ⢀⣴⣿⣿⠿⠛⠛⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠙⠛⠻⢿⣿⣷⣄      
     ⢀⣿⣿⡟⠁                             ⠙⣿⣿⣇     
     ⢸⣿⣿      ⢀⣀⣀              ⢀⣀⣀      ⢸⣿⣿     
     ⣿⣿⡇   ⢀⣴⣾⠿⠿⠿⢿⣷⣄        ⢀⣴⣿⠿⠿⠿⢿⣶⣄    ⣿⣿⡇    
 ⣴⣾⣷⣦⣿⣿⡇   ⣾⡿⠁⢀⣤⣄ ⠙⣿⣇      ⢀⣿⡟⠁⢀⣤⣄ ⠹⣿⡆   ⣿⣿⣧⣶⣿⣶⡄
⢸⣿⣿⣿⣿⣿⣿⡇   ⣿⡇ ⢸⣿⣿⠇ ⣿⣿      ⢸⣿⡇ ⢿⣿⣿  ⣿⡇   ⣿⣿⣿⣿⣿⣿⣿
⢸⣿⣿⣿⣿⣿⣿⡇   ⠹⣿⣄⡀  ⣀⣴⣿⠃       ⢻⣷⣄⡀  ⣀⣼⡿⠁   ⣿⣿⣿⣿⣿⣿⣿
⢸⣿⣿⣿⣿⣿⣿⡇    ⠈⠛⠿⠿⠿⠿⠛⠁         ⠙⠻⠿⠿⠿⠟⠋     ⣿⣿⣿⣿⣿⣿⣿
⢸⣿⣿⣿⣿⣿⣿⡇      ⢀⡀                 ⢀⡀      ⣿⣿⣿⣿⣿⣿⣿
⠈⢿⣿⣿⡿⣿⣿⡇      ⠘⣿⣄               ⣠⣿⠃      ⣿⣿⡿⣿⣿⣿⠏
  ⠈⠁ ⣿⣿⡇       ⠈⠻⣷⣄⡀         ⢀⣠⣾⠟⠁       ⣿⣿⡇ ⠉  
     ⢹⣿⣷         ⠈⠙⠻⢷⣦⣤⣤⣀⣤⣤⣴⡾⠟⠋⠁        ⢰⣿⣿⠁    
     ⠘⣿⣿⣆              ⠉⠉⠉             ⢀⣾⣿⡟     
      ⠙⢿⣿⣷⣤⣀⣀                      ⢀⣀⣠⣴⣿⣿⠟⠁     
        ⠙⠿⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠿⠟⠁       
             ⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠁            
⚡ Build • Test • Deploy]]
  Snacks.setup({
    bigfile = { enabled = true },
    bufdelete = { enabled = true },
    -- Global animation engine settings (easing/fps defaults for scroll,
    -- indent, dim and any custom Snacks.animate() calls)
    animate = {
      fps = 60,
    },
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
    dim = {
      enabled = true,
      animate = {
        duration = { step = 20, total = 400 },
        easing = "outCubic",
      },
    },
    explorer = { enabled = true, replace_netrw = true },
    gitbrowse = { enabled = true },
    image = {
      enabled = true,
      doc = {
        enabled = true,
        inline = false,
        float = true,
      },
    },
    indent = {
      enabled = true,
      animate = {
        enabled = false,
      },
    },
    input = { enabled = true },
    lazygit = { enabled = true },
    notifier = { enabled = true, timeout = 3000 },
    picker = {
      enabled = true,
      sources = {
        explorer = {
          hidden = true, -- show hidden (dot) files in the explorer
        },
      },
      -- Scroll the preview (the searched file) with Ctrl+d / Ctrl+u,
      -- matching the previous Telescope behaviour instead of scrolling the result list.
      win = {
        input = {
          keys = {
            ["<c-d>"] = { "preview_scroll_down", mode = { "i", "n" } },
            ["<c-u>"] = { "preview_scroll_up", mode = { "i", "n" } },
          },
        },
        list = {
          keys = {
            ["<c-d>"] = { "preview_scroll_down", mode = { "i", "n" } },
            ["<c-u>"] = { "preview_scroll_up", mode = { "i", "n" } },
          },
        },
      },
    },
    quickfile = { enabled = true },
    rename = { enabled = true },
    scope = { enabled = true },
    scroll = {
      enabled = true,
    },
    -- Global floating window defaults. Applies to every snacks float
    -- (picker, notifier, dashboard, terminal, input, ...). Named styles
    -- registered below are referenced via `style = "..."`.
    win = {
      backdrop = 60,
      border = "rounded",
      footer_keys = false, -- disabled: show key hints (e.g. "q" to close) in float footer
      resize = true,
    },
    terminal = { enabled = true },
    toggle = { enabled = true },
    words = { enabled = true },
    zen = { enabled = true },
  })

  -- Custom window style used by config.popup for git hunks & scratch popups.
  -- Registered after setup so it overrides the default `float` style.
  Snacks.config.style("popup_large", {
    position = "float",
    border = "rounded",
    backdrop = 60,
    title_pos = "center",
    width = 0.7,
    height = 0.5,
    resize = true,
  })
end

return M
