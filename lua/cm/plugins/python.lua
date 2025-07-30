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
    keys = {
      { "<leader>pi", "<cmd>PyenvInfo<cr>", desc = "Show pyenv info" },
      { "<leader>pr", "<cmd>PyenvReactivate<cr>", desc = "Reactivate pyenv environment" },
      { "<leader>pl", "<cmd>PyenvInstallLSP<cr>", desc = "Install LSP packages" },
    },
  },
  
  -- Enhanced Python debugging
  {
    "mfussenegger/nvim-dap-python",
    ft = "python",
    dependencies = {
      "mfussenegger/nvim-dap",
      "rcarriga/nvim-dap-ui",
    },
    config = function()
      local path = "~/.local/share/nvim/mason/packages/debugpy/venv/bin/python"
      require("dap-python").setup(path)
      
      -- Python-specific debugging keymaps
      local keymap = vim.keymap
      keymap.set("n", "<leader>dpr", function() require("dap-python").test_method() end, { desc = "Debug Python test method" })
      keymap.set("n", "<leader>dpc", function() require("dap-python").test_class() end, { desc = "Debug Python test class" })
      keymap.set("v", "<leader>ds", function() require("dap-python").debug_selection() end, { desc = "Debug Python selection" })
    end,
  },
  
  -- Better Python syntax and features
  {
    "Vimjas/vim-python-pep8-indent",
    ft = "python",
  },
  
  -- Django template support
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
  },
}
