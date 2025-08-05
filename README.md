# Neovim Configuration

A modern, comprehensive Neovim configuration optimized for **full-stack development** with a focus on **Python/Django, JavaScript/TypeScript, CSS, Bash, and SQL**. This configuration provides a PyCharm-like development experience with advanced LSP support, debugging capabilities, and a well-organized plugin structure.

## ✨ Features

### 🏗️ **NeoVim Configuration Directory Structure**
- **Organized Structure**: Plugins organized by category (languages, tools, ui)
- **Centralized Keymaps**: All keybindings managed in one place
- **Tech Stack Focus**: Optimized for Python/Django, JS/TS, CSS, Bash, SQL

### 🔧 **Language Support**
- **Python/Django**: Pyright, Ruff, Django templates, virtual environment management
- **JavaScript/TypeScript**: ESLint, Prettier, advanced IntelliSense
- **CSS**: Stylelint, Prettier, Tailwind CSS support
- **SQL**: Database UI, SQLfluff formatting and linting
- **Bash**: Shellcheck linting, shfmt formatting

### 🚀 **Development Tools**
- **LSP Integration**: Multi-server setup with conflict resolution
- **Debugging**: Full DAP support with Python/Django debugging
- **Testing**: Neotest integration with pytest
- **Git Integration**: Gitsigns, Fugitive, blame toggle
- **File Management**: Telescope, NvimTree, Spectre search/replace

### 🎨 **User Experience**
- **Advanced Folding**: nvim-ufo with PyCharm-like shortcuts
- **Auto-completion**: nvim-cmp with multiple sources
- **Environment Management**: Pyenv integration with automatic detection
- **Code Actions**: Enhanced import management and refactoring

## Keybindings

### General
- `<leader>ca` - Code Actions
- `<leader>tt` - Toggle Type Checking Diagnostics
- `<leader>zR` - Open all folds
- `<leader>zM` - Close all folds
- `<Ctrl-=>` or `<Ctrl-->` - Toggle fold

### Python
- `<leader>pi` - Add Missing Imports (pylsp)
- `<leader>po` - Organize Imports (pylsp)
- `<leader>pr` - Reactivate Pyenv
- `<leader>pl` - Install LSP Packages

For a complete list of keybindings, press `<leader>` and explore the `which-key.nvim` menu.

## Setup

1.  **Clone the repository:**

    ```bash
    git clone git@github.com:chandesh/nvim-config.git ~/.config/nvim
    ```

2.  **Install Neovim and dependencies:**

    Make sure you have Neovim (v0.11+) and the necessary dependencies installed, such as `pyenv` and a global Python version >= 3.9 for Mason.

3.  **Launch Neovim:**

    The first time you launch Neovim, `lazy.nvim` will automatically install all the plugins. You may see some errors from Mason if certain LSPs are not yet installed, but this is normal.

4.  **Install LSPs:**

    You can install the language servers manually with `:MasonInstallAll` or let the configuration handle it as you open files.

## 🧪 Testing

This configuration includes a comprehensive test suite to ensure everything works correctly:

```bash
# Run all tests
./tests/run_tests.sh

# Quick tests for development
./tests/quick_test.sh
```

The test suite validates:
- ✅ Plugin loading and configuration
- ✅ LSP server setup for all supported languages
- ✅ Essential keymaps (including `gd` for go-to-definition and `<C-o>` to go back)
- ✅ Python/Django environment integration
- ✅ File type detection for your tech stack
- ✅ Mason tool installation

See `tests/README.md` for detailed testing documentation.

## Customization

- **Plugins**: Add or remove plugins in the `lua/cm/plugins` directory.
- **Keybindings**: Customize keybindings in `lua/cm/core/keymaps.lua` and `lua/cm/plugins/which-key.lua`.
- **LSP Configuration**: Adjust LSP settings in `lua/cm/plugins/lsp/lspconfig.lua`.

🚀 Enjoy coding with `nvim`! 🚀
