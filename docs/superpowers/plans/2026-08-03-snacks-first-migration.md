# Snacks-First Migration Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Migrate the Neovim config to a Snacks-first architecture on native `vim.pack`, replacing ~24 plugins with Snacks modules while preserving startup performance and the user's custom look.

**Architecture:** Add `folke/snacks.nvim` as the single new start plugin. Enable its modules (picker, dashboard, indent, input, notifier, whichkey, lazygit, explorer, terminal, scroll, animate, dim, zen, undo). Fold dashboard content from `alpha.lua` into Snacks. Replace Telescope/nvim-tree/aerial keymaps and git suite with `snacks.picker.*`, `snacks.explorer`, and `snacks.lazygit`. Slim `git.lua` to gitsigns signs only. Keep lualine/bufferline/gitsigns/auto-session and all no-Snacks-equivalent plugins.

**Tech Stack:** Neovim v0.12.4 · native vim.pack (`pack/<bundle>/<start|opt>`) · snacks.nvim v3 · Fish-free zsh/bash scripts

---

### Task 1: Update plugin registry (`plugins.lua`)

**Files:**
- Modify: `lua/config/plugins.lua`

- [ ] **Step 1: Add snacks.nvim to `core` start**

In the `core.start` list, insert snacks before plenary:

```lua
  core = {
    start = {
      { source = "folke/snacks.nvim",             name = "snacks.nvim" },
      { source = "nvim-lua/plenary.nvim",        name = "plenary.nvim" },
      { source = "nvim-tree/nvim-web-devicons",  name = "nvim-web-devicons" },
    },
```

- [ ] **Step 2: Remove replaced plugins from each bundle**

Edit the `theme`, `lsp`, `nav`, `ui`, `editing`, `git` bundles to delete the entries in this removal table (exact `source`/`name` strings from the current file):

`lsp` start: remove `rmagatti/goto-preview` ("goto-preview"), `nvimtools/none-ls.nvim` ("none-ls.nvim").
`nav` start: remove `nvim-telescope/telescope.nvim` ("telescope.nvim"), `nvim-telescope/telescope-fzf-native.nvim` ("telescope-fzf-native.nvim"), `nvim-tree/nvim-tree.lua` ("nvim-tree.lua"), `stevearc/aerial.nvim` ("aerial.nvim").
`nav` opt: remove `rmagatti/goto-preview` ("goto-preview"), `andrew-george/telescope-themes` ("telescope-themes"), `ThePrimeagen/harpoon` ("harpoon").
`ui` start: remove lualine? NO - keep. Remove `folke/which-key.nvim` ("which-key.nvim"), `folke/trouble.nvim` ("trouble.nvim"), `folke/todo-comments.nvim` ("todo-comments.nvim"), `MunifTanjim/nui.nvim` ("nui.nvim"), `folke/noice.nvim` ("noice.nvim"), `rcarriga/nvim-notify` ("nvim-notify"), `goolord/alpha-nvim` ("alpha-nvim"), `stevearc/dressing.nvim` ("dressing.nvim"), `smiteshp/nvim-navic` ("nvim-navic"), `lukas-reineke/indent-blankline.nvim` ("indent-blankline.nvim"), `norcalli/nvim-colorizer.lua` ("nvim-colorizer.lua").

> NOTE: Keep `nvim-lualine/lualine.nvim`, `akinsho/bufferline.nvim` in `ui` start.

`ui` opt: remove `folke/zen-mode.nvim` ("zen-mode.nvim"), `folke/twilight.nvim` ("twilight.nvim"). KEEP `MeanderingProgrammer/render-markdown.nvim`.
`editing` start: remove `mbbill/undotree` ("undotree"), `karb94/neoscroll.nvim` ("neoscroll.nvim"). KEEP `kylechui/nvim-surround`, `Comment.nvim`, `nvim-autopairs`, `conform.nvim`, `vim-visual-multi`, `nvim-ufo`, `promise-async`, `nvim-spectre`.
`editing` opt: KEEP `folke/flash.nvim`.
`git` start: remove `tpope/vim-fugitive` ("vim-fugitive"). KEEP `lewis6991/gitsigns.nvim`.
`git` opt: remove `sindrets/diffview.nvim` ("diffview.nvim"), `junegunn/gv.vim` ("gv.vim"), `TimUntersberger/neogit` ("neogit"), `akinsho/git-conflict-nvim` ("git-conflict-nvim").

- [ ] **Step 3: Verify** — run `nvim --headless -c "lua vim.pretty_print(require('config.plugins'))"` and confirm `snacks.nvim` present, removed entries gone. Expected: output prints registry without telescope/alpha/noice/etc.

- [ ] **Step 4: Commit**

```bash
git add lua/config/plugins.lua
git commit -m "chore(plugins): add snacks.nvim, remove replaced plugins"
```

---

## Task 2 — Install snacks.nvim + physically remove old plugins

**Files:**
- Modify: disk under `pack/` (gitignored, no git commit needed)

- [ ] **Step 1: Install snacks.nvim**

```bash
git clone --depth=1 --quiet https://github.com/folke/snacks.nvim ~/.config/nvim/pack/core/start/snacks.nvim
```

Verify: `ls ~/.config/nvim/pack/core/start/snacks.nvim/lua/snacks/init.lua` exists.

- [ ] **Step 2: Remove replaced plugin directories**

```bash
cd ~/.config/nvim/pack
rm -rf \
  nav/start/telescope.nvim nav/start/telescope-fzf-native.nvim nav/start/nvim-tree.lua nav/start/aerial.nvim \
  nav/opt/goto-preview nav/opt/telescope-themes nav/opt/harpoon \
  lsp/start/goto-preview lsp/start/none-ls.nvim \
  ui/start/which-key.nvim ui/start/trouble.nvim ui/start/todo-comments.nvim ui/start/nui.nvim \
  ui/start/noice.nvim ui/start/nvim-notify ui/start/alpha-nvim ui/start/dressing.nvim \
  ui/start/nvim-navic ui/start/indent-blankline.nvim ui/start/nvim-colorizer.lua \
  ui/opt/zen-mode.nvim ui/opt/twilight.nvim \
  editing/start/undotree editing/start/neoscroll.nvim \
  git/start/vim-fugitive git/opt/diffview.nvim git/opt/gv.vim git/opt/neogit git/opt/git-conflict-nvim
```

Verify: `find ~/.config/nvim/pack -mindepth 3 -maxdepth 3 -type d | wc -l` and confirm no telescope/alpha/noice/etc remain.

---

## Task 3 — Create `lua/config/snacks.lua`

**Files:**
- Create: `lua/config/snacks.lua`

- [ ] **Step 1: Write the module**

```lua
-- ~/.config/nvim/lua/config/snacks.lua
-- =============================================================================
-- Snacks.nvim — unified QoL modules (picker, dashboard, indent, terminal, ...)
-- Loaded synchronously in init.lua. Replaces telescope, alpha, which-key,
-- indent-blankline, noice, nvim-notify, dressing, trouble, neoscroll, undotree,
-- neogit/diffview/fugitive, goto-preview, aerial, zen-mode, twilight.
-- =============================================================================

local M = {}

local icons = require('config.icons')

function M.setup()
  local Snacks = require('snacks')

  -- ── Dashboard (former alpha-nvim) ──────────────────────────────────────
  local function dashboard_footer()
    local count = 0
    local pack_dir = vim.fn.stdpath("config") .. "/pack"
    for _, type in ipairs({ "start", "opt" }) do
      local bundle_dir = pack_dir .. "/" .. type
      if vim.fn.isdirectory(bundle_dir) == 1 then
        for _, bundle in ipairs(vim.fn.readdir(bundle_dir)) do
          local dir = bundle_dir .. "/" .. bundle
          if vim.fn.isdirectory(dir) == 1 then
            count = count + #vim.fn.readdir(dir)
          end
        end
      end
    end
    local v = vim.version()
    return string.format("%s   %d plugins   v%d.%d.%d", os.date(" %d-%m-%Y   %H:%M:%S"), count, v.major, v.minor, v.patch)
  end

  local dashboard_sections = {
    { section = "header", align = "center", padding = { 0, 3 } },
    {
      pane = "center",
      align = "center",
      icons_vmidline = 1,
      padding = { 2 },
      ui_labels = {
        keys = "KEY",
        desc = "DESC",
      },
      {
        text = {
          { "  ███╗   ██╗ ███████╗ ██████╗  ██╗   ██╗ ██╗ ███╗   ███╗ ", hl = "snacks_dashboard_header" },
          { "  ████╗  ██║ ██╔════╝ ██╔═══██╗ ██║   ██║ ██║ ████╗ ████║ ", hl = "snacks_dashboard_header" },
          { "  ██╔██╗ ██║ █████╗   ██║   ██║ ██║   ██║ ██║ ██╔████╔██║ ", hl = "snacks_dashboard_header" },
          { "  ██║╚██╗██║ ██╔══╝   ██║   ██║ ╚██╗ ██╔╝ ██║ ██║╚██╔╝██║ ", hl = "snacks_dashboard_header" },
          { "  ██║ ╚████║ ███████╗ ╚██████╔╝  ╚████╔╝  ██║ ██║ ╚═╝ ██║ ", hl = "snacks_dashboard_header" },
          { "  ╚═╝  ╚═══╝ ╚══════╝  ╚═════╝    ╚═══╝   ╚═╝ ╚═╝     ╚═╝ ", hl = "snacks_dashboard_header" },
          { "            ⚡ Build • Test • Deploy                   ", hl = "snacks_dashboard_header" },
        },
      },
      { "────────────────────────────ˋ────────────────────────────" },
      {
        action = function() Snacks.picker.files() end,
        icon = icons.dashboard.find_file,
        desc = " Find File",
        key = "f f",
      },
      {
        action = function() vim.cmd("ene") end,
        icon = icons.dashboard.new_file,
        desc = " New File",
        key = "f n",
      },
      {
        action = function() Snacks.picker.recent() end,
        icon = icons.dashboard.recent_files,
        desc = " Recent Files",
        key = "f r",
      },
      {
        action = function() Snacks.picker.grep() end,
        icon = icons.dashboard.live_grep,
        desc = " Find Text",
        key = "f g",
      },
      {
        action = function()
          vim.cmd("packadd auto-session")
          local ok, as = pcall(require, "auto-session")
          if ok then
            as.setup({ auto_restore = false, suppressed_dirs = { "~/", "~/Dev/", "~/Downloads", "~/Documents", "~/Desktop/" } })
            vim.cmd("AutoSession restore")
          end
        end,
        desc = " Restore Session",
        key = "S P C wr",
      },
      {
        action = function() vim.cmd("e $MYVIMRC") end,
        icon = icons.dashboard.config,
        desc = " Config",
        key = "c o",
      },
      {
        action = function() vim.cmd("qa") end,
        icon = icons.dashboard.quit,
        desc = " Quit",
        key = "q",
      },
    },
    {
      section = "footer",
      align = "center",
      padding = { 1, 2 },
      text = dashboard_footer(),
    },
  }

  Snacks.setup({
    bigfile = { enabled = true },
    bufdelete = { enabled = true },
    dashboard = {
      enabled = true,
      preset = {},
      sections = dashboard,
    },
    dim = { enabled = true },
    explorer = { enabled = true, replace_netrw = true },
    indent = { enabled = true },
    input = { enabled = true },
    lazygit = { enabled = true },
    notifier = { enabled = true, timeout = 3000 },
    picker = { enabled = true },
    quickfile = { enabled = true },
    rename = { enabled = true },
    scope = { enabled = true },
    scroll = { enabled = true },
    terminal = { enabled = true },
    toggle = { enabled = true },
    words = { enabled = true },
    zen = { enabled = true },
    styles = {},
  })
end

return M
```

> NOTE: `icons.icons` is a typo — access via `require('config.icons')` registry: `icons.dashboard.find_file` etc. See Step 2.

- [ ] **Step 2: Fix icon refs** — `config.icons.lua` exposes `M.dashboard = { find_file, new_file, recent_files, live_grep, session, config, quit, toggle_tree }`. In the dashboard action blocks replace `icons.icons.find_file` → `icons.dashboard.find_file`, `icons.dashboard.new_file`, `icons.dashboard.recent_files`, `icons.dashboard.live_grep`, `icons.dashboard.session`, `icons.dashboard.config`, `icons.dashboard.quit`. Ensure all are referenced correctly.

- [ ] **Step 3: Verify** — `nvim --headless -c "lua require('config.snacks').setup()" -c "qall"`. Expected: no errors.

- [ ] **Step 4: Commit**

```bash
git add lua/config/snacks.lua
git commit -m "feat(snacks): add configuration with dashboard, picker, terminal, etc"
```

---

## Task 4 — Wire Snacks into `init.lua`

**Files:**
- Modify: `init.lua`

- [ ] **Step 1: Load snacks synchronously (after theme, before schedule) and remove replaced requires**

Add `require('config.snacks')` after `require('config.theme')` and BEFORE `require('config.alpha')`, then REMOVE the `require('config.alpha')` line (alpha is gone). In the deferred block, remove these lines:
- `require('config.telescope').setup()`
- `require('config.nvimtree').setup()`
- `require('config.aerial').setup()`

Edit `init.lua`:

```lua
require('config.options')
require('config.theme')
require('config.snacks')   -- Snacks must load early (autocmds, dashboard)
```

The `vim.schedule` block should now read:

```lua
vim.schedule(function()
  require('config.keymaps')
  require('config.autocmds')
  -- session management unchanged
  require('config.treesitter').setup()
  require('config.lsp').setup()
  require('config.copilot').setup()
  require('config.completion').setup()
  require('config.folding').setup()
  require('config.git').setup()
  require('config.ui').setup()
  require('config.manager').setup()
  require('config.dap').setup()
  require('config.editing').setup()
  require('config.local_history').setup()
  require('config.lang.python')
  require('config.lang.typescript')
  require('config.lang.go')
end)
```

- [ ] **Step 2: Verify** — `nvim --headless -c "qall"` (startup smoke test; dashboard may produce warning if `config.alpha` still required — it won't be).

- [ ] **Step 3: Commit**

```bash
git add init.lua
git commit -m "feat(init): load snacks synchronously, drop telescope/nvimtree/aerial"
```

---

## Task 5 — Rewrite `lua/config/keymaps.lua`

**Files:**
- Modify: `lua/config/keymaps.lua`

- [ ] **Step 1: Replace Telescope, git-suite, preview, terminal, todo, undotree, explorer mappings**

Replace the "Telescope (Fast Search)" block (lines ~109-175) with Snacks picker mappings. Replace these specific call sites:

```lua
-- ── Snacks Picker (Fast Search) ────────────────────────────────────────────
local Snacks = require('snacks')

keymap.set("n", "<leader>ff", function() Snacks.picker.files() end, { desc = "Smart find files" })
keymap.set("n", "<leader>fF", function() Snacks.picker.files({ ignored = true }) end, { desc = "Find all files (ignore gitignore)" })
keymap.set("n", "<leader>fg", function() Snacks.picker.git_files() end, { desc = "Find git files" })
keymap.set("n", "<leader>fr", function() Snacks.picker.recent({ cwd_only = true }) end, { desc = "Find recent files (cwd only)" })
keymap.set("n", "<leader>fs", function() Snacks.picker.grep() end, { desc = "Live grep (fast)" })
keymap.set("n", "<leader>fb", function() Snacks.picker.grep_buffers() end, { desc = "Search in open buffers" })
keymap.set("n", "<leader>fc", function() Snacks.picker.grep_word() end, { desc = "Find string under cursor" })
keymap.set("n", "<leader>fp", function() Snacks.picker.grep({ file_pattern = { "%.py$" } }) end, { desc = "Search Python files" })
keymap.set("n", "<leader>fj", function() Snacks.picker.grep({ file_pattern = { "%.js$", "%.ts$", "%.jsx$", "%.tsx$" } }) end, { desc = "Search JS/TS files" })
keymap.set("n", "<leader>fB", function() Snacks.picker.buffers() end, { desc = "Find buffers" })
keymap.set("n", "<leader>ft", function() Snacks.picker.grep({ pattern = "TODO|FIXME|HACK|WARN|PERF|NOTE", argv = {} }) end, { desc = "Find TODOs" })
keymap.set("n", "<leader>fT", function() Snacks.picker.colorschemes() end, { desc = "Switch themes" })
keymap.set("n", "<leader>fh", function() Snacks.picker.help() end, { desc = "Find help" })
```

- [ ] **Step 2: Replace LSP nav + goto-preview**

```lua
-- ── LSP Navigation (via picker, replaces goto-preview) ─────────────────────
keymap.set("n", "gd", function() Snacks.picker.lsp_definitions() end, { desc = "Go to Definition" })
keymap.set("n", "gD", function() Snacks.picker.lsp_declarations() end, { desc = "Go to Declaration" })
keymap.set("n", "gi", function() Snacks.picker.lsp_implementations() end, { desc = "Go to Implementation" })
keymap.set("n", "gy", function() Snacks.picker.lsp_type_definitions() end, { desc = "Go to Type Definition" })
keymap.set("n", "gr", function() Snacks.picker.lsp_references() end, { desc = "Go to References" })
```

Remove the entire `goto-preview` keymap block (`gpd`, `gpt`, `gpi`, `gpD`, `gP`, `gpr`).

- [ ] **Step 3: Replace git `<leader>g` suite**

```lua
-- ── Git Integration (<leader>g) via LazyGit + Snacks pickers ──────────────
keymap.set("n", "<leader>gg", function() Snacks.lazygit() end, { desc = "LazyGit" })
keymap.set("n", "<leader>gs", function() Snacks.lazygit() end, { desc = "LazyGit status" })
keymap.set("n", "<leader>gl", function() Snacks.picker.git_log() end, { desc = "Git Log" })
keymap.set("n", "<leader>gB", function() Snacks.picker.git_branches() end, { desc = "Git Branches" })
keymap.set("n", "<leader>gS", function() Snacks.picker.git_stash() end, { desc = "Git Stash" })
keymap.set("n", "<leader>gd", function() Snacks.picker.git_diff() end, { desc = "Git Diff (Hunks)" })
keymap.set("n", "<leader>gf", function() Snacks.picker.git_log_file() end, { desc = "Git Log File" })
keymap.set("n", "<leader>gp", function() Snacks.lazygit() end, { desc = "LazyGit (push)" })
keymap.set("n", "<leader>gP", function() Snacks.lazygit() end, { desc = "LazyGit (pull)" })
```

Remove references to `git.open_neogit_status`, `git.open_diffview`, `git.open_git_log`, `git.open_git_stash`, `git.git_push`, `git.git_pull`, `git.open_git_branches`, `git.open_git_commits`, `git.close_diffview` mappings.

- [ ] **Step 4: undo/exporus/terminal mappings**

Replace:
- `<leader>hl` undo tree → `keymap.set("n", "<leader>hl", function() Snacks.picker.undo() end, { desc = "Undo history" })`
- `<leader>ee` explorer → `keymap.set("n", "<leader>ee", function() Snacks.explorer() end, { desc = "Toggle file explorer" })`
- remove `<leader>ef`, `<leader>ec`, `<leader>er`, `<leader>ew` (nvim-tree only) OR remap `<leader>ef` to follow file: `keymap.set("n", "<leader>ef", function() Snacks.explorer({ follow = true }) end, { desc = "Explorer at current file" })`
- Terminal: `keymap.set("n", "<leader>T", function() Snacks.terminal() end, { desc = "Terminal" })` and `<c-/>` likewise.
- Zoom: `keymap.set("n", "<leader>sm", function() Snacks.zen.zoom() end, { desc = "Toggle zoom" })`
- Keep the rest (window nav, splits, formatting, python, DAP, pyright toggle, history).

- [ ] **Step 5: Remove now-dangling `require('config.spectre')`/neotest references**

`neotest` was never installed — the `<leader>tr/tf/td/ts/tO` blocks use `pcall`. Keep `pcall` (safe). Leave only if clean; simplest is to delete the whole "Testing (neotest)" block since neotest isn't a plugin. Delete the "Spectre" block only if `<leader>sr/sw` remain valid — `nvim-spectre` stays installed, so keep those keymaps referencing `require('spectre')`.

- [ ] **Step 6: Verify headless**

`nvim --headless -c "lua require('config.keymaps')" -c "qall"` — expected no error. Confirm no `require('telescope')`, `require('nvim-tree')`, `require('aerial')`, `require('goto-preview')`, `require('neogit')` remains: `grep -rn "telescope\|goto-preview\|nvim-tree\|aerial\|neogit\|diffview\|harpoon\|alpha" lua/config/keymaps.lua` → empty.

- [ ] **Step 7: Commit**

```bash
git add lua/config/keymaps.lua
git commit -m "feat(keymaps): remap to snacks picker, lazygit, terminal, explorer"
```

---

## Task 6 — Slim `lua/config/git.lua` to gitsigns + lazygit

**Files:**
- Modify: `lua/config/git.lua`

- [ ] **Step 1: Keep only M.setup() gitsigns config and add lazygit**

Keep the `safe_setup('gitsigns', ...)` block verbatim. Add a lazygit wrapper in `setup()`:

```lua
  safe_setup('gitsigns', 'gitsigns.nvim', function(gs)
    gs.setup({
      signs = {
        add = { text = icons.git.add },
        change = { text = icons.git.change },
        delete = { text = icons.git.delete },
        topdelete = { text = icons.git.topdelete },
        changedelete = { text = icons.git.changedelete },
        untracked = { text = icons.git.untracked },
      },
      current_line_blame = true,
      current_line_blame_opts = { virt_text = true, virt_text_pos = 'eol' },
      -- ... keep rest of gitsigns opts & on_attach from current file
    })
  end)
```

- [ ] **Step 2: Delete non-gitsigns functions** — remove `ensure()` usages for neogit/diffview/git_conflict, remove `open_neogit_status`, `open_neogit_commit`, `open_diffview`, `open_diffview_current`, `open_git_log`, `open_git_stash`, `git_push`, `git_pull`, `show_commit_for_line`, `show_commit`, `show_status_summary`, `open_git_branches`, `open_git_commits`, `close_diffview`. Keep only `M.setup()` and, if still wanted, `preview_hunk`, `blame_line`, `stage_all_hunks`, `reset_hunk` (used by statusline column/on_attach).

- [ ] **Step 3: Ensure no dangling `which-key` pcall** — remove the `which-key` group add block (which-key is gone).

- [ ] **Step 4: Verify** — `rg -n "neogit|diffview|gv\.vim|fugitive|git_conflict|which-key" lua/config/git.lua` returns empty. `nvim --headless -c "lua require('config.git')" -c "qall"` no error.

- [ ] **Step 5: Commit**

```bash
git add lua/config/git.lua
git commit -m "refactor(git): reduce to gitsigns signs + snacks.lazygit"
```

---

## Task 7 — Clean `lua/config/ui.lua`

**Files:**
- Modify: `lua/config/ui.lua`

- [ ] **Step 1: Remove replaced plugin blocks** — delete the `ibl.setup` (indent-blankline), `dressing.setup`, `noice.setup`, `which-key` blocks and their icon/rainbow code. Remove `nvim-navic` setup. Keep `lualine.setup`, `bufferline.setup` (+ buffer keymaps), and `nvim-colorizer` setup.

- [ ] **Step 2: Keep lualine custom theme intact** — do NOT alter `my_lualine_theme`, sections, or extensions. The `plugin_manager_status` component stays (used by manager.lua). Remove the `noice`-based status component from `lualine_x` (line ~138-143) since noice is gone; replace with a no-op returning `""`.

- [ ] **Step 3: Verify** — `rg -n "ibl|noice|which.le|dressing|navic|nvim-notify|indent-blankline" lua/config/ui.lua` empty. `nvim --headless -c "lua require('config.ui').setup()"` no error.

- [ ] **Step 4: Commit**

```bash
git add lua/config/ui.lua
git commit -m "refactor(ui): use snacks for indent/noice/dressing, keep lualine+bufferline"
```

---

## Task 8 — Remove now-orphaned config files & references

**Files:**
- Delete: `lua/config/alpha.lua`, `lua/config/nvimtree.lua`, `lua/config/aerial.lua`, `lua/config/telescope.lua`
- Modify: `lua/config/autocmds.lua`, `lua/config/theme.lua`

- [ ] **Step 1: Delete files**

```bash
rm lua/config/alpha.lua lua/config/nvimtree.lua lua/config/aerial.lua lua/config/telescope.lua
```

- [ ] **Step 2: autocmds** — remove `pattern = { "Trouble", "lazy", "mason", "notify" }` leftover references if present (only `alpha`/`NvimTree`/`Trouble`/`notify` exclude entries in `ibl` gone already; also check "close_with_q" list). Update `close_with_q` excludes: drop `spectre_panel` if `nvim-spectre` removed? It's kept — keep. Remove `NvimTree` from any list in autocmds.lua (none refs it). Grep to confirm. **No change needed if nothing refs them** — leave skinematic.

- [ ] **Step 3: theme.lua** — remove dead highlight overrides for removed plugins (`BufferLine*`, `NvimTree*`, `NeoTree*`, `BlinkCmp` NOT needed at alpha, `Telescope*` block in `apply_custom_highlights`). Keep solarized base + `GitSigns*` + `BlinkCmp*` + `Normal(NC)`. Delete the `if nvimtree_bg` block only if it breaks (it calls `synIDattr` on removed `NvimTreeNormal`); replace with fixed background assignment.

- [ ] **Step 4: Final headless sanity** — `nvim --headless -c "lua local ok,e=pcall(require,'config.ui'); print(ok)" -c "qall"` and grep config dir for removed plugin refs:

```$SHELL
grep -rn "telescope\|goto-preview\|nvim-tree\|aerial\|neogit\|diffview\|fugitive\|alpha\|noice\|which-key\|dressing\|trouble\|nvim-notify\|nvim-colorizer\|indent-blankline\|zeta\|twilight\|undotree\|neoscroll\|harpoon" lua/ init.lua | grep -v "config/plugins.lua"
```

THE ONLY remaining hits beyond `plugins.lua` should be intentional (e.g. in README/comments). Fix each hit by removing or replacing.

- [ ] **Step 5: Commit**

```bash
git add -A
rm -f lua/config/alpha.lua lua/config/nvimtree.lua lua/config/aerial.lua lua/config/telescope.lua
git commit -m "chore(config): remove orphaned config files (alpha, nvimtree, aerial, telescope)"
```

---

## Task 9 — Update noice import/verify + README + run checks

**Files:**
- Modify: `README.md`

- [ ] **Step 1: Update README plugin list & keybindings table** — replace "Telescope" mentions with "Snacks picker", replace Git Fugitive/Neogit rows with LazyGit, replace alpha with snacks dashboard descriptor. Update "KEEP" list to match new registry.

- [ ] **Step 2: Final verification battery**

```bash
nvim --headless -c "lua require('config.snacks').setup()" -c "qall"
nvim --headless -c "lua require('config.keymaps')" -c "qall"
nvim --headless -c "require('config.ui').setup()" -c "qall"
nvim --headless -c "require('config.git')" -c "qall"
nvim --startuptime /tmp/nvim_start.txt -c "qall"; grep -E "^[0-9]+\." /tmp/nvim_start.txt | sort -rn | head -20
```

Expected: all headless loads return 0, no errors; startup shows Snacks modules loading under a few ms.

- [ ] **Step 3: Commit README**

```bash
git add README.md
git commit -m "docs: update README for snacks-first setup"
```

---

## Self-Review & Handoff

- [ ] **Step: Spec coverage check** — confirm every design decision has a task: plugins registry (T1), install/remove dirs (T2), snacks config + dashboard (T3), init wiring (T4), keymaps (T5), git slimming (T6), ui cleanup (T7), orphan removal + theme (T8), README + checks (T9).
- [ ] **Step: Placeholder scan** — no TBD/TODO across tasks.
- [ ] **Step: Type/API consistency** — verify snack calls (`snacks.picker.files`, `snacks.picker.grep`, `snacks.lazygit`, `snacks.explorer`, `snacks.terminal`, `snacks.zen.zoom`, `snacks.picker.undo`, `snacks.picker.lsp_*`, `snacks.picker.git_*`) all match Snacks v3 public API from Task 3's README-researched names.

**Plan complete.**