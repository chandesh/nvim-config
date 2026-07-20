-- ~/.config/nvim/lua/config/autocmds.lua
-- =============================================================================
-- Neovim Autocommands Configuration
-- Handles file-type specific settings, UI polish, and environment triggers.
-- =============================================================================

local function augroup(name)
  return vim.api.nvim_create_augroup("pixelforge_" .. name, { clear = true })
end

-- ── System Polishing ─────────────────────────────────────────────────────────

-- Reload files when they change on disk (Focus Gained / Term Close)
vim.api.nvim_create_autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
  group = augroup("checktime"),
  command = "checktime",
})

-- Highlight on yank
vim.api.nvim_create_autocmd("TextYankPost", {
  group = augroup("highlight_yank"),
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- Reset splits on window resize
vim.api.nvim_create_autocmd({ "VimResized" }, {
  group = augroup("resize_splits"),
  callback = function()
    local current_tab = vim.fn.tabpagenr()
    vim.cmd("tabdo wincmd =")
    vim.cmd("tabnext " .. current_tab)
  end,
})

-- Restore cursor position when opening a buffer
vim.api.nvim_create_autocmd("BufReadPost", {
  group = augroup("last_loc"),
  callback = function(event)
    local exclude = { "gitcommit" }
    local buf = event.buf
    if vim.tbl_contains(exclude, vim.bo[buf].filetype) or vim.b[buf].lazyvim_last_loc then
      return
    end
    vim.b[buf].lazyvim_last_loc = true
    local mark = vim.api.nvim_buf_get_mark(buf, '"')
    local lcount = vim.api.nvim_buf_line_count(buf)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- Close specific transient windows with <q>
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("close_with_q"),
  pattern = {
    "PlenaryTestPopup", "help", "lspinfo", "man", "notify", "qf",
    "spectre_panel", "startuptime", "tsplayground", "neotest-output",
    "checkhealth", "neotest-summary", "neotest-output-panel",
  },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = event.buf, silent = true })
  end,
})

-- ── Filetype Specific Settings ──────────────────────────────────────────────

-- Text and Markdown: enable wrap and spellcheck
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("wrap_spell"),
  pattern = { "gitcommit", "markdown" },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.spell = true
  end,
})

-- Markdown: load render-markdown.nvim on demand
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("render_markdown"),
  pattern = { "markdown", "md", "mdx", "quarto", "rmd" },
  callback = function()
    require("config.markdown").setup()
  end,
  once = true,
})



-- Python: set PEP8 line length and color column
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("python_settings"),
  pattern = "python",
  callback = function()
    vim.opt_local.colorcolumn = "88,120"
    vim.opt_local.textwidth = 88
  end,
})

-- JS/TS: set 2-space indentation
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("js_ts_settings"),
  pattern = { "javascript", "typescript", "javascriptreact", "typescriptreact" },
  callback = function()
    vim.opt_local.shiftwidth = 2
    vim.opt_local.tabstop = 2
    vim.opt_local.softtabstop = 2
    vim.opt_local.colorcolumn = "80,120"
  end,
})

-- Web (HTML/CSS/SASS): set 2-space indentation
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("web_settings"),
  pattern = { "html", "css", "scss", "sass", "less" },
  callback = function()
    vim.opt_local.shiftwidth = 2
    vim.opt_local.tabstop = 2
    vim.opt_local.softtabstop = 2
  end,
})

-- YAML: set 2-space indentation
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("yaml_settings"),
  pattern = { "yaml", "yml" },
  callback = function()
    vim.opt_local.shiftwidth = 2
    vim.opt_local.tabstop = 2
    vim.opt_local.softtabstop = 2
  end,
})

-- ── Special File Detection ──────────────────────────────────────────────────

-- Django templates: set filetype to htmldjango for files in template dirs
vim.api.nvim_create_autocmd({"BufNewFile", "BufRead"}, {
  group = augroup("django_templates"),
  pattern = "*.html",
  callback = function()
    local path = vim.fn.expand("%:p")
    if path:match("templates") or path:match("django") then
      vim.bo.filetype = "htmldjango"
    end
  end,
})

-- JSX: ensure .jsx files are detected as javascriptreact
vim.api.nvim_create_autocmd({"BufNewFile", "BufRead"}, {
  group = augroup("jsx_filetype"),
  pattern = "*.jsx",
  callback = function()
    vim.bo.filetype = "javascriptreact"
  end,
})

-- ── Maintenance & Tooling ──────────────────────────────────────────────────

-- Auto-create directory when saving a file
vim.api.nvim_create_autocmd({ "BufWritePre" }, {
  group = augroup("auto_create_dir"),
  callback = function(event)
    if event.match:match("^%w%w+://") then return end
    local file = vim.loop.fs_realpath(event.match) or event.match
    vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
  end,
})

-- Reload Python host on .python-version change
vim.api.nvim_create_autocmd({ "BufWritePost", "FileChangedShellPost" }, {
  group = augroup("pyenv_version_watch"),
  pattern = ".python-version",
  callback = function()
    require('config.python_host')
    vim.notify('[pyenv] .python-version changed — reloading Python host', vim.log.levels.INFO)
  end,
})

-- Trim whitespace on save for common languages
vim.api.nvim_create_autocmd("BufWritePre", {
  group = augroup("trim_whitespace"),
  pattern = { "python", "javascript", "typescript", "go", "lua", "sql", "yaml", "json" },
  callback = function()
    local save_cursor = vim.fn.getcurpos()
    vim.cmd([[ %s/\s\+$//e ]])
    vim.api.nvim_restore_cursor(save_cursor, true)
  end,
})
