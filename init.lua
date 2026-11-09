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

-- Icon registry — loaded early for access by all deferred modules
require('config.icons')

-- Popup window utility — required synchronously so all deferred modules
-- (git, editing, etc.) can call popup.save_origin() and popup.close_all()
require('config.popup')

-- Synchronous loading of critical configuration
require('config.options')
require('config.theme')
require('config.snacks').setup()  -- Snacks must load early (autocmds, dashboard)

-- Completion is opt. Arm the loader before the first tick so a scripted
-- insert cannot miss it. The callback does not run until InsertEnter.
vim.api.nvim_create_autocmd('InsertEnter', {
  callback = function()
    require('config.completion').ensure()
  end,
})

-- Defer the rest to ensure immediate screen paint (the "Zed-speed" trick)
vim.schedule(function()
  require('config.keymaps')
  require('config.autocmds')

  vim.keymap.set("n", "<leader>wr", function()
    if require('config.snacks').ensure_session() then
      vim.cmd("AutoSession restore")
    end
  end, { desc = "Restore session for cwd" })

  vim.keymap.set("n", "<leader>ws", function()
    if require('config.snacks').ensure_session() then
      vim.cmd("AutoSession save")
    end
  end, { desc = "Save session for auto session root dir" })

  require('config.treesitter').setup()
  require('config.lsp').setup()
  require('config.copilot').setup()
  require('config.folding').setup()
  require('config.git').setup()
  require('config.ui').setup()

  -- Task-runner, AI chat, and sticky contexts: keymaps now, plugins on use.
  require('config.neotest').setup()
  require('config.copilot_chat').setup()
  require('config.treesitter_context').setup()

  require('config.smear_cursor').setup()
  require('config.noice').setup()
  require('config.pkg_manager').setup()
  require('config.editing').setup()
  require('config.local_history').setup()
  
  -- Load language-specific configurations
  require('config.lang.python')
  require('config.lang.typescript')
  require('config.lang.go')
  require('config.lang.flutter')
end)
