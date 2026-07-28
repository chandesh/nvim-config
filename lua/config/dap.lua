local M = {}

local function packadd(name)
  vim.cmd('packadd ' .. name)
end

local function get_python()
  local ok, python_host = pcall(require, 'config.python_host')
  if ok and python_host.resolve then
    local path, src = python_host.resolve()
    if path then
      return path, src
    end
  end
  return vim.fn.exepath('python3'), 'fallback'
end

function M.setup()
  packadd('nvim-dap')
  packadd('nvim-dap-ui')
  packadd('nvim-nio')
  packadd('nvim-dap-virtual-text')

  local dap = require('dap')
  local dapui = require('dapui')

  dapui.setup({
    layouts = {
      {
        elements = {
          { id = "scopes",      size = 0.25 },
          { id = "breakpoints", size = 0.25 },
          { id = "stacks",      size = 0.25 },
          { id = "watches",     size = 0.25 },
        },
        position = "right",
        size = 40,
      },
      {
        elements = {
          { id = "repl",      size = 0.5 },
          { id = "console",   size = 0.5 },
        },
        position = "bottom",
        size = 12,
      },
    },
    floating = {
      max_height = 0.8,
      max_width = 0.6,
    },
  })

  require('nvim-dap-virtual-text').setup()

  dap.listeners.before.attach.dapui = dapui.open
  dap.listeners.before.launch.dapui = dapui.open
  dap.listeners.before.event_terminated.dapui = dapui.close
  dap.listeners.before.event_exited.dapui = dapui.close

  packadd('nvim-dap-python')
  local py_path, py_src = get_python()
  require('dap-python').setup(py_path)
  vim.notify('[dap] Python debugger using: ' .. py_src .. ' → ' .. py_path, vim.log.levels.DEBUG)

  packadd('nvim-dap-go')
  require('dap-go').setup()

  vim.api.nvim_create_autocmd('DirChanged', {
    group = vim.api.nvim_create_augroup('DapPythonUpdate', { clear = true }),
    callback = function()
      local new_path, new_src = get_python()
      require('dap-python').setup(new_path)
      vim.notify('[dap] Python debugger switched to: ' .. new_src .. ' → ' .. new_path, vim.log.levels.DEBUG)
    end,
  })
end

return M