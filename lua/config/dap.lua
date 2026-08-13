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

  -- Keep the lualine DAP status indicator in sync as the session progresses.
  local function refresh_statusline()
    vim.cmd('redrawstatus')
  end
  dap.listeners.after.event_initialized.statusline = function() refresh_statusline() end
  dap.listeners.after.event_stopped.statusline = function() refresh_statusline() end
  dap.listeners.after.event_continued.statusline = function() refresh_statusline() end
  dap.listeners.after.event_exited.statusline = function() refresh_statusline() end
  dap.listeners.before.event_terminated.statusline = function() refresh_statusline() end
  dap.listeners.before.disconnect.statusline = function() refresh_statusline() end

  packadd('nvim-dap-python')
  local py_path, py_src = get_python()
  require('dap-python').setup(py_path)
  vim.notify('[dap] Python debugger using: ' .. py_src .. ' → ' .. py_path, vim.log.levels.DEBUG)

  -- ── Remote Container Bridge ──────────────────────────────────────────────────
  local env_bridge = require('config.env_bridge')
  local dap = require('dap')

  -- Attach directly over TCP to the debugpy server running in the container
  -- (`python -m debugpy --listen 0.0.0.0:5678 …`). A `server` adapter makes
  -- nvim-dap speak the DAP protocol straight to the remote debugpy, avoiding the
  -- host-vs-container debugpy version mismatch entirely.
  dap.adapters.python_remote = {
    type = 'server',
    host = '127.0.0.1',
    port = 5678,
  }

  dap.configurations.python = {
    {
      type = 'python_remote',
      request = 'attach',
      name = 'Docker: Attach to Container',
      pathMappings = function()
        local config = env_bridge.get_config()
        if not config then return {} end
        -- debugpy requires a list of { localRoot, remoteRoot } maps for
        -- breakpoint path translation. localRoot = local copy of the source,
        -- remoteRoot = the container path (config.app_path).
        return {
          {
            localRoot = env_bridge.get_local_source_dir() or vim.fn.getcwd(),
            remoteRoot = config.app_path,
          },
        }
      end,
    },
  }

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