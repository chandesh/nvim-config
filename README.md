# Neovim Configuration for Full-Stack Development

A complete, modern Neovim configuration optimized for full-stack development with Python/Django and JavaScript/TypeScript/Angular/React.

## 🚀 Features

### Core Features
- **Modern Plugin Manager**: Lazy.nvim for fast, efficient plugin loading
- **LSP (Language Server Protocol)**: Full language server support with autocomplete, diagnostics, and navigation
- **Treesitter**: Advanced syntax highlighting and code understanding
- **Completion Engine**: Intelligent autocompletion with nvim-cmp
- **Advanced File Navigation**: nvim-tree explorer + Telescope fuzzy finder with performance optimizations
- **Git Integration**: Comprehensive Git workflow with gitsigns, fugitive, and diffview
- **Debugging**: Full DAP (Debug Adapter Protocol) support for Python and JavaScript/TypeScript
- **AI Code Assistance**: GitHub Copilot integration with chat support
- **Advanced Text Editing**: Surround, autopairs, multicursors, and more
- **Project-Wide Operations**: Search & replace with nvim-spectre
- **Session Management**: Auto-session with directory-aware restoration
- **Enhanced Diagnostics**: Trouble.nvim for better error/warning management
- **TODO Management**: Todo-comments with Telescope integration
- **Code Folding**: Advanced UFO folding with manual controls
- **Window Management**: Split maximization and comprehensive window operations

### Language Support

#### Python & Django
- **Python LSP**: pylsp with rope, black, isort integration
- **Django Support**: Template syntax highlighting, smart environment detection
- **Virtual Environment**: Automatic pyenv and virtualenv detection
- **Debugging**: Full Python and Django debugging with debugpy
- **Formatting**: Black, isort automatic formatting
- **Linting**: flake8, mypy integration

#### JavaScript/TypeScript & Frameworks
- **TypeScript LSP**: ts_ls (formerly tsserver) with full IntelliSense
- **ESLint Integration**: Real-time linting and fixing
- **Framework Support**: React, Angular syntax and snippets
- **Emmet Support**: Fast HTML/CSS expansion
- **Prettier Integration**: Automatic code formatting
- **Node.js Debugging**: Debug Node.js and TypeScript applications

#### Web Technologies
- **HTML/CSS**: Full syntax support with Emmet
- **JSON/YAML**: Schema validation and autocompletion
- **Markdown**: Enhanced editing with preview capabilities

### UI & Experience
- **Beautiful Theme**: Solarized Osaka (your favorite from backup) with transparent background
- **Alternative Themes**: Tokyo Night and Catppuccin available
- **Custom Telescope Styling**: Seamless integration with theme
- **Statusline**: Information-rich lualine configuration
- **File Explorer**: Neo-tree with Git integration
- **Fuzzy Finding**: Telescope with custom styling
- **Notifications**: Modern notification system with noice.nvim
- **Dashboard**: Beautiful alpha-nvim startup screen

## 📋 Requirements

### System Dependencies
- **Neovim**: 0.10+ (latest stable recommended)
- **Node.js**: 20+ (for TypeScript/JavaScript language servers)
- **Python**: 3.11+ (with pip)
- **Git**: For version control features
- **ripgrep**: For fast text searching
- **fd**: For fast file finding
- **fzf**: For fuzzy finding

### Optional but Recommended
- **pyenv**: For Python version management
- **nvm**: For Node.js version management

## 🚀 Setup

### Prerequisites

Ensure you have the following installed:
- **Neovim**: v0.10+ (v0.11+ recommended)
- **Git**: For cloning the repository and version control features
- **Python**: 3.9+ (for Mason and Python development)
- **Node.js**: 20+ (for TypeScript/JavaScript language servers)

### Quick Setup

1. **Clone the repository:**
   ```bash
   git clone https://github.com/chandesh/nvim-config.git ~/.config/nvim
   ```

2. **Install Neovim and dependencies:**
   
   **macOS (using Homebrew):**
   ```bash
   # Install essential tools
   brew install neovim ripgrep fd fzf git curl wget tree-sitter
   brew install node@20 python@3.11
   
   # Python tools
   pip3 install black isort flake8 mypy debugpy
   
   # Node.js tools (global)
   npm install -g prettier eslint typescript @angular/cli
   ```
   
   **Ubuntu/Debian:**
   ```bash
   # Install Neovim (latest)
   sudo snap install nvim --classic
   
   # Install dependencies
   sudo apt update
   sudo apt install ripgrep fd-find fzf git curl wget nodejs npm python3-pip
   
   # Python tools
   pip3 install black isort flake8 mypy debugpy
   
   # Node.js tools
   sudo npm install -g prettier eslint typescript @angular/cli
   ```

3. **Launch Neovim:**
   ```bash
   nvim
   ```
   
   The first time you launch Neovim:
   - **lazy.nvim** will automatically install all plugins
   - You may see some errors from Mason if certain LSPs are not yet installed - this is normal
   - Wait for all plugins to finish installing (check the bottom status)

4. **Install Language Servers:**
   
   After Neovim opens, install language servers using Mason:
   ```vim
   :Mason
   ```
   
   Or install all recommended servers at once:
   ```vim
   :MasonInstallAll
   ```
   
   **Recommended LSPs to install:**
   - `pyright` or `pylsp` (Python)
   - `typescript-language-server` (TypeScript/JavaScript) 
   - `html-lsp` (HTML)
   - `css-lsp` (CSS)
   - `json-lsp` (JSON)
   - `lua-language-server` (Lua)

5. **Restart Neovim:**
   ```bash
   nvim
   ```
   
   After restart, everything should be working smoothly!

### Verification

To verify your setup is working correctly:

1. **Check health:**
   ```vim
   :checkhealth
   ```

2. **Test LSP:**
   - Open a Python or TypeScript file
   - You should see syntax highlighting and diagnostics
   - Try `gd` (go to definition) on a function

3. **Test key bindings:**
   - Press `<Space>` and wait to see which-key popup
   - Try `<Space>ff` to find files
   - Try `<Space>sm` to maximize/minimize window splits

4. **Test Copilot (if you have access):**
   - In insert mode, start typing code
   - Use `Ctrl+y` to accept Copilot suggestions

### Environment Setup (Optional but Recommended)

For the best development experience:

1. **Python virtual environment management:**
   ```bash
   # Install pyenv for Python version management
   curl https://pyenv.run | bash
   ```

2. **Node.js version management:**
   ```bash
   # Install nvm for Node.js version management
   curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
   ```

### Troubleshooting Setup

- **Plugin installation fails:** Restart Neovim and run `:Lazy sync`
- **LSP not working:** Check `:LspInfo` and install missing servers via `:Mason`
- **Python issues:** Ensure Python 3.9+ is available and run `:checkhealth python`
- **Permission issues:** Make sure you have write access to `~/.config/nvim`

## 🛠 Installation & Dependency Management

### Automated Dependency Installation

This configuration includes a comprehensive dependency installation script that automatically handles all required tools and packages:

```bash
# Run the automated installer (macOS)
~/.config/nvim/scripts/install-dependencies.sh
```

The script will:
- Install Homebrew (if not present)
- Install system dependencies via Homebrew
- Set up Python 3.11 and required packages
- Install Node.js 20 and global npm packages
- Configure environment variables
- Verify all installations

### What Gets Installed

### System Packages (via Homebrew)
```bash
brew install neovim node@20 python@3.11 ripgrep fd fzf git curl wget tree-sitter
```

### Python Tools
```bash
pip install black isort flake8 mypy debugpy
```

### Node.js Tools (Global)
```bash
npm install -g prettier eslint typescript @angular/cli
```

### Plugin Installation
Plugins are automatically installed via lazy.nvim on first startup.

## 🎯 Key Bindings

### General Navigation & Editing
- `<Space>` - Leader key
- `<C-s>` - Save file
- `<leader>qq` - Quit all
- `<Esc>` - Clear search highlights
- `<leader>nh` - Clear search highlights (alternative)
- `dw` - Delete word backwards (custom)
- `<C-h/j/k/l>` - Navigate windows
- `<C-Up/Down/Left/Right>` - Resize windows
- `<A-j/k>` - Move lines up/down
- `<S-h/l>` - Navigate buffers

### 🔍 Telescope (Advanced File & Text Search)

#### File Finding
- `<leader>ff` - **Smart find files** (git-aware, primary finder)
- `<leader>fF` - Find ALL files (ignore .gitignore)
- `<leader>fg` - Git files only
- `<leader>fr` - Recent files (current directory)
- `<leader>fB` - Browse open buffers
- `<leader>fh` - Help tags
- `<leader>ft` - Find TODOs/FIXMEs

#### Text Searching (Lightning Fast with ripgrep)
- `<leader>fs` - **Live grep** (search text in all files)
- `<leader>fb` - Search in open buffers only
- `<leader>fc` - Find word under cursor
- `<leader>fp` - Search Python files only
- `<leader>fj` - Search JS/TS files only

#### Smart Adaptive Search (Project-size aware)
- `<leader>fS` - Smart find files (adapts to project size)
- `<leader>fG` - Smart live grep (optimized for large projects)
- `<leader>fds` - Search src/ directories
- `<leader>fdt` - Search test/ directories  
- `<leader>fdc` - Search config/ directories

#### Additional Telescope Functions
- `<leader>sjm` - Jump to marks (Telescope marks)

### 📁 File Explorer (nvim-tree)
- `<leader>ee` - Toggle file explorer
- `<leader>ef` - Find current file in explorer
- `<leader>ec` - Collapse file explorer
- `<leader>er` - Refresh file explorer

### 🔄 Search & Replace (Project-wide)
- `<leader>sr` - **Open Spectre** (search & replace across project)
- `<leader>sw` - Search current word with Spectre
- `<leader>sw` - Search current selection with Spectre (visual mode)
- `<leader>sp` - Search in current file with Spectre

### ❌ Diagnostics & Trouble
- `<leader>xw` - Workspace diagnostics (Trouble)
- `<leader>xd` - Document diagnostics (Trouble)
- `<leader>xq` - Quickfix list (Trouble)
- `<leader>xl` - Location list (Trouble) 
- `<leader>xt` - TODOs in Trouble
- `]t` / `[t` - Next/previous TODO comment
- `]d` / `[d` - Next/previous diagnostic
- `]e` / `[e` - Next/previous error
- `]w` / `[w` - Next/previous warning

### 🪟 Window & Session Management
- `<leader>sv` - Split window vertically
- `<leader>sh` - Split window horizontally  
- `<leader>se` - Make splits equal size
- `<leader>sx` - Close current split
- `<leader>sm` - **Maximize/minimize split** (vim-maximizer)
- `<leader>wr` - Restore session for current directory
- `<leader>ws` - Save session

### 📑 Tab Management
- `<leader>to` - Open new tab
- `<leader>tx` - Close current tab
- `<leader>tn` - Next tab
- `<leader>tp` - Previous tab
- `<leader><tab><tab>` - New tab
- `<leader><tab>d` - Close tab
- `<leader><tab>]` / `<leader><tab>[` - Navigate tabs

### 🎨 Manual Formatting & Linting (Preferred Workflow)
- `<leader>mp` - **Format file or range** (manual, primary)
- `<leader>mf` - **Format + Lint combo** (thorough cleanup)
- `<leader>mq` - Quick format (formatters only, no LSP)
- `<leader>ma` - Toggle auto-format for current session
- `<leader>ll` - Trigger linting for current file

### 🐍 Python Development

#### Python Execution & Django
- `<leader>pr` - Run Python file
- `<leader>pm` - Django manage.py command (prompt)
- `<leader>ps` - Start Django dev server
- `<leader>psh` - Django shell  
- `<leader>pdb` - Django database shell

#### Python Environment & Tools
- `<leader>tt` - **Toggle Pyright type checking diagnostics**
- `<leader>pv` - Pick Python virtual environment

### 🌐 JavaScript/TypeScript Development  
- `<leader>jr` - Run JavaScript/Node file
- `<leader>jt` - Run npm tests
- `<leader>jd` - Run npm dev server
- `<leader>jb` - Build project (npm run build)
- `<leader>ji` - Install npm packages

### 🛠 Quick File Access
- `<leader>ep` - Edit pyproject.toml
- `<leader>eR` - Edit requirements.txt
- `<leader>ej` - Edit package.json
- `<leader>ed` - Edit docker-compose.yml
- `<leader>edf` - Edit Dockerfile

### 🗄️ Database Development
- `<leader>sq` - Open SQLite in terminal
- `<leader>sp` - Open PostgreSQL in terminal

### 🖥️ Terminal Management
- `<leader>T` - Open terminal (moved to avoid conflict)
- `<leader>term` - Open horizontal terminal
- `<leader>tv` - Open vertical terminal
- `<C-/>` - Quick terminal toggle

### 🐛 Advanced Debugging (DAP)

#### Breakpoint Management
- `<leader>db` - **Toggle breakpoint**
- `<leader>dbc` - Set conditional breakpoint
- `<leader>dbl` - List all breakpoints
- `<leader>dca` - Clear all breakpoints

#### Debug Session Control
- `<leader>dc` - **Continue/Start debugging**
- `<leader>dso` - Step over
- `<leader>dsi` - Step into
- `<leader>dse` - Step out
- `<leader>dt` - Terminate debug session
- `<leader>dr` - Restart debug session

#### Debug UI & Evaluation
- `<leader>du` - **Toggle debug UI**
- `<leader>de` - Evaluate expression (normal/visual mode)
- `<leader>dre` - Toggle REPL
- `<leader>drl` - Run last debug configuration

#### Python-Specific Debugging
- `<leader>dpt` - Debug Python test method
- `<leader>dpc` - Debug Python test class
- `<leader>dps` - Debug Python selection (visual mode)

### 🧪 Testing (Python)
- `<leader>tr` - Run nearest test
- `<leader>tf` - Run test file
- `<leader>td` - Debug nearest test
- `<leader>ts` - Toggle test summary
- `<leader>tO` - Show test output

### 🤖 AI Code Assistance (GitHub Copilot)
- `<Ctrl+y>` - Accept Copilot suggestion (insert mode, primary)
- `<Ctrl+l>` - Accept Copilot suggestion (insert mode, alternative)
- `<Ctrl+]>` - Next Copilot suggestion (insert mode)
- `<Ctrl+[>` - Previous Copilot suggestion (insert mode)
- `<leader>cc` - Open Copilot Chat
- `<leader>ce` - Explain code/selection
- `<leader>cr` - Review code/selection
- `<leader>cf` - Fix code/selection
- `<leader>co` - Optimize code
- `<leader>cd` - Generate documentation
- `<leader>ct` - Generate tests

### ✂️ Advanced Text Editing & Completion
- `<Tab>` - Navigate completion menu / Accept completion (nvim-cmp)
- `<S-Tab>` - Navigate completion menu backwards (nvim-cmp)
- `<CR>` - Accept selected completion (nvim-cmp)
- `<C-Space>` - Trigger completion manually (nvim-cmp)
- `<leader>M` - **Multiple cursors** (visual/normal mode)
- Surround operations (nvim-surround): `ys`, `cs`, `ds`
- Auto-pairs: `<M-e>` - Fast wrap

### 📂 Code Folding (Manual Control)
- `za` - Toggle fold under cursor
- `zo` / `zc` - Open/close fold under cursor
- `zO` / `zC` - Open/close all folds under cursor
- `zR` - Open all folds (UFO)
- `zM` - Close all folds (UFO)
- `zr` - Open folds except kinds
- `zm` - Close folds with
- `zj` / `zk` - Navigate to next/previous fold
- `<C-=>` / `<C-->` - Toggle fold (convenient shortcuts)

### 📋 Buffer Management
- `<leader>bd` - Delete current buffer
- `<leader>bD` - Force delete current buffer
- `<leader>bp` - Toggle buffer pin
- `<leader>bo` - Delete other buffers
- `<leader>br` / `<leader>bl` - Delete buffers to right/left

### Git Integration (Enhanced)
- `<leader>gp` - Preview git hunk
- `<leader>gt` - Toggle git blame line
- `]h` / `[h` - Next/previous git hunk

## 🐍 Python Development

### Virtual Environments
The configuration automatically detects:
- **virtualenv/venv**: `VIRTUAL_ENV` environment variable
- **pyenv**: System pyenv installation
- **conda**: Conda environments

### Django Support
- Django template syntax highlighting (`.html` files in `templates/` directories)
- Django-specific debugging configurations
- Automatic Django project detection

### Python-specific Features
- **Auto-formatting**: Black (88 character line length)
- **Import sorting**: isort integration
- **Type checking**: mypy support
- **Linting**: flake8 with customized rules
- **Environment display**: Current virtual environment in statusline

## 🌐 JavaScript/TypeScript Development

### TypeScript Support
- Full TypeScript language server with IntelliSense
- Real-time error checking and suggestions
- Import/export assistance
- Refactoring support

### Framework Support
- **React**: JSX/TSX syntax highlighting and completion
- **Angular**: Component and service templates
- **HTML/CSS**: Emmet expansion and completion

### Code Quality
- **ESLint**: Real-time linting with auto-fix
- **Prettier**: Consistent code formatting
- **Import sorting**: Automatic import organization

## 🔧 Customization

### Adding Languages
To add support for new languages:

1. Add the language server to `lua/plugins/lsp.lua`
2. Add Treesitter parser to `lua/plugins/treesitter.lua`
3. Add formatters/linters to `lua/plugins/formatting.lua`

### Changing Themes
Your favorite **Solarized Osaka** theme is now set as default! To switch themes:

```bash
# In Neovim, try these commands:
:colorscheme tokyonight        # Switch to Tokyo Night
:colorscheme catppuccin        # Switch to Catppuccin
:colorscheme solarized-osaka   # Back to your favorite (default)
```

To make a theme change permanent, edit `lua/plugins/ui.lua` and change the `vim.cmd.colorscheme()` line.

**Available themes:**
- **solarized-osaka** (default - your favorite from backup)
- **tokyonight** (modern dark theme)
- **catppuccin** (pastel theme)

You can also use Telescope to preview themes:
```bash
:Telescope colorscheme enable_preview=true
```

### Custom Keybindings
Add your custom keybindings to `lua/config/keymaps.lua`

### Environment-specific Settings
Create `.nvimrc.lua` files in your project directories for project-specific settings.

## 🔍 Troubleshooting

### Plugin Issues
```bash
# Open Neovim and run:
:Lazy sync
:Mason
```

### LSP Issues
```bash
# Check LSP status:
:LspInfo
# Restart LSP:
:LspRestart
```

### Python Environment Issues
```bash
# Check Python path:
:lua print(vim.g.python3_host_prog)
# Select virtual environment:
:VenvSelect
```

### Performance Issues
If Neovim feels slow:
1. Check `:checkhealth`
2. Disable unused plugins in plugin configs
3. Reduce `updatetime` in `lua/config/options.lua`

## 📁 Configuration Structure

```
~/.config/nvim/
├── init.lua                         # Main configuration entry point
├── lua/
│   ├── config/
│   │   ├── autocmds.lua              # Autocommands
│   │   ├── keymaps.lua               # Comprehensive key mappings
│   │   ├── options.lua               # Neovim options
│   │   └── telescope-performance.lua # Advanced telescope optimizations
│   └── plugins/
│       ├── core.lua                 # Core plugins (which-key, etc.)
│       ├── lsp.lua                  # Language server configuration
│       ├── treesitter.lua           # Syntax highlighting
│       ├── completion.lua           # Autocompletion setup
│       ├── debugging.lua            # Debug adapter protocol
│       ├── formatting.lua           # Formatters and linters
│       ├── git.lua                  # Git integration
│       ├── ui.lua                   # Themes and UI enhancements
│       ├── telescope.lua            # Advanced telescope with FZF
│       ├── file-explorer.lua        # nvim-tree configuration
│       ├── folding.lua              # UFO code folding
│       ├── search-replace.lua       # nvim-spectre configuration
│       ├── diagnostics.lua          # Trouble & todo-comments
│       ├── editing.lua              # Surround, autopairs, multicursors
│       ├── window-session.lua       # Window maximizer & auto-session
│       └── copilot.lua              # GitHub Copilot integration
├── scripts/                         # Installation and utility scripts
└── README.md                        # This comprehensive guide
```

## 🎉 Getting Started

1. **Open Neovim**: The configuration will auto-install plugins on first launch
2. **Wait for installation**: Let all plugins download and install
3. **Restart Neovim**: For best results after initial setup
4. **Open a project**: Navigate to your development directory
5. **Test features**: Try the key bindings and explore the interface

### First Steps
1. Press `<Space>ff` to find files
2. Open a Python or TypeScript file to see LSP in action
3. Try `gd` to go to definition
4. Use `<leader>e` to open the file explorer
5. Test debugging with `<leader>db` to set a breakpoint

## 📚 Learning Resources

- **Which-key**: Press `<Space>` and wait to see available keybindings
- **Help system**: Use `:help` for Neovim documentation
- **Plugin docs**: Most plugins have excellent documentation
- **LSP info**: Use `:LspInfo` to see active language servers

## 🤝 Support

This configuration provides a solid foundation for full-stack development. The setup includes:

- ✅ **Python/Django**: Full IDE features with debugging
- ✅ **JavaScript/TypeScript**: Modern development with IntelliSense  
- ✅ **React/Angular**: Framework-specific support
- ✅ **Git Integration**: Complete version control workflow
- ✅ **Modern UI**: Beautiful and functional interface
- ✅ **Cross-platform**: Works on macOS, Linux, and Windows (WSL)

Happy coding! 🚀
