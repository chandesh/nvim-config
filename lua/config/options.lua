-- ~/.config/nvim/lua/config/options.lua
-- =============================================================================
-- General Neovim Options
-- Organized by category for better maintainability.
-- =============================================================================

local opt = vim.opt

-- ── Basic Settings ──────────────────────────────────────────────────────────
opt.mouse = "a"                       -- Enable mouse support
opt.clipboard = "unnamedplus"         -- Use system clipboard
opt.undofile = true                   -- Persistent undo
opt.swapfile = false                  -- Disable swap files
opt.backup = false                    -- Disable backup files

-- ── UI Settings ─────────────────────────────────────────────────────────────
opt.number = true                     -- Show line numbers
opt.relativenumber = true             -- Show relative line numbers
opt.signcolumn = "yes"                -- Always show sign column
opt.cursorline = true                 -- Highlight current line
opt.wrap = false                      -- Disable line wrap
opt.scrolloff = 8                     -- Keep 8 lines above/below cursor
opt.sidescrolloff = 8                  -- Keep 8 columns left/right of cursor
opt.colorcolumn = "88,120"             -- Show rulers at 88 and 120 characters
opt.termguicolors = true              -- Enable true color support
opt.laststatus = 3                    -- Global statusline (Neovim 0.7+)

-- ── Indentation ─────────────────────────────────────────────────────────────
opt.expandtab = true                  -- Use spaces instead of tabs
opt.shiftwidth = 4                    -- Size of an indent
opt.tabstop = 4                       -- Number of spaces tabs count for
opt.softtabstop = 4                    -- Number of spaces tabs count for in insert mode
opt.smartindent = true                -- Smart indenting
opt.autoindent = true                 -- Auto indenting

-- ── Search Settings ──────────────────────────────────────────────────────────
opt.ignorecase = true                 -- Ignore case in search
opt.smartcase = true                  -- Override ignorecase if search has uppercase
opt.incsearch = true                  -- Incremental search
opt.hlsearch = true                   -- Highlight search results

-- ── Split Settings ───────────────────────────────────────────────────────────
opt.splitbelow = true                  -- Horizontal splits go below
opt.splitright = true                  -- Vertical splits go right
opt.fillchars = { 
  vert = "│", horiz = "─", horizup = "┴", horizdown = "┬", 
  vertleft = "┤", vertright = "├", verthoriz = "┼" 
}

-- ── Completion Settings ─────────────────────────────────────────────────────
opt.completeopt = "menu,menuone,noselect" -- Better completion experience
opt.pumheight = 10                    -- Maximum items in completion menu

-- ── Performance & Responsiveness ────────────────────────────────────────────
opt.updatetime = 250                  -- Faster completion and diagnostic updates
opt.timeoutlen = 300                  -- Time to wait for mapped sequence
vim.env.PYTHONUNBUFFERED = '1'        -- Prevent buffering in Python output

-- ── File Handling ───────────────────────────────────────────────────────────
opt.autoread = true                   -- Auto reload files changed outside vim
opt.confirm = true                    -- Ask for confirmation instead of erroring

-- ── Folding ─────────────────────────────────────────────────────────────────
-- Note: These are base settings, Treesitter overrides these via expr folding
opt.foldenable = true                 -- Enable folding
opt.foldlevel = 99                    -- Start with all folds open
opt.foldlevelstart = 99               -- Start with all folds open

-- ── Formatting & Search ────────────────────────────────────────────────────
opt.formatoptions = "jcroqlnt"        -- Standard formatting options
opt.grepprg = "rg --vimgrep"          -- Use ripgrep for grep
opt.grepformat = "%f:%l:%c:%m"

-- ── Miscellaneous ────────────────────────────────────────────────────────────
-- conceallevel managed per-filetype; render-markdown handles it internally
opt.wildmode = "longest:full,full"    -- Command-line completion mode
opt.sessionoptions = { "blank", "buffers", "curdir", "folds", "help", "tabpages", "winsize", "winpos", "terminal", "localoptions" }

-- Reduce LSP noise
vim.lsp.log.set_level("WARN")
