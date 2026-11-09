-- ~/.config/nvim/lua/config/lang/python.lua
-- =============================================================================
-- Python-Specific Logic
-- Handles venv-selector, linting, and Django project detection.
-- =============================================================================

-- Resolve the active virtualenv's site-packages path.
-- mypy (installed under Homebrew/system Python 3.11) needs PYTHONPATH pointed at
-- the venv's site-packages to resolve Django/storages/etc. synced there by the
-- env bridge; otherwise it reports "Cannot find implementation or library stub".
local function get_active_site_packages()
  local active = vim.env.VIRTUAL_ENV or vim.env.PYENV_VIRTUAL_ENV
  if not active or active == '' then return nil end
  local py = active .. '/bin/python'
  if vim.fn.executable(py) ~= 1 then return nil end
  local out = vim.fn.system({ py, '-c', 'import site; print(site.getsitepackages()[0])' })
  local sp = vim.trim(out)
  if sp == '' then return nil end
  return sp
end

local M = {}

local setup_done = false

-- One-time setup for the Python tooling. The FileType callback and <leader>pv
-- both call this; the per-buffer work stays in the FileType callback.
function M.ensure_setup()
  if setup_done then return true end

  vim.cmd('packadd venv-selector.nvim')
  vim.cmd('packadd nvim-lint')
  vim.cmd('packadd python-import.nvim')

  require('venv-selector').setup({
    pyenv_path = os.getenv('PYENV_ROOT') or (os.getenv('HOME') .. '/.pyenv'),
    search_venv_managers = true,
    search_workspace = true,
    name = { '.venv', 'venv', 'env' },
  })

  require('lint').linters_by_ft = {
    python = { 'flake8', 'mypy' }
  }

  -- Point mypy at the active venv's site-packages so it resolves the
  -- packages synced there by the env bridge (PYTHONPATH replaces the full
  -- env in nvim-lint, so seed it from the current environment).
  local site_packages = get_active_site_packages()
  if site_packages then
    local mypy = require('lint').linters.mypy
    if mypy then
      local lint_env = vim.fn.environ()
      lint_env.PYTHONPATH = site_packages
      mypy.env = lint_env
    end
  end

  require('python_import').setup({})
  setup_done = true
  return true
end

vim.api.nvim_create_autocmd('FileType', {
  group = vim.api.nvim_create_augroup('PythonExtras', { clear = true }),
  pattern = 'python',
  callback = function()
    M.ensure_setup()

    vim.api.nvim_create_autocmd({ 'BufWritePost', 'InsertLeave' }, {
      buffer = 0,
      callback = function() require('lint').try_lint() end
    })

    local py = require('config.python_host').get_python()
    if py then
      vim.b.python_path = py
    end

    local cwd = vim.fn.getcwd()
    if vim.fn.filereadable(cwd .. '/manage.py') == 1 then
      vim.b.is_django_project = true
      vim.notify('[python] Django project detected', vim.log.levels.DEBUG)
    end

    -- Insert the missing import for the symbol under the cursor. pyright has no
    -- auto-import code action; python-import.nvim resolves via project search,
    -- lookup tables, then pyright completion. Its own notify is a no-op without
    -- nvim-notify, so report success/failure with vim.notify instead.
    local function add_python_import(visual)
      local before = vim.api.nvim_buf_get_lines(0, 0, -1, false)
      local api = require('python_import.api')
      if visual then
        api.add_import_current_selection_and_notify()
      else
        api.add_import_current_word_and_notify()
      end
      local after = vim.api.nvim_buf_get_lines(0, 0, -1, false)
      if not vim.deep_equal(before, after) then
        vim.notify('Python import added', vim.log.levels.INFO)
      else
        vim.notify('No import found for symbol under cursor', vim.log.levels.WARN)
      end
    end

    vim.keymap.set('n', '<leader>ci', function() add_python_import(false) end,
      { buffer = 0, desc = 'Add Python import' })
    vim.keymap.set('x', '<leader>ci', function() add_python_import(true) end,
      { buffer = 0, desc = 'Add Python import (selection)' })
  end,
})

-- Watch .python-version changes to auto-reload the Python host
vim.api.nvim_create_autocmd({ 'BufWritePost', 'FileChangedShellPost' }, {
  group = vim.api.nvim_create_augroup('PyenvVersionWatch', { clear = true }),
  pattern = '.python-version',
  callback = function()
    require('config.python_host')
    vim.notify('[pyenv] .python-version changed — reloading Python host', vim.log.levels.INFO)
  end,
})

return M
