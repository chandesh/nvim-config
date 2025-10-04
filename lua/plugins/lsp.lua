-- ========================================
-- LSP (Language Server Protocol) Configuration
-- ========================================

return {
  -- Mason for managing language servers, DAP servers, linters, and formatters
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
          -- Python (multiple options for reliability)
          "pylsp",
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
        -- Disable automatic setup for servers we don't configure
        handlers = {
          -- Default handler for configured servers
          function(server_name)
            -- Only setup servers that are in our servers table
            local servers = {
              "pylsp", "pyright", "ts_ls", "eslint", "html", "cssls", 
              "emmet_ls", "jsonls", "yamlls", "lua_ls"
            }
            
            for _, configured_server in ipairs(servers) do
              if server_name == configured_server then
                return true -- Let the normal setup handle this
              end
            end
            
            -- Don't setup unconfigured servers like pyright
            print("Skipping unconfigured server: " .. server_name)
            return false
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
      "folke/neodev.nvim", -- Lua LSP configuration
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

      -- LSP keymaps - Simple and reliable approach
      -- Fixed: Removed complex error handling that was causing "method not supported" errors
      -- Fixed: Conditional keymap setting based on actual server capabilities
      local on_attach = function(client, bufnr)
        local opts = { buffer = bufnr, silent = true }
        
        -- Navigation keymaps - only set if server supports the capability
        if client.server_capabilities.definitionProvider then
          vim.keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "Go to Definition", buffer = bufnr, silent = true })
        end
        
        if client.server_capabilities.declarationProvider then
          vim.keymap.set("n", "gD", vim.lsp.buf.declaration, { desc = "Go to Declaration", buffer = bufnr, silent = true })
        else
          -- Fallback to definition if declaration not supported (common for Python)
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

        -- Workspace
        vim.keymap.set("n", "<leader>wa", vim.lsp.buf.add_workspace_folder, { desc = "Add Workspace Folder", unpack(opts) })
        vim.keymap.set("n", "<leader>wr", vim.lsp.buf.remove_workspace_folder, { desc = "Remove Workspace Folder", unpack(opts) })
        vim.keymap.set("n", "<leader>wl", function()
          print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
        end, { desc = "List Workspace Folders", unpack(opts) })

        -- Formatting
        if client.server_capabilities.documentFormattingProvider then
          vim.keymap.set("n", "<leader>cf", function()
            vim.lsp.buf.format({ async = true })
          end, { desc = "Format Document", unpack(opts) })
        end

        if client.server_capabilities.documentRangeFormattingProvider then
          vim.keymap.set("v", "<leader>cf", function()
            vim.lsp.buf.format({ async = true })
          end, { desc = "Format Range", unpack(opts) })
        end

        -- Highlight symbol under cursor
        if client.server_capabilities.documentHighlightProvider then
          local highlight_augroup = vim.api.nvim_create_augroup("lsp_document_highlight", { clear = false })
          vim.api.nvim_clear_autocmds({ buffer = bufnr, group = highlight_augroup })
          vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
            buffer = bufnr,
            group = highlight_augroup,
            callback = vim.lsp.buf.document_highlight,
          })
          vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
            buffer = bufnr,
            group = highlight_augroup,
            callback = vim.lsp.buf.clear_references,
          })
        end
      end

      -- Language server configurations
      local servers = {
        -- Python Language Server
        pylsp = {
          -- Use Mason's pylsp installation
          cmd = { "pylsp" },
          settings = {
            pylsp = {
              -- Configure the Python executable path
              configurationSources = { "pycodestyle" },
              plugins = {
                pycodestyle = {
                  ignore = {"W391", "E501"},
                  maxLineLength = 88
                },
                mccabe = {
                  threshold = 15
                },
                pyflakes = { enabled = true },
                pylint = { enabled = false }, -- We'll use external linters
                autopep8 = { enabled = false },
                yapf = { enabled = false },
                black = { enabled = true },
                isort = { enabled = true },
                rope_completion = { 
                  enabled = true,
                  completionEnabled = true,
                  codeActionsEnabled = true
                },
                rope_autoimport = { 
                  enabled = true,
                  completionsEnabled = true,
                  codeActionsEnabled = true
                },
                jedi_completion = {
                  enabled = true,
                  include_params = true,
                  include_class_objects = true,
                  fuzzy = true
                },
                jedi_definition = {
                  enabled = true,
                  follow_imports = true,
                  follow_builtin_imports = true
                },
                jedi_hover = { enabled = true },
                jedi_references = { enabled = true },
                jedi_signature_help = { enabled = true },
                jedi_symbols = {
                  enabled = true,
                  all_scopes = true
                }
              },
              -- Fix for progress reporting timeout issues
              configurationSources = { "pycodestyle" },
            }
          },
          -- Enhanced initialization options
          init_options = {
            workspace = {
              skip_token_initialization = true,
            },
          },
          -- Set the root directory to your project
          root_dir = function(fname)
            local util = require('lspconfig.util')
            -- Look for Django project indicators
            local django_root = util.root_pattern('manage.py', 'settings.py', 'pyproject.toml', '.git')(fname)
            if django_root then
              return django_root
            end
            -- Fallback to default Python patterns
            return util.root_pattern('setup.py', 'setup.cfg', 'requirements.txt', '.git')(fname)
          end,
          -- Configure pylsp to use the Python environment detected by pyenv module
          on_new_config = function(config, root_dir)
            local pyenv = require('config.pyenv')
            local python_executable = pyenv.get_python_executable()
            
            if python_executable and python_executable ~= "/bin/python" then
              -- Set environment for Jedi (used by pylsp for definitions)
              config.settings.pylsp.plugins.jedi_completion.environment = python_executable
              config.settings.pylsp.plugins.jedi_definition.environment = python_executable
              config.settings.pylsp.plugins.jedi_hover.environment = python_executable
              config.settings.pylsp.plugins.jedi_references.environment = python_executable
              config.settings.pylsp.plugins.jedi_signature_help.environment = python_executable
              config.settings.pylsp.plugins.jedi_symbols.environment = python_executable
              
              -- Also set the Python path in init_options
              config.init_options.settings = config.init_options.settings or {}
              config.init_options.settings.python = {
                pythonPath = python_executable
              }
            end
          end,
        },

        -- Pyright (Alternative Python LSP - Backup for PYLSP)
        -- Added as fallback in case pylsp has issues
        pyright = {
          settings = {
            python = {
              analysis = {
                autoSearchPaths = true,
                useLibraryCodeForTypes = true,
                diagnosticMode = 'openFilesOnly',
              },
            },
          },
          -- Only use Pyright if pylsp fails
          on_attach = function(client, bufnr)
            -- Disable Pyright's hover in favor of pylsp if both are running
            local pylsp_clients = vim.lsp.get_clients({ name = "pylsp", bufnr = bufnr })
            if #pylsp_clients > 0 then
              client.server_capabilities.hoverProvider = false
            end
            
            -- Call the common on_attach
            on_attach(client, bufnr)
          end,
        },

        -- TypeScript/JavaScript
        ts_ls = {
          settings = {
            typescript = {
              inlayHints = {
                includeInlayParameterNameHints = "literal",
                includeInlayParameterNameHintsWhenArgumentMatchesName = false,
                includeInlayFunctionParameterTypeHints = true,
                includeInlayVariableTypeHints = false,
                includeInlayPropertyDeclarationTypeHints = true,
                includeInlayFunctionLikeReturnTypeHints = true,
                includeInlayEnumMemberValueHints = true,
              },
            },
            javascript = {
              inlayHints = {
                includeInlayParameterNameHints = "all",
                includeInlayParameterNameHintsWhenArgumentMatchesName = false,
                includeInlayFunctionParameterTypeHints = true,
                includeInlayVariableTypeHints = true,
                includeInlayPropertyDeclarationTypeHints = true,
                includeInlayFunctionLikeReturnTypeHints = true,
                includeInlayEnumMemberValueHints = true,
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
              showDocumentation = {
                enable = true
              }
            },
            codeActionOnSave = {
              enable = false,
              mode = "all"
            },
            format = true,
            nodePath = "",
            onIgnoredFiles = "off",
            packageManager = "npm",
            problems = {
              shortenToSingleLine = false
            },
            quiet = false,
            rulesCustomizations = {},
            run = "onType",
            useESLintClass = false,
            validate = "on",
            workingDirectory = {
              mode = "location"
            }
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

  -- LSP progress indicator
  {
    "j-hui/fidget.nvim",
    event = "LspAttach",
    tag = "legacy",
    config = function()
      require("fidget").setup({
        window = {
          blend = 0,
        },
      })
    end,
  },

  -- Enhanced LSP UIs
  {
    "glepnir/lspsaga.nvim",
    event = "LspAttach",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons"
    },
    keys = {
      { "gh", "<cmd>Lspsaga finder<CR>", desc = "LSP Finder", mode = "n" },
      { "<leader>ca", "<cmd>Lspsaga code_action<CR>", desc = "Code Action", mode = "n" },
      { "<leader>cr", "<cmd>Lspsaga rename<CR>", desc = "Rename", mode = "n" },
      { "gp", "<cmd>Lspsaga peek_definition<CR>", desc = "Peek Definition", mode = "n" },
      -- FIXED: Removed gd and gD keymaps to prevent conflicts with native LSP keymaps
      -- Native LSP keymaps are now handled directly in the on_attach function above
      { "<leader>sl", "<cmd>Lspsaga show_line_diagnostics<CR>", desc = "Line Diagnostics", mode = "n" },
      { "<leader>sc", "<cmd>Lspsaga show_cursor_diagnostics<CR>", desc = "Cursor Diagnostics", mode = "n" },
      { "[e", "<cmd>Lspsaga diagnostic_jump_prev<CR>", desc = "Previous Diagnostic", mode = "n" },
      { "]e", "<cmd>Lspsaga diagnostic_jump_next<CR>", desc = "Next Diagnostic", mode = "n" },
      { "K", "<cmd>Lspsaga hover_doc<CR>", desc = "Hover Doc", mode = "n" },
      { "<A-d>", "<cmd>Lspsaga term_toggle<CR>", desc = "Toggle Terminal", mode = "n" },
    },
    config = function()
      require("lspsaga").setup({
        ui = {
          border = "rounded",
          code_action = "💡",
        },
        hover = {
          max_width = 0.6,
        },
        lightbulb = {
          enable = true,
          sign = true,
          sign_priority = 40,
          virtual_text = true,
        },
        symbol_in_winbar = {
          enable = false,
        },
        outline = {
          win_position = "right",
          win_with = "",
          win_width = 30,
          show_detail = true,
          auto_preview = true,
          auto_refresh = true,
          auto_close = true,
          custom_sort = nil,
          keys = {
            jump = "o",
            expand_collapse = "u",
            quit = "q",
          },
        },
      })
    end,
  },
}
