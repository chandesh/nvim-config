-- Performance optimizations for Neovim
-- These settings improve startup time and runtime performance

-- Disable some built-in plugins for better performance
vim.g.loaded_gzip = 1
vim.g.loaded_zip = 1
vim.g.loaded_zipPlugin = 1
vim.g.loaded_tar = 1
vim.g.loaded_tarPlugin = 1

vim.g.loaded_getscript = 1
vim.g.loaded_getscriptPlugin = 1
vim.g.loaded_vimball = 1
vim.g.loaded_vimballPlugin = 1

vim.g.loaded_matchit = 1
vim.g.loaded_matchparen = 1
vim.g.loaded_2html_plugin = 1
vim.g.loaded_logiPat = 1
vim.g.loaded_rrhelper = 1

-- Disable some providers we don't need
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0

-- Performance settings
vim.opt.updatetime = 250 -- Faster completion (default 4000ms)
vim.opt.timeoutlen = 2000 -- Key sequence completion timeout
vim.opt.redrawtime = 10000 -- Allow more time for loading syntax in large files
vim.opt.maxmempattern = 5000 -- Increase memory for pattern matching

-- Better search performance
vim.opt.regexpengine = 0 -- Use automatic regexp engine selection

-- Improve scrolling performance
vim.opt.lazyredraw = true -- Don't redraw while executing macros
vim.opt.ttyfast = true -- Fast terminal connection

-- File handling optimizations
vim.opt.hidden = true -- Allow switching buffers without saving
vim.opt.backup = false -- Don't create backup files
vim.opt.writebackup = false -- Don't create backup before overwriting
vim.opt.swapfile = false -- Don't create swap files

-- Better completion performance
vim.opt.pumheight = 10 -- Limit popup menu height
vim.opt.pumblend = 10 -- Popup blend

-- Syntax and highlighting optimizations
vim.opt.synmaxcol = 300 -- Don't highlight super long lines
vim.opt.syntax = "on" -- Enable syntax highlighting

-- Fold performance
vim.opt.foldmethod = "manual" -- Use manual folding for better performance (ufo handles this)

-- Session optimizations
vim.opt.sessionoptions = "blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal"

-- Better diff performance
vim.opt.diffopt:append("algorithm:patience")
vim.opt.diffopt:append("indent-heuristic")

-- Optimize for macOS
if vim.fn.has("mac") == 1 then
  vim.opt.clipboard = "unnamedplus" -- Use system clipboard
  vim.g.clipboard = {
    name = "macOS-clipboard",
    copy = {
      ["+"] = "pbcopy",
      ["*"] = "pbcopy",
    },
    paste = {
      ["+"] = "pbpaste",
      ["*"] = "pbpaste",
    },
    cache_enabled = 0,
  }
end

-- LSP performance optimizations
vim.lsp.set_log_level("WARN") -- Reduce LSP logging

-- Optimize treesitter
vim.treesitter.language.require_language = function(lang, path, silent, symbol_name)
  local ok, parser = pcall(vim.treesitter.language.add, lang, path, symbol_name)
  if not ok then
    if not silent then
      vim.notify("Failed to load parser for " .. lang .. ": " .. parser, vim.log.levels.ERROR)
    end
    return false
  end
  return true
end
