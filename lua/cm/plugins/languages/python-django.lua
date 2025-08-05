-- Comprehensive Python and Django development support
-- This file contains all Python-related plugins including Django-specific tools
return {
  -- Python environment management with pyenv integration
  {
    "nvim-lua/plenary.nvim", -- Required for pyenv commands
    config = function()
      local pyenv = require("cm.core.pyenv")
      
      -- Create pyenv-related commands
      vim.api.nvim_create_user_command("PyenvInfo", function()
        local env_name = pyenv.get_env_name()
        local python_executable = pyenv.get_python_executable()
        local site_packages = pyenv.get_site_packages_path()
        
        local info = string.format(
          "Current pyenv environment: %s\nPython executable: %s\nSite-packages: %s",
          env_name or "None",
          python_executable or "None",
          site_packages or "None"
        )
        vim.notify(info, vim.log.levels.INFO)
      end, { desc = "Show current pyenv environment info" })
      
      vim.api.nvim_create_user_command("PyenvReactivate", function()
        pyenv.activate()
        vim.cmd("LspRestart")
      end, { desc = "Reactivate pyenv environment and restart LSP" })
      
      vim.api.nvim_create_user_command("PyenvInstallLSP", function()
        pyenv.ensure_lsp_packages()
      end, { desc = "Install LSP packages in current pyenv environment" })
    end,
  },
  
  -- Enhanced Python support
  {
    "Vimjas/vim-python-pep8-indent",
    ft = "python",
  },
  
  {
    "vim-python/python-syntax",
    ft = "python",
    config = function()
      vim.g.python_highlight_all = 1
      vim.g.python_highlight_space_errors = 0
      vim.g.python_highlight_func_calls = 1
      vim.g.python_highlight_class_vars = 1
      vim.g.python_highlight_operators = 1
    end,
  },
  
  -- Django support
  {
    "tweekmonster/django-plus.vim",
    ft = { "python", "htmldjango" },
    config = function()
      vim.g.django_activate_venv = 1
      -- Set Django settings module if needed
      -- vim.env.DJANGO_SETTINGS_MODULE = "myproject.settings"
    end,
  },
  
  -- Django template support
  {
    "mjbrownie/vim-htmldjango_omnicomplete",
    ft = "htmldjango",
  },
  
  -- Enhanced Django template detection
  {
    "glench/vim-jinja2-syntax",
    ft = { "htmldjango", "jinja2" },
  },
  
  -- Python docstring support
  {
    "heavenshell/vim-pydocstring",
    ft = "python",
    build = "make install",
    config = function()
      vim.g.pydocstring_formatter = "google"
      -- Keymaps are now managed in lua/cm/core/keymaps.lua
    end,
  },
  
  -- Python virtual environment detection
  {
    "AckslD/swenv.nvim",
    ft = "python",
    config = function()
      require("swenv").setup({
        get_venvs = function(venvs_path)
          return require("swenv.api").get_venvs(venvs_path)
        end,
        venvs_path = vim.fn.expand("~/.pyenv/versions"),
        post_set_venv = function()
          vim.cmd("LspRestart")
        end,
      })
      
      -- Keymaps are now managed in lua/cm/core/keymaps.lua
    end,
  },
  
  -- Python debugging support
  {
    "mfussenegger/nvim-dap-python",
    ft = "python",
    dependencies = {
      "mfussenegger/nvim-dap",
      "rcarriga/nvim-dap-ui",
    },
    config = function()
      -- Use Mason's debugpy installation as fallback, but prefer pyenv
      local python_path = require("cm.core.pyenv").get_python_executable()
      local mason_debugpy = vim.fn.expand("~/.local/share/nvim/mason/packages/debugpy/venv/bin/python")
      
      -- Use pyenv python if available, otherwise fall back to Mason's debugpy
      local debugpy_python = python_path or mason_debugpy
      require("dap-python").setup(debugpy_python)
      
      -- Keymaps are now managed in lua/cm/core/keymaps.lua
    end,
  },
  
  -- Python testing support
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-neotest/neotest-python",
      "nvim-lua/plenary.nvim",
      "antoinemadec/FixCursorHold.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    ft = "python",
    config = function()
      require("neotest").setup({
        adapters = {
          require("neotest-python")({
            dap = { justMyCode = false },
            runner = "pytest",
            python = require("cm.core.pyenv").get_python_executable(),
          }),
        },
      })
      
      -- Keymaps are now managed in lua/cm/core/keymaps.lua
    end,
  },
  
  -- Django-specific enhancements
  {
    "pappasam/nvim-repl",
    ft = "python",
    config = function()
      -- Django shell integration
      vim.g.repl_filetype_commands = {
        python = "python manage.py shell",
      }
    end,
  },
}
