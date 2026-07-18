-- ~/.config/nvim/lua/config/manager.lua
-- =============================================================================
-- Detached Plugin Manager
-- Async git operations via vim.fn.jobstart — no plugin manager dependency.
-- Exposes progress & update state for lualine to display.
-- vim.pack remains the sole runtime loading mechanism.
-- =============================================================================

local M = {}

local plugins = require('config.plugins')
local pack_root = vim.fn.stdpath("config") .. "/pack"

-- Shared state consumed by lualine component in ui.lua
vim.g.plugin_manager = {
  active = false,
  operation = "",
  current = 0,
  total = 0,
  updates_available = 0,
}

-- ── Async job queue with concurrency limit ────────────────────────────────
local function run_parallel(tasks, max_concurrent, on_all_done)
  local total = #tasks
  if total == 0 then
    vim.g.plugin_manager.active = false
    if on_all_done then on_all_done() end
    return
  end

  local running = 0
  local idx = 1
  local completed = 0
  local done = false

  local function check_done()
    if done then return end
    if running == 0 and completed >= total then
      done = true
      vim.schedule(function()
        vim.g.plugin_manager.active = false
        if on_all_done then on_all_done() end
      end)
    end
  end

  local function start_next()
    while running < max_concurrent and idx <= total do
      local task = tasks[idx]
      idx = idx + 1
      running = running + 1

      vim.fn.jobstart(task.cmd, {
        stdout_buffered = true,
        on_stdout = function(_, data)
          if task.on_stdout then
            vim.schedule(function()
              for _, line in ipairs(data) do
                task.on_stdout(line)
              end
            end)
          end
        end,
        on_exit = function(_, exit_code)
          running = running - 1
          completed = completed + 1
          vim.schedule(function()
            vim.g.plugin_manager.current = completed
            if task.on_exit then task.on_exit(exit_code) end
          end)
          start_next()
          check_done()
        end,
      })
    end
    check_done()
  end

  vim.g.plugin_manager.current = 0
  vim.g.plugin_manager.total = total
  vim.g.plugin_manager.active = true
  start_next()
end

local function dir_name(path)
  return vim.fn.fnamemodify(path, ":t")
end

-- ── Internal: build update tasks (used by both update & sync) ────────────
local function build_update_tasks()
  local git_dirs = vim.fn.glob(pack_root .. "/**/*/.git", false, true)
  if #git_dirs == 0 then return {} end

  local tasks = {}
  for _, git_dir in ipairs(git_dirs) do
    local repo = git_dir:gsub("/%.git$", "")
    local name = dir_name(repo)
    local task_updated = false

    table.insert(tasks, {
      cmd = { "git", "-C", repo, "pull", "--rebase", "--autostash" },
      on_stdout = function(line)
        if line and line ~= "" and not line:find("Already up") and not line:find("Current branch") then
          task_updated = true
        end
      end,
      on_exit = function()
        if task_updated then
          vim.g.plugin_manager.updates_available = (vim.g.plugin_manager.updates_available or 0) + 1
        end
      end,
    })
  end
  return tasks
end

-- ── Internal: build install tasks (used by both install & sync) ──────────
local function build_install_tasks()
  local tasks = {}
  local fzf_path = nil

  for bundle, types in pairs(plugins) do
    for type, list in pairs(types) do
      for _, plugin in ipairs(list) do
        local dest = pack_root .. "/" .. bundle .. "/" .. type .. "/" .. plugin.name
        if vim.fn.isdirectory(dest) == 0 then
          table.insert(tasks, {
            cmd = { "git", "clone", "--depth", "1", "--quiet",
                    "https://github.com/" .. plugin.source, dest },
            on_exit = function()
              vim.notify("  ✓ " .. plugin.name, vim.log.levels.INFO)
            end,
          })
          if plugin.name == "telescope-fzf-native.nvim" then
            fzf_path = dest
          end
        end
      end
    end
  end

  return tasks, fzf_path
end

-- ── Install ───────────────────────────────────────────────────────────────
function M.install(callback)
  vim.g.plugin_manager.operation = "Installing"
  vim.g.plugin_manager.updates_available = 0

  local tasks, fzf_path = build_install_tasks()

  if #tasks == 0 then
    vim.notify("All plugins already installed.", vim.log.levels.INFO)
    vim.g.plugin_manager.active = false
    if callback then callback() end
    return
  end

  vim.notify("Installing " .. #tasks .. " plugins...", vim.log.levels.INFO)

  run_parallel(tasks, 4, function()
    vim.notify("Installation complete.", vim.log.levels.INFO)
    if fzf_path then
      vim.notify("Building telescope-fzf-native...", vim.log.levels.INFO)
      vim.fn.jobstart({ "make" }, {
        cwd = fzf_path,
        on_exit = function(_, code)
          if code == 0 then
            vim.notify("  ✓ telescope-fzf-native built", vim.log.levels.INFO)
          else
            vim.notify("  ⚠ fzf-native build failed", vim.log.levels.WARN)
          end
          if callback then callback() end
        end,
      })
    else
      if callback then callback() end
    end
  end)
end

-- ── Update ───────────────────────────────────────────────────────────────
function M.update(callback)
  vim.g.plugin_manager.operation = "Updating"
  vim.g.plugin_manager.updates_available = 0

  local tasks = build_update_tasks()

  if #tasks == 0 then
    vim.notify("No plugins found to update.", vim.log.levels.WARN)
    vim.g.plugin_manager.active = false
    if callback then callback() end
    return
  end

  vim.notify("Checking " .. #tasks .. " plugins...", vim.log.levels.INFO)

  run_parallel(tasks, 4, function()
    local count = vim.g.plugin_manager.updates_available
    if count > 0 then
      vim.notify("Updated " .. count .. " plugins.", vim.log.levels.INFO)
    else
      vim.notify("All plugins up to date.", vim.log.levels.INFO)
    end
    if callback then callback() end
  end)
end

-- ── Sync (Update → Install) ──────────────────────────────────────────────
function M.sync()
  vim.g.plugin_manager.operation = "Syncing"
  vim.notify("Starting sync...", vim.log.levels.INFO)
  M.update(function()
    M.install()
  end)
end

-- ── Commands ──────────────────────────────────────────────────────────────
function M.setup()
  vim.api.nvim_create_user_command("PluginInstall", function() M.install() end, { desc = "Install missing plugins" })
  vim.api.nvim_create_user_command("PluginUpdate",  function() M.update() end,  { desc = "Update all plugins" })
  vim.api.nvim_create_user_command("PluginSync",    function() M.sync() end,    { desc = "Sync (Update + Install)" })

  vim.api.nvim_create_user_command("PI", function() M.install() end, { desc = "Install missing plugins" })
  vim.api.nvim_create_user_command("PU", function() M.update() end,  { desc = "Update all plugins" })
  vim.api.nvim_create_user_command("PS", function() M.sync() end,    { desc = "Sync (Update + Install)" })
end

return M
