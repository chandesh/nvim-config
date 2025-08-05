-- LSP Configuration Test Module
-- Validates the configuration and availability of LSP servers

local M = {}

function M.run_all()
    print("🔍 Running LSP Configuration Tests...")
    
    local lspconfig = require("lspconfig")
    local servers = {
        "pyright",
        "html",
        "cssls",
        "tsserver",
        "bashls",
        "sqlls",
        "jsonls",
        "yamlls",
        "lua_ls",
    }
    
    for _, server in ipairs(servers) do
        if not lspconfig[server] then
            error("LSP Server " .. server .. " is not configured properly.")
        end
    end

    print("✅ All LSP Configuration Tests Passed!")
end

return M

