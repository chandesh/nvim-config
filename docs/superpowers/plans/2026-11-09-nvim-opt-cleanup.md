# Neovim opt-cleanup Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Cut eager startup and redraw work, collapse duplicated boot logic, and add neotest, CopilotChat, and treesitter-context without changing an existing key or dropping a working feature.

**Architecture:** Keep `lua/config/plugins.lua` as the only registry and `pkg_manager.lua` as the only in-editor installer. Move expensive `start` plugins to `opt` and `packadd` them on the event that already owns the feature. New plugins follow the `lang/flutter.lua` pattern: registry row in `opt`, setup module under `lua/config/`, `packadd` inside the keymap callback. A keymap ledger written in Task 1 is the gate for every later map.

**Tech Stack:** Neovim 0.12 (this machine reports 0.12.6) · `pack/*/start` and `pack/*/opt` · blink.cmp · snacks.nvim · mason.nvim · no lazy.nvim

**Spec:** `docs/superpowers/specs/2026-11-09-nvim-opt-cleanup-design.md`

## Global Constraints

- Do not break existing functionality.
- Do not override an existing keybinding. The only rhs repair allowed is `<leader>pv`: lhs and desc `"Pick Python virtual environment"` stay; the body calls venv-selector instead of the missing `swenv` module.
- Before writing any new keymap, run the Task 1 ledger in `diff` mode. If the lhs is already mapped, stop. Do not choose a replacement key.
- Do not add lazy.nvim. Do not call `vim.pack.add`.
- Do not change `opt.updatetime`, `opt.colorcolumn`, `opt.relativenumber`, or gitsigns `current_line_blame`.
- Do not remove which-key. Do not add `dartls` to Mason. Do not add `copilot.lua` or `copilot.vim`.
- Do not set CopilotChat `trusted_tools = true`.
- `s` stays `<nop>`. `<Tab>`, `<S-Tab>`, `<CR>`, and `<C-space>` stay blink's (`completion.lua`). `<C-s>` stays save. `<F5>` `<F10>` `<F11>` `<F12>` stay dart-buffer DAP maps in `lang/flutter.lua`. `<leader>fl*` stays Flutter. `<leader>tt` stays the Pyright toggle.
- New global keymaps are only the lhs values in the spec table, including the `<leader>a` prefix `<Nop>`. Plugin default maps that are not in that table must be disabled, not rebound to something else.
- Do not remap bare `a` or `i`. `<leader>a` in modes `n` and `x` is `<Nop>` with desc `AI`, not `nowait`, registered as a which-key group before `<leader>aa` / `<leader>ae` / `<leader>aq`. Leaving it unmapped makes which-key and the 300ms `timeoutlen` run builtin `a`, which enters insert mode and swallows the rest of the chord.
- `install.sh` and `update.sh` stay. They are the documented bootstrap. Do not delete them.

## Review Focus

- Opening `nvim some.py` still attaches pyright. A `FileType` autocmd registered only inside `vim.schedule` misses the first buffer. Servers stay on `vim.lsp.enable` of the explicit list; only SchemaStore and Mason install move off the first tick.
- `<leader>a` must not enter insert. It is unmapped today. Builtin `a` is append, and a headless `normal a` fires `InsertEnter`. which-key 3.17 auto-triggers on `<leader>`, and `timeoutlen` is 300, so an unbound `<leader>a` runs that append and the next key is text. The prefix is `<Nop>` in `n` and `x`, not `nowait`. Bare `a` and `i` stay unmapped.
- The first `<Tab>` / `<C-space>` in insert mode is still blink, including after CopilotChat is installed. CopilotChat's default completion key has been both `<Tab>` and `<C-Space>`.
- `<leader>fT` still lists tokyonight and catppuccin after those colorschemes leave `start`.
- `<leader>ghs` still stages a hunk after gitsigns leaves `start`.
- A JSON buffer still receives SchemaStore schemas. Moving the catalog off startup must not leave `jsonls` with an empty schema list.
- Dashboard `w` and `<leader>wr` must not each call `auto_session.setup`.
- Dart `<F5>` still continues DAP after `dap.lua` stops packadding on the first tick.
- A second Copilot LSP client must not appear. Inline completion stays `vim.lsp.enable('copilot')`.

---

## File structure

| File | Responsibility |
|---|---|
| `scripts/check_keymaps.lua` | Ledger writer and diff. Not required at startup. |
| `docs/superpowers/plans/keymap-ledger-2026-11-09.txt` | Frozen global maps from Task 1. |
| `lua/config/plugins.lua` | Registry only. Names and `start`/`opt` buckets. |
| `lua/config/lsp.lua` | One server table. `M.enabled_servers()`. SchemaStore applied per filetype. |
| `lua/config/completion.lua` | Unchanged blink maps. Gains `M.ensure()` that packadds before `setup`. |
| `lua/config/git.lua` | Already packadds gitsigns when `require` fails. No new keys. |
| `lua/config/snacks.lua` | Owns the single session setup table. Colorscheme picker packadds opt themes. |
| `lua/config/dap.lua` | `M.ensure()` packadds the DAP stack. `M.setup()` does not. |
| `lua/config/ui.lua` | Cached statusline parts. navic limits. which-key stays. |
| `lua/config/lang/python.lua` | Calls `python_host.get_python()`. `setup_done` guard. |
| `lua/config/lang/typescript.lua` | Same `setup_done` guard. |
| `lua/config/neotest.lua` | New. packadd on first of the six `<leader>t*` callbacks. |
| `lua/config/copilot_chat.lua` | New. packadd on first `<leader>a*` callback. No default maps. |
| `lua/config/treesitter_context.lua` | New. packadd on `FileType` after treesitter start. |
| `install.sh` | Drops the telescope build. Gains a tiktoken build if CopilotChat is present. |
| `update.sh` | Pull flags match `pkg_manager.lua`. |

---

### Task 1: Freeze the keymap ledger

**Files:**
- Create: `scripts/check_keymaps.lua`
- Create: `docs/superpowers/plans/keymap-ledger-2026-11-09.txt`

**Interfaces:**
- Consumes: nothing
- Produces: `scripts/check_keymaps.lua` run as `nvim --headless -c 'lua vim.g.keymap_check = "<mode>"' -c 'lua vim.defer_fn(function() dofile("scripts/check_keymaps.lua") vim.cmd("qa!") end, 800)'`. Modes are `write` and `diff`. `diff` exits non-zero unless every baseline `mode<TAB>lhs<TAB>desc` line is still present and every global map that is not in the baseline has an lhs in the spec's new-key table. Prints `LEDGER_OK` on success.

The desc comparison is the contract. Do not compare rhs text. Function rhs values do not stringify stably. `<leader>pv` is in the baseline; its desc must stay `"Pick Python virtual environment"`.

- [ ] **Step 1: Write `scripts/check_keymaps.lua`**

The script reads `vim.g.keymap_check` (`write` or `diff`) and the ledger path above. It collects global maps with `vim.api.nvim_get_keymap` for modes `n`, `x`, `v`, `i`, `s`, `t`. Each line is `mode`, lhs, and `desc` (empty string if missing), separated by tabs. `write` overwrites the ledger and prints `LEDGER_WRITTEN <count>`. `diff` loads the ledger, fails if any baseline line is missing, fails if any current global lhs is neither in the baseline nor in the spec's new-key table, and prints `LEDGER_OK`. The new-key table includes `<leader>a` in modes `n` and `x`.

Do not `require` this file from `init.lua`.

- [ ] **Step 2: Write the baseline**

Run the `write` command from the Interfaces block, from `~/.config/nvim`, timeout 30s.

Expected: stdout contains `LEDGER_WRITTEN` and the file contains `<leader>tt`, `<leader>flr`, `<leader>wr`, `gd`, `<C-s>`, and `<F5>` is absent (F5 is buffer-local to dart and must not be in the global ledger).

- [ ] **Step 3: Prove `diff` passes on an unchanged config**

Run the same command with `vim.g.keymap_check = "diff"`.

Expected: `LEDGER_OK`, exit 0.

- [ ] **Step 4: Commit**

```bash
git add scripts/check_keymaps.lua docs/superpowers/plans/keymap-ledger-2026-11-09.txt docs/superpowers/specs/2026-11-09-nvim-opt-cleanup-design.md docs/superpowers/plans/2026-11-09-nvim-opt-cleanup.md
git commit -m "test: freeze nvim keymap ledger before opt cleanup"
```

---

### Task 2: One installer, dead registry rows, Mason remote

**Files:**
- Modify: `lua/config/plugins.lua`
- Modify: `install.sh:41-46`
- Modify: `update.sh` pull invocation
- Modify: on-disk remotes only if the clones exist: `pack/lsp/start/mason.nvim`, `pack/lsp/start/mason-lspconfig.nvim`

**Interfaces:**
- Consumes: nothing from Task 1 except "do not touch keymaps"
- Produces: registry with no `typescript-tools.nvim` row, no empty `nav` or `git.opt` tables, Mason `source` fields `mason-org/mason.nvim` and `mason-org/mason-lspconfig.nvim`. which-key, fidget, spectre, Comment.nvim, flash, dressing, and both extra colorschemes are still in the registry after this task.

- [ ] **Step 1: Point Mason at the new org without recloning**

In `plugins.lua`, change the two Mason `source` strings to `mason-org/mason.nvim` and `mason-org/mason-lspconfig.nvim`. Leave `name` as `mason.nvim` and `mason-lspconfig.nvim` so the dest path does not change.

If `pack/lsp/start/mason.nvim/.git` exists, run `git -C` that directory `remote set-url origin https://github.com/mason-org/mason.nvim.git`. Same for mason-lspconfig. Do not delete the directory. `install.sh` skips clones that already have `.git`, so a source-only registry edit would leave the old remote in place.

- [ ] **Step 2: Delete rows that have no `require` and no keymap**

Remove `{ source = "pmizio/typescript-tools.nvim", ... }` from `lang.opt`. Remove the empty `nav` bundle and the empty `git.opt` table. Do not remove any other row in this task.

- [ ] **Step 3: Make the shell scripts follow the registry**

Delete the `telescope-fzf-native` `make` block in `install.sh` (lines 41-46). Leave the python-import `uv` block.

In `update.sh`, change `git pull --ff-only` to `git pull --rebase --autostash`, matching `pkg_manager.lua:126`. Do not rewrite `update.sh` to call the async Neovim command. That command returns before the jobs finish.

- [ ] **Step 4: Verify**

```bash
nvim --headless -c 'lua local p=require("config.plugins"); assert(p.lsp.start); local src={}; for _,pl in ipairs(p.lsp.start) do src[pl.name]=pl.source end; assert(src["mason.nvim"]=="mason-org/mason.nvim"); assert(src["mason-lspconfig.nvim"]=="mason-org/mason-lspconfig.nvim"); assert(p.nav==nil); assert(p.git.opt==nil); print("REGISTRY_OK")' -c qa
```

Expected: `REGISTRY_OK`. `rg typescript-tools lua` finds nothing. `rg telescope-fzf install.sh` finds nothing. Ledger `diff` still prints `LEDGER_OK`.

- [ ] **Step 5: Commit**

```bash
git add lua/config/plugins.lua install.sh update.sh
git commit -m "fix: one plugin installer and drop dead registry rows"
```

---

### Task 3: Event-load the expensive plugins

**Files:**
- Modify: `lua/config/plugins.lua` (`start` → `opt` for the plugins named below)
- Modify: `lua/config/completion.lua` — add `M.ensure()`
- Modify: `init.lua:75-86` — call `completion.ensure` from an `InsertEnter` autocmd, not unconditionally
- Modify: `lua/config/lsp.lua:148-197` — SchemaStore and Mason install timing
- Modify: `lua/config/dap.lua` — add `M.ensure()`, stop packadding inside `M.setup()`
- Modify: `lua/config/lang/flutter.lua:56-59` — F5-F12 call `require('config.dap').ensure()` before `require('dap')`
- Modify: `lua/config/snacks.lua` colorscheme picker path used by `<leader>fT`
- Modify: `lua/config/keymaps.lua:323-337` — packadd spectre inside the existing callbacks, lhs unchanged

**Interfaces:**
- Consumes: gitsigns `safe_setup(mod, pack_name, setup_fn)` in `git.lua:19-32`. It already packadds when `require` fails. Do not add keys there.
- Produces:
  - `require('config.completion').ensure() -> boolean` — packadds `blink.cmp`, `blink-copilot`, `LuaSnip`, `friendly-snippets`, then calls `M.setup()` once. Later calls return true without a second `setup`.
  - `require('config.lsp').enabled_servers() -> string[]` — module-level, safe to call before `M.setup()`. Returns the names `M.setup` passes to `vim.lsp.enable`, sorted. After this task: `cssls`, `emmet_ls`, `eslint`, `html`, `jsonls`, `lua_ls`, `pyright` (omitted only when `python_host.get_python()` is nil), `ts_ls`, `yamlls`. No `dartls`. No `angularls` yet.
  - `require('config.snacks').packadd_themes()` — packadds `tokyonight.nvim` and `catppuccin`. The `<leader>fT` callback calls this, then `Snacks.picker.colorschemes()`. Lhs stays `<leader>fT`.
  - `require('config.dap').ensure() -> boolean` — packadds `nvim-dap`, `nvim-dap-ui`, `nvim-nio`, `nvim-dap-virtual-text`, then the existing adapter setup, once.

Move these registry rows from `start` to `opt`, same `source` and `name`: `saghen/blink.cmp`, `fang2hou/blink-copilot`, `L3MON4D3/LuaSnip`, `rafamadriz/friendly-snippets`, `lewis6991/gitsigns.nvim`, `craftzdog` is not in this list (solarized-osaka stays `start`), `folke/tokyonight.nvim`, `catppuccin/nvim`, `nvim-pack/nvim-spectre`. Leave the on-disk `pack/.../start/...` directories. `install.sh` will not move them. After editing the registry, move the directories with `mv` from `pack/<bundle>/start/<name>` to `pack/<bundle>/opt/<name>` so the next boot does not still load the old `start` copy. If the dest exists, stop and do not overwrite.

- [ ] **Step 1: Completion loads on InsertEnter**

`init.lua` must not call `require('config.completion').setup()` on the first tick. Register `InsertEnter` once, `once = true` is wrong if the first insert happens in a buffer that is closed — use a `loaded` flag inside `M.ensure` instead of `once = true`. The autocmd calls `M.ensure()`.

Do not change the blink keymap table in `completion.lua:12-18`.

- [ ] **Step 2: Keep `vim.lsp.enable` of the explicit list; move only the expensive work**

Delete the two SchemaStore IIFEs at `lsp.lua:151-154` and `163-166`. `jsonls` and `yamlls` settings ship with `schemas = {}` until applied.

Add `M.apply_schemastore(bufnr)` in `lsp.lua`. It packadds `SchemaStore.nvim` once, then sets that buffer's client settings for `jsonls` or `yamlls` from `require('schemastore').json.schemas()` / `yaml.schemas()`. Call it from a `FileType` autocmd for `json,jsonc,yaml,yml` registered at the top of `M.setup()`, and also immediately for any buffer already showing those filetypes. Then `vim.lsp.enable`. Do not move `vim.lsp.enable` into the autocmd. A file opened as `nvim file.py` gets `FileType` before `vim.schedule`; enable-on-FileType would miss it.

Wrap `require('mason').setup` and `mason_lspconfig.setup` in `vim.defer_fn(..., 3000)`. Keep `ensure_installed` and `automatic_enable = false`. Build `ensure_installed` from the keys of the `servers` table minus `skip_enable`, not from a second handwritten list.

Move `vim.lsp.log.set_level("WARN")` from `options.lua:80` into the start of `M.setup()`. Options must not `require` vim.lsp's log on the pre-paint path. The level stays `WARN`.

- [ ] **Step 3: DAP and gitsigns and themes load when used**

`dap.setup()` in `init.lua` may still be called. It must only define commands/state. `M.ensure()` does the `packadd`s that `dap.lua` currently does at the top. `keymaps.lua` `safe_require` for `dap`, `dapui`, and `dap-python` calls `require('config.dap').ensure()` before `require`. Flutter F5-F12 do the same. Do not change those lhs values.

`git.lua` needs no new packadd if gitsigns is `opt`: `safe_setup` already packadds on require failure. Confirm the pack name argument is `gitsigns.nvim`.

`<leader>fT` lhs stays. Its callback packadds `tokyonight.nvim` and `catppuccin` before `Snacks.picker.colorschemes()`.

`<leader>sr` and `<leader>sw` lhs stay. Each callback packadds `nvim-spectre` before `require('spectre')`.

- [ ] **Step 4: Verify startup no longer sources those plugin scripts**

```bash
nvim --headless --startuptime /tmp/nvim-opt-startup.log +qa
```

Expected: the log's `NVIM STARTED` line does not follow a `luasnip.loaders.from_vscode` line or a `blink-cmp.lua` line or a `gitsigns.lua` line. Exit 0.

```bash
nvim --headless -c 'lua vim.defer_fn(function() local ok,lsp=pcall(require,"config.lsp"); assert(ok); local names=lsp.enabled_servers(); assert(not vim.tbl_contains(names,"dartls")); assert(not vim.tbl_contains(names,"angularls")); assert(package.loaded["schemastore"]==nil); print("LSP_DEFER_OK") vim.cmd("qa!") end, 500)'
```

Expected: `LSP_DEFER_OK`. Ledger `diff` prints `LEDGER_OK`.

Also, from `~/.config/nvim`:

```bash
nvim --headless -c 'lua vim.defer_fn(function() require("config.snacks").packadd_themes(); assert(vim.fn.isdirectory(vim.fn.stdpath("config").."/pack/theme/opt/tokyonight.nvim")==1); print("THEMES_OK"); local gs=package.loaded["gitsigns"]; print(gs and "GITSIGNS_LOADED" or "GITSIGNS_PENDING") vim.cmd("qa!") end, 800)'
```

Expected: `THEMES_OK`. `GITSIGNS_PENDING` is acceptable only if `git.lua` still calls `safe_setup('gitsigns', 'gitsigns.nvim', ...)`. `GITSIGNS_LOADED` is the expected result, because that call still runs on the first tick.

```bash
nvim --headless /dev/null -c 'lua vim.defer_fn(function() vim.cmd("edit /private/tmp/ua-schema.json"); vim.cmd("set filetype=json"); vim.defer_fn(function() assert(package.loaded["schemastore"]~=nil, "SchemaStore did not load for json"); print("SCHEMA_OK") vim.cmd("qa!") end, 400) end, 800)'
```

Expected: `SCHEMA_OK`. If SchemaStore is not cloned, clone it with the registry row before treating this as a code failure.

- [ ] **Step 5: Commit**

```bash
git add lua/config/plugins.lua lua/config/completion.lua lua/config/lsp.lua lua/config/dap.lua lua/config/lang/flutter.lua lua/config/snacks.lua lua/config/keymaps.lua lua/config/options.lua init.lua
git commit -m "perf: packadd completion, git, themes, and DAP on use"
```

---

### Task 4: One session, one jump path, one Python resolver

**Files:**
- Modify: `lua/config/snacks.lua:40-49`
- Modify: `init.lua:47-73`
- Modify: `lua/config/lsp.lua:17-45` and `lsp.lua:82-92`
- Modify: `lua/config/lang/python.lua:7-42` and the FileType body
- Modify: `lua/config/lang/typescript.lua` FileType body
- Modify: `lua/config/keymaps.lua:299-302` (`<leader>pv` body only)

**Interfaces:**
- Consumes: `require('config.python_host').get_python() -> string|nil` (`python_host.lua:159-162`). Do not call `resolve_provider` from language modules. Provider selection stays inside `python_host.lua`.
- Produces: `require('config.snacks').ensure_session() -> boolean`. Both the dashboard `w` action and `<leader>wr` / `<leader>ws` call it. The `auto_session.setup` table exists in that function only: `auto_restore = false`, `suppressed_dirs` unchanged from `init.lua:56`.

- [ ] **Step 1: Session**

Move the setup table into `M.ensure_session`. A `session_loaded` flag inside the module prevents a second `setup`. `<leader>wr` still runs `AutoSession restore`. `<leader>ws` still runs `AutoSession save`. Dashboard key `w` still restores. Do not change those lhs values. Delete the copy in `init.lua`.

- [ ] **Step 2: Jumps**

Delete `jump_to_first_location` and the two `vim.lsp.handlers["textDocument/..."]` assignments (`lsp.lua:19-45`). Delete the `gd`/`gD`/`gi`/`gy`/`gr`/`K`/`<C-k>` maps inside `on_attach` (`lsp.lua:82-92`). Leave the `LspAttach` maps for `<leader>ca`, `<leader>cr`, and `<leader>cf`. Leave `keymaps.lua:272-276` as the only `gd`/`gr` maps. They already point at `Snacks.picker`.

- [ ] **Step 3: Python and typescript setup once**

Delete `get_project_python`. Where `lang/python.lua` stored that result on `vim.b.python_path`, assign `require('config.python_host').get_python()` instead. Wrap the venv-selector / lint / import `setup()` calls in a `setup_done` flag, same shape as `flutter.lua`'s flag. The `BufWritePost` / `InsertLeave` lint autocmd stays outside the flag so each buffer still gets it. Do the same guard around `typescript.lua`'s `setup()` calls. Do not guard the per-buffer lint autocmd.

`<leader>pv` lhs and desc stay. Body packadds `venv-selector.nvim` and calls its picker. If the module name differs from `venv-selector`, read the installed plugin's `lua/` directory and call the documented picker. Do not reintroduce `swenv`.

- [ ] **Step 4: Verify**

```bash
nvim --headless some.py -c 'lua vim.defer_fn(function() local py=require("config.python_host").get_python(); assert(vim.b.python_path==nil or vim.b.python_path==py or vim.b.python_path~=""); print("PYTHON_OK") vim.cmd("qa!") end, 800)'
```

Expected: `PYTHON_OK`, and the command does not notify a second session setup. `rg "textDocument/definition" lua/config/lsp.lua` finds nothing. `rg swenv lua` finds nothing. `rg "auto_session.setup" lua` matches only `snacks.lua`. `rg "dap.ensure" lua/config/lang/flutter.lua` matches the F5-F12 callbacks. Ledger `diff` prints `LEDGER_OK`.

The python assert is weak on purpose: `vim.b.python_path` is only set inside the FileType callback. If that callback has not run by 800 ms, print `PYTHON_SKIP` rather than failing the boot. A `PYTHON_SKIP` means re-check by reading `lang/python.lua` and confirming the assignment calls `get_python()`. Do not point it back at a local resolver to make the assert pass.

- [ ] **Step 5: Commit**

```bash
git add lua/config/snacks.lua init.lua lua/config/lsp.lua lua/config/lang/python.lua lua/config/lang/typescript.lua lua/config/keymaps.lua
git commit -m "fix: one session loader, one jump path, one Python resolver"
```

---

### Task 5: Stop the statusline and navic from working every redraw

**Files:**
- Modify: `lua/config/ui.lua:144-178` and `ui.lua:211-256`
- Modify: `lua/config/snacks.lua:128-130` and the `scroll` / `indent` animate blocks
- Modify: `lua/config/smear_cursor.lua:19` and `:28`

**Interfaces:**
- Consumes: `require('config.icons')` fields already used by the statusline (`plugin_updates.checking`, `plugin_updates.available`, `kinds`)
- Produces: no new keymaps. `:SmearCursorToggle` still exists.

- [ ] **Step 1: Cache statusline inputs**

At the top of the lualine setup closure, `local icons = require('config.icons')` once. `plugin_manager_status` and `copilot_status` use that local. Do not `require` inside a component function.

Filename icon: a `icons_by_ft` table filled from `nvim-web-devicons` on `FileType` and `BufEnter`, read by the filename `fmt`. The `fmt` function does not `require`.

LSP / pyright / copilot client labels: compute them in `LspAttach` and `LspDetach` into a buffer or global cache the component functions read. The component functions do not call `vim.lsp.get_clients`.

- [ ] **Step 2: Bound navic**

In `navic.setup`, set `lazy_update_context = true` and `depth_limit = 5`. Leave `auto_attach = true`. `navic_location` may still call `get_location()`; it must not `pcall(require)` on every winbar redraw. Require once at setup.

- [ ] **Step 3: Cut animation defaults, keep the toggle**

`snacks.lua`: `animate.fps = 60`. Disable the `scroll.animate` and `indent.animate` blocks by setting those animate features off, using the snacks field that disables them (if the field is `enabled` on the animate subtable, set that `false`; do not set `scroll.enabled = false` or `indent.enabled = false`). Guides and scroll still exist. The animation does not.

`smear_cursor.lua`: `smear_between_neighbor_lines = false`, `smear_insert_mode = false`. Leave `smear_between_buffers = true` and the plugin installed. Do not remove `:SmearCursorToggle`.

Do not edit `options.lua` rulers, relative numbers, or `updatetime`.

- [ ] **Step 4: Verify**

`rg "require%('config%.icons')" lua/config/ui.lua` matches the one cache site, not the component functions. `rg "require%('nvim-web-devicons')" lua/config/ui.lua` does not match inside the filename `fmt` function. Ledger `diff` prints `LEDGER_OK`. Headless `nvim +qa` still exits 0.

- [ ] **Step 5: Commit**

```bash
git add lua/config/ui.lua lua/config/snacks.lua lua/config/smear_cursor.lua
git commit -m "perf: cache statusline data and quiet cursor animation"
```

---

### Task 6: Retire overlaps that are proven unused

**Files:**
- Modify: `lua/config/editing.lua:19` and the flash `pcall`
- Modify: `lua/config/plugins.lua` Comment.nvim row, only if Step 1 passes
- Modify: `lua/config/lang/flutter.lua:18` dressing packadd
- Modify: `lua/config/snacks.lua:4-6` and `lua/config/ui.lua:5` comments
- Modify: `lua/config/keymaps.lua` — add only `<leader>js`

**Interfaces:**
- Consumes: Task 1 ledger. `<leader>js` must be absent before this task.
- Produces: `<leader>js` → flash jump, and nothing else from flash. which-key still `setup()`s.

- [ ] **Step 1: Builtin comment before deleting Comment.nvim**

Headless, after startup schedule:

```bash
nvim --headless -c 'lua vim.defer_fn(function() vim.cmd("packadd! matchit"); local map=vim.fn.maparg("gcc","n"); print("GCC:"..map) vim.cmd("qa!") end, 800)'
```

If `GCC:` is non-empty, remove the Comment.nvim registry row, `mv` it out of `pack/editing/start` if present, and delete `require('Comment').setup()` in `editing.lua`. If `GCC:` is empty, leave Comment.nvim. Do not invent a replacement mapping. `gc` is the builtin, not a new lhs.

- [ ] **Step 2: Stop dressing from hijacking select**

Remove `vim.cmd('packadd dressing.nvim')` from `flutter.lua`. Leave the registry row so a regression can be restored in one line. Do not delete the clone. Flutter device select falls through to `vim.ui.select`. Snacks `input` stays the `vim.ui.input` handler (`snacks.lua:172`).

- [ ] **Step 3: Flash on the one free key**

Run ledger `diff` first. Confirm `<leader>js` is not in the baseline. In `editing.lua`, packadd `flash.nvim` inside a function called by a new map, not at setup. `flash.setup` must set its default jump keys (`s`, `S`, and any `f`/`t` override the plugin would install) to disabled. The only map this task adds is:

```lua
vim.keymap.set('n', '<leader>js', function()
  -- packadd flash.nvim, then flash.jump()
end, { desc = 'Flash jump' })
```

Do not map `s`. `keymaps.lua:379` stays `s` → `<nop>`.

- [ ] **Step 4: Fix the comments, keep which-key**

`snacks.lua` header and `ui.lua:5` must not say Snacks replaced which-key. which-key stays in `ui.start` and `wk.setup({ preset = "classic" })` stays.

- [ ] **Step 5: Verify**

Ledger `diff` prints `LEDGER_OK`. The only new lhs is `<leader>js`. `rg "packadd dressing" lua` finds nothing. Headless startup exits 0.

- [ ] **Step 6: Commit**

```bash
git add lua/config/editing.lua lua/config/plugins.lua lua/config/lang/flutter.lua lua/config/snacks.lua lua/config/ui.lua lua/config/keymaps.lua
git commit -m "fix: drop proven overlaps without stealing keys"
```

---

### Task 7: Restore angularls and tailwindcss on the single server list

**Files:**
- Modify: `lua/config/lsp.lua` server table and `M.enabled_servers()`
- Modify: `README.md` LSP line only if it still omits a server this task enables, or still lists one it does not

**Interfaces:**
- Consumes: `M.enabled_servers()` from Task 3. `ensure_installed` is derived from that same table.
- Produces: `enabled_servers()` includes `angularls` and `tailwindcss`, still excludes `dartls`. No new keymaps. Default lspconfig filetypes. No custom `cmd`.

- [ ] **Step 1: Add the two servers to the one table**

Add `angularls = {}` and `tailwindcss = {}` to the `servers` table. Do not append them to a second list. `skip_enable` is unchanged.

- [ ] **Step 2: Verify**

```bash
nvim --headless -c 'lua vim.defer_fn(function() local n=require("config.lsp").enabled_servers(); assert(vim.tbl_contains(n,"angularls")); assert(vim.tbl_contains(n,"tailwindcss")); assert(not vim.tbl_contains(n,"dartls")); print("SERVERS_OK") vim.cmd("qa!") end, 500)'
```

Expected: `SERVERS_OK`. Ledger `diff` prints `LEDGER_OK`. Mason may still be inside the 3s defer; this check does not require the binaries to be installed.

- [ ] **Step 3: Commit**

```bash
git add lua/config/lsp.lua README.md
git commit -m "fix: enable angularls and tailwindcss from the server table"
```

---

### Task 8: Add the three plugins on the reserved keys

**Files:**
- Modify: `lua/config/plugins.lua` — new `opt` rows
- Create: `lua/config/neotest.lua`
- Create: `lua/config/copilot_chat.lua`
- Create: `lua/config/treesitter_context.lua`
- Modify: `init.lua` schedule — `require` the three modules' `setup()` so the keymaps exist. `setup()` must not `packadd`.
- Modify: `install.sh` — build tiktoken when the CopilotChat clone exists
- Modify: `README.md` — one line each for the three plugins and their keys

**Interfaces:**
- Consumes: Task 1 allow-list. Task 3 `dap.ensure()` for `<leader>td`. plenary is already in `core.start`.
- Produces:
  - `require('config.neotest').setup()` registers the six `<leader>t*` maps and does not packadd.
  - `require('config.copilot_chat').setup()` registers the `<leader>a` prefix `<Nop>` first, then `<leader>aa`, `<leader>ae`, `<leader>aq`. It does not packadd. It does not map bare `a` or `i`.
  - `require('config.treesitter_context').setup()` registers `[c` and `]c` and packadds on the first `FileType`, after `vim.treesitter.start` has been attempted for that buffer.

Registry rows, all `opt`:

| Bundle | source | name |
|---|---|---|
| editing | `nvim-neotest/neotest` | `neotest` |
| editing | `nvim-neotest/neotest-python` | `neotest-python` |
| editing | `nvim-neotest/neotest-jest` | `neotest-jest` |
| editing | `fredrikaverpil/neotest-golang` | `neotest-golang` |
| editing | `CopilotC-Nvim/CopilotChat.nvim` | `CopilotChat.nvim` |
| treesitter | `nvim-treesitter/nvim-treesitter-context` | `nvim-treesitter-context` |

If a clone URL 404s, stop that row. Do not substitute a different repo.

- [ ] **Step 1: Ledger gate**

Run ledger `diff`. Expected: `LEDGER_OK`, and `<leader>a`, `<leader>aa`, `<leader>tr`, `<leader>js`, `[c` are not in the baseline. If any reserved lhs is already mapped, stop the task.

- [ ] **Step 2: Register and clone**

Add the rows. Run `bash install.sh` or `:PI` equivalent (`nvim` is not required if you `git clone --depth=1` into `pack/<bundle>/opt/<name>` matching the registry). Install.sh's python-import block must still run.

CopilotChat build, in `install.sh`, only if `pack/editing/opt/CopilotChat.nvim` exists and `make` exists: `(cd that dir && make tiktoken)`. A failed make prints a warning and does not fail the script (`|| echo warn`), same shape as the old telescope block. Do not fail the whole install on a missing compiler.

- [ ] **Step 3: Neotest**

`neotest.setup` adapters: python (`pytest`, `python` from `require('config.python_host').get_python()`), jest, golang. Disable any keymap table the plugin would register. This module's maps, and only these:

| Lhs | Call |
|---|---|
| `<leader>tr` | `neotest.run.run()` |
| `<leader>tF` | `neotest.run.run(vim.fn.expand('%'))` |
| `<leader>tS` | `neotest.summary.toggle()` |
| `<leader>tl` | `neotest.run.run_last()` |
| `<leader>tq` | `neotest.run.stop()` |
| `<leader>td` | `require('config.dap').ensure()` then `neotest.run.run({ strategy = 'dap' })` |

Each callback packadds `neotest` and the three adapters, then `require`s them, then runs the call. Desc strings: `Test nearest`, `Test file`, `Test summary`, `Test last`, `Test stop`, `Debug nearest test`.

Do not map `<leader>tt`, `<leader>to`, `<leader>jt`, or `<leader>dpt`.

- [ ] **Step 4: CopilotChat**

Register the prefix before the children, in both `n` and `x`:

```lua
vim.keymap.set({ "n", "x" }, "<leader>a", "<Nop>", { desc = "AI" })
```

No `nowait`. Then, if which-key is loaded (it is, `ui.setup()` runs earlier in the same schedule — require this module after `config.ui`):

```lua
require("which-key").add({ { "<leader>a", group = "AI", mode = { "n", "x" } } })
```

The prefix rhs must stay `<Nop>`. Do not point it at `startinsert`, `a`, or `i`. Bare `a` and `i` stay unmapped.

Do not `require('copilot')`. Do not packadd `copilot.lua` or `copilot.vim`.

After reading the installed plugin's default `mappings` table, set every default that binds `<Tab>`, `<S-Tab>`, `<CR>`, `<C-s>`, `<C-space>`, `<C-Space>`, or `s` to disabled. Do not replace them with another global lhs. Chat-buffer-local maps are acceptable only when they are not also global.

`require('CopilotChat').setup` opts: `trusted_tools` unset or false. Window uses the existing rounded border style. No model override.

Maps, packadd on first use:

| Lhs | Mode | Call | Desc |
|---|---|---|---|
| `<leader>aa` | n | `CopilotChat.toggle()` or the installed equivalent | `Copilot chat` |
| `<leader>ae` | n, x | explain visual or cursor line | `Explain selection` |
| `<leader>aq` | n | quick chat prompt | `Quick chat` |

If the installed API names differ, use the names in that clone's `doc/CopilotChat.txt`. Do not add a fourth map.

- [ ] **Step 5: Treesitter context**

`setup()` registers `[c` / `]c` with desc `Previous context` / `Next context`. The callback packadds `nvim-treesitter-context` and calls `require('treesitter-context').go_to_context(true/false)` using the direction that clone documents. Also packadd on `FileType` so the sticky window exists without pressing the key. The FileType callback no-ops when `vim.treesitter.language.get_lang` is nil for that filetype. Do not add other maps. Do not enable a plugin default that binds `s` or `[b` `]b` `[d` `]d`.

- [ ] **Step 6: Verify**

Ledger `diff` prints `LEDGER_OK`.

```bash
nvim --headless -c 'lua vim.defer_fn(function() local function has(mode, lhs) return vim.fn.maparg(lhs, mode) ~= "" end; assert(vim.fn.maparg("<leader>a", "n") == "<Nop>"); assert(vim.fn.maparg("<leader>a", "x") == "<Nop>"); assert(vim.fn.maparg("a", "n") == ""); assert(vim.fn.maparg("i", "n") == ""); assert(has("n","<leader>aa")); assert(has("n","<leader>tr")); assert(has("n","<leader>tF")); assert(has("n","[c")); assert(has("n","<leader>js")); local tab=vim.fn.maparg("<Tab>","i"); local cspace=vim.fn.maparg("<C-space>","i"); assert(tab=="" or not tab:find("CopilotChat")); assert(cspace=="" or not cspace:find("CopilotChat")); assert(vim.fn.maparg("<C-s>","n"):find("w") or vim.fn.maparg("<C-s>","i"):find("w")); print("NEWKEYS_OK") vim.cmd("qa!") end, 800)'
```

Expected: `NEWKEYS_OK`. A global `<Tab>` or `<C-space>` map whose rhs mentions CopilotChat is a failure. Blink has not loaded yet in this headless run, so those mapargs being empty is the pass.

```bash
nvim --headless --startuptime /tmp/nvim-opt-startup2.log +qa
```

Expected: `NVIM STARTED` still does not follow `blink-cmp.lua` or `luasnip.loaders.from_vscode`. `neotest` and `CopilotChat` plugin scripts are absent from that log (they are `opt` and not packadded yet).

`:checkhealth` is not required to be clean for Copilot auth. A missing token is not a failure of this task. A second `copilot` client name from `copilot.lua` is a failure: `rg "copilot%.lua|copilot%.vim" lua/config` finds nothing.

- [ ] **Step 7: Commit**

```bash
git add lua/config/plugins.lua lua/config/neotest.lua lua/config/copilot_chat.lua lua/config/treesitter_context.lua init.lua install.sh README.md
git commit -m "feat: add neotest, CopilotChat, and treesitter-context on free keys"
```

---

## Spec coverage

| Spec item | Task |
|---|---|
| Event packadd instead of first-tick `vim.schedule` | 3 |
| One installer, dead registry rows, Mason org | 2 |
| One Python resolver, one `gd`, one session | 4 |
| Statusline / navic / animation | 5 |
| Comment, dressing, flash, which-key kept | 6 |
| angularls and tailwindcss | 7 |
| neotest, CopilotChat, treesitter-context | 8 |
| Keymap ledger before any new map | 1, re-run in 6 and 8 |
| Do not change rulers, relative numbers, updatetime, blame | 5 explicitly skips them |
| No lazy.nvim, no second Copilot client, no dartls in Mason | Global Constraints, Tasks 3, 7, 8 |

## Out of scope reminder

lazydev.nvim, oil.nvim, trouble.nvim, a lazy.nvim migration, deleting `install.sh`, and turning off `current_line_blame` are not in this plan. Do not add them while executing it.
