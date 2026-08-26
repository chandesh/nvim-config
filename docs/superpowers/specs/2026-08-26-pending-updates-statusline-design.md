# Pending Plugin Updates Statusline Item — Design

**Date:** 2026-08-26
**Target:** Neovim v0.12.4 · detached plugin manager (`lua/config/manager.lua`) · lualine (`lua/config/ui.lua`)
**Status:** Approved by user

## 1. Goal

Show, directly in the lualine statusline, how many plugins have updates
available upstream **before** any update is performed, so the user can decide
whether to run `:PluginUpdate` / `:PluginSync`.

Today `vim.g.plugin_manager.updates_available` is only populated *after*
`:PluginUpdate` runs (it counts what was just pulled). Nothing checks upstream
read-only. This design adds a non-destructive check pass and surfaces its
result in the existing statusline component.

## 2. Decisions (confirmed with user)

| Decision | Choice |
|---|---|
| Check trigger | **Both** auto (~10 s after startup) + manual `:PluginCheck` / `:PC` |
| Click action | **Display only** — no click handler; user runs `:PU` / `:PS` themselves |
| Detection method | **A:** per-repo `git fetch` + `git rev-list --count HEAD..@{u}` |

Rejected alternatives:

- **B: `git ls-remote` SHA compare** — lighter network use but binary yes/no,
  conflates "behind" with "diverged", no commit count.
- **C: status quo** — post-update counter only; requires updating to discover
  updates. Does not meet the requirement.

## 3. Architecture

All changes live in two files, following existing patterns:

### 3.1 `lua/config/manager.lua`

New state fields on the shared `vim.g.plugin_manager` table (kept separate from
the existing post-update counter):

```lua
pending_updates = 0,    -- total commits-behind across repos, from last check
checking_updates = false,
```

New function `M.check_updates(callback)`:

- Discovers repos exactly like `build_update_tasks()`:
  `vim.fn.glob(pack_root .. "/**/*/.git", false, true)`.
- Builds one task per repo for the existing `run_parallel(tasks, 4)` runner.
  Each task is a single shell job chaining fetch + count (no working-tree
  mutation; fetch only updates remote-tracking refs):

  ```lua
  cmd = { "sh", "-c",
    "git -C '" .. repo .. "' fetch --quiet origin && "
    .. "git -C '" .. repo .. "' rev-list --count HEAD..@{u}" },
  ```

- `on_stdout` captures the last numeric line (that repo's behind-count) into a
  closure-local counter; all counters are summed into `pending_updates` when
  the last job exits (`run_parallel`'s `on_all_done`).
- Per-repo failures (offline, missing upstream, detached HEAD oddities) are
  skipped silently and counted as 0 — never error to the user.
- Guards: returns immediately if `active == true` or `checking_updates == true`.
- Sets `checking_updates = true` while running, clears it on completion,
  then invokes `callback` if provided.

Notification policy:

- Manual check → always notify summary ("N plugins have updates available" /
  "All plugins up to date").
- Auto check (startup) → notify only when N > 0 (no startup noise).

New commands in `M.setup()`:

- `:PluginCheck` / `:PC` → `M.check_updates()`

Auto trigger in `M.setup()`:

- `vim.defer_fn(function() M.check_updates() end, 10000)` — off the startup
  critical path.

Refresh-after-update in `M.update()` completion callback:

- After reporting "Updated N plugins", re-run `M.check_updates()` so
  `pending_updates` drops to 0 automatically (and install-side new clones are
  also counted on subsequent syncs).

### 3.2 `lua/config/ui.lua`

Rework the existing `plugin_manager_status()` component (priority order):

1. Active operation → unchanged progress string `" N/M"` (existing behavior).
2. `checking_updates == true` → `" Checking"`.
3. `pending_updates > 0` → `" N updates"`.
4. Otherwise `""`.

Component color becomes a dynamic color function (same pattern as
`dap_color`) returning:

| State | Color |
|---|---|
| `pending_updates > 0` | yellow `#FFDA7B` on bg `#0d4f3c` |
| `checking_updates == true` | dim `#6a7079` on bg `#0d4f3c` |
| active operation (progress) | cyan `#00f5ff` on bg `#0d4f3c` (current static values, unchanged) |

No click handler (display-only decision).

## 4. Data flow

```
setup() ──defer 10 s──▶ M.check_updates()
 :PC ─────────────────▶     │
                            ▼
              run_parallel(1 task/repo, 4 concurrent)
              git fetch + rev-list --count HEAD..@{u}
                            │
                            ▼
        vim.g.plugin_manager.pending_updates = Σ counts
                            │
                            ▼
        lualine component re-evaluates on next refresh cycle
```

After `:PU`: update tasks pull repos → completion callback re-checks →
count reflects post-update reality (0 when fully caught up).

## 5. Error handling & edge cases

- Offline / fetch failure → repo contributes 0, silently skipped.
- Shallow clones (`--depth 1`) work: `rev-list HEAD..@{u}` compares two local
  refs after fetch.
- Concurrent invocation blocked by the `checking_updates` guard.
- Update/sync running when auto-check fires → guarded by `active` check; the
  post-update refresh covers it.
- No test framework exists in this dotfiles repo. Verification is manual:
  restart nvim and observe item states; run `:PC`; cross-check one repo's
  count against `git -C <repo> rev-list --count HEAD..@{u}`; run `:PU` and see
  the count clear. Headless smoke test:
  `nvim --headless "+lua require('config.manager').check_updates(function() print(vim.g.plugin_manager.pending_updates) end)" +qa`.

## 6. Out of scope

- Click-to-update on the statusline item.
- Per-plugin breakdown popup (could read `pending_updates` detail later).
- Changes to `update.sh` (shell updater remains independent).
