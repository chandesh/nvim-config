-- ~/.config/nvim/lua/config/ui.lua
-- =============================================================================
-- UI Enhancements Configuration
-- Preserves the aesthetic identity of the backup with a focus on responsiveness.
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
      disabled_filetypes = { statusline = { "dashboard", "alpha", "starter" } },
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
          {
            function()
              return package.loaded["noice"] and require("noice").api.status.command.get() or ""
            end,
            color = { fg = "#ff9e64", bg = "#3a2a1a" },
          },
        },

      lualine_y = {
        { "progress", color = { fg = "#1c1c1c", bg = "#e4b622" } },
        { "location", color = { fg = "#c3ccdc", bg = "#424242" } },
      },
      lualine_z = {},
    },
    extensions = { "nvim-tree", "lazy", "fugitive", "mason", "trouble" },
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
        offsets = {
          {
            filetype = "NvimTree",
            text = "File Explorer",
            highlight = "Directory",
            text_align = "left",
          },
        },
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

  -- ── Indent Guides ─────────────────────────────────────────────────────────
  local icons = require('config.icons')
  local ibl = require('ibl')
  local rainbow_hl = {
    "RainbowRed", "RainbowYellow", "RainbowBlue", "RainbowOrange", 
    "RainbowGreen", "RainbowViolet", "RainbowCyan"
  }
  
  -- Set rainbow colors manually to match backup palette
  local colors_map = {
    RainbowRed    = "#E06C75", RainbowYellow = "#E5C07B",
    RainbowBlue   = "#61AFEF", RainbowOrange = "#D19A66",
    RainbowGreen  = "#98C379", RainbowViolet = "#C678DD",
    RainbowCyan   = "#56B6C2",
  }
  for hl, color in pairs(colors_map) do
    vim.api.nvim_set_hl(0, hl, { fg = color })
  end

  ibl.setup({
    indent = { highlight = rainbow_hl, char = icons.indent.char, tab_char = icons.indent.tab_char },
    whitespace = { highlight = rainbow_hl, remove_blankline_trail = false },
    scope = { enabled = false },
    exclude = {
      filetypes = { "help", "alpha", "dashboard", "NvimTree", "Trouble", "lazy", "mason", "notify" },
    },
  })

  -- ── UI Polish ──────────────────────────────────────────────────────────────
  local ok_dressing, dressing = pcall(require, 'dressing')
  if ok_dressing then
    dressing.setup({
      input = { border = "rounded" },
      select = { ui_select = { border = "rounded" } },
    })
  end

  local ok_colorizer, colorizer = pcall(require, 'colorizer')
  if ok_colorizer then
    colorizer.setup({
      filetypes = { "*" },
      user_default_options = { mode = "background", virtualtext = "■" },
    })
  end

  local ok_navic, navic = pcall(require, 'nvim-navic')
  if ok_navic then
    navic.setup({
      separator = " > ",
      lsp = { auto_attach = true },
    })
  end

  -- ── Notifications & Noice ─────────────────────────────────────────────────
  -- Noice manages vim.notify and uses nvim-notify as its rendering backend
  local ok_noice, noice = pcall(require, 'noice')
  if ok_noice then
    noice.setup({
      notify = { enabled = false },
      lsp = {
        override = {
          ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
          ["vim.lsp.util.stylize_markdown"] = true,
          ["cmp.entry.get_documentation"] = true,
        },
      },
      routes = {
        {
          filter = {
            event = "msg_show",
            any = {
              { find = "progress reporting" },
              { find = "TimeoutError" },
              { find = "stubPath.*is not a valid directory" },
            },
          },
          opts = { skip = true },
        },
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
      presets = {
        bottom_search = true,
        command_palette = true,
        long_message_to_split = true,
        inc_rename = false,
        lsp_doc_border = false,
      },
    })
  end

  -- ── Which-Key Groups ──────────────────────────────────────────────────────
  local ok_wk, wk = pcall(require, 'which-key')
  if ok_wk then
    wk.add({
      { "<leader>b",  group = icons.which_key.buffer .. "Buffer" },
      { "<leader>c",  group = icons.which_key.code .. "Code" },
      { "<leader>d",  group = icons.which_key.debug .. "Debug" },
      { "<leader>e",  group = icons.which_key.window .. "Explorer" },
      { "<leader>f",  group = icons.which_key.find .. "Find" },
      { "<leader>g",  group = icons.which_key.git .. "Git" },
      { "<leader>h",  group = icons.which_key.history .. "History" },
      { "<leader>l",  group = icons.which_key.language .. "Language" },
      { "<leader>m",  group = icons.which_key.format .. "Format" },
      { "<leader>p",  group = icons.which_key.python .. "Python" },
      { "<leader>s",  group = icons.which_key.search .. "Search" },
      { "<leader>t",  group = icons.which_key.test .. "Test" },
      { "<leader>u",  group = icons.which_key.ui .. "UI" },
      { "<leader>w",  group = icons.which_key.window .. "Window" },
    })
  end
end

return M
