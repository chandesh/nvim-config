-- File Type Detection Test Module
-- Tests that file types are detected correctly for the tech stack

local M = {}

function M.run_all()
    print("📁 Running File Type Detection Tests...")
    
    local tests_passed = 0
    local tests_total = 0
    
    -- Helper function to test file type detection
    local function test_filetype(filename, expected_filetype, description)
        tests_total = tests_total + 1
        
        -- Create a temporary buffer with the filename
        local bufnr = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_buf_set_name(bufnr, filename)
        
        -- Trigger filetype detection
        vim.bo[bufnr].filetype = vim.filetype.match({ filename = filename }) or ""
        local detected_filetype = vim.bo[bufnr].filetype
        
        -- Clean up
        vim.api.nvim_buf_delete(bufnr, { force = true })
        
        if detected_filetype == expected_filetype then
            print("  ✅ " .. filename .. " -> " .. detected_filetype .. " (" .. description .. ")")
            tests_passed = tests_passed + 1
            return true
        else
            print("  ❌ " .. filename .. " -> " .. detected_filetype .. " (expected: " .. expected_filetype .. ")")
            return false
        end
    end
    
    -- Test Python files
    test_filetype("test.py", "python", "Python file")
    test_filetype("manage.py", "python", "Django manage.py")
    test_filetype("settings.py", "python", "Django settings")
    
    -- Test Django templates
    test_filetype("template.html", "html", "HTML template")
    test_filetype("base.html", "html", "Django base template")
    
    -- Test JavaScript/TypeScript files
    test_filetype("app.js", "javascript", "JavaScript file")
    test_filetype("component.ts", "typescript", "TypeScript file")
    test_filetype("component.jsx", "javascriptreact", "JSX file")
    test_filetype("component.tsx", "typescriptreact", "TSX file")
    
    -- Test CSS files
    test_filetype("styles.css", "css", "CSS file")
    test_filetype("styles.scss", "scss", "SCSS file")
    test_filetype("styles.sass", "sass", "Sass file")
    
    -- Test configuration files
    test_filetype("package.json", "json", "Package.json")
    test_filetype("config.yaml", "yaml", "YAML config")
    test_filetype("docker-compose.yml", "yaml", "Docker compose")
    test_filetype("pyproject.toml", "toml", "Python project config")
    
    -- Test shell scripts
    test_filetype("script.sh", "sh", "Shell script")
    test_filetype("setup.bash", "bash", "Bash script")
    
    -- Test SQL files
    test_filetype("query.sql", "sql", "SQL file")
    
    -- Test Lua files (for Neovim config)
    test_filetype("init.lua", "lua", "Lua file")
    
    print(string.format("File Type Tests: %d/%d passed", tests_passed, tests_total))
    
    if tests_passed == tests_total then
        print("✅ All File Type Detection Tests Passed!")
        return true
    else
        error(string.format("❌ File Type Tests Failed: %d/%d tests failed", tests_total - tests_passed, tests_total))
    end
end

return M
