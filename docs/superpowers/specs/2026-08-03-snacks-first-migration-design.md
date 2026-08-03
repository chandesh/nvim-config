# Snacks-First Migration Design

**Date:** 2026-08-03
**Target:** Neovim v0.12.4 · native `vim.pack` (`pack/<bundle>/<start|opt>/<name>`) · Snacks-first
**Status:** Approved by user

## 1. Goal

Make this configuration **Snacks-first** while remaining on the existing native
`vim.pack` architecture (the `pack/*/start` + `pack/*/opt` layout managed by
`lua/config/manager.lua`, `install.sh`, `update.sh`). Adopt every Snacks.nvim
module that is a mature, stable replacement for an existing plugin. Keep
dedicated plugins only where Snacks or native Neovim cannot replace the
functionality.

## 2. Decisions (confirmed with user)

| Decision | Choice |
|---|---|
| Aggressiveness | **Maximal** Snacks adoption |
| Git workflow | **LazyGit-first** via `snacks.lazygit` + `snacks.picker.git_*` |
| Statusline | **Keep lualine custom** (no `snacks.statusline` exists) |
| Gutter signs | **Keep gitsigns for signs only** (no `snacks.gitsigns` exists) |
| Sessions | **Keep auto-session** (no `snacks.sessions` exists) |
| Buffer tabs | **Keep bufferline** (no `snacks.bufferline` exists) |

Corrections to my earlier mislabels: Snacks has **no** `statusline`, `gitsigns`,
`bufferline`, or `sessions` modules. The real Snacks v3 module set is: animate,
bigfile, bufdelete, dashboard, debug, dim, explorer, gh, git, gitbrowse, image,
indent, input, keymap, layout, lazygit, notifier, notify, picker, profiler,
quickfile, rename, scope, scratch, scroll, statuscolumn, terminal, toggle, util,
win, words, zen.

## 3. Plugin Registry Changes

### 3.1 Add

- `folke/snacks.nvim` → `pack/core/start/snacks.nvim`

### 3.2 Remove (Snacks replacement)

| Plugin | Snacks replacement |
|---|---|
| telescope.nvim | `snacks.picker` |
| telescope-fzf-native.nvim | `snacks.picker` (native, no fzf build) |
| telescope-themes | `snacks.picker.colorschemes` |
| alpha-nvim | `snacks.dashboard` |
| indent-blankline.nvim | `snacks.indent` |
| which-key.nvim | `snacks.whichkey` |
| trouble.nvim | `snacks.picker` (diagnostics/loclist/qflist) |
| todo-comments.nvim | `snacks.picker.grep` TODO pattern |
| noice.nvim | `snacks.notifier` + native cmdline |
| nvim-notify | `snacks.notifier` |
| nui.nvim | dropped (dep of noice/trouble) |
| dressing.nvim | `snacks.input` |
| nvim-navic | `snacks.picker` / statusline |
| neoscroll.nvim | `snacks.animate` + `snacks.scroll` |
| undotree.nvim | `snacks.picker.undo` |
| vim-fugitive | `snacks.lazygit` |
| neogit | `snacks.lazygit` |
| diffview.nvim | `snacks.lazygit` + `snacks.picker.git_*` |
| gv.vim | `snacks.picker.git_log` |
| git-conflict-nvim | `snacks.lazygit` |
| goto-preview | `snacks.picker` LSP pickers (peek/preview) |
| harpoon | `snacks.picker` buffers/files |
| aerial.nvim | `snacks.picker.lsp_symbols` / `snacks.picker.treesitter` |
| twilight.nvim | `snacks.dim` |
| zen-mode.nvim | `snacks.zen` |
| none-ls.nvim | removed (unused) |
| nvim-tree.lua | `snacks.explorer` |

### 3.3 Keep (no Snacks equivalent)

- core: plenary.nvim, nvim-web-devicons, auto-session
- theme: solarized-osaka.nvim, tokyonight.nvim, catppuccin
- treesitter: nvim-treesitter, nvim-treesitter-textobjects, nvim-ts-autotag
- lsp: nvim-lspconfig, mason.nvim, mason-lspconfig.nvim, SchemaStore.nvim
- completion: blink.cmp, blink-copilot, LuaSnip, friendly-snippets
- editing: conform.nvim, nvim-autopairs, nvim-surround, Comment.nvim,
  vim-visual-multi, nvim-ufo, promise-async, nvim-spectre, flash.nvim
- git: gitsigns.nvim (signs only)
- ui: lualine.nvim, bufferline.nvim, nvim-colorizer.lua, render-markdown.nvim
- debug: nvim-dap, nvim-dap-python, nvim-dap-go, nvim-dap-ui, nvim-dap-virtual-text, nvim-nio
- lang: venv-selector.nvim, nvim-lint, typescript-tools.nvim, tsc.nvim, gopher.nvim

## 4. Configuration Architecture

### 4.1 New file: `lua/config/snacks.lua`

- Single `require('snacks').setup()` called **synchronously** in `init.lua`
  (after theme, before `vim.schedule` deferred block).
- Enabled modules: `bigfile`, `bufdelete`, `dashboard`, `indent`, `input`,
  `lazygit`, `notifier`, `picker`, `quickfile`, `scope`, `scroll`, `statuscolumn`,
  `terminal`, `toggle`, `words`, `zen`, `dim`.
- Disabled: `image` (no kitty/wezterm guaranteed), `profiler` (optional,
  enable), `gitbrowse` (optional), `gh` (optional).
- Dashboard sections ported from `alpha.lua` (header wordmark, buttons, footer
  with plugin count/version).

### 4.2 Removed config files

- `lua/config/alpha.lua` → content folded into `snacks.dashboard` sections in `config/snacks.lua`
- `lua/config/nvimtree.lua` → replaced by `snacks.explorer`
- `lua/config/aerial.lua` → replaced by `snacks.picker.lsp_symbols`/`snacks.picker.treesitter`
- `lua/config/telescope.lua` → replaced by `snacks.picker` keymaps

### 4.3 Rewritten config files

- **`lua/config/keymaps.lua`**: telescope → `snacks.picker.*`; git suite →
  `snacks.lazygit()` + `snacks.picker.git_*`; goto-preview → LSP picker
  keymaps; `<leader>ft` todo → picker grep TODO; terminal → `snacks.terminal`;
  remove neotest/spectre/harpoon leftovers that reference removed plugins.
- **`lua/config/git.lua`**: slim to gitsigns signs setup + hunk keymaps +
  `snacks.lazygit` wrapper. Remove neogit/diffview/gv/popup workflows.
- **`lua/config/ui.lua`**: keep lualine (custom theme), bufferline (+ keymaps),
  nvim-colorizer. Remove dressing/noice/which-key/navic/indent-blankline blocks.
- **`lua/config/theme.lua`**: unchanged (solarized-osaka) but remove
  plugin-specific highlight overrides for removed plugins if dead.
- **`lua/config/init.lua`**: add `require('config.snacks')` synchronous load;
  remove `telescope`, `nvimtree`, `aerial` requires.

### 4.4 Unchanged files

- `lua/config/options.lua`, `autocmds.lua`, `icons.lua`, `popup.lua`,
  `python_host.lua`, `local_history.lua`, `markdown.lua`, `folding.lua`,
  `completion.lua`, `lsp.lua`, `copilot.lua`, `dap.lua`,
  `lang/{python,typescript,go}.lua`.

### 4.5 Scripts / manager

- `lua/config/plugins.lua` updated to new registry.
- `install.sh`/`update.sh` unchanged (drive off `plugins.lua`).
- `manager.lua` unchanged logic.
- **Physical cleanup**: deleted `pack/` dirs for removed plugins must be
  removed from disk (they still auto-start). `install.sh` installs only
  missing plugins; removal is manual `rm -rf pack/...`.

## 5. Keybinding Migration Map

| Old | New |
|---|---|
| `<leader>ff` smart find | `snacks.picker.files()` (git-aware via `smart`) |
| `<leader>fF` all files | `snacks.picker.files({ ignored = true })` |
| `<leader>fg` git files | `snacks.picker.git_files()` |
| `<leader>fr` recent (cwd) | `snacks.picker.recent()` |
| `<leader>fs` live grep | `snacks.picker.grep()` |
| `<leader>fb` grep buffers | `snacks.picker.grep_buffers()` |
| `<leader>fc` grep word | `snacks.picker.grep_word()` |
| `<leader>fp` grep python | `snacks.picker.grep({ regex = ..., file_pattern })` |
| `<leader>fj` grep js/ts | `snacks.picker.grep({ ... })` |
| `<leader>fB` buffers | `snacks.picker.buffers()` |
| `<leader>ft` todo | `snacks.picker.grep` TODO pattern |
| `<leader>fT` themes | `snacks.picker.colorschemes()` |
| `<leader>fh` help | `snacks.picker.help()` |
| `gd/gD/gi/gy/gr` | `snacks.picker.lsp_*` |
| `gpd/gpt/gpi/gpD/gP/gpr` | `snacks.picker.lsp_*` (preview) |
| `<leader>sr`/`<leader>sw` spectre | `snacks.picker.grep` + `snacks.rename` |
| `<leader>gs` neogit status | `snacks.lazygit()` |
| `<leader>gg` fugitive | `snacks.lazygit()` |
| `<leader>gl` git log | `snacks.picker.git_log()` |
| `<leader>gB` branches | `snacks.picker.git_branches()` |
| `<leader>gS` stash | `snacks.picker.git_stash()` |
| `<leader>gd` diff | `snacks.picker.git_diff()` |
| `<leader>gp` push | `snacks.lazygit()` |
| `<leader>gP` pull | `snacks.lazygit()` |
| `<leader>gx` close diffview | removed |
| `<leader>hl` undo tree | `snacks.picker.undo()` |
| `<leader>ee` explorer | `snacks.explorer()` |
| `<leader>T` / `<c-/>` terminal | `snacks.terminal()` |
| `<leader>sm` zoom | `snacks.zen.zoom()` or `snacks.toggle.zoom` |

## 6. Success Criteria

- Startup stays under ~30ms (`--startuptime`).
- `:checkhealth snacks` clean.
- Headless load test: `nvim --headless -c "qall"` no errors.
- No remaining `require()` of removed plugins in config.
- `lazygit` present (already installed at `/opt/homebrew/bin/lazygit`).
