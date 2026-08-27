-- ~/.config/nvim/lua/config/lang/python.lua
-- =============================================================================
-- Python-Specific Logic
-- Handles venv-selector, linting, and Django project detection.
-- =============================================================================

local function get_project_python()
  local cwd = vim.fn.getcwd()
  local pyenv_root = os.getenv('PYENV_ROOT') or (os.getenv('HOME') .. '/.pyenv')
  local active_venv = os.getenv('VIRTUAL_ENV') or os.getenv('PYENV_VIRTUAL_ENV')
  local candidates = {}
  if active_venv and active_venv ~= '' then
    table.insert(candidates, active_venv .. '/bin/python')
  end
  table.insert(candidates, cwd .. '/.venv/bin/python')
  table.insert(candidates, cwd .. '/venv/bin/python')
  
  local local_ver = vim.fn.system('cat ' .. cwd .. '/.python-version 2>/dev/null'):gsub('\n','')
  if local_ver ~= '' then
    table.insert(candidates, pyenv_root .. '/versions/' .. local_ver .. '/bin/python')
  end
  
  local global_ver = vim.fn.system('pyenv global 2>/dev/null'):gsub('\n','')
  if global_ver ~= '' and global_ver ~= 'system' then
    table.insert(candidates, pyenv_root .. '/versions/' .. global_ver .. '/bin/python3')
  end
  
  table.insert(candidates, vim.fn.exepath('python3'))
  for _, p in ipairs(candidates) do
    if p and p ~= '' and vim.fn.executable(p) == 1 then
      return p
    end
  end
  return nil
end

-- Resolve the active virtualenv's site-packages path.
-- mypy (installed under Homebrew/system Python 3.11) needs PYTHONPATH pointed at
-- the venv's site-packages to resolve Django/storages/etc. synced there by the
-- env bridge; otherwise it reports "Cannot find implementation or library stub".
local function get_active_site_packages()
  local active = vim.env.VIRTUAL_ENV or vim.env.PYENV_VIRTUAL_ENV
  if not active or active == '' then return nil end
  local py = active .. '/bin/python'
  if vim.fn.executable(py) ~= 1 then return nil end
  local out = vim.fn.system(py .. ' -c "import site; print(site.getsitepackages()[0])"')
  local sp = out:gsub('%s+', '')
  if sp == '' then return nil end
  return sp
end

vim.api.nvim_create_autocmd('FileType', {
  group = vim.api.nvim_create_augroup('PythonExtras', { clear = true }),
  pattern = 'python',
  callback = function()
    -- Lazy-load specific python tools via packadd
    vim.cmd('packadd venv-selector.nvim')
    vim.cmd('packadd nvim-lint')

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

    vim.api.nvim_create_autocmd({ 'BufWritePost', 'InsertLeave' }, {
      buffer = 0,
      callback = function() require('lint').try_lint() end
    })

    local py = get_project_python()
    if py then
      vim.b.python_path = py
    end

    local cwd = vim.fn.getcwd()
    if vim.fn.filereadable(cwd .. '/manage.py') == 1 then
      vim.b.is_django_project = true
      vim.notify('[python] Django project detected', vim.log.levels.DEBUG)
    end
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
