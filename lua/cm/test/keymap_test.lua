-- Keymap Configuration Test Module
-- Tests that essential keymaps are configured correctly

local M = {}

function M.run_all()
    print("⌨️  Running Keymap Configuration Tests...")
    
    local tests_passed = 0
    local tests_total = 0
    
    -- Helper function to test keymap existence
    local function test_keymap(keymap, mode, description)
        tests_total = tests_total + 1
        mode = mode or "n" -- default to normal mode
        
        local mapping = vim.fn.mapcheck(keymap, mode)
        if mapping ~= "" then
            print("  ✅ " .. keymap .. " (" .. description .. ") is mapped")
            tests_passed = tests_passed + 1
            return true
        else
            print("  ❌ " .. keymap .. " (" .. description .. ") is not mapped")
            return false
        end
    end

    -- Test essential keymaps
    test_keymap("<leader>ff", "n", "Find files")
    test_keymap("<leader>fs", "n", "Live grep")
    test_keymap("<leader>ee", "n", "Toggle file explorer")
    test_keymap("<leader>ca", "n", "Code actions")
    test_keymap("<leader>db", "n", "Toggle breakpoint")
    test_keymap("<leader>dc", "n", "Continue debugging")
    test_keymap("<leader>gp", "n", "Preview git hunk")
    test_keymap("<leader>mp", "n", "Format file")
    test_keymap("<leader>ll", "n", "Trigger linting")
    test_keymap("<leader>pr", "n", "Run Python file")
    test_keymap("<leader>pi", "n", "Pyenv info")
    test_keymap("<leader>tr", "n", "Run nearest test")
    test_keymap("<leader>xw", "n", "Workspace diagnostics")
    test_keymap("<leader>sr", "n", "Search and replace")
    test_keymap("zR", "n", "Open all folds")
    test_keymap("zM", "n", "Close all folds")
    
    -- Test Python LSP keymaps
    test_keymap("gd", "n", "Go to definition")
    test_keymap("<C-o>", "n", "Go back from definition")
    
    print(string.format("Keymap Tests: %d/%d passed", tests_passed, tests_total))
    
    if tests_passed == tests_total then
        print("✅ All Keymap Tests Passed!")
        return true
    else
        error(string.format("❌ Keymap Tests Failed: %d/%d tests failed", tests_total - tests_passed, tests_total))
    end
end

return M

