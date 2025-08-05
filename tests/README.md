# Neovim Configuration Tests

This directory contains automated tests for the Neovim configuration to ensure everything works as expected.

## Test Structure

```
tests/
├── run_tests.sh          # Main test runner (comprehensive)
├── quick_test.sh         # Quick test runner (essential tests only)
├── test_results.log      # Test execution log
└── README.md            # This file

lua/cm/test/
├── plugin_test.lua       # Tests plugin loading
├── lsp_test.lua         # Tests LSP configuration
├── keymap_test.lua      # Tests keymaps (including gd and <C-o>)
├── mason_test.lua       # Tests Mason tool installation
├── pyenv_test.lua       # Tests Python environment integration
└── filetype_test.lua    # Tests file type detection
```

## Running Tests

### Full Test Suite
```bash
cd ~/.config/nvim
./tests/run_tests.sh
```

### Quick Tests (for development)
```bash
cd ~/.config/nvim
./tests/quick_test.sh
```

### Individual Test Modules
```bash
# Test plugins only
nvim --headless -c 'lua require("cm.test.plugin_test").run_all()' -c 'qall!'

# Test keymaps only
nvim --headless -c 'lua require("cm.test.keymap_test").run_all()' -c 'qall!'
```

## Test Coverage

### 🔌 Plugin Tests
- ✅ Lazy.nvim plugin manager
- ✅ Telescope (file finder)
- ✅ LSP configuration
- ✅ Mason (tool installer)
- ✅ TreeSitter (syntax highlighting)
- ✅ CMP (completion)
- ✅ DAP (debugging)
- ✅ Git integration
- ✅ Language-specific plugins

### ⌨️ Keymap Tests
- ✅ File operations (`<leader>ff`, `<leader>fs`)
- ✅ Code actions (`<leader>ca`)
- ✅ Debugging (`<leader>db`, `<leader>dc`)
- ✅ Git operations (`<leader>gp`)
- ✅ Python development (`<leader>pr`, `<leader>pi`)
- ✅ Testing (`<leader>tr`)
- ✅ **Go to definition (`gd`) and go back (`<C-o>`)** ← Essential for Python development
- ✅ Folding (`zR`, `zM`)

### 🔍 LSP Tests
- ✅ Python (Pyright)
- ✅ JavaScript/TypeScript
- ✅ HTML/CSS
- ✅ Bash
- ✅ SQL
- ✅ JSON/YAML
- ✅ Lua

### 🐍 Python-Specific Tests
- ✅ Pyenv integration
- ✅ Virtual environment detection
- ✅ Custom commands (PyenvInfo, PyenvReactivate)
- ✅ Django support

### 📁 File Type Detection
- ✅ Python files (.py)
- ✅ Django templates (.html)
- ✅ JavaScript/TypeScript (.js, .ts, .jsx, .tsx)
- ✅ CSS/SCSS (.css, .scss, .sass)
- ✅ Configuration files (.json, .yaml, .toml)
- ✅ Shell scripts (.sh, .bash)
- ✅ SQL files (.sql)

## Test Output

The tests provide colored output:
- 🟢 **Green**: Tests passed
- 🔴 **Red**: Tests failed  
- 🟡 **Yellow**: Warnings or informational messages

All test results are logged to `tests/test_results.log` for detailed review.

## Continuous Integration

You can integrate these tests into your workflow:

```bash
# Before committing changes
./tests/quick_test.sh

# After major changes
./tests/run_tests.sh
```

## Adding New Tests

To add new tests:

1. Create a new test module in `lua/cm/test/`
2. Follow the existing pattern with `run_all()` function
3. Add the test to `run_tests.sh`
4. Update this README

## Troubleshooting

If tests fail:

1. Check `test_results.log` for detailed error messages
2. Run individual test modules to isolate issues
3. Ensure all plugins are installed (`nvim` then `:Lazy sync`)
4. Verify Mason tools are installed (`:Mason`)
