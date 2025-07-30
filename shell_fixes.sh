#!/bin/bash
#
# Neovim & Pyenv Integration Helper
#
# This script provides a wrapper function for Neovim to ensure seamless
# integration with pyenv virtual environments, resolving potential PATH
# conflicts that can cause warnings in `:checkhealth`.
#
# Works with zsh and bash on macOS and Linux.
#
# INSTRUCTIONS:
# 1. Add the following line to your ~/.zshrc (or ~/.bashrc):
#    source "/Users/chandesh/.config/nvim/shell_fixes.sh"
# 2. Restart your shell or run `source ~/.zshrc`.
# 3. (Optional) Alias `nvim` to `nvim_with_venv` to use it automatically.
#    You can do this by uncommenting the alias line at the end of this file.

function nvim_with_venv() {
    # Check if a virtual environment is active by checking for $VIRTUAL_ENV
    # and ensuring the 'activate' script exists.
    if [[ -n "$VIRTUAL_ENV" && -e "${VIRTUAL_ENV}/bin/activate" ]]; then
        # Temporarily source the activate script to align shell paths for Neovim.
        source "${VIRTUAL_ENV}/bin/activate"

        # Run Neovim with all original arguments.
        # 'command' ensures we call the real nvim executable, not the function itself.
        command nvim "$@"

        # Deactivate the virtual environment when Neovim exits.
        # This prevents the venv from polluting your parent shell session.
        # Errors are suppressed in case deactivate isn't available or fails.
        deactivate 2>/dev/null || true
    else
        # If no virtual environment is active, just run Neovim normally.
        command nvim "$@"
    fi
}

# To automatically use this wrapper, uncomment the line below in the file
# located at ~/.config/nvim/shell_fixes.sh.
# Otherwise, you can manually run `nvim_with_venv` to start Neovim.
# alias nvim=nvim_with_venv

