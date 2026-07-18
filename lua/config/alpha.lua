-- ~/.config/nvim/lua/config/alpha.lua
-- Dashboard setup — MUST load synchronously before VimEnter opens buffers

local alpha = require('alpha')
local dashboard = require('alpha.themes.dashboard')

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

dashboard.section.buttons.val = {
  dashboard.button("e", "  > New File", "<cmd>ene<CR>"),
  dashboard.button("SPC ee", "  > Toggle file explorer", "<cmd>NvimTreeToggle<CR>"),
  dashboard.button("SPC ff", "󰱼 > Find File", "<cmd>Telescope find_files<CR>"),
  dashboard.button("SPC fs", "  > Find Word", "<cmd>Telescope live_grep<CR>"),
  dashboard.button("SPC wr", "󰁯  > Restore Session", function()
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
  dashboard.button("r", "  Recent files", "<cmd>Telescope oldfiles<CR>"),
  dashboard.button("c", "  Config", "<cmd>e $MYVIMRC<CR>"),
  dashboard.button("u", "  Update Plugins", "<cmd>!bash ~/.config/nvim/update.sh<CR>"),
  dashboard.button("q", "  Quit NVIM", "<cmd>qa<CR>"),
}

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
  return datetime .. "   " .. count .. " plugins" .. nvim_version_info
end

dashboard.section.footer.val = footer()
dashboard.config.opts.noautocmd = true
alpha.setup(dashboard.config)
