-- ~/.config/nvim/lua/config/python_host.lua
-- Resolves the correct Python3 for Neovim's remote plugin host.
-- Resolution order:
--   1. pyenv 'neovim' dedicated virtualenv  (best — isolated, always has pynvim)
--   2. pyenv local version for current dir  (respects .python-version)
--   3. pyenv global version                 (pyenv global)
--   4. .venv/bin/python in cwd             (project venv)
--   5. venv/bin/python in cwd              (project venv alt)
--   6. $PYENV_ROOT/shims/python3           (pyenv shim)
--   7. system python3                       (final fallback)

local M = {}

local function is_executable(path)
  return path and path ~= '' and vim.fn.executable(path) == 1
end

local function resolve_python()
  local pyenv_root = os.getenv('PYENV_ROOT') or (os.getenv('HOME') .. '/.pyenv')

  -- 1. Dedicated 'neovim' pyenv virtualenv
  local nvim_venv = pyenv_root .. '/versions/neovim/bin/python'
  if is_executable(nvim_venv) then
    return nvim_venv, 'pyenv:neovim-venv'
  end

  -- 2. pyenv local
  local pyenv_local = vim.fn.system('pyenv local --unset 2>/dev/null; pyenv which python3 2>/dev/null'):gsub('\n', '')
  if pyenv_local == '' then
    local local_ver = vim.fn.system('cat .python-version 2>/dev/null'):gsub('\n', '')
    if local_ver ~= '' then
      pyenv_local = pyenv_root .. '/versions/' .. local_ver .. '/bin/python'
    end
  end
  if is_executable(pyenv_local) then
    return pyenv_local, 'pyenv:local'
  end

  -- 3. pyenv global
  local global_ver = vim.fn.system('pyenv global 2>/dev/null'):gsub('\n', '')
  if global_ver ~= '' and global_ver ~= 'system' then
    local global_py = pyenv_root .. '/versions/' .. global_ver .. '/bin/python3'
    if is_executable(global_py) then
      return global_py, 'pyenv:global(' .. global_ver .. ')'
    end
  end

  -- 4. Project .venv
  local cwd = vim.fn.getcwd()
  local project_venv = cwd .. '/.venv/bin/python'
  if is_executable(project_venv) then
    return project_venv, 'project:.venv'
  end

  -- 5. Project venv
  local project_venv2 = cwd .. '/venv/bin/python'
  if is_executable(project_venv2) then
    return project_venv2, 'project:venv'
  end

  -- 6. pyenv shim
  local pyenv_shim = pyenv_root .. '/shims/python3'
  if is_executable(pyenv_shim) then
    return pyenv_shim, 'pyenv:shim'
  end

  -- 7. System Python
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
