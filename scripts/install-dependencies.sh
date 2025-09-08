#!/bin/bash

# ========================================
# Neovim Full-Stack Development Dependencies Installation Script
# ========================================

set -e

echo "🚀 Installing Neovim Full-Stack Development Dependencies..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper functions
print_step() {
    echo -e "${BLUE}==> $1${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check if we're on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    print_error "This script is designed for macOS. Please adapt it for your OS."
    exit 1
fi

# Check if Homebrew is installed
if ! command_exists brew; then
    print_step "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
    print_success "Homebrew is already installed"
fi

# Update Homebrew
print_step "Updating Homebrew..."
brew update

# Install system dependencies
print_step "Installing system dependencies via Homebrew..."

HOMEBREW_PACKAGES=(
    "neovim"
    "node@20"
    "python@3.11"
    "ripgrep"
    "fd"
    "fzf"
    "git"
    "curl"
    "tree-sitter"
    "lazygit"
)

for package in "${HOMEBREW_PACKAGES[@]}"; do
    if brew list "$package" &>/dev/null; then
        print_success "$package is already installed"
    else
        print_step "Installing $package..."
        brew install "$package"
    fi
done

# Set up Python environment
print_step "Setting up Python development tools..."

PYTHON_CMD="/opt/homebrew/bin/python3.11"
PIP_CMD="/opt/homebrew/bin/pip3.11"

if [[ ! -f "$PYTHON_CMD" ]]; then
    print_error "Python 3.11 not found. Please install it via: brew install python@3.11"
    exit 1
fi

# Install Python packages
PYTHON_PACKAGES=(
    "black"
    "isort"
    "flake8"
    "mypy"
    "debugpy"
    "python-lsp-server[all]"
    "pylsp-mypy"
    "python-lsp-black"
    "python-lsp-isort"
    "djlint"
)

for package in "${PYTHON_PACKAGES[@]}"; do
    print_step "Installing Python package: $package..."
    $PIP_CMD install --upgrade "$package" || print_warning "Failed to install $package"
done

# Set up Node.js environment
print_step "Setting up Node.js development tools..."

NODE_CMD="/opt/homebrew/bin/node"
NPM_CMD="/opt/homebrew/bin/npm"

if [[ ! -f "$NODE_CMD" ]]; then
    print_error "Node.js not found. Please install it via: brew install node@20"
    exit 1
fi

# Install global Node.js packages
NPM_PACKAGES=(
    "typescript"
    "prettier"
    "eslint"
    "@typescript-eslint/eslint-plugin"
    "@typescript-eslint/parser"
    "typescript-language-server"
    "vscode-langservers-extracted"
    "emmet-ls"
    "yaml-language-server"
    "@angular/cli"
    "jsonlint"
    "markdownlint-cli"
)

for package in "${NPM_PACKAGES[@]}"; do
    print_step "Installing Node.js package: $package..."
    $NPM_CMD install -g "$package" || print_warning "Failed to install $package"
done

# Install additional tools via Homebrew
print_step "Installing additional development tools..."

ADDITIONAL_TOOLS=(
    "shellcheck"  # Shell script linter
    "hadolint"    # Dockerfile linter
    "stylua"      # Lua formatter
    "shfmt"       # Shell script formatter
)

for tool in "${ADDITIONAL_TOOLS[@]}"; do
    if brew list "$tool" &>/dev/null; then
        print_success "$tool is already installed"
    else
        print_step "Installing $tool..."
        brew install "$tool"
    fi
done

# Create Neovim config directory if it doesn't exist
CONFIG_DIR="$HOME/.config/nvim"
if [[ ! -d "$CONFIG_DIR" ]]; then
    print_step "Creating Neovim config directory..."
    mkdir -p "$CONFIG_DIR"
fi

# Set up environment variables
print_step "Setting up environment variables..."

# Add to shell profile
SHELL_PROFILE=""
if [[ "$SHELL" == *"zsh"* ]]; then
    SHELL_PROFILE="$HOME/.zshrc"
elif [[ "$SHELL" == *"bash"* ]]; then
    SHELL_PROFILE="$HOME/.bashrc"
fi

if [[ -n "$SHELL_PROFILE" ]]; then
    # Add Homebrew paths
    if ! grep -q "homebrew.*bin" "$SHELL_PROFILE" 2>/dev/null; then
        echo "" >> "$SHELL_PROFILE"
        echo "# Homebrew paths for Neovim development" >> "$SHELL_PROFILE"
        echo 'export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"' >> "$SHELL_PROFILE"
    fi
    
    # Add Node.js path
    if ! grep -q "node@20" "$SHELL_PROFILE" 2>/dev/null; then
        echo 'export PATH="/opt/homebrew/opt/node@20/bin:$PATH"' >> "$SHELL_PROFILE"
    fi
    
    # Add Python path
    if ! grep -q "python@3.11" "$SHELL_PROFILE" 2>/dev/null; then
        echo 'export PATH="/opt/homebrew/opt/python@3.11/bin:$PATH"' >> "$SHELL_PROFILE"
    fi
    
    print_success "Environment variables added to $SHELL_PROFILE"
fi

# Verify installations
print_step "Verifying installations..."

echo ""
echo "System Tools:"
echo "  Neovim: $(nvim --version | head -1 | grep -o 'v[0-9]\+\.[0-9]\+\.[0-9]\+')"
echo "  Node.js: $(node --version)"
echo "  Python: $(python3.11 --version)"
echo "  Git: $(git --version | grep -o '[0-9]\+\.[0-9]\+\.[0-9]\+')"

echo ""
echo "Python Tools:"
python3.11 -c "
import sys
packages = ['black', 'isort', 'flake8', 'mypy', 'debugpy']
for pkg in packages:
    try:
        __import__(pkg)
        print(f'  ✓ {pkg}')
    except ImportError:
        print(f'  ✗ {pkg}')
"

echo ""
echo "Node.js Tools:"
for tool in typescript prettier eslint; do
    if command_exists "$tool"; then
        version=$($tool --version 2>/dev/null || echo "installed")
        echo "  ✓ $tool ($version)"
    else
        echo "  ✗ $tool"
    fi
done

# Final instructions
echo ""
print_success "🎉 Dependencies installation completed!"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo "1. Restart your terminal or run: source $SHELL_PROFILE"
echo "2. Open Neovim and let it install plugins: nvim"
echo "3. Run :Mason to verify language servers are installed"
echo "4. Run :checkhealth to verify everything is working"
echo ""
echo -e "${BLUE}Happy coding! 🚀${NC}"
