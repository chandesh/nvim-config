-- Global keymap ledger. Not required at startup.
-- Run via: nvim --headless -c 'lua vim.g.keymap_check = "write|diff"' -c 'lua vim.defer_fn(function() dofile("scripts/check_keymaps.lua") vim.cmd("qa!") end, 800)'

local ledger = vim.fn.stdpath("config") .. "/docs/superpowers/plans/keymap-ledger-2026-11-09.txt"
local mode = vim.g.keymap_check
local leader = vim.g.mapleader or " "

-- New global lhs values this plan may add. See the spec table.
local allowed_new = {
  ["n\t<leader>a"] = true,
  ["x\t<leader>a"] = true,
  ["v\t<leader>a"] = true,
  ["n\t<leader>aa"] = true,
  ["n\t<leader>ae"] = true,
  ["x\t<leader>ae"] = true,
  ["v\t<leader>ae"] = true,
  ["n\t<leader>aq"] = true,
  ["n\t<leader>tr"] = true,
  ["n\t<leader>tF"] = true,
  ["n\t<leader>tS"] = true,
  ["n\t<leader>tl"] = true,
  ["n\t<leader>tq"] = true,
  ["n\t<leader>td"] = true,
  ["n\t<leader>js"] = true,
  ["n\t<leader>mv"] = true,
  ["n\t[c"] = true,
  ["n\t]c"] = true,
}

local function normalize(lhs)
  if leader ~= "" and lhs:sub(1, #leader) == leader then
    return "<leader>" .. lhs:sub(#leader + 1)
  end
  return lhs
end

local function fail(msg)
  print(msg)
  vim.cmd("cquit 1")
end

local function collect()
  -- Completion is opt now, but its insert-mode maps and <Plug> entries are part
  -- of the baseline. Load it so `diff` still checks the full map surface
  -- instead of only what boots eagerly.
  pcall(function() require('config.completion').ensure() end)

  local lines = {}
  for _, map_mode in ipairs({ "n", "x", "v", "i", "s", "t" }) do
    for _, map in ipairs(vim.api.nvim_get_keymap(map_mode)) do
      local lhs = normalize(map.lhs or "")
      local desc = map.desc or ""
      lines[#lines + 1] = map_mode .. "\t" .. lhs .. "\t" .. desc
    end
  end
  table.sort(lines)
  return lines
end

local function lhs_key(line)
  local map_mode, lhs = line:match("^([^\t]+)\t([^\t]*)\t")
  if not map_mode then
    return nil
  end
  return map_mode .. "\t" .. lhs
end

if mode == "write" then
  local lines = collect()
  vim.fn.mkdir(vim.fn.fnamemodify(ledger, ":h"), "p")
  vim.fn.writefile(lines, ledger)
  print("LEDGER_WRITTEN " .. #lines)
  return
end

if mode ~= "diff" then
  fail("KEYMAP_CHECK_MODE " .. tostring(mode))
  return
end

if vim.fn.filereadable(ledger) ~= 1 then
  fail("LEDGER_MISSING")
  return
end

local current = collect()
local current_set = {}
local current_lhs = {}
for _, line in ipairs(current) do
  current_set[line] = true
  local key = lhs_key(line)
  if key then
    current_lhs[key] = true
  end
end

local baseline = vim.fn.readfile(ledger)
local baseline_lhs = {}
for _, line in ipairs(baseline) do
  if line ~= "" and not current_set[line] then
    fail("LEDGER_MISSING_LINE " .. line)
    return
  end
  local key = lhs_key(line)
  if key then
    baseline_lhs[key] = true
  end
end

for _, line in ipairs(current) do
  local key = lhs_key(line)
  if key and not baseline_lhs[key] and not allowed_new[key] then
    fail("LEDGER_NEW " .. line)
    return
  end
end

print("LEDGER_OK")
