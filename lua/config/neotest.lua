-- ~/.config/nvim/lua/config/neotest.lua
-- =============================================================================
-- Neotest — test runner for Python (pytest), JS/TS (jest), and Go.
-- Every plugin is an opt plugin; setup() only registers keymaps and the
-- adapters are loaded on first use.
-- =============================================================================

local M = {}

local loaded = false

local function ensure()
  if loaded then
    return require('neotest')
  end

  -- neotest requires nvim-nio at require time.
  vim.cmd('packadd nvim-nio')
  vim.cmd('packadd neotest')
  vim.cmd('packadd neotest-python')
  vim.cmd('packadd neotest-jest')
  vim.cmd('packadd neotest-golang')

  local python = require('config.python_host').get_python()
  local python_opts = { runner = 'pytest' }
  if python then
    python_opts.python = python
  end

  require('neotest').setup({
    adapters = {
      require('neotest-python')(python_opts),
      require('neotest-jest')({}),
      require('neotest-golang')({}),
    },
  })

  loaded = true
  return require('neotest')
end

M.ensure = ensure

function M.setup()
  vim.keymap.set('n', '<leader>tr', function()
    ensure().run.run()
  end, { desc = 'Test nearest' })

  vim.keymap.set('n', '<leader>tF', function()
    ensure().run.run(vim.fn.expand('%'))
  end, { desc = 'Test file' })

  vim.keymap.set('n', '<leader>tS', function()
    ensure().summary.toggle()
  end, { desc = 'Test summary' })

  vim.keymap.set('n', '<leader>tl', function()
    ensure().run.run_last()
  end, { desc = 'Test last' })

  vim.keymap.set('n', '<leader>tq', function()
    ensure().run.stop()
  end, { desc = 'Test stop' })

  vim.keymap.set('n', '<leader>td', function()
    require('config.dap').ensure()
    ensure().run.run({ strategy = 'dap' })
  end, { desc = 'Debug nearest test' })
end

return M
