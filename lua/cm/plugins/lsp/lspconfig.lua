return {
  "neovim/nvim-lspconfig",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    "hrsh7th/cmp-nvim-lsp",
    { "antosha417/nvim-lsp-file-operations", config = true },
    { "folke/neodev.nvim",                   opts = {} },
    { "williamboman/mason-lspconfig.nvim" },
  },
  config = function()
    local lspconfig = require("lspconfig")
    local mason_lspconfig = require("mason-lspconfig")
    local cmp_nvim_lsp = require("cmp_nvim_lsp")
    local keymap = vim.keymap
    local pyenv = require("cm.core.pyenv")

    -- Handle offset encoding globally
    local function setup_encodings(client)
      if client.name == "pyright" or client.name == "ruff" then
        client.offset_encoding = "utf-8"
      end
    end

    -- DRY helper for mapping with fallback
    local function set_lsp_keymap_if_supported(client, bufnr, mode, lhs, rhs, desc, method)
      local opts = { buffer = bufnr, silent = true, desc = desc }
      if not method or client.supports_method(method) then
        keymap.set(mode, lhs, rhs, opts)
      elseif client.name == "pyright" then
        keymap.set(mode, lhs, rhs, opts) -- temporary override
      else
        keymap.set(mode, lhs, function()
          vim.notify("LSP: " .. desc .. " not supported", vim.log.levels.WARN)
        end, opts)
      end
    end

    -- Capabilities for autocompletion + encoding consistency
    local capabilities = vim.tbl_deep_extend(
      "force",
      vim.lsp.protocol.make_client_capabilities(),
      cmp_nvim_lsp.default_capabilities()
    )

    -- Diagnostic signs
    vim.diagnostic.config({
      virtual_text = true,
      signs = {
        text = {
          [vim.diagnostic.severity.ERROR] = "",
          [vim.diagnostic.severity.WARN] = "",
          [vim.diagnostic.severity.INFO] = "",
          [vim.diagnostic.severity.HINT] = "󰠠",
        },
      },
      float = { border = "rounded" },
      update_in_insert = false,
    })

    -- Servers to install and configure manually for your tech stack:
    -- Python, Django, JavaScript, TypeScript, CSS, Bash, SQL
    local servers = {
      -- JavaScript/TypeScript stack
      "ts_ls",           -- TypeScript/JavaScript LSP
      "html",            -- HTML support for Django templates
      "cssls",           -- CSS LSP
      "tailwindcss",     -- Tailwind CSS (common in modern projects)
      "emmet_ls",        -- HTML/CSS snippets
      
      -- Python/Django stack
      "pyright",         -- Python type checking
      "ruff",            -- Python linting/formatting
      
      -- Shell scripting
      "bashls",          -- Bash LSP
      
      -- Database/SQL
      "sqlls",           -- SQL LSP
      
      -- Configuration files
      "jsonls",          -- JSON (package.json, configs)
      "yamlls",          -- YAML (docker-compose, configs)
      
      -- Lua (for Neovim config)
      "lua_ls",
    }

    mason_lspconfig.setup({
      ensure_installed = servers,
      automatic_installation = false, -- we’ll handle setup manually below
    })

    -- Enhanced keymap setup function
    local function setup_lsp_keymaps(client, bufnr)
      local opts = { buffer = bufnr, silent = true }
      
      -- Navigation keymaps
      keymap.set("n", "gd", vim.lsp.buf.definition, vim.tbl_extend("force", opts, { desc = "Go to definition" }))
      keymap.set("n", "gD", vim.lsp.buf.declaration, vim.tbl_extend("force", opts, { desc = "Go to declaration" }))
      keymap.set("n", "gi", vim.lsp.buf.implementation, vim.tbl_extend("force", opts, { desc = "Go to implementation" }))
      keymap.set("n", "gr", vim.lsp.buf.references, vim.tbl_extend("force", opts, { desc = "Show references" }))
      keymap.set("n", "gt", vim.lsp.buf.type_definition, vim.tbl_extend("force", opts, { desc = "Go to type definition" }))
      
      -- Enhanced code actions with import-specific handling
      local function enhanced_code_action()
        -- Get current word under cursor
        local word = vim.fn.expand("<cword>")
        
        -- Check if we have diagnostics that might need imports
        local diagnostics = vim.diagnostic.get(bufnr, { lnum = vim.fn.line(".") - 1 })
        local has_import_error = false
        
        -- Enhanced diagnostic patterns
        for _, diag in ipairs(diagnostics) do
          local msg_lower = diag.message:lower()
          if msg_lower:find("not defined") or 
             msg_lower:find("cannot resolve import") or
             msg_lower:find("unresolved import") or
             msg_lower:find("undefined") or
             msg_lower:find("name .* is not defined") or
             msg_lower:find("module .* has no attribute") or
             msg_lower:find("import .* could not be resolved") then
            has_import_error = true
            break
          end
        end
        
        -- Always try to show import-related actions if we have a word under cursor or import errors
        if has_import_error or (word ~= "" and vim.bo.filetype == "python") then
          vim.lsp.buf.code_action({
            context = {
              diagnostics = diagnostics,
              only = { "quickfix", "source.fixAll", "source.addMissingImports" },
            },
            filter = function(action)
              local title_lower = action.title:lower()
              -- More comprehensive import action detection
              return title_lower:find("import") or 
                     title_lower:find("add import") or
                     title_lower:find("auto-import") or
                     title_lower:find("organize import") or
                     title_lower:find("missing import") or
                     title_lower:find("resolve import") or
                     title_lower:find("fix import") or
                     title_lower:find("from.*import")
            end,
            apply = false, -- Show the menu to let user choose
          })
        else
          -- Show all code actions
          vim.lsp.buf.code_action()
        end
      end
      
      -- Code actions with multiple options for macOS/Warp terminal
      keymap.set({ "n", "v" }, "<M-CR>", enhanced_code_action, vim.tbl_extend("force", opts, { desc = "Code actions (Option+Enter)" }))
      keymap.set({ "n", "v" }, "<A-CR>", enhanced_code_action, vim.tbl_extend("force", opts, { desc = "Code actions (Alt+Enter)" }))
      keymap.set({ "n", "v" }, "<leader>ca", enhanced_code_action, vim.tbl_extend("force", opts, { desc = "Code actions" }))
      keymap.set({ "n", "v" }, "<leader>.", enhanced_code_action, vim.tbl_extend("force", opts, { desc = "Code actions (Quick fix)" }))
      
      -- Additional Warp-friendly alternatives
      keymap.set({ "n", "v" }, "<C-.>", vim.lsp.buf.code_action, vim.tbl_extend("force", opts, { desc = "Code actions (Ctrl+.)" }))
      keymap.set({ "n", "v" }, "<leader>lc", vim.lsp.buf.code_action, vim.tbl_extend("force", opts, { desc = "LSP Code actions" }))
      
      
      -- Documentation and hover
      keymap.set("n", "K", vim.lsp.buf.hover, vim.tbl_extend("force", opts, { desc = "Show hover documentation" }))
      keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, vim.tbl_extend("force", opts, { desc = "Show signature help" }))
      
      -- Refactoring
      keymap.set("n", "<leader>rn", vim.lsp.buf.rename, vim.tbl_extend("force", opts, { desc = "Rename symbol" }))
      keymap.set("n", "<leader>rf", function() vim.lsp.buf.format({ async = true }) end, vim.tbl_extend("force", opts, { desc = "Format buffer" }))
      
      -- Diagnostics
      keymap.set("n", "[d", vim.diagnostic.goto_prev, vim.tbl_extend("force", opts, { desc = "Previous diagnostic" }))
      keymap.set("n", "]d", vim.diagnostic.goto_next, vim.tbl_extend("force", opts, { desc = "Next diagnostic" }))
      keymap.set("n", "<leader>d", vim.diagnostic.open_float, vim.tbl_extend("force", opts, { desc = "Show diagnostic" }))
      keymap.set("n", "<leader>q", vim.diagnostic.setloclist, vim.tbl_extend("force", opts, { desc = "Diagnostic quickfix" }))
      
      -- Python-specific keymaps
      if client.name == "pyright" then
        keymap.set("n", "<leader>oi", function()
          vim.lsp.buf.code_action({
            context = { only = { "source.organizeImports" } },
            buffer = bufnr,
          })
        end, vim.tbl_extend("force", opts, { desc = "Organize imports" }))
      end
    end

    -- Set up keymaps when an LSP attaches
    vim.api.nvim_create_autocmd("LspAttach", {
      group = vim.api.nvim_create_augroup("UserLspConfig", {}),
      callback = function(ev)
        local bufnr = ev.buf
        local client = vim.lsp.get_client_by_id(ev.data.client_id)

        setup_encodings(client)
        setup_lsp_keymaps(client, bufnr)
      end,
    })

    -- Setup each server with specific configurations
    local server_configs = {
      pyright = {
        -- Pyright is a high-performance type checker.
        -- We use it primarily for its diagnostics and type-checking capabilities.
        capabilities = capabilities,
        on_attach = function(client, bufnr)
          -- Disable features that will be handled by pylsp to avoid conflicts.
          client.server_capabilities.hoverProvider = false
          client.server_capabilities.completionProvider = false
          client.server_capabilities.renameProvider = false
          client.server_capabilities.referencesProvider = false
          client.server_capabilities.definitionProvider = false
          client.server_capabilities.implementationProvider = false
          client.server_capabilities.signatureHelpProvider = false
          client.server_capabilities.documentFormattingProvider = false
          client.server_capabilities.documentRangeFormattingProvider = false
          
          -- State to track if type checking diagnostics are enabled
          local type_checking_enabled = false
          
          -- Function to toggle type checking diagnostics
          local function toggle_type_checking()
            type_checking_enabled = not type_checking_enabled
            
            if type_checking_enabled then
              -- Enable type checking diagnostics
              vim.diagnostic.config({
                virtual_text = {
                  source = "if_many",
                  prefix = "■",
                },
                signs = true,
                underline = true,
                update_in_insert = false,
                severity_sort = true,
              }, client.id)
              vim.notify("Type checking diagnostics: ON", vim.log.levels.INFO)
            else
              -- Disable type checking diagnostics (hide pyright diagnostics)
              vim.diagnostic.config({
                virtual_text = false,
                signs = false,
                underline = false,
                update_in_insert = false,
              }, client.id)
              -- Clear existing diagnostics by hiding them
              vim.diagnostic.hide(nil, bufnr)
              vim.notify("Type checking diagnostics: OFF", vim.log.levels.INFO)
            end
          end
          
          -- Keybinding to toggle type checking diagnostics
          local opts = { buffer = bufnr, silent = true }
          vim.keymap.set("n", "<leader>tt", toggle_type_checking, 
            vim.tbl_extend("force", opts, { desc = "Toggle type checking diagnostics" }))
          
          -- Start with type checking disabled by default
          vim.defer_fn(function()
            if vim.api.nvim_buf_is_valid(bufnr) then
              -- Just call once to set it to OFF (default state)
              vim.diagnostic.config({
                virtual_text = false,
                signs = false,
                underline = false,
                update_in_insert = false,
              }, client.id)
              vim.diagnostic.hide(nil, bufnr)
              -- Only show notification in debug mode to reduce noise
              if vim.env.DEBUG_PYRIGHT then
                vim.notify("Type checking diagnostics: OFF (default)", vim.log.levels.INFO)
              end
            end
          end, 100) -- Reduced delay to be more responsive
        end,
        settings = {
          python = {
            pythonPath = pyenv.get_python_executable(),
            analysis = {
              autoSearchPaths = true,
              useLibraryCodeForTypes = true,
              diagnosticMode = "openFilesOnly",
              typeCheckingMode = "strict",
              -- We rely on Ruff for most linting, so we can disable some pyright diagnostics.
              reportMissingImports = true, -- Keep this for type analysis
              reportUnusedVariable = "none",
              reportUnusedImport = "none",
            },
          },
        },
      },
      pylsp = {
        -- Pylsp provides robust language features like auto-imports and refactoring.
        capabilities = capabilities,
        on_attach = function(client, bufnr)
          -- Disable pylsp's formatting, as we use Ruff.
          client.server_capabilities.documentFormattingProvider = false
          client.server_capabilities.documentRangeFormattingProvider = false

          local opts = { buffer = bufnr, silent = true }
          vim.keymap.set("n", "<leader>pi", function()
            vim.lsp.buf.code_action({
              context = { only = { "source.addMissingImports.pylsp" } },
              apply = true,
            })
          end, vim.tbl_extend("force", opts, { desc = "Add Missing Imports (pylsp)" }))

          vim.keymap.set("n", "<leader>po", function()
            vim.lsp.buf.code_action({
              context = { only = { "source.organizeImports" } },
              apply = true,
            })
          end, vim.tbl_extend("force", opts, { desc = "Organize Imports (pylsp)" }))
        end,
        settings = {
          pylsp = {
            plugins = {
              -- Disable linters that conflict with Ruff.
              pycodestyle = { enabled = false },
              pylint = { enabled = false },
              flake8 = { enabled = false },
              -- Enable plugins for language features.
              rope_autoimport = { enabled = true },
              rope_completion = { enabled = true },
              jedi_completion = { enabled = true },
              jedi_hover = { enabled = true },
              jedi_references = { enabled = true },
              jedi_signature_help = { enabled = true },
              jedi_symbols = { enabled = true, all_scopes = true },
            },
          },
        },
      },
      ruff = {
        capabilities = capabilities,
        init_options = {
          settings = {
            args = {
              "--config", vim.fn.expand("~/.config/ruff/ruff.toml"),
            },
          },
        },
        on_attach = function(client, bufnr)
          -- Disable Ruff's hover in favor of Pyright
          client.server_capabilities.hoverProvider = false
        end,
      },
      lua_ls = {
        capabilities = capabilities,
        settings = {
          Lua = {
            runtime = {
              version = "LuaJIT",
            },
            diagnostics = {
              globals = { "vim" },
            },
            workspace = {
              library = vim.api.nvim_get_runtime_file("", true),
              checkThirdParty = false,
            },
            telemetry = {
              enable = false,
            },
          },
        },
      },
      ts_ls = {
        capabilities = capabilities,
        settings = {
          typescript = {
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
      bashls = {
        capabilities = capabilities,
      },
    }

    -- Setup servers with their specific configurations
    for _, server in ipairs(servers) do
      local config = server_configs[server] or { capabilities = capabilities }
      
      -- Use only the new Neovim 0.11 LSP configuration to avoid duplicates
      vim.lsp.config(server, config)
    end
    
    -- Manually configure pylsp using the existing pyenv installation
    if vim.fn.executable("pylsp") == 1 then
      vim.lsp.config("pylsp", server_configs.pylsp)
    else
      vim.notify("pylsp not found in PATH. Install it in your pyenv: pip install python-lsp-server[rope]", vim.log.levels.WARN)
    end
  end,
}
