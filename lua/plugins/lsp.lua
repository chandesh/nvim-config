-- Robust LSP configuration without PathD errors
return {
  -- Mason for managing language servers
  {
    "williamboman/mason.nvim",
    cmd = "Mason",
    keys = { { "<leader>cm", "<cmd>Mason<cr>", desc = "Mason" } },
    build = ":MasonUpdate",
    config = function()
      require("mason").setup({
        ui = {
          border = "rounded",
          icons = {
            package_installed = "✓",
            package_pending = "➜",
            package_uninstalled = "✗"
          }
        }
      })
    end,
  },

  -- Bridge between mason and lspconfig
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = {
      "williamboman/mason.nvim",
      "neovim/nvim-lspconfig",
    },
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = {
          -- Use Pyright instead of pylsp to avoid PathD errors
          "pyright",
          -- JavaScript/TypeScript
          "ts_ls",
          "eslint",
          -- Web
          "html",
          "cssls",
          "emmet_ls",
          -- JSON
          "jsonls",
          -- YAML
          "yamlls",
          -- Lua
          "lua_ls",
        },
        automatic_installation = true,
        -- Explicitly block pylsp from being installed
        handlers = {
          -- Default handler
          function(server_name)
            -- Block pylsp from being set up
            if server_name == "pylsp" then
              vim.notify("Blocking pylsp installation - using Pyright instead", vim.log.levels.INFO)
              return
            end
            -- Setup other servers normally
            require("lspconfig")[server_name].setup({})
          end,
        },
      })
    end,
  },

  -- LSP Configuration
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "williamboman/mason-lspconfig.nvim",
      "hrsh7th/cmp-nvim-lsp",
      "folke/neodev.nvim",
    },
    config = function()
      -- Neodev setup for better Lua LSP
      require("neodev").setup()

      local lspconfig = require("lspconfig")
      local cmp_nvim_lsp = require("cmp_nvim_lsp")

      -- LSP capabilities with nvim-cmp
      local capabilities = cmp_nvim_lsp.default_capabilities()

      -- Diagnostic configuration
      vim.diagnostic.config({
        underline = true,
        update_in_insert = false,
        virtual_text = {
          spacing = 4,
          source = "if_many",
          prefix = "●",
        },
        severity_sort = true,
        signs = {
          text = {
            [vim.diagnostic.severity.ERROR] = "✘",
            [vim.diagnostic.severity.WARN] = "▲",
            [vim.diagnostic.severity.INFO] = "⚑",
            [vim.diagnostic.severity.HINT] = "💡",
          },
        },
      })

      -- LSP keymaps
      local on_attach = function(client, bufnr)
        local opts = { buffer = bufnr, silent = true }
        
        -- Navigation keymaps
        if client.server_capabilities.definitionProvider then
          vim.keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "Go to Definition", buffer = bufnr, silent = true })
        end
        
        if client.server_capabilities.declarationProvider then
          vim.keymap.set("n", "gD", vim.lsp.buf.declaration, { desc = "Go to Declaration", buffer = bufnr, silent = true })
        else
          vim.keymap.set("n", "gD", vim.lsp.buf.definition, { desc = "Go to Definition (fallback)", buffer = bufnr, silent = true })
        end
        
        vim.keymap.set("n", "gi", vim.lsp.buf.implementation, { desc = "Go to Implementation", unpack(opts) })
        vim.keymap.set("n", "gt", vim.lsp.buf.type_definition, { desc = "Go to Type Definition", unpack(opts) })
        vim.keymap.set("n", "gr", vim.lsp.buf.references, { desc = "References", unpack(opts) })

        -- Documentation
        vim.keymap.set("n", "K", vim.lsp.buf.hover, { desc = "Hover Documentation", unpack(opts) })
        vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, { desc = "Signature Help", unpack(opts) })
        
        -- Code actions
        vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, { desc = "Code Action", unpack(opts) })
        vim.keymap.set("n", "<leader>cr", vim.lsp.buf.rename, { desc = "Rename", unpack(opts) })

        -- Formatting
        if client.server_capabilities.documentFormattingProvider then
          vim.keymap.set("n", "<leader>cf", function()
            vim.lsp.buf.format({ async = true })
          end, { desc = "Format Document", unpack(opts) })
        end
      end

      -- Language server configurations
      local servers = {
        -- Python Language Server (Pyright - more stable than pylsp)
        pyright = {
          settings = {
            python = {
              analysis = {
                autoSearchPaths = true,
                useLibraryCodeForTypes = true,
                diagnosticMode = 'openFilesOnly',
                typeCheckingMode = "basic",
              },
            },
          },
        },

        -- TypeScript/JavaScript
        ts_ls = {
          settings = {
            typescript = {
              inlayHints = {
                includeInlayParameterNameHints = "literal",
                includeInlayFunctionParameterTypeHints = true,
                includeInlayVariableTypeHints = false,
                includeInlayPropertyDeclarationTypeHints = true,
                includeInlayFunctionLikeReturnTypeHints = true,
              },
            },
            javascript = {
              inlayHints = {
                includeInlayParameterNameHints = "all",
                includeInlayFunctionParameterTypeHints = true,
                includeInlayVariableTypeHints = true,
                includeInlayPropertyDeclarationTypeHints = true,
                includeInlayFunctionLikeReturnTypeHints = true,
              },
            },
          },
        },

        -- ESLint
        eslint = {
          settings = {
            codeAction = {
              disableRuleComment = {
                enable = true,
                location = "separateLine"
              },
            },
            format = true,
            validate = "on",
          }
        },

        -- HTML
        html = {
          filetypes = { "html", "htmldjango" }
        },

        -- CSS
        cssls = {},

        -- Emmet
        emmet_ls = {
          filetypes = { "html", "css", "scss", "javascript", "javascriptreact", "typescript", "typescriptreact", "htmldjango" }
        },

        -- JSON
        jsonls = {
          settings = {
            json = {
              schemas = require('schemastore').json.schemas(),
              validate = { enable = true },
            },
          },
        },

        -- YAML
        yamlls = {
          settings = {
            yaml = {
              schemaStore = {
                enable = false,
                url = "",
              },
              schemas = require('schemastore').yaml.schemas(),
            },
          },
        },

        -- Lua
        lua_ls = {
          settings = {
            Lua = {
              workspace = {
                checkThirdParty = false,
              },
              completion = {
                callSnippet = "Replace",
              },
            },
          },
        },
      }

      -- Explicitly disable pylsp to prevent PathD errors
      if lspconfig.pylsp then
        lspconfig.pylsp.setup = function()
          vim.notify("pylsp blocked - using Pyright for Python instead", vim.log.levels.WARN)
          return false
        end
      end
      
      -- Setup servers
      for server, config in pairs(servers) do
        config.capabilities = capabilities
        config.on_attach = on_attach
        lspconfig[server].setup(config)
      end
    end,
  },

  -- JSON/YAML schema support
  {
    "b0o/schemastore.nvim",
    lazy = true,
  },

  -- Neovim development support
  {
    "folke/neodev.nvim",
    lazy = true,
  },
}
