-- Pyenv Integration Test Module
-- Tests Python environment management functionality

local M = {}

function M.run_all()
    print("🐍 Running Pyenv Integration Tests...")
    
    local tests_passed = 0
    local tests_total = 0
    
    -- Helper function for tests
    local function test_function(test_name, test_func)
        tests_total = tests_total + 1
        local success, result = pcall(test_func)
        
        if success and result then
            print("  ✅ " .. test_name)
            tests_passed = tests_passed + 1
            return true
        else
            print("  ❌ " .. test_name .. " failed")
            return false
        end
    end
    
    -- Test pyenv module loading
    test_function("Pyenv module loads", function()
        local pyenv = require("cm.core.pyenv")
        return pyenv ~= nil
    end)
    
    -- Test Python executable detection
    test_function("Python executable detection", function()
        local pyenv = require("cm.core.pyenv")
        local python_path = pyenv.get_python_executable()
        return python_path ~= nil and python_path ~= ""
    end)
    
    -- Test environment name detection
    test_function("Environment name detection", function()
        local pyenv = require("cm.core.pyenv")
        local env_name = pyenv.get_env_name()
        -- Can be nil in some cases, so we just check it doesn't error
        return true
    end)
    
    -- Test custom commands existence
    test_function("PyenvInfo command exists", function()
        return vim.fn.exists(":PyenvInfo") == 2
    end)
    
    test_function("PyenvReactivate command exists", function()
        return vim.fn.exists(":PyenvReactivate") == 2
    end)
    
    test_function("PyenvInstallLSP command exists", function()
        return vim.fn.exists(":PyenvInstallLSP") == 2
    end)
    
    print(string.format("Pyenv Tests: %d/%d passed", tests_passed, tests_total))
    
    if tests_passed == tests_total then
        print("✅ All Pyenv Integration Tests Passed!")
        return true
    else
        error(string.format("❌ Pyenv Tests Failed: %d/%d tests failed", tests_total - tests_passed, tests_total))
    end
end

return M
