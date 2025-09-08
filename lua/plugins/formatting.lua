-- ========================================
-- Formatters and Linters Configuration
-- ========================================

return {
  -- Modern formatting plugin
  {
    "stevearc/conform.nvim",
    dependencies = { "williamboman/mason.nvim" },
    event = { "BufReadPre", "BufNewFile" },
    keys = {
      {
        "<leader>cf",
        function()
          require("conform").format({ async = true, lsp_fallback = true })
        end,
        mode = { "n", "v" },
        desc = "Format buffer",
      },
    },
    config = function()
      local conform = require("conform")

      conform.setup({
        formatters_by_ft = {
          -- Python
          python = { "black", "isort" },
          
          -- JavaScript/TypeScript
          javascript = { "prettier" },
          typescript = { "prettier" },
          javascriptreact = { "prettier" },
          typescriptreact = { "prettier" },
          
          -- Web languages
          html = { "prettier" },
          css = { "prettier" },
          scss = { "prettier" },
          sass = { "prettier" },
          less = { "prettier" },
          
          -- JSON/YAML
          json = { "prettier" },
          jsonc = { "prettier" },
          yaml = { "prettier" },
          
          -- Markdown
          markdown = { "prettier" },
          
          -- Lua
          lua = { "stylua" },
          
          -- Shell
          sh = { "shfmt" },
          bash = { "shfmt" },
          
          -- Django templates
          htmldjango = { "djlint" },
        },

        -- Disable auto-formatting on save (manual only to avoid git diff noise in legacy code)
        -- format_on_save = false,

        -- Custom formatters
        formatters = {
          black = {
            prepend_args = { 
              "--line-length", "88", 
              "--skip-string-normalization",
              "--fast"  -- Enable fast mode for better performance
            },
          },
          prettier = {
            prepend_args = function()
              -- Check for project-specific prettier config
              local config_files = vim.fs.find({
                ".prettierrc",
                ".prettierrc.json",
                ".prettierrc.js",
                "prettier.config.js",
                ".prettierrc.yml",
                ".prettierrc.yaml",
              }, { upward = true, path = vim.fn.getcwd() })
              
              if #config_files > 0 then
                return {}
              else
                -- Default prettier settings for consistency
                return {
                  "--print-width", "80",
                  "--tab-width", "2",
                  "--use-tabs", "false",
                  "--semi", "true",
                  "--single-quote", "true",
                  "--quote-props", "as-needed",
                  "--trailing-comma", "es5",
                  "--bracket-spacing", "true",
                  "--bracket-same-line", "false",
                  "--arrow-parens", "avoid",
                }
              end
            end,
          },
          stylua = {
            prepend_args = { "--column-width", "120", "--line-endings", "Unix", "--indent-type", "Spaces", "--indent-width", "2" },
          },
          shfmt = {
            prepend_args = { "-i", "2", "-ci", "-bn" },
          },
          djlint = {
            args = { "--reformat", "--indent", "2", "-" },
            stdin = true,
          },
        },
      })

      -- Install formatters via Mason
      local mason_registry = require("mason-registry")
      local formatters_to_install = {
        "black", "isort", "prettier", "stylua", "shfmt", "djlint"
      }

      for _, formatter in ipairs(formatters_to_install) do
        if not mason_registry.is_installed(formatter) then
          vim.cmd("MasonInstall " .. formatter)
        end
      end
    end,
  },

  -- Linting support
  {
    "mfussenegger/nvim-lint",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      local lint = require("lint")

      lint.linters_by_ft = {
        -- Python
        python = { "flake8", "mypy" },
        
        -- JavaScript/TypeScript
        javascript = { "eslint_d" },
        typescript = { "eslint_d" },
        javascriptreact = { "eslint_d" },
        typescriptreact = { "eslint_d" },
        
        -- JSON
        json = { "jsonlint" },
        
        -- YAML
        yaml = { "yamllint" },
        
        -- Markdown
        markdown = { "markdownlint" },
        
        -- Shell
        sh = { "shellcheck" },
        bash = { "shellcheck" },
        
        -- Docker
        dockerfile = { "hadolint" },
        
        -- Django templates
        htmldjango = { "djlint" },
      }

      -- Custom linter configurations
      lint.linters.flake8.args = {
        "--format=%(path)s:%(row)d:%(col)d: %(code)s %(text)s",
        "--max-line-length=88",
        "--extend-ignore=E203,W503,E501",
        "--stdin-display-name",
        function()
          return vim.api.nvim_buf_get_name(0)
        end,
        "-",
      }

      lint.linters.mypy.args = {
        "--show-column-numbers",
        "--show-error-codes",
        "--show-error-context",
        "--no-color-output",
        "--no-error-summary",
        "--no-pretty",
        function()
          return vim.api.nvim_buf_get_name(0)
        end,
      }

      -- Auto lint on certain events
      local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })
      vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave", "TextChanged" }, {
        group = lint_augroup,
        callback = function()
          -- Only lint if LSP is not available for the current filetype
          local clients = vim.lsp.get_active_clients({ bufnr = 0 })
          if #clients == 0 then
            lint.try_lint()
          end
        end,
      })

      -- Manually trigger linting
      vim.keymap.set("n", "<leader>cl", function()
        lint.try_lint()
      end, { desc = "Trigger linting for current file" })

      -- Install linters via Mason
      local mason_registry = require("mason-registry")
      local linters_to_install = {
        "flake8", "mypy", "eslint_d", "jsonlint", "yamllint", 
        "markdownlint", "shellcheck", "hadolint", "djlint"
      }

      for _, linter in ipairs(linters_to_install) do
        if not mason_registry.is_installed(linter) then
          vim.cmd("MasonInstall " .. linter)
        end
      end
    end,
  },

  -- Mason integration for tools
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    dependencies = { "williamboman/mason.nvim" },
    config = function()
      require("mason-tool-installer").setup({
        ensure_installed = {
          -- Formatters
          "black",
          "isort",
          "prettier",
          "stylua",
          "shfmt",
          "djlint",
          
          -- Linters
          "flake8",
          "mypy",
          "eslint_d",
          "jsonlint",
          "yamllint",
          "markdownlint",
          "shellcheck",
          "hadolint",
          
          -- Language servers (ensure they're installed)
          "pylsp",
          "typescript-language-server",
          "html-lsp",
          "css-lsp",
          "json-lsp",
          "yaml-language-server",
          "lua-language-server",
          "emmet-ls",
          
          -- DAP adapters
          "debugpy",
          "node-debug2-adapter",
        },
        auto_update = false,
        run_on_start = true,
        start_delay = 3000,
      })
    end,
  },

  -- Auto-detect and configure project-specific settings
  {
    "editorconfig/editorconfig-vim",
    event = "BufReadPre",
    config = function()
      vim.g.EditorConfig_exclude_patterns = { "fugitive://.*", "scp://.*" }
    end,
  },

  -- Python environment and imports management
  {
    "linux-cultist/venv-selector.nvim",
    dependencies = { "neovim/nvim-lspconfig", "nvim-telescope/telescope.nvim", "mfussenegger/nvim-dap-python" },
    cmd = "VenvSelect",
    keys = {
      { "<leader>cv", "<cmd>VenvSelect<cr>", desc = "Select VirtualEnv" },
    },
    config = function()
      require("venv-selector").setup({
        auto_refresh = true,
        dap_enabled = true,
        parents = 2,
        name = {
          "venv",
          ".venv",
          "env",
          ".env",
        },
      })
    end,
  },

  -- Organize Python imports automatically
  {
    "stsewd/isort.nvim",
    ft = "python",
    cmd = { "Isort", "IsortAsync" },
    keys = {
      { "<leader>ci", "<cmd>Isort<cr>", desc = "Organize imports", ft = "python" },
    },
    build = ":UpdateRemotePlugins", -- Required for remote plugins
    config = function()
      -- Configure isort.nvim (it's a remote plugin, uses vim variables)
      -- First try to use system isort if available
      if vim.fn.executable("isort") == 1 then
        vim.g.isort_command = "isort"
      elseif vim.fn.executable("/opt/homebrew/bin/python3.11") == 1 then
        -- Use Homebrew python with isort module
        vim.g.isort_command = "/opt/homebrew/bin/python3.11 -m isort"
      else
        -- Fallback to default
        vim.g.isort_command = "isort"
      end
    end,
  },
}
