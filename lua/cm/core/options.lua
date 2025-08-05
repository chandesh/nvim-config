vim.cmd("let g:netrw_liststyle = 3")

local opt = vim.opt -- for conciseness

-- line numbers
opt.relativenumber = true -- show relative line numbers
opt.number = true -- shows absolute line number on cursor line (when relative number is on)

-- tabs & indentation
opt.tabstop = 2 -- 2 spaces for tabs (prettier default)
opt.shiftwidth = 2 -- 2 spaces for indent width
opt.expandtab = true -- expand tab to spaces
opt.autoindent = true -- copy indent from current line when starting new one

-- line wrapping
opt.wrap = false -- disable line wrapping

-- search settings
opt.ignorecase = true -- ignore case when searching
opt.smartcase = true -- if you include mixed case in your search, assumes you want case-sensitive

-- cursor line
opt.cursorline = true -- highlight the current cursor line

-- appearance

-- turn on termguicolors for nightfly colorscheme to work
-- (have to use iterm2 or any other true color terminal)
opt.termguicolors = true
opt.background = "dark" -- colorschemes that can be light or dark will be made dark
opt.signcolumn = "yes" -- show sign column so that text doesn't shift

-- backspace
opt.backspace = "indent,eol,start" -- allow backspace on indent, end of line or insert mode start position

-- clipboard
opt.clipboard:append("unnamedplus") -- use system clipboard as default register

-- split windows
opt.splitright = true -- split vertical window to the right
opt.splitbelow = true -- split horizontal window to the bottom

-- turn off swapfile
opt.swapfile = false

-- Tech stack specific settings
-- Django template detection
vim.api.nvim_create_autocmd({"BufNewFile", "BufRead"}, {
  pattern = "*.html",
  callback = function()
    local bufname = vim.api.nvim_buf_get_name(0)
    -- Check if we're in a Django project (look for common Django patterns)
    if string.match(bufname, "templates/") or 
       string.match(bufname, "template") or
       vim.fs.find({"manage.py", "settings.py"}, {upward = true, path = vim.fn.expand("%:p:h")})[1] then
      vim.bo.filetype = "htmldjango"
    end
  end,
})

-- SQL file detection improvements
vim.api.nvim_create_autocmd({"BufNewFile", "BufRead"}, {
  pattern = {"*.sql", "*.psql", "*.mysql"},
  callback = function()
    vim.bo.filetype = "sql"
  end,
})

-- Python development settings
vim.api.nvim_create_autocmd("FileType", {
  pattern = "python",
  callback = function()
    vim.opt_local.tabstop = 4
    vim.opt_local.shiftwidth = 4
    vim.opt_local.softtabstop = 4
    vim.opt_local.textwidth = 88  -- Black's default line length
  end,
})

-- JavaScript/TypeScript settings
vim.api.nvim_create_autocmd("FileType", {
  pattern = {"javascript", "typescript", "javascriptreact", "typescriptreact"},
  callback = function()
    vim.opt_local.tabstop = 2
    vim.opt_local.shiftwidth = 2
    vim.opt_local.softtabstop = 2
  end,
})

-- CSS settings
vim.api.nvim_create_autocmd("FileType", {
  pattern = {"css", "scss", "sass", "less"},
  callback = function()
    vim.opt_local.tabstop = 2
    vim.opt_local.shiftwidth = 2
    vim.opt_local.softtabstop = 2
  end,
})

