-- ~/.config/nvim/init.lua
-- Neovim 0.12.4 | vim.pack | Python/Django · TypeScript/Angular/React · Go
-- Target startup: <30ms (Zed-comparable)
-- Architecture: theme + options only at startup, everything deferred

-- Disable unused providers to shave off precious milliseconds
vim.g.loaded_ruby_provider   = 0
vim.g.loaded_perl_provider   = 0
vim.g.loaded_python_provider = 0   -- only use python3
vim.g.loaded_node_provider   = 0   -- copilot handles node

-- Disable built-in plugins that aren't used
local disabled_plugins = {
  'gzip','zip','zipPlugin','tar','tarPlugin','getscript','getscriptPlugin',
  'vimball','vimballPlugin','2html_plugin','logiPat','rrhelper',
  'netrw','netrwPlugin','netrwSettings','netrwFileHandlers',
  'matchit','matchparen','spec','shada_plugin',
}
for _, plugin in ipairs(disabled_plugins) do 
  vim.g['loaded_'..plugin] = 1 
end

-- Set leader keys early
vim.g.mapleader      = ' '
vim.g.maplocalleader = ' '

-- Resolve Python host before any other plugins load
require('config.python_host')

-- Synchronous loading of critical configuration
require('config.options')
require('config.theme')
require('config.alpha')  -- MUST load before VimEnter opens buffers

-- Defer the rest to ensure immediate screen paint (the "Zed-speed" trick)
vim.schedule(function()
  require('config.keymaps')
  require('config.autocmds')

  -- Session management — loaded on-demand to keep dashboard visible on startup
  local session_loaded = false
  local function ensure_session()
    if session_loaded then return true end
    vim.cmd('packadd auto-session')
    local ok, auto_session = pcall(require, 'auto-session')
    if ok then
      auto_session.setup({
        auto_restore = false,
        suppressed_dirs = { "~/", "~/Dev/", "~/Downloads", "~/Documents", "~/Desktop/" },
      })
      session_loaded = true
    end
    return ok
  end

  vim.keymap.set("n", "<leader>wr", function()
    if ensure_session() then
      vim.cmd("AutoSession restore")
    end
  end, { desc = "Restore session for cwd" })

  vim.keymap.set("n", "<leader>ws", function()
    if ensure_session() then
      vim.cmd("AutoSession save")
    end
  end, { desc = "Save session for auto session root dir" })

  require('config.treesitter').setup()
  require('config.lsp').setup()
  require('config.copilot').setup()
  require('config.completion').setup()
  require('config.telescope').setup()
  require('config.nvimtree').setup()
  require('config.aerial').setup()
  require('config.folding').setup()
  require('config.git').setup()
  require('config.ui').setup()
  require('config.manager').setup()
  require('config.editing').setup()
  
  -- Load language-specific configurations
  require('config.lang.python')
  require('config.lang.typescript')
  require('config.lang.go')
end)
