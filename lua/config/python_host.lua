-- ~/.config/nvim/lua/config/python_host.lua
-- Resolves the correct Python3 for Neovim's remote plugin host.
-- Resolution order (highest priority first):
--   1. $VIRTUAL_ENV / $PYENV_VIRTUAL_ENV  (honor what the user explicitly activated)
--   2. $PYENV_VERSION                      (pyenv shell version)
--   3. .python-version in cwd             (pyenv local — read-only, never unset)
--   4. pyenv 'nvim-env' dedicated venv    (isolated fallback, always has pynvim)
--   5. pyenv global version                (pyenv global)
--   6. .venv/bin/python in cwd            (project venv)
--   7. venv/bin/python in cwd             (project venv alt)
--   8. $PYENV_ROOT/shims/python3          (pyenv shim)
--   9. system python3                      (final fallback)

local M = {}

local function is_executable(path)
  return path and path ~= '' and vim.fn.executable(path) == 1
end

local function resolve_python()
  local pyenv_root = os.getenv('PYENV_ROOT') or (os.getenv('HOME') .. '/.pyenv')

  -- 1. Active virtualenv — respect what the user explicitly activated
  local active_venv = os.getenv('VIRTUAL_ENV') or os.getenv('PYENV_VIRTUAL_ENV')
  if active_venv and active_venv ~= '' then
    local active_py = active_venv .. '/bin/python'
    if is_executable(active_py) then
      return active_py, 'venv:active(' .. vim.fn.fnamemodify(active_venv, ':t') .. ')'
    end
  end

  -- 2. pyenv shell version (set by `pyenv shell` or `pyenv activate`)
  local pyenv_version = os.getenv('PYENV_VERSION')
  if pyenv_version and pyenv_version ~= '' then
    local shell_py = pyenv_root .. '/versions/' .. pyenv_version .. '/bin/python'
    if is_executable(shell_py) then
      return shell_py, 'pyenv:shell(' .. pyenv_version .. ')'
    end
  end

  -- 3. pyenv local version — read-only, never run `pyenv local --unset`
  local local_ver = vim.fn.system('cat .python-version 2>/dev/null'):gsub('\n', '')
  if local_ver ~= '' then
    local local_py = pyenv_root .. '/versions/' .. local_ver .. '/bin/python'
    if is_executable(local_py) then
      return local_py, 'pyenv:local(' .. local_ver .. ')'
    end
  end

  -- 4. Dedicated 'nvim-env' pyenv virtualenv (isolated, always has pynvim)
  local nvim_venv = pyenv_root .. '/versions/nvim-env/bin/python'
  if is_executable(nvim_venv) then
    return nvim_venv, 'pyenv:nvim-env'
  end

  -- 5. pyenv global
  local global_ver = vim.fn.system('pyenv global 2>/dev/null'):gsub('\n', '')
  if global_ver ~= '' and global_ver ~= 'system' then
    local global_py = pyenv_root .. '/versions/' .. global_ver .. '/bin/python3'
    if is_executable(global_py) then
      return global_py, 'pyenv:global(' .. global_ver .. ')'
    end
  end

  -- 6. Project .venv
  local cwd = vim.fn.getcwd()
  local project_venv = cwd .. '/.venv/bin/python'
  if is_executable(project_venv) then
    return project_venv, 'project:.venv'
  end

  -- 7. Project venv
  local project_venv2 = cwd .. '/venv/bin/python'
  if is_executable(project_venv2) then
    return project_venv2, 'project:venv'
  end

  -- 8. pyenv shim
  local pyenv_shim = pyenv_root .. '/shims/python3'
  if is_executable(pyenv_shim) then
    return pyenv_shim, 'pyenv:shim'
  end

  -- 9. System Python
  local sys_py = vim.fn.exepath('python3')
  if is_executable(sys_py) then
    return sys_py, 'system:python3'
  end

  return nil, 'NOT FOUND'
end

local python_path, python_source = resolve_python()

if python_path then
  vim.g.python3_host_prog = python_path
  vim.schedule(function()
    vim.notify(
      string.format('[python_host] %s → %s', python_source, python_path),
      vim.log.levels.DEBUG
    )
  end)
else
  vim.schedule(function()
    vim.notify(
      '[python_host] WARNING: No Python3 found. Run :checkhealth provider.',
      vim.log.levels.WARN
    )
  end)
end

vim.api.nvim_create_autocmd('DirChanged', {
  group = vim.api.nvim_create_augroup('PythonHostUpdate', { clear = true }),
  callback = function()
    local new_py, new_src = resolve_python()
    if new_py and new_py ~= vim.g.python3_host_prog then
      vim.g.python3_host_prog = new_py
      vim.notify(
        string.format('[python_host] switched → %s (%s)', new_src, new_py),
        vim.log.levels.INFO
      )
    end
  end
})

M.get_python = function() return vim.g.python3_host_prog end
M.resolve    = resolve_python

return M
