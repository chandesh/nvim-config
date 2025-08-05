-- Plugin Loading Test Module
-- Tests that essential plugins are loaded correctly

local M = {}

function M.run_all()
    print("🔌 Running Plugin Loading Tests...")
    
    local tests_passed = 0
    local tests_total = 0
    
    -- Helper function to test plugin loading
    local function test_plugin(plugin_name, require_path)
        tests_total = tests_total + 1
        local success, plugin = pcall(require, require_path)
        
        if success and plugin then
            print("  ✅ " .. plugin_name .. " loaded successfully")
            tests_passed = tests_passed + 1
            return true
        else
            print("  ❌ " .. plugin_name .. " failed to load")
            return false
        end
    end
    
    -- Test core plugins
    test_plugin("Lazy.nvim", "lazy")
    test_plugin("Telescope", "telescope")
    test_plugin("LSP Config", "lspconfig")
    test_plugin("Mason", "mason")
    test_plugin("TreeSitter", "nvim-treesitter")
    test_plugin("CMP", "cmp")
    test_plugin("DAP", "dap")
    test_plugin("DAP UI", "dapui")
    test_plugin("Gitsigns", "gitsigns")
    test_plugin("Which-key", "which-key")
    test_plugin("UFO", "ufo")
    test_plugin("NvimTree", "nvim-tree")
    
    -- Test language-specific plugins
    test_plugin("DAP Python", "dap-python")
    test_plugin("Neotest", "neotest")
    
    -- Test tools
    test_plugin("Conform", "conform")
    test_plugin("Lint", "lint")
    test_plugin("Comment", "Comment")
    
    print(string.format("Plugin Tests: %d/%d passed", tests_passed, tests_total))
    
    if tests_passed == tests_total then
        print("✅ All Plugin Tests Passed!")
        return true
    else
        error(string.format("❌ Plugin Tests Failed: %d/%d tests failed", tests_total - tests_passed, tests_total))
    end
end

return M
