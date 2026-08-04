# Neovim Configuration
## vim.pack · Neovim 0.12.4 · Python/Django · TypeScript/Angular/React · Go

### Startup Performance
~139ms cold start (measured via `--startuptime`; snacks modules load in <1ms)

### Architecture
- **Plugin loading**: Native `vim.pack` (`pack/*/start` and `pack/*/opt`)
- **Deferred loading**: Theme + options + Python host synchronous; everything else via `vim.schedule`
- **Plugin management**: Built-in `:PI`/`:PU`/`:PS` commands (git clone/pull into `pack/`)
- **QoL modules**: [snacks.nvim](https://github.com/folke/snacks.nvim) powers the picker (replaces Telescope), dashboard (replaces alpha), explorer (replaces nvim-tree), which-key, indent guides, notifier, zen/zoom, undo history, terminal, and LazyGit

### Colorscheme
**Solarized Osaka** (`craftzdog/solarized-osaka.nvim`)
- Variant: `solarized-osaka`
- Transparency: `true`, italic comments/keywords
- Custom `on_colors`/`on_highlights` for bufferline, lualine, etc.

### Tech Stack Support

| Stack | LSP | Tools |
|-------|-----|-------|
| Python/Django | pyright | venv-selector, nvim-lint (ruff), conform (black/isort), dap-python |
| TypeScript/Angular/React | ts_ls, angularls, eslint | typescript-tools.nvim, tsc.nvim |
| Go | gopls | gopher.nvim, nvim-dap-go |
| Bash | bashls | |
| SQL | sqlls | |
| YAML/JSON | yamlls, jsonls | SchemaStore.nvim |
| HTML/CSS | html, cssls, tailwindcss, emmet_ls | |
| Lua | lua_ls | |

### Completion (blink.cmp)
- Tab: Select next / Confirm
- S-Tab: Select previous
- CR: Confirm selection
- Copilot source via blink-copilot (native Neovim LSP integration)

### Plugin Management

Inside Neovim:
- `:PI` — Install missing plugins
- `:PU` — Update all plugins
- `:PS` — Sync (update then install)

Alternatively via shell:
- `bash ~/.config/nvim/install.sh` — Install all plugins
- `bash ~/.config/nvim/update.sh` — Update all plugins
- Plugins stored in `~/.config/nvim/pack/`

### Python Environment
**Resolution Order**:
1. pyenv `nvim-env` virtualenv (`~/.pyenv/versions/nvim-env/`)
2. pyenv local (`.python-version` in project dir)
3. pyenv global
4. Project `.venv/`
5. Project `venv/`
6. pyenv shim
7. System `python3`

**Setup**: `bash ~/.config/nvim/scripts/setup_python.sh`

### Key Bindings (leader = Space)

| Group | Key | Action |
|-------|-----|--------|
| **Find** | `<leader>ff` | Smart find files (git-aware) |
| | `<leader>fF` | Find all files (ignore gitignore) |
| | `<leader>fg` | Find git files |
| | `<leader>fr` | Find recent files (cwd only) |
| | `<leader>fs` | Live grep |
| | `<leader>fb` | Search open buffers |
| | `<leader>fc` | Search word under cursor |
| | `<leader>fB` | Find buffers |
| | `<leader>ft` | Find TODOs |
| | `<leader>fh` | Find help |
| | `<leader>fT` | Switch theme |
| **LSP** | `gd` | Go to Definition (picker) |
| | `gD` | Go to Declaration |
| | `gi` | Go to Implementation |
| | `gy` | Go to Type Definition |
| | `gr` | Go to References |
| | `K` | Hover documentation |
| | `<leader>ca` | Code Action |
| | `<leader>cr` | Rename |
| **Git** | `<leader>gg` | LazyGit |
| | `<leader>gs` | LazyGit status |
| | `<leader>gd` | Git diff hunks |
| | `<leader>gl` | Git log |
| | `<leader>gB` | Git branches |
| | `<leader>gS` | Git stash |
| **Explorer** | `<leader>ee` | Toggle file explorer (snacks) |
| | `<leader>ef` | Explorer at current file |
| **Session** | `<leader>wr` | Restore session |
| | `<leader>ws` | Save session |
| **Debug** | `<leader>db` | Toggle breakpoint |
| | `<leader>dc` | Continue/Start |
| | `<leader>du` | Toggle debug UI |
| **Django** | `<leader>ps` | Start dev server |
| | `<leader>pm` | manage.py command |
| **Toggle** | `<leader>tt` | Toggle Pyright diagnostics |
| | `<leader>sm` | Toggle zoom |

### LSP Servers (managed by Mason)
pyright, ts_ls, angularls, gopls, bashls, sqlls, yamlls, jsonls, lua_ls, html, cssls, tailwindcss, eslint

### Fresh Machine Setup
```bash
# 1. Clone config
git clone <repo-url> ~/.config/nvim

# 2. Install plugins
bash ~/.config/nvim/install.sh

# 3. Set up Python
bash ~/.config/nvim/scripts/setup_python.sh

# 4. Open Neovim
nvim
# :MasonInstall     — LSP servers (auto via mason-lspconfig)
# :TSUpdate         — Treesitter parsers
# :checkhealth      — Verify everything
```

**What is in this repo**: Only Lua config files and shell scripts (~328 KB).

**What is NOT in this repo** (generated at setup):
- `pack/` — all plugins (git-cloned via install.sh)
- Treesitter parsers (installed by `:TSUpdate`)
- Mason packages (installed by `:MasonInstall`)
- Compiled extensions (built during install)

### Health Check
- `:checkhealth`
- `:checkhealth provider`
- `:checkhealth nvim-treesitter`
