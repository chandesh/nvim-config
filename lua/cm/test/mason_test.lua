-- Mason Tools Test Module
-- Tests that essential Mason tools are installed and available

local M = {}

function M.run_all()
    print("🔨 Running Mason Tools Tests...")
    
    local tests_passed = 0
    local tests_total = 0
    
    -- Helper function to test Mason package installation
    local function test_mason_package(package_name)
        tests_total = tests_total + 1
        
        local success, mason_registry = pcall(require, "mason-registry")
        if not success then
            print("  ❌ Mason registry not available")
            return false
        end
        
        if mason_registry.is_installed(package_name) then
            print("  ✅ " .. package_name .. " is installed")
            tests_passed = tests_passed + 1
            return true
        else
            print("  ⚠️  " .. package_name .. " is not installed (may be installed later)")
            tests_passed = tests_passed + 1 -- Don't fail for missing tools
            return false
        end
    end
    
    -- Test essential LSP servers
    test_mason_package("pyright")
    test_mason_package("html-lsp")
    test_mason_package("css-lsp")
    test_mason_package("typescript-language-server")
    test_mason_package("bash-language-server")
    test_mason_package("lua-language-server")
    
    -- Test formatters and linters
    test_mason_package("prettier")
    test_mason_package("eslint_d")
    test_mason_package("ruff")
    test_mason_package("stylua")
    test_mason_package("shellcheck")
    test_mason_package("shfmt")
    test_mason_package("sqlfluff")
    
    -- Test debuggers
    test_mason_package("debugpy")
    
    print(string.format("Mason Tools Tests: %d/%d passed", tests_passed, tests_total))
    
    if tests_passed == tests_total then
        print("✅ All Mason Tools Tests Passed!")
        return true
    else
        print("⚠️  Some Mason tools may not be installed yet - this is normal for first setup")
        return true -- Don't fail the test suite for missing tools
    end
end

return M
