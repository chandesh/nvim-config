-- ~/.config/nvim/lua/config/ui.lua
-- =============================================================================
-- UI Enhancements Configuration
-- Configures Lualine (statusline) and Bufferline (tabs/buffers).
-- Indent guides, notifications, dressing, and which-key are handled by snacks.
-- =============================================================================

local M = {}

function M.setup()
  -- ── Statusline (Lualine) ────────────────────────────────────────────────────
  -- Exact reproduction of the custom backup theme and layout
  local lualine = require('lualine')

  local colors = {
    custom = "#979a29",
    blue = "#65D1FF",
    green = "#3EFFDC",
    violet = "#FF61EF",
    yellow = "#FFDA7B",
    red = "#FF4A4A",
    fg = "#c3ccdc",
    bg = "#101010",
    inactive_bg = "#28292e",
  }

  local my_lualine_theme = {
    normal = {
      a = { bg = colors.custom, fg = colors.bg, gui = "bold" },
      b = { bg = colors.bg, fg = colors.fg },
      c = { bg = colors.bg, fg = colors.fg },
    },
    insert = {
      a = { bg = colors.green, fg = colors.bg, gui = "bold" },
      b = { bg = colors.bg, fg = colors.fg },
      c = { bg = colors.bg, fg = colors.fg },
    },
    visual = {
      a = { bg = colors.violet, fg = colors.bg, gui = "bold" },
      b = { bg = colors.bg, fg = colors.fg },
      c = { bg = colors.bg, fg = colors.fg },
    },
    command = {
      a = { bg = colors.yellow, fg = colors.bg, gui = "bold" },
      b = { bg = colors.bg, fg = colors.fg },
      c = { bg = colors.bg, fg = colors.fg },
    },
    replace = {
      a = { bg = colors.red, fg = colors.bg, gui = "bold" },
      b = { bg = colors.bg, fg = colors.fg },
      c = { bg = colors.bg, fg = colors.fg },
    },
    inactive = {
      a = { bg = colors.inactive_bg, fg = colors.fg, gui = "bold" },
      b = { bg = colors.inactive_bg, fg = colors.fg },
      c = { bg = colors.inactive_bg, fg = colors.fg },
    },
  }

  -- Custom components for the statusline
  local function show_macro_recording()
    local recording = vim.fn.reg_recording()
    return recording == "" and "" or "Recording @" .. recording
  end

  local function lsp_status()
    local clients = vim.lsp.get_clients({ bufnr = 0 })
    if #clients == 0 then return "" end
    local names = {}
    for _, client in ipairs(clients) do table.insert(names, client.name) end
    return " " .. table.concat(names, ", ")
  end

  local function python_env()
    if vim.bo.filetype == "python" then
      local venv = vim.env.VIRTUAL_ENV
      if venv then
        return " \u{eb2a} " .. vim.fn.fnamemodify(venv, ":t")
      end
      return " \u{e73c}"
    end
    return ""
  end

  local function copilot_status()
    local clients = vim.lsp.get_clients({ bufnr = 0 })
    for _, client in ipairs(clients) do
      if client.name == "copilot" then
        return " " .. require('config.icons').copilot.enabled
      end
    end
    return ""
  end

  local function plugin_manager_status()
    local pm = vim.g.plugin_manager
    if not pm then return "" end
    if pm.active then
      return string.format(" %s %d/%d", pm.operation, pm.current, pm.total)
    end
    if pm.updates_available and pm.updates_available > 0 then
      local text = " " .. pm.updates_available .. " updates"
      return text
    end
    return ""
  end

  lualine.setup({
    options = {
      theme = my_lualine_theme,
      globalstatus = true,
      disabled_filetypes = { statusline = { "snacks_dashboard" } },
      component_separators = { left = "", right = "" },
      section_separators = { left = "", right = "" },
    },
    sections = {
      lualine_a = { "mode" },
      lualine_b = {
        { "filename", path = 1, file_status = true, fmt = function(name)
          local ok, devicons = pcall(require, 'nvim-web-devicons')
          if ok then
            local icon, _ = devicons.get_icon_by_filetype(vim.bo.filetype)
            if icon then return icon .. ' ' .. name end
          end
          return name
        end, color = { fg = "#e4b622", bg = "#024554" } },
      },
      lualine_c = {
        { "branch", icon = '\u{e725}', color = { fg = "#1c1c1c", bg = "#b5663d" } },
        { "diff", symbols = { added = '\u{f067}', modified = '\u{f044}', removed = '\u{f068}' }, color = { fg = "#c1c1c1", bg = "#02383e" } },
        { "diagnostics", symbols = { error = '\u{f057} ', warn = '\u{f071} ', info = '\u{f05a} ', hint = '\u{f0eb} ' }, color = { bg = "#313C37" }, always_visible = false },
      },
        lualine_x = {
          { show_macro_recording, color = { fg = "#ff9e64", bg = "#2a2a2a" } },
          { python_env, color = { fg = "#1c1c1c", bg = "#03a678" } },
          { copilot_status, color = { fg = "#00f5ff", bg = "#0d4f3c" } },
         { plugin_manager_status, color = { fg = "#00f5ff", bg = "#0d4f3c" } },
          { lsp_status, color = { fg = "#7dcfff", bg = "#1a3a4a" } },
        },

      lualine_y = {
        { "progress", color = { fg = "#1c1c1c", bg = "#e4b622" } },
        { "location", color = { fg = "#c3ccdc", bg = "#424242" } },
      },
      lualine_z = {},
    },
    extensions = { "lazy", "mason" },
  })

  -- ── Buffer Line (tabs / buffers visible at top) ───────────────────────────
  local ok_bufferline, bufferline = pcall(require, 'bufferline')
  if ok_bufferline then
    bufferline.setup({
      options = {
        close_command = "bdelete! %d",
        right_mouse_command = "bdelete! %d",
        diagnostics = "nvim_lsp",
        always_show_bufferline = false,
        diagnostics_update_in_insert = false,
      },
    })

    -- Buffer management keymaps (matches backup)
    vim.keymap.set("n", "<leader>bp", "<Cmd>BufferLineTogglePin<CR>", { desc = "Toggle pin" })
    vim.keymap.set("n", "<leader>bP", "<Cmd>BufferLineGroupClose ungrouped<CR>", { desc = "Delete non-pinned buffers" })
    vim.keymap.set("n", "<leader>bo", "<Cmd>BufferLineCloseOthers<CR>", { desc = "Delete other buffers" })
    vim.keymap.set("n", "<leader>br", "<Cmd>BufferLineCloseRight<CR>", { desc = "Delete buffers to the right" })
    vim.keymap.set("n", "<leader>bl", "<Cmd>BufferLineCloseLeft<CR>", { desc = "Delete buffers to the left" })
    vim.keymap.set("n", "<leader>bd", "<cmd>bdelete!<CR>", { desc = "Delete Buffer" })
  end
end

return M
