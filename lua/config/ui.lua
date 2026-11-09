-- ~/.config/nvim/lua/config/ui.lua
-- =============================================================================
-- UI Enhancements Configuration
-- Configures Lualine (statusline) and Bufferline (tabs/buffers).
-- Indent guides are handled by snacks; which-key has its own setup below.
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
    inactive_fg = "#6a7079",
  }

  local amber_chip = { fg = colors.yellow, bg = "#4a3410" }

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
  local icons = require('config.icons')

  -- nvim-web-devicons is required once and cached per filetype. The filename
  -- formatter reads this table on every redraw instead of requiring the plugin.
  local icons_by_ft = {}
  local function cache_filetype_icon()
    local ok, devicons = pcall(require, 'nvim-web-devicons')
    if not ok then return end
    local ft = vim.bo.filetype
    icons_by_ft[ft] = devicons.get_icon_by_filetype(ft, { default = false }) or false
  end
  cache_filetype_icon()
  vim.api.nvim_create_autocmd({ 'FileType', 'BufEnter' }, {
    group = vim.api.nvim_create_augroup('LualineFiletypeIcons', { clear = true }),
    callback = cache_filetype_icon,
  })

  -- LSP client labels are built on attach/detach and read by the components.
  -- Nothing on the redraw path calls vim.lsp.get_clients or require.
  local lsp_cache = {}
  local function refresh_lsp_cache(bufnr)
    if not bufnr or bufnr == 0 then bufnr = vim.api.nvim_get_current_buf() end
    local names, pyright, copilot = {}, false, false
    for _, client in ipairs(vim.lsp.get_clients({ bufnr = bufnr })) do
      names[#names + 1] = client.name
      if client.name == 'pyright' then pyright = true end
      if client.name == 'copilot' then copilot = true end
    end
    lsp_cache[bufnr] = { names = names, pyright = pyright, copilot = copilot }
  end
  refresh_lsp_cache(0)
  vim.api.nvim_create_autocmd({ 'LspAttach', 'LspDetach' }, {
    group = vim.api.nvim_create_augroup('LualineLspCache', { clear = true }),
    callback = function(args) refresh_lsp_cache(args.buf) end,
  })
  vim.api.nvim_create_autocmd('BufDelete', {
    group = vim.api.nvim_create_augroup('LualineLspCacheClear', { clear = true }),
    callback = function(args) lsp_cache[args.buf] = nil end,
  })

  local function show_macro_recording()
    local recording = vim.fn.reg_recording()
    return recording == "" and "" or "Recording @" .. recording
  end

  local function lsp_status()
    local cached = lsp_cache[vim.api.nvim_get_current_buf()]
    if not cached or #cached.names == 0 then return "" end
    return " " .. table.concat(cached.names, ", ")
  end

  -- Pyright LSP indicator (󰌠 = U+F0320).
  -- Returns only a string (lualine component functions must return strings);
  -- per-state color is supplied by the component's `color` function below.
  local function pyright_status()
    local cached = lsp_cache[vim.api.nvim_get_current_buf()]
    if cached and cached.pyright then
      return ' \u{f0320} Pyright'
    end
    if vim.bo.filetype == 'python' then
      return ' \u{f0320} Off'
    end
    return ''
  end

  local function pyright_color()
    local cached = lsp_cache[vim.api.nvim_get_current_buf()]
    if cached and cached.pyright then
      return { fg = colors.green }
    end
    return { fg = colors.inactive_fg }
  end

  -- DAP state indicator.
  -- No session → idle; stopped_thread_id set → paused; otherwise running.
  local function dap_status()
    local ok, dap = pcall(require, 'dap')
    if not ok then return '' end
    local session = dap.session()
    if not session then
      return ' \u{f01a7} DAP off'
    elseif session.stopped_thread_id then
      return ' \u{f00e4} Paused'
    else
      return ' \u{f00e4} Running'
    end
  end

  local function dap_color()
    local ok, dap = pcall(require, 'dap')
    if not ok then return { fg = colors.inactive_fg } end
    local session = dap.session()
    if not session then
      return { fg = colors.inactive_fg }
    elseif session.stopped_thread_id then
      return { fg = colors.yellow }
    else
      return { fg = colors.green }
    end
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
    local cached = lsp_cache[vim.api.nvim_get_current_buf()]
    if cached and cached.copilot then
      return " " .. icons.copilot.enabled .. " "
    end
    return ""
  end

  -- Priority: active op progress → checking → pending updates → hidden
  local function plugin_manager_status()
    local pm = vim.g.plugin_manager
    if not pm then return "" end
    if pm.active then
      return string.format(" %s %d/%d", pm.operation, pm.current, pm.total)
    end
    if pm.checking_updates then
      return " " .. icons.plugin_updates.checking .. " Checking"
    end
    if (pm.pending_updates or 0) > 0 then
      return string.format(" %s %d updates", icons.plugin_updates.available, pm.pending_updates)
    end
    return ""
  end

  local function plugin_manager_color()
    local pm = vim.g.plugin_manager
    if pm and pm.active then
      return { fg = "#00f5ff", bg = "#0d4f3c" }
    end
    if pm and pm.checking_updates then
      return { fg = colors.inactive_fg, bg = "#26282e" }
    end
    if pm and (pm.pending_updates or 0) > 0 then
      -- dark amber bg: visually distinct from copilot's teal chip next to it
      return amber_chip
    end
    return { fg = "#00f5ff", bg = "#0d4f3c" }
  end

  -- Env bridge sync indicator. Shows an animated spinner + phase while the
  -- container site-packages sync (<leader>eS) is running in the background.
  local function env_sync_status()
    local s = vim.g.env_sync
    if not s or not s.active then return "" end
    local icon = s.spinner or '\u{f111}'
    local phase = s.phase or ""
    return " " .. icon .. " Syncing: " .. phase
  end

  local function env_sync_color()
    local s = vim.g.env_sync
    if s and s.active then
      return amber_chip
    end
    return { fg = colors.inactive_fg }
  end

  -- ── Breadcrumbs (nvim-navic) ──────────────────────────────────────────────
  -- Renders the current symbol hierarchy (e.g. MyClass > process_data) in the
  -- winbar. auto_attach hooks LspAttach for any server exposing documentSymbol.
  local ok_navic, navic = pcall(require, 'nvim-navic')
  if ok_navic then
    -- navic concatenates `icon .. name`, so each glyph needs a trailing space
    -- to keep it from colliding with the symbol name.
    local navic_icons = {}
    for kind, icon in pairs(icons.kinds) do
      navic_icons[kind] = icon .. " "
    end

    navic.setup({
      icons = navic_icons,
      lsp = { auto_attach = true, preference = nil },
      highlight = false,
      separator = " > ",
      depth_limit = 5,
      depth_limit_indicator = "..",
      safe_output = true,
      lazy_update_context = true,
      click = false,
    })
  end

  local function navic_location()
    if navic and navic.is_available() then
      local location = navic.get_location()
      if location and location ~= "" then
        return " " .. location
      end
    end
    return ""
  end

  lualine.setup({
    options = {
      theme = my_lualine_theme,
      globalstatus = true,
      disabled_filetypes = {
        statusline = { "snacks_dashboard" },
        winbar = { "snacks_dashboard" },
      },
      component_separators = { left = "", right = "" },
      section_separators = { left = "", right = "" },
    },
    sections = {
      lualine_a = { "mode" },
      lualine_b = {
        { "filename", path = 1, file_status = true, fmt = function(name)
          local icon = icons_by_ft[vim.bo.filetype]
          if icon then return icon .. ' ' .. name end
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
         { plugin_manager_status, color = plugin_manager_color },
          { env_sync_status, color = env_sync_color },
          { dap_status, color = dap_color },
          { pyright_status, color = pyright_color },
          { lsp_status, color = { fg = "#7dcfff", bg = "#1a3a4a" } },
        },

      lualine_y = {
        { "progress", color = { fg = "#1c1c1c", bg = "#e4b622" } },
        { "location", color = { fg = "#c3ccdc", bg = "#424242" } },
      },
      lualine_z = {},
    },
    winbar = {
      lualine_c = {
        { navic_location, color = { fg = colors.fg, bg = colors.bg } },
      },
    },
    inactive_winbar = {
      lualine_c = {
        { navic_location, color = { fg = colors.inactive_fg, bg = colors.inactive_bg } },
      },
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

  -- ── Which-Key (Leader Key Menu) ──────────────────────────────────────────
  -- Configured once at setup. Previously this ran inside the lualine filename
  -- formatter, which re-invoked setup on every statusline redraw.
  local ok_wk, wk = pcall(require, 'which-key')
  if ok_wk then
    wk.setup({ preset = "classic" })
  end
end

return M
