# Neovim Configuration

This is a customized Neovim configuration designed for a seamless and productive development experience, especially for Python/Django projects. It includes a variety of plugins and custom settings to provide a PyCharm-like environment within Neovim.

## Features

- **LSP Support**: Comprehensive language server support with `nvim-lspconfig`, featuring a conflict-free setup for Pyright, Pylsp, and Ruff.
- **Pyenv Integration**: Automatic detection and activation of `pyenv` environments for project-specific Python versions.
- **Advanced Folding**: PyCharm-like code folding with `nvim-ufo`, including default folding for functions and classes.
- **Type Checking Toggle**: A custom keybinding to toggle Pyright's type checking diagnostics on and off, keeping your workspace clean.
- **Auto-Imports**: Robust auto-import functionality powered by `pylsp` and `rope`.
- **Custom Keybindings**: A rich set of custom keybindings for code actions, folding, debugging, and more, all documented with `which-key.nvim`.

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

## Customization

- **Plugins**: Add or remove plugins in the `lua/cm/plugins` directory.
- **Keybindings**: Customize keybindings in `lua/cm/core/keymaps.lua` and `lua/cm/plugins/which-key.lua`.
- **LSP Configuration**: Adjust LSP settings in `lua/cm/plugins/lsp/lspconfig.lua`.

🚀 Enjoy coding with `nvim`! 🚀
