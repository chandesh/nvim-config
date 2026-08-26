# Pending Plugin Updates Statusline Item — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Show how many plugin updates are available upstream, directly in the lualine statusline, *before* running `:PluginUpdate`.

**Architecture:** New read-only `check_updates()` pass in the detached plugin manager (`lua/config/manager.lua`) reusing the existing async `run_parallel` git-job infrastructure: one `sh -c` job per repo chaining `git fetch --quiet origin && git rev-list --count HEAD..@{u}`. Results land in new `vim.g.plugin_manager.pending_updates` / `.checking_updates` state consumed by the existing `plugin_manager_status` lualine component in `lua/config/ui.lua`, which gains a dynamic color function.

**Tech Stack:** Neovim Lua API (`vim.fn.jobstart`, `vim.defer_fn`, `vim.notify`), git plumbing, lualine.nvim custom components.

**Spec:** `docs/superpowers/specs/2026-08-26-pending-updates-statusline-design.md`

**Testing note:** This dotfiles repo has no test framework (per spec §5). Each task substitutes: a headless syntax check, a headless functional smoke test (real network fetches), and a final manual interactive checklist performed by the user.

---

### Task 1: Manager — state, `check_updates()`, commands, triggers

**Files:**
- Modify: `lua/config/manager.lua` (state table ~line 15; `run_parallel` ~line 24; new builder + function after `build_update_tasks` ~line 116; `update()` completion ~line 180; `setup()` ~line 203)

- [ ] **Step 1: Baseline syntax check (verify clean starting point)**

Run:
```bash
nvim --headless "+lua assert(loadfile('lua/config/manager.lua')); print('SYNTAX_OK')" +qa
```
Expected stdout: `SYNTAX_OK`

- [ ] **Step 2: Add new state fields**

In `lua/config/manager.lua`, replace the shared state table:

```lua
-- Shared state consumed by lualine component in ui.lua
vim.g.plugin_manager = {
  active = false,
  operation = "",
  current = 0,
  total = 0,
  updates_available = 0,
  pending_updates = 0,
  checking_updates = false,
}
```

- [ ] **Step 3: Extend `run_parallel` with an `opts` parameter**

The checker must NOT flip `active` (that flag means "install/update/sync running" and gates the checker itself plus statusline priority). Add a trailing `opts` param; existing callers pass nothing and behave identically.

Replace the function header and the three places that touch `active`/progress counters:

```lua
-- ── Async job queue with concurrency limit ────────────────────────────────
-- opts.set_active = false → manage state externally (used by check_updates)
local function run_parallel(tasks, max_concurrent, on_all_done, opts)
  opts = opts or {}
  local set_active = opts.set_active ~= false
  local total = #tasks
  if total == 0 then
    if set_active then vim.g.plugin_manager.active = false end
    if on_all_done then on_all_done() end
    return
  end
```

Inside `check_done`, replace the scheduled completion block:

```lua
  local function check_done()
    if done then return end
    if running == 0 and completed >= total then
      done = true
      vim.schedule(function()
        if set_active then vim.g.plugin_manager.active = false end
        if on_all_done then on_all_done() end
      end)
    end
  end
```

Replace the pre-start state assignment at the bottom of `run_parallel`:

```lua
  if set_active then
    vim.g.plugin_manager.current = 0
    vim.g.plugin_manager.total = total
    vim.g.plugin_manager.active = true
  end
  start_next()
end
```

- [ ] **Step 4: Add `build_check_tasks` + `M.check_updates`**

Insert directly after the closing `end` of `build_update_tasks()` (before the `build_install_tasks` comment block):

```lua
-- ── Internal: build check tasks (read-only upstream comparison) ──────────
-- One shell job per repo: fetch remote refs, then count commits HEAD is
-- behind its upstream. Never touches the working tree or local branches.
local function build_check_tasks(on_result)
  local git_dirs = vim.fn.glob(pack_root .. "/**/*/.git", false, true)
  local tasks = {}
  for _, git_dir in ipairs(git_dirs) do
    local repo = git_dir:gsub("/%.git$", "")
    local behind = 0
    table.insert(tasks, {
      cmd = { "sh", "-c",
        "git -C '" .. repo .. "' fetch --quiet origin && "
          .. "git -C '" .. repo .. "' rev-list --count HEAD..@{u}" },
      on_stdout = function(line)
        local n = tonumber(line and line:match("(%d+)"))
        if n then behind = n end
      end,
      on_exit = function(exit_code)
        if exit_code == 0 then on_result(repo, behind) end
      end,
    })
  end
  return tasks
end
```

Insert `M.check_updates` right after `build_check_tasks` (before the Install section):

```lua
-- ── Check (available updates, no pulling) ────────────────────────────────
-- o.auto = true → suppress the "all up to date" notification (startup/post-update)
function M.check_updates(callback, o)
  o = o or {}
  local pm = vim.g.plugin_manager
  if pm.active or pm.checking_updates then return end

  local behind_total, repos_behind = 0, 0
  local tasks = build_check_tasks(function(_, n)
    if n > 0 then
      behind_total = behind_total + n
      repos_behind = repos_behind + 1
    end
  end)

  if #tasks == 0 then
    pm.pending_updates = 0
    if callback then callback() end
    return
  end

  pm.checking_updates = true
  run_parallel(tasks, 4, function()
    local state = vim.g.plugin_manager
    state.pending_updates = behind_total
    state.checking_updates = false
    if behind_total > 0 then
      vim.notify(
        string.format("  %d plugin(s) have updates available (%d commit(s) behind).",
          repos_behind, behind_total),
        vim.log.levels.INFO)
    elseif not o.auto then
      vim.notify("All plugins up to date.", vim.log.levels.INFO)
    end
    if callback then callback() end
  end, { set_active = false })
end
```

- [ ] **Step 5: Refresh pending count after `M.update` completes**

In `M.update()`, append a chained re-check to the `run_parallel` completion callback (callback first so `:PS` proceeds to install immediately; the checker's `active` guard makes it skip harmlessly if install is mid-flight):

```lua
  run_parallel(tasks, 4, function()
    local count = vim.g.plugin_manager.updates_available
    if count > 0 then
      vim.notify("Updated " .. count .. " plugins.", vim.log.levels.INFO)
    else
      vim.notify("All plugins up to date.", vim.log.levels.INFO)
    end
    if callback then callback() end
    M.check_updates(nil, { auto = true })
  end)
```

- [ ] **Step 6: Register commands + startup auto-check in `M.setup()`**

Add inside `M.setup()`, alongside the existing `PI/PU/PS` commands:

```lua
  vim.api.nvim_create_user_command("PluginCheck", function() M.check_updates() end, { desc = "Check for plugin updates (read-only)" })
  vim.api.nvim_create_user_command("PC",           function() M.check_updates() end, { desc = "Check for plugin updates (read-only)" })

  -- Deferred startup check: off the critical path, silent unless outdated
  vim.defer_fn(function() M.check_updates(nil, { auto = true }) end, 10000)
```

- [ ] **Step 7: Syntax check**

Run:
```bash
nvim --headless "+lua assert(loadfile('lua/config/manager.lua')); print('SYNTAX_OK')" +qa
```
Expected stdout: `SYNTAX_OK`

- [ ] **Step 8: Headless functional smoke test (real fetches, ~30–90 s)**

Run:
```bash
nvim --headless "+lua local m=require('config.manager'); m.setup(); local done=false; m.check_updates(function() done=true end); vim.wait(120000, function() return done end); local pm=vim.g.plugin_manager; print(('SMOKE pending=%d checking=%s'):format(pm.pending_updates, tostring(pm.checking_updates)))" +qa
```
Expected stdout: `SMOKE pending=<integer> checking=false` (process exits right after printing; `pending` matches reality — cross-check one repo below)

Cross-check one repo independently:
```bash
git -C "$HOME/.config/nvim/pack/core/start/plenary.nvim" rev-list --count HEAD..@{u}
```
Expected: an integer consistent with the aggregate (plenary is rarely behind; `0` is typical).

- [ ] **Step 9: Commit**

```bash
git add lua/config/manager.lua
git commit -m "feat(manager): add read-only upstream update check (:PluginCheck)"
```

---

### Task 2: Statusline — pending-updates component with dynamic color

**Files:**
- Modify: `lua/config/ui.lua` (replace `plugin_manager_status` ~lines 148–159; component entry ~line 198)

- [ ] **Step 1: Replace the status function and add the color function**

In `lua/config/ui.lua`, delete the existing `plugin_manager_status` function and insert these two in its place (priority order per spec §3.2: active op → checking → pending → hidden):

```lua
  local function plugin_manager_status()
    local pm = vim.g.plugin_manager
    if not pm then return "" end
    if pm.active then
      return string.format(" %s %d/%d", pm.operation, pm.current, pm.total)
    end
    if pm.checking_updates then
      return " Checking"
    end
    if (pm.pending_updates or 0) > 0 then
      return string.format(" %d updates", pm.pending_updates)
    end
    return ""
  end

  local function plugin_manager_color()
    local pm = vim.g.plugin_manager
    if pm and pm.active then
      return { fg = "#00f5ff", bg = "#0d4f3c" }
    end
    if pm and pm.checking_updates then
      return { fg = colors.inactive_fg, bg = "#0d4f3c" }
    end
    if pm and (pm.pending_updates or 0) > 0 then
      return { fg = colors.yellow, bg = "#0d4f3c" }
    end
    return { fg = "#00f5ff", bg = "#0d4f3c" }
  end
```

(The old post-update `updates_available` branch is intentionally gone — the pending model supersedes it per spec.)

- [ ] **Step 2: Point the lualine component at the new color function**

In the `lualine_x` section, replace:

```lua
         { plugin_manager_status, color = { fg = "#00f5ff", bg = "#0d4f3c" } },
```

with:

```lua
         { plugin_manager_status, color = plugin_manager_color },
```

- [ ] **Step 3: Syntax check**

Run:
```bash
nvim --headless "+lua assert(loadfile('lua/config/ui.lua')); print('SYNTAX_OK')" +qa
```
Expected stdout: `SYNTAX_OK`

- [ ] **Step 4: Commit**

```bash
git add lua/config/ui.lua
git commit -m "feat(ui): surface pending plugin updates in statusline"
```

---

### Task 3: Interactive verification (user-performed)

**Files:** none (verification only)

- [ ] **Step 1: Startup auto-check**

Launch `nvim`. Within ~10 s the statusline briefly shows dim ` Checking`; afterwards it is either empty (up to date) or yellow ` N updates`. Notification appears only in the latter case.

- [ ] **Step 2: Manual check**

Run `:PC`. Expected: notification summary always ("…have updates available…" or "All plugins up to date."), statusline reflects result.

- [ ] **Step 3: Update clears the count**

Run `:PU`. Expected: progress ` Updating N/M` (cyan) during run, then "Updated N plugins." and the pending count refreshes to empty/0 without a second notification.

- [ ] **Step 4: Guard sanity**

Run `:PC` twice in rapid succession, then during a `:PS`. Expected: no errors, no duplicate concurrent checks; sync completes normally.

---

## Self-Review

- **Spec coverage:** §3.1 state fields (T1S2), `run_parallel` non-interference (T1S3), `build_check_tasks`/`M.check_updates` with guards + notify policy (T1S4), post-update refresh (T1S5), `:PluginCheck`/`:PC` + 10 s deferred auto-check (T1S6) — all covered. §3.2 priority order + exact color table (T2S1–S2) — covered. §5 verification adapted to no-framework reality (syntax + headless smoke + manual checklist) — covered. §6 out-of-scope items untouched.
- **Placeholder scan:** none — every step carries complete code or exact commands with expected output.
- **Type/name consistency:** `pending_updates`, `checking_updates`, `set_active`, `o.auto`, `build_check_tasks(on_result)`, `M.check_updates(callback, o)` used identically across tasks; ui.lua reads exactly the field names manager writes.

---

## Revision (2026-08-26, during execution)

Per user decision mid-execution: `lua/config/manager.lua` was **renamed to
`lua/config/pkg_manager.lua`** (`git mv`, init.lua wiring updated, commit
f5cd044) after confirming the module is single-responsibility (plugin/package
management only). All Task 1 logic therefore lives in `pkg_manager.lua`
instead of `update_manager.lua`; the earlier `update_manager.lua` detour was
abandoned and no such file exists. Task 2 unchanged. Commits: f5cd044
(rename), af71b4d (check feature), 0a03966 (statusline).
