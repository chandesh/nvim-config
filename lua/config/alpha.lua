-- ~/.config/nvim/lua/config/alpha.lua
-- Dashboard setup — MUST load synchronously before VimEnter opens buffers
local alpha = require('alpha')
local dashboard = require('alpha.themes.dashboard')

-- ===== Color palette (GitHub octocat green / blue / purple) =====
local colors = {
  green  = "#7ee787",
  blue   = "#58a6ff",
  purple = "#bc8cff",
  grey   = "#8b949e",
  white  = "#c9d1d9",
}

vim.api.nvim_set_hl(0, "AlphaHeader",   { fg = colors.green,  bold = true })
vim.api.nvim_set_hl(0, "AlphaSubtitle",{ fg = colors.blue,   italic = true })
vim.api.nvim_set_hl(0, "AlphaButtons", { fg = colors.white })
vim.api.nvim_set_hl(0, "AlphaShortcut",{ fg = colors.green,  bold = true })
vim.api.nvim_set_hl(0, "AlphaFooter",  { fg = colors.purple, italic = true })

-- ===== Header: NEOVIM wordmark + original tagline (kept as-is) =====
dashboard.section.header.val = {
  "                                                     ",
  "  ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗ ",
  "  ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║ ",
  "  ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║ ",
  "  ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║ ",
  "  ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║ ",
  "  ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝ ",
  "                                                     ",
  "            ⚡ Build • Test • Deploy                 ",
  "                                                     ",
}
dashboard.section.header.opts = { hl = "AlphaHeader", position = "center" }

-- ===== Buttons: matches the image's menu (icon, label, keys) =====
local icons = require('config.icons')

dashboard.section.buttons.val = {
  dashboard.button("f f", icons.dashboard.find_file    .. "  Find File",    "<cmd>Telescope find_files<CR>"),
  dashboard.button("f n", icons.dashboard.new_file      .. "  New File",     "<cmd>ene<CR>"),
  dashboard.button("f r", icons.dashboard.recent_files  .. "  Recent Files", "<cmd>Telescope oldfiles<CR>"),
  dashboard.button("f g", icons.dashboard.live_grep     .. "  Find Text",    "<cmd>Telescope live_grep<CR>"),
  dashboard.button("SPC wr", icons.dashboard.session .. "  Restore Session", function()
    vim.cmd("packadd auto-session")
    local ok, auto_session = pcall(require, "auto-session")
    if ok then
      auto_session.setup({
        auto_restore = false,
        suppressed_dirs = { "~/", "~/Dev/", "~/Downloads", "~/Documents", "~/Desktop/" },
      })
      vim.cmd("AutoSession restore")
    end
  end),
  dashboard.button("c o", icons.dashboard.config        .. "  Config",       "<cmd>e $MYVIMRC<CR>"),
  dashboard.button("q",   icons.dashboard.quit          .. "  Quit",         "<cmd>qa<CR>"),
}

for _, button in ipairs(dashboard.section.buttons.val) do
  button.opts.hl = "AlphaButtons"
  button.opts.hl_shortcut = "AlphaShortcut"
end
dashboard.section.buttons.opts = { spacing = 1 }

-- ===== Footer: version/plugin info, styled to echo the image's bottom bar =====
local function footer()
  local count = 0
  local pack_dir = vim.fn.stdpath("config") .. "/pack"
  for _, type in ipairs({ "start", "opt" }) do
    local bundle_dir = pack_dir .. "/" .. type
    if vim.fn.isdirectory(bundle_dir) == 1 then
      for _, bundle in ipairs(vim.fn.readdir(bundle_dir)) do
        local dir = bundle_dir .. "/" .. bundle
        if vim.fn.isdirectory(dir) == 1 then
          count = count + #vim.fn.readdir(dir)
        end
      end
    end
  end
  local datetime = os.date(" %d-%m-%Y   %H:%M:%S")
  local version = vim.version()
  local nvim_version_info = "   v" .. version.major .. "." .. version.minor .. "." .. version.patch

  return datetime .. "   " .. count .. " plugins" .. nvim_version_info .. "   ⚡ Ready"
end

dashboard.section.footer.val = footer()
dashboard.section.footer.opts = { hl = "AlphaFooter", position = "center" }

dashboard.config.opts.noautocmd = true
alpha.setup(dashboard.config)
