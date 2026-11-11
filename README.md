# Neovim Configuration
## vim.pack · Neovim 0.12.6 · Python/Django · TypeScript/Angular/React · Go · Flutter/Dart

### Startup Performance
~32ms headless startup (measured via `--startuptime`; ~50% faster than the 64.6ms pre-cleanup baseline; snacks modules load in <1ms)

### Architecture
- **Plugin loading**: Native `vim.pack` (`pack/*/start` and `pack/*/opt`)
- **Deferred loading**: Theme + options + Python host synchronous; the remaining modules are deferred and load on the event that needs them
- **Plugin management**: Built-in `:PI`/`:PU`/`:PS` commands (git clone/pull into `pack/`)
- **QoL modules**: [snacks.nvim](https://github.com/folke/snacks.nvim) powers the picker (replaces Telescope), dashboard (replaces alpha), explorer (replaces nvim-tree), indent guides, notifier, zen/zoom, undo history, terminal, and LazyGit. which-key remains its own plugin.
- **Markdown preview**: `render-markdown.nvim` renders inline; `vellum.nvim` opens a read-only side preview on `<leader>mv`. Diagrams/images require kitty or Ghostty (run `:Vellum build` once there); WezTerm falls back to text.

### Colorscheme
**Solarized Osaka** (`craftzdog/solarized-osaka.nvim`)
- Variant: `solarized-osaka`
- Transparency: `true`, italic comments/keywords
- Custom `on_colors`/`on_highlights` for bufferline, lualine, etc.

### Tech Stack Support

| Stack | LSP | Tools |
|-------|-----|-------|
| Python/Django | pyright | venv-selector, nvim-lint (ruff), conform (black/isort), dap-python |
| TypeScript/Angular/React | ts_ls, angularls, eslint | tsc.nvim |
| Go | — | gopher.nvim, nvim-dap-go |
| Flutter/Dart | dartls (via flutter-tools.nvim) | flutter-tools.nvim (hot reload, devices, outline), conform (dart_format), nvim-dap |
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
| **Tests** | `<leader>tr` | Test nearest (neotest); `<leader>tF` file, `<leader>tS` summary, `<leader>tl` last, `<leader>tq` stop, `<leader>td` debug |
| **AI** | `<leader>aa` | Copilot chat; `<leader>ae` explain selection/line, `<leader>aq` quick prompt |
| **Context** | `[c` / `]c` | Jump to an `nvim-treesitter-context` header |
| **Markdown** | `<leader>mv` | Toggle Vellum read-only side preview (text-only in WezTerm) |
| **Flutter** | `<leader>flr` | Flutter run |
| | `<leader>fld` | Select device |
| | `<leader>fle` | Select emulator |
| | `<leader>flh` | Hot reload |
| | `<leader>flR` | Hot restart |
| | `<leader>flq` | Quit session |
| | `<leader>flo` | Widget outline |
| | `<leader>flv` | Visual debug |
| | `<F5>` | DAP continue |
| | `<F10>`/`<F11>`/`<F12>` | DAP step over/into/out |
| **Django** | `<leader>ps` | Start dev server |
| | `<leader>pm` | manage.py command |
| **Toggle** | `<leader>tt` | Toggle Pyright diagnostics |
| | `<leader>sm` | Toggle zoom |

### LSP Servers (managed by Mason)
pyright, ts_ls, angularls, yamlls, jsonls, lua_ls, html, cssls, tailwindcss, eslint, emmet_ls

*Note: `dartls` is bundled with the Flutter SDK and configured by flutter-tools.nvim — do not add it to Mason.*

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
