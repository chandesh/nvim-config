-- ~/.config/nvim/lua/config/lsp.lua
-- =============================================================================
-- LSP Configuration
-- Managed via Mason and nvim-lspconfig.
-- Includes robust jump handlers and project-aware Python resolution.
-- =============================================================================

local M = {}

function M.setup()
  local lspconfig = require('lspconfig')
  local mason_lspconfig = require('mason-lspconfig')
  
  -- ── LSP Capabilities (Integration with blink.cmp) ─────────────────────────
  -- Using blink.cmp's default capabilities for seamless completion
  local capabilities = require('blink.cmp').get_lsp_capabilities()

  -- ── Robust Jump Handlers ──────────────────────────────────────────────────
  local ok_gp, goto_preview = pcall(require, 'goto-preview')
  if ok_gp then
    goto_preview.setup({})
  end

  -- Workaround for "no-jump" cases and LocationLink normalization
  local function jump_to_first_location(result)
    if not result or (type(result) == 'table' and vim.tbl_isempty(result)) then
      vim.notify("No locations found", vim.log.levels.WARN)
      return
    end
    local loc = vim.tbl_islist(result) and result[1] or result
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

  -- ── Diagnostic Styling ─────────────────────────────────────────────────────
  local icons = require('config.icons')
  local sev = vim.diagnostic.severity
  vim.diagnostic.config({
    underline = true,
    update_in_insert = false,
    virtual_text = {
      spacing = 4,
      source = "if_many",
      prefix = " ",
      format = function(diagnostic)
        local icon = diagnostic.severity == sev.ERROR and icons.diagnostics.error
          or diagnostic.severity == sev.WARN and icons.diagnostics.warn
          or diagnostic.severity == sev.INFO and icons.diagnostics.info
          or icons.diagnostics.hint
        return icon .. ' ' .. diagnostic.message
      end,
    },
    severity_sort = true,
    signs = {
      text = {
        [vim.diagnostic.severity.ERROR] = icons.diagnostics.error,
        [vim.diagnostic.severity.WARN] = icons.diagnostics.warn,
        [vim.diagnostic.severity.INFO] = icons.diagnostics.info,
        [vim.diagnostic.severity.HINT] = icons.diagnostics.hint,
      },
    },
  })

  -- ── On Attach Handler ───────────────────────────────────────────────────────
  local on_attach = function(client, bufnr)
    local function map(mode, lhs, rhs, desc)
      vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, silent = true, desc = desc })
    end
    
    map("n", "gd", function() vim.lsp.buf.definition() end, "Go to Definition")

    if client.server_capabilities.declarationProvider then
      map("n", "gD", function() vim.lsp.buf.declaration() end, "Go to Declaration")
    else
      map("n", "gD", function() vim.lsp.buf.definition() end, "Go to Definition")
    end

    map("n", "gi", function() vim.lsp.buf.implementation() end, "Go to Implementation")
    map("n", "gy", function() vim.lsp.buf.type_definition() end, "Go to Type Definition")
    map("n", "gr", function() vim.lsp.buf.references() end, "Go to References")
    map("n", "K", vim.lsp.buf.hover, "Hover Documentation")
    map("n", "<C-k>", vim.lsp.buf.signature_help, "Signature Help")
    map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, "Code Action")
    map("n", "<leader>cr", vim.lsp.buf.rename, "Rename")

    if client.server_capabilities.documentFormattingProvider then
      map("n", "<leader>cf", function() vim.lsp.buf.format({ async = true }) end, "Format Document")
    end
  end

  -- ── Server Configurations ──────────────────────────────────────────────────
  local python_path = require('config.python_host').get_python()
  
  local servers = {
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
    eslint = {
      settings = {
        codeAction = { disableRuleComment = { enable = true, location = "separateLine" } },
        format = true,
        validate = "on",
      }
    },
    html = { filetypes = { "html", "htmldjango" } },
    cssls = {},
    emmet_ls = {
      filetypes = { "html", "css", "scss", "javascript", "javascriptreact", "typescript", "typescriptreact", "htmldjango" }
    },
    jsonls = {
      settings = {
        json = {
          schemas = (function()
            vim.cmd('packadd SchemaStore.nvim')
            return require('schemastore').json.schemas()
          end)(),
          validate = { enable = true },
        },
      },
    },
    yamlls = {
      settings = {
        yaml = {
          schemaStore = { enable = false, url = "" },
          schemas = (function()
            vim.cmd('packadd SchemaStore.nvim')
            return require('schemastore').yaml.schemas()
          end)(),
        },
      },
    },
    lua_ls = {
      settings = {
        Lua = {
          workspace = { checkThirdParty = false },
          completion = { callSnippet = "Replace" },
        },
      },
    },
  }

  -- ── Mason Integration ───────────────────────────────────────────────────────
  require('mason').setup({
    ui = { border = "rounded" }
  })

  mason_lspconfig.setup({
    ensure_installed = {
      "pyright", "ts_ls", "eslint", "html", "cssls", "emmet_ls", "jsonls", "yamlls", "lua_ls"
    },
    automatic_installation = true,
    handlers = {
      function(server_name)
        if server_name == "pylsp" then return end
        
        if server_name == "pyright" and not python_path then
          vim.notify('Skipping Pyright setup - no Python environment detected', vim.log.levels.WARN)
          return
        end
        
        local server_config = servers[server_name] or {}
        lspconfig[server_name].setup(vim.tbl_deep_extend("force", {
          capabilities = capabilities,
          on_attach = on_attach,
        }, server_config))
      end,
    },
  })
end

return M
