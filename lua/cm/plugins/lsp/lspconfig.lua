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
    vim.fn.sign_define("DiagnosticSignError", { text = " ", texthl = "DiagnosticSignError" })
    vim.fn.sign_define("DiagnosticSignWarn", { text = " ", texthl = "DiagnosticSignWarn" })
    vim.fn.sign_define("DiagnosticSignInfo", { text = " ", texthl = "DiagnosticSignInfo" })
    vim.fn.sign_define("DiagnosticSignHint", { text = "󰠠 ", texthl = "DiagnosticSignHint" })

    vim.diagnostic.config({
      virtual_text = true,
      signs = true,
      float = { border = "rounded" },
      update_in_insert = false,
    })

    -- Servers to install and configure manually
    local servers = {
      "ts_ls",
      "html",
      "cssls",
      "tailwindcss",
      "lua_ls",
      "emmet_ls",
      "pyright",
      "ruff",
    }

    mason_lspconfig.setup({
      ensure_installed = servers,
      automatic_installation = false, -- we’ll handle setup manually below
    })

    -- Set up keymaps when an LSP attaches
    vim.api.nvim_create_autocmd("LspAttach", {
      group = vim.api.nvim_create_augroup("UserLspConfig", {}),
      callback = function(ev)
        local bufnr = ev.buf
        local client = vim.lsp.get_client_by_id(ev.data.client_id)

        setup_encodings(client)

        set_lsp_keymap_if_supported(
          client,
          bufnr,
          "n",
          "gd",
          vim.lsp.buf.definition,
          "Go to definition",
          "textDocument/definition"
        )
        set_lsp_keymap_if_supported(
          client,
          bufnr,
          "n",
          "gD",
          vim.lsp.buf.declaration,
          "Go to declaration",
          "textDocument/declaration"
        )
        set_lsp_keymap_if_supported(
          client,
          bufnr,
          "n",
          "gi",
          vim.lsp.buf.implementation,
          "Go to implementation",
          "textDocument/implementation"
        )
      end,
    })

    -- Setup each server manually
    for _, server in ipairs(servers) do
      lspconfig[server].setup({
        capabilities = capabilities,
      })
    end
  end,
}
