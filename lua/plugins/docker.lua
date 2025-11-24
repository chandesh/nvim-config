-- ========================================
-- Docker Development & Debugging Configuration
-- ========================================
-- Extends existing DAP setup with Docker debugging capabilities
-- Does NOT interfere with existing local debugging workflow

return {
  -- Docker management UI (Optional - commented out due to reactivex dependency)
  -- Uncomment if you install reactivex: luarocks install reactivex
  --[[
  {
    "dgrbrady/nvim-docker",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
    },
    cmd = {
      "Docker",
      "DockerPs",
      "DockerImages",
      "DockerContainers",
      "DockerExec",
      "DockerLogs",
    },
    keys = {
      { "<leader>Dk", "<cmd>Docker<cr>", desc = "Docker Dashboard" },
      { "<leader>Dp", "<cmd>DockerPs<cr>", desc = "Docker PS (Running Containers)" },
      { "<leader>Di", "<cmd>DockerImages<cr>", desc = "Docker Images" },
      { "<leader>Dx", "<cmd>DockerExec<cr>", desc = "Docker Exec into Container" },
      { "<leader>Dl", "<cmd>DockerLogs<cr>", desc = "Docker Logs" },
    },
    config = function()
      require("nvim-docker").setup({
        compose_command = "docker compose",
        refresh_interval = 5,
      })
    end,
  },
  --]]

  -- Extend existing nvim-dap with Docker debugging configurations
  {
    "mfussenegger/nvim-dap",
    optional = true,
    keys = {
      -- Docker debugging is accessed via normal debug menu (<leader>dc)
      -- No separate keybinds needed - Docker configs appear in debug selection
    },
    config = function()
      local dap = require("dap")

      -- ===================================
      -- Docker Python Debugging Configurations
      -- ===================================
      -- These are ADDED to existing configurations, not replacing them

      -- 1. Attach to Python app in Docker container (standard debugpy port)
      table.insert(dap.configurations.python, {
        type = "python",
        request = "attach",
        name = "🐳 Docker: Attach to Container (port 5678)",
        connect = {
          host = "127.0.0.1",
          port = 5678,
        },
        pathMappings = {
          {
            localRoot = vim.fn.getcwd(),
            remoteRoot = "/app",
          },
        },
        justMyCode = false,
      })

      -- 2. Attach to Django in Docker
      table.insert(dap.configurations.python, {
        type = "python",
        request = "attach",
        name = "🐳 Docker: Attach to Django (port 5678)",
        connect = {
          host = "127.0.0.1",
          port = 5678,
        },
        pathMappings = {
          {
            localRoot = vim.fn.getcwd(),
            remoteRoot = "/app",
          },
        },
        django = true,
        justMyCode = false,
      })

      -- 3. Attach to Docker with custom port and path
      table.insert(dap.configurations.python, {
        type = "python",
        request = "attach",
        name = "🐳 Docker: Custom Port/Path",
        connect = function()
          local host = vim.fn.input("Container Host [127.0.0.1]: ")
          host = host ~= "" and host or "127.0.0.1"
          local port = tonumber(vim.fn.input("Port [5678]: ")) or 5678
          return { host = host, port = port }
        end,
        pathMappings = function()
          local local_root = vim.fn.input("Local Root [" .. vim.fn.getcwd() .. "]: ")
          local_root = local_root ~= "" and local_root or vim.fn.getcwd()
          local remote_root = vim.fn.input("Remote Root [/app]: ")
          remote_root = remote_root ~= "" and remote_root or "/app"
          return {
            {
              localRoot = local_root,
              remoteRoot = remote_root,
            }
          }
        end,
        justMyCode = false,
      })

      -- 4. Attach to remote container on different host
      table.insert(dap.configurations.python, {
        type = "python",
        request = "attach",
        name = "🐳 Docker: Remote Host",
        connect = function()
          local host = vim.fn.input("Remote Host: ")
          local port = tonumber(vim.fn.input("Port [5678]: ")) or 5678
          return { host = host, port = port }
        end,
        pathMappings = {
          {
            localRoot = vim.fn.getcwd(),
            remoteRoot = "/app",
          },
        },
        justMyCode = false,
      })

      -- Create Docker debugging helper commands
      vim.api.nvim_create_user_command("DockerDebugAttach", function()
        -- Quick attach to standard Docker debugpy setup
        dap.run({
          type = "python",
          request = "attach",
          name = "Quick Docker Attach",
          connect = { host = "127.0.0.1", port = 5678 },
          pathMappings = {
            { localRoot = vim.fn.getcwd(), remoteRoot = "/app" }
          },
          justMyCode = false,
        })
      end, { desc = "Quick attach to Docker container debugger" })

      vim.api.nvim_create_user_command("DockerDebugInfo", function()
        local info = [[
Docker Debugging Setup Guide:
==============================

1. Add debugpy to your Dockerfile/requirements.txt:
   pip install debugpy

2. Start your app with debugpy in docker-compose.yml:
   
   services:
     web:
       build: .
       volumes:
         - .:/app
       ports:
         - "8000:8000"   # Django/Flask app
         - "5678:5678"   # Debugpy port
       command: python -m debugpy --listen 0.0.0.0:5678 --wait-for-client manage.py runserver 0.0.0.0:8000

3. Start your containers:
   docker compose up

4. In Neovim:
   - Set breakpoints: <leader>db
   - Start debugging: <leader>dc
   - Select "🐳 Docker: Attach to Django"

5. Your breakpoints will hit when code executes!

Keybindings:
- <leader>Dk - Docker Dashboard
- <leader>Dp - Running Containers
- <leader>Dx - Exec into Container
- <leader>dc - Start/Continue Debugging

Path Mappings:
- Local:  ]] .. vim.fn.getcwd() .. [[

- Remote: /app (default)

If paths differ, use "🐳 Docker: Custom Port/Path" config.
]]
        
        -- Create a floating window with the info
        local buf = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(info, "\n"))
        vim.api.nvim_buf_set_option(buf, "modifiable", false)
        vim.api.nvim_buf_set_option(buf, "filetype", "markdown")
        
        local width = 80
        local height = 35
        local win = vim.api.nvim_open_win(buf, true, {
          relative = "editor",
          width = width,
          height = height,
          col = (vim.o.columns - width) / 2,
          row = (vim.o.lines - height) / 2,
          style = "minimal",
          border = "rounded",
        })
        
        -- Close on q or Esc
        vim.api.nvim_buf_set_keymap(buf, "n", "q", ":close<CR>", { noremap = true, silent = true })
        vim.api.nvim_buf_set_keymap(buf, "n", "<Esc>", ":close<CR>", { noremap = true, silent = true })
      end, { desc = "Show Docker debugging setup guide" })
    end,
  },
}
