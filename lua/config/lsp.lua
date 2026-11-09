-- ~/.config/nvim/lua/config/lsp.lua
-- =============================================================================
-- LSP Configuration
-- Managed via Mason and nvim-lspconfig.
-- Includes robust jump handlers and project-aware Python resolution.
-- =============================================================================

local M = {}

-- Single server list. ensure_installed and vim.lsp.enable both derive from this.
local server_names = {
  "angularls", "cssls", "emmet_ls", "eslint", "html", "jsonls", "lua_ls", "pyright",
  "tailwindcss", "ts_ls", "yamlls",
}

local function skip_enable()
  local python_path = require('config.python_host').get_python()
  return { pylsp = true, pyright = not python_path }
end

function M.enabled_servers()
  local skip = skip_enable()
  local names = {}
  for _, name in ipairs(server_names) do
    if not skip[name] then
      names[#names + 1] = name
    end
  end
  table.sort(names)
  return names
end

local schemastore_ready = false

function M.apply_schemastore(bufnr)
  local ft = vim.bo[bufnr].filetype
  local server, key
  if ft == "json" or ft == "jsonc" then
    server, key = "jsonls", "json"
  elseif ft == "yaml" or ft == "yml" then
    server, key = "yamlls", "yaml"
  else
    return
  end
  if not schemastore_ready then
    vim.cmd("packadd SchemaStore.nvim")
    schemastore_ready = true
  end
  local schemas = key == "json"
    and require("schemastore").json.schemas()
    or require("schemastore").yaml.schemas()
  local settings = { [key] = { schemas = schemas } }
  if key == "json" then
    settings.json.validate = { enable = true }
  else
    settings.yaml.schemaStore = { enable = false, url = "" }
  end
  vim.lsp.config(server, { settings = settings })
  for _, client in ipairs(vim.lsp.get_clients({ bufnr = bufnr, name = server })) do
    client.config.settings = vim.tbl_deep_extend("force", client.config.settings or {}, settings)
    pcall(client.notify, "workspace/didChangeConfiguration", { settings = client.config.settings })
  end
end

function M.setup()
  vim.lsp.log.set_level("WARN")

  -- ── LSP Capabilities ──────────────────────────────────────────────────────
  -- blink.cmp is an opt plugin and is not on the runtime path at startup. Use
  -- its table when it happens to be loaded; otherwise advertise the two things
  -- it needs (snippets and lazy completion item resolution) directly.
  local capabilities
  local have_blink, blink = pcall(require, 'blink.cmp')
  if have_blink then
    capabilities = blink.get_lsp_capabilities()
  else
    capabilities = vim.lsp.protocol.make_client_capabilities()
    capabilities.textDocument.completion.completionItem.snippetSupport = true
    capabilities.textDocument.completion.completionItem.resolveSupport = {
      properties = { 'documentation', 'detail', 'additionalTextEdits' },
    }
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
    angularls = {},
    tailwindcss = {},
    emmet_ls = {
      filetypes = { "html", "css", "scss", "javascript", "javascriptreact", "typescript", "typescriptreact", "htmldjango" }
    },
    jsonls = {
      settings = {
        json = {
          schemas = {},
          validate = { enable = true },
        },
      },
    },
    yamlls = {
      settings = {
        yaml = {
          schemaStore = { enable = false, url = "" },
          schemas = {},
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
  -- Deferred so the first tick does not install servers. vim.lsp.enable below
  -- still starts servers that are already on PATH.
  vim.defer_fn(function()
    local skip = skip_enable()
    local ensure_installed = {}
    for name in pairs(servers) do
      if not skip[name] then
        ensure_installed[#ensure_installed + 1] = name
      end
    end
    require('mason').setup({
      ui = { border = "rounded" }
    })
    require('mason-lspconfig').setup({
      ensure_installed = ensure_installed,
      automatic_installation = true,
    -- Disable auto-enabling every installed Mason server. Only the servers we
    -- explicitly `vim.lsp.enable()` below get started, so our per-server config
    -- (LSP keymaps) is actually applied. Without this,
    -- mason-lspconfig auto-enables all installed servers via `vim.lsp.enable()`
    -- with no on_attach, and servers already auto-started on filetype.
    automatic_enable = false,
    })
  end, 3000)

  -- SchemaStore catalogs are built on json/yaml, not at startup.
  vim.api.nvim_create_autocmd("FileType", {
    group = vim.api.nvim_create_augroup("UserSchemaStore", { clear = true }),
    pattern = { "json", "jsonc", "yaml", "yml" },
    callback = function(args)
      M.apply_schemastore(args.buf)
    end,
  })
  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(bufnr) then
      local ft = vim.bo[bufnr].filetype
      if ft == "json" or ft == "jsonc" or ft == "yaml" or ft == "yml" then
        M.apply_schemastore(bufnr)
      end
    end
  end

  -- ── Server Configuration (vim.lsp.config API) ─────────────────────────────
  -- Defaults applied to every server we enable.
  vim.lsp.config('*', {
    capabilities = capabilities,
  })

  -- Per-server overrides from the `servers` table above.
  for server_name, server_config in pairs(servers) do
    vim.lsp.config(server_name, server_config)
  end

  vim.lsp.enable(M.enabled_servers())

  -- ── LSP Code-Action Keymaps ───────────────────────────────────────────────
  -- Registered from a global autocmd, NOT from on_attach: nvim-lspconfig's
  -- per-server configs (pyright, ts_ls, eslint, …) ship their own on_attach,
  -- which overrides the '*' default. Copilot also exposes an LSP client but
  -- has no code actions; skip it so these never appear in copilot-only buffers.
  vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('UserLspCodeActions', { clear = true }),
    callback = function(args)
      local client = vim.lsp.get_client_by_id(args.data.client_id)
      if not client or client.name == 'copilot' then return end
      local bufnr = args.buf
      local function map(mode, lhs, rhs, desc)
        vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, silent = true, desc = desc })
      end

      map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, "Code Action")
      map("n", "<leader>cr", vim.lsp.buf.rename, "Rename")
      if client.server_capabilities.documentFormattingProvider then
        map("n", "<leader>cf", function() vim.lsp.buf.format({ async = true }) end, "Format Document")
      end
    end,
  })
end

return M
