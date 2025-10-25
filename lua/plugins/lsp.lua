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
    -- NOTE: mason-lspconfig config is now handled in lspconfig plugin's config
    -- to ensure on_attach is defined before handlers are set up
  },

  -- LSP Configuration
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      {
        "williamboman/mason-lspconfig.nvim",
        config = false,  -- Disable auto-config, we'll configure it ourselves
      },
      "hrsh7th/cmp-nvim-lsp",
      "folke/neodev.nvim",
    },
    config = function()
      -- Neodev setup for better Lua LSP
      require("neodev").setup()

      local lspconfig = require("lspconfig")
      local cmp_nvim_lsp = require("cmp_nvim_lsp")

      -- Robust LSP handlers for definition/declaration (work around no-jump cases)
      local function jump_to_first_location(result)
        if not result or (type(result) == 'table' and vim.tbl_isempty(result)) then
          vim.notify("No locations found", vim.log.levels.WARN)
          return
        end
        local loc
        if vim.tbl_islist(result) then
          loc = result[1]
        else
          loc = result
        end
        -- Normalize LocationLink to Location
        if loc.targetUri then
          loc = { uri = loc.targetUri, range = loc.targetSelectionRange or loc.targetRange }
        end
        vim.lsp.util.jump_to_location(loc, "utf-8")
      end

      vim.lsp.handlers["textDocument/definition"] = function(err, result, ctx, config)
        if err then
          vim.notify("LSP definition error: " .. (err.message or vim.inspect(err)), vim.log.levels.ERROR)
          return
        end
        jump_to_first_location(result)
      end

      vim.lsp.handlers["textDocument/declaration"] = function(err, result, ctx, config)
        if err then
          vim.notify("LSP declaration error: " .. (err.message or vim.inspect(err)), vim.log.levels.ERROR)
          return
        end
        jump_to_first_location(result)
      end

      -- LSP capabilities with nvim-cmp
      local capabilities = cmp_nvim_lsp.default_capabilities()
      
      -- Python environment detection (moved before on_attach)
      local function get_python_path()
        local venv = vim.env.VIRTUAL_ENV
        if venv then
          return venv .. '/bin/python'
        else
          -- Check if pyenv is available
          local handle = io.popen('which pyenv 2>/dev/null')
          if handle then
            local pyenv_path = handle:read('*a'):gsub('%s+$', '')
            handle:close()
            
            if pyenv_path ~= '' then
              -- Get current pyenv python
              handle = io.popen('pyenv which python 2>/dev/null')
              if handle then
                local python_path = handle:read('*a'):gsub('%s+$', '')
                handle:close()
                
                if python_path ~= '' then
                  return python_path
                end
              end
            end
          end
          
          vim.notify(
            'No Python virtual environment detected!\n' ..
            'Please activate a virtual environment or create one:\n' ..
            '  pyenv virtualenv <python-version> your-project-env\n' ..
            '  pyenv activate your-project-env',
            vim.log.levels.ERROR
          )
          return nil
        end
      end

      local python_path = get_python_path()

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
        local function map(mode, lhs, rhs, desc)
          vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, silent = true, desc = desc })
        end
        
        -- Navigation keymaps
        -- Always set gd to go to definition (all LSP servers support this)
        map("n", "gd", vim.lsp.buf.definition, "Go to Definition")
        
        -- gD goes to declaration if supported, otherwise to definition
        if client.server_capabilities.declarationProvider then
          map("n", "gD", vim.lsp.buf.declaration, "Go to Declaration")
        else
          map("n", "gD", vim.lsp.buf.definition, "Go to Definition")
        end
        
        map("n", "gi", vim.lsp.buf.implementation, "Go to Implementation")
        map("n", "gy", vim.lsp.buf.type_definition, "Go to Type Definition")  -- Changed from gt to gy
        map("n", "gr", vim.lsp.buf.references, "Go to References")

        -- Documentation
        map("n", "K", vim.lsp.buf.hover, "Hover Documentation")
        map("n", "<C-k>", vim.lsp.buf.signature_help, "Signature Help")
        
        -- Code actions
        map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, "Code Action")
        map("n", "<leader>cr", vim.lsp.buf.rename, "Rename")

        -- Formatting
        if client.server_capabilities.documentFormattingProvider then
          map("n", "<leader>cf", function()
            vim.lsp.buf.format({ async = true })
          end, "Format Document")
        end
        
        -- Register with which-key for visibility
        local ok, wk = pcall(require, "which-key")
        if ok then
          wk.add({
            { "gd", desc = "[LSP] Go to Definition", buffer = bufnr },
            { "gD", desc = "[LSP] Go to Declaration", buffer = bufnr },
            { "gi", desc = "[LSP] Go to Implementation", buffer = bufnr },
            { "gy", desc = "[LSP] Go to Type Definition", buffer = bufnr },
            { "gr", desc = "[LSP] Go to References", buffer = bufnr },
            { "K", desc = "[LSP] Hover Documentation", buffer = bufnr },
            { "<C-k>", desc = "[LSP] Signature Help", buffer = bufnr, mode = "n" },
          })
        end
      end

      -- Language server configurations
      local servers = {
        -- Python Language Server (Pyright)
        pyright = {
          settings = {
            python = {
              pythonPath = python_path,
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

      -- Setup mason-lspconfig NOW that on_attach is defined
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
        handlers = {
          -- Default handler
          function(server_name)
            -- Block pylsp from being set up
            if server_name == "pylsp" then
              vim.notify("Blocking pylsp installation - using Pyright instead", vim.log.levels.INFO)
              return
            end
            
            -- Skip Python servers if no environment is detected
            if server_name == "pyright" then
              if not python_path then
                vim.notify('Skipping Pyright setup - no Python environment detected', vim.log.levels.WARN)
                return
              end
            end
            
            -- Get server-specific configuration and merge with common config
            local server_config = servers[server_name] or {}
            local config = vim.tbl_deep_extend("force", {
              capabilities = capabilities,
              on_attach = on_attach,
            }, server_config)
            
            
            -- Setup server with configuration
            lspconfig[server_name].setup(config)
          end,
        },
      })
      
      -- LspAttach autocmd as failsafe
      -- Ensures on_attach is called even if servers attach via other mechanisms
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('UserLspConfig', { clear = true }),
        callback = function(args)
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          local bufnr = args.buf
          
          if client then
            -- Check if keymaps already set (avoid duplicate)
            local existing_maps = vim.api.nvim_buf_get_keymap(bufnr, 'n')
            local has_gd = false
            for _, map in ipairs(existing_maps) do
              if map.lhs == 'gd' then
                has_gd = true
                break
              end
            end
            
            -- Only call on_attach if keymaps not already set
            if not has_gd then
              on_attach(client, bufnr)
            end
          end
        end,
      })
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
