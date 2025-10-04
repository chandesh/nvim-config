-- ========================================
-- Neovim Options Configuration
-- ========================================

local opt = vim.opt

-- Basic Settings
opt.mouse = "a" -- Enable mouse support
opt.clipboard = "unnamedplus" -- Use system clipboard
opt.undofile = true -- Persistent undo
opt.swapfile = false -- Disable swap files
opt.backup = false -- Disable backup files

-- UI Settings
opt.number = true -- Show line numbers
opt.relativenumber = true -- Show relative line numbers
opt.signcolumn = "yes" -- Always show sign column
opt.cursorline = true -- Highlight current line
opt.wrap = false -- Disable line wrap
opt.scrolloff = 8 -- Keep 8 lines above/below cursor
opt.sidescrolloff = 8 -- Keep 8 columns left/right of cursor
opt.colorcolumn = "88,120" -- Show rulers at 88 and 120 characters
opt.termguicolors = true -- Enable true color support

-- Indentation
opt.expandtab = true -- Use spaces instead of tabs
opt.shiftwidth = 4 -- Size of an indent
opt.tabstop = 4 -- Number of spaces tabs count for
opt.softtabstop = 4 -- Number of spaces tabs count for in insert mode
opt.smartindent = true -- Smart indenting
opt.autoindent = true -- Auto indenting

-- Search Settings
opt.ignorecase = true -- Ignore case in search
opt.smartcase = true -- Override ignorecase if search has uppercase
opt.incsearch = true -- Incremental search
opt.hlsearch = true -- Highlight search results

-- Split Settings
opt.splitbelow = true -- Horizontal splits go below
opt.splitright = true -- Vertical splits go right

-- Completion Settings
opt.completeopt = "menu,menuone,noselect" -- Better completion experience
opt.pumheight = 10 -- Maximum items in completion menu

-- Performance
opt.updatetime = 250 -- Faster completion
opt.timeoutlen = 300 -- Time to wait for mapped sequence

-- File Handling
opt.autoread = true -- Auto reload files changed outside vim
opt.confirm = true -- Ask for confirmation instead of erroring

-- Folding (basic settings)
opt.foldenable = true -- Enable folding
opt.foldlevel = 1 -- Start with some folds closed
opt.foldlevelstart = 1 -- Start with some folds closed

-- Formatting
opt.formatoptions = "jcroqlnt" -- tcqj
opt.grepprg = "rg --vimgrep"
opt.grepformat = "%f:%l:%c:%m"

-- Concealment
opt.conceallevel = 3 -- Hide * markup for bold and italic

-- Wildmenu
opt.wildmode = "longest:full,full" -- Command-line completion mode

-- Session
opt.sessionoptions = { "buffers", "curdir", "tabpages", "winsize" }

-- LSP Configuration for reduced noise
vim.lsp.set_log_level("WARN") -- Reduce LSP log verbosity to minimize startup errors

-- Python provider (for better performance) - will be set by pyenv module
-- Initial fallback, will be updated by pyenv.activate()
vim.g.python3_host_prog = vim.fn.exepath("python3")

-- Disable some default providers
vim.g.loaded_python_provider = 0 -- Disable Python 2
vim.g.loaded_ruby_provider = 0 -- Disable Ruby
vim.g.loaded_perl_provider = 0 -- Disable Perl
vim.g.loaded_node_provider = 0 -- Disable Node.js (we'll use specific paths)
