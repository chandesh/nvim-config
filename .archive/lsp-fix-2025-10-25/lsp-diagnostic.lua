-- Comprehensive LSP Diagnostic Script
-- Usage: :lua require('lsp-diagnostic').run_full_diagnostic()

local M = {}

-- ANSI colors for better output readability
local function header(text)
  print("\n" .. string.rep("=", 60))
  print("  " .. text)
  print(string.rep("=", 60))
end

local function subheader(text)
  print("\n--- " .. text .. " ---")
end

local function success(text)
  print("✓ " .. text)
end

local function warning(text)
  print("⚠ " .. text)
end

local function error_msg(text)
  print("✗ " .. text)
end

local function info(text)
  print("  " .. text)
end

-- 1. Check keymaps for gd and gD
function M.check_keymaps()
  header("STEP 1: Checking gd/gD Keymaps")
  
  local buf = vim.api.nvim_get_current_buf()
  local modes = {'n', 'v'}
  
  for _, mode in ipairs(modes) do
    subheader(mode:upper() .. " Mode Keymaps")
    
    -- Buffer-local keymaps
    local buf_keymaps = vim.api.nvim_buf_get_keymap(buf, mode)
    local found_gd = false
    local found_gD = false
    
    for _, map in ipairs(buf_keymaps) do
      if map.lhs == 'gd' then
        found_gd = true
        success("Buffer-local 'gd' found")
        info(string.format("  RHS: %s", map.rhs or "no rhs"))
        info(string.format("  Callback: %s", map.callback and "yes" or "no"))
        info(string.format("  Desc: %s", map.desc or "no description"))
      end
      if map.lhs == 'gD' then
        found_gD = true
        success("Buffer-local 'gD' found")
        info(string.format("  RHS: %s", map.rhs or "no rhs"))
        info(string.format("  Callback: %s", map.callback and "yes" or "no"))
        info(string.format("  Desc: %s", map.desc or "no description"))
      end
    end
    
    if not found_gd then
      error_msg("Buffer-local 'gd' NOT FOUND in " .. mode .. " mode")
    end
    if not found_gD then
      error_msg("Buffer-local 'gD' NOT FOUND in " .. mode .. " mode")
    end
    
    -- Global keymaps
    local global_keymaps = vim.api.nvim_get_keymap(mode)
    for _, map in ipairs(global_keymaps) do
      if map.lhs == 'gd' and not found_gd then
        warning("Global 'gd' found (should be buffer-local)")
        info(string.format("  RHS: %s", map.rhs or "no rhs"))
      end
      if map.lhs == 'gD' and not found_gD then
        warning("Global 'gD' found (should be buffer-local)")
        info(string.format("  RHS: %s", map.rhs or "no rhs"))
      end
    end
  end
end

-- 2. Check LSP client attachment and capabilities
function M.check_lsp_clients()
  header("STEP 2: LSP Client Status")
  
  local buf = vim.api.nvim_get_current_buf()
  local clients = vim.lsp.get_clients({ bufnr = buf })
  
  if #clients == 0 then
    error_msg("NO LSP clients attached to current buffer!")
    info("Filetype: " .. vim.bo.filetype)
    info("Buffer: " .. buf)
    return false
  end
  
  success(string.format("%d LSP client(s) attached", #clients))
  
  for _, client in ipairs(clients) do
    subheader("Client: " .. client.name .. " (ID: " .. client.id .. ")")
    
    local caps = client.server_capabilities
    
    -- Check critical capabilities
    local critical_caps = {
      {"definitionProvider", caps.definitionProvider},
      {"declarationProvider", caps.declarationProvider},
      {"implementationProvider", caps.implementationProvider},
      {"referencesProvider", caps.referencesProvider},
      {"hoverProvider", caps.hoverProvider},
    }
    
    for _, cap_info in ipairs(critical_caps) do
      local cap_name, cap_value = cap_info[1], cap_info[2]
      if cap_value then
        if cap_value == true then
          success(cap_name .. ": ✓")
        else
          success(cap_name .. ": " .. vim.inspect(cap_value))
        end
      else
        warning(cap_name .. ": NOT SUPPORTED")
      end
    end
  end
  
  return true
end

-- 3. Test LSP functions manually
function M.test_lsp_functions()
  header("STEP 3: Testing LSP Functions")
  
  local word = vim.fn.expand("<cword>")
  local pos = vim.api.nvim_win_get_cursor(0)
  
  info(string.format("Word under cursor: '%s'", word))
  info(string.format("Position: line %d, col %d", pos[1], pos[2]))
  
  if word == "" then
    error_msg("No word under cursor! Place cursor on a symbol first.")
    return
  end
  
  -- Test hover (non-intrusive)
  subheader("Testing vim.lsp.buf.hover()")
  local hover_success = pcall(function()
    vim.lsp.buf.hover()
  end)
  if hover_success then
    success("hover() executed without error")
  else
    error_msg("hover() failed")
  end
  
  -- We won't auto-test definition as it moves the cursor
  subheader("Manual test needed for vim.lsp.buf.definition()")
  info("Run this command: :lua vim.lsp.buf.definition()")
  info("Expected: cursor should jump to definition")
  info("If it doesn't move, there's an LSP communication issue")
end

-- 4. Check vim.lsp.buf.definition behavior with detailed logging
function M.test_definition_with_logging()
  header("STEP 4: Testing Definition with Detailed Logging")
  
  local word = vim.fn.expand("<cword>")
  if word == "" then
    error_msg("No word under cursor! Place cursor on a symbol first.")
    return
  end
  
  info(string.format("Testing definition for: '%s'", word))
  
  -- Store current position
  local before_pos = vim.api.nvim_win_get_cursor(0)
  local before_buf = vim.api.nvim_get_current_buf()
  
  info(string.format("Before: buf=%d, line=%d, col=%d", before_buf, before_pos[1], before_pos[2]))
  
  -- Enable debug logging temporarily
  local original_level = vim.lsp.log.get_level()
  vim.lsp.log.set_level("DEBUG")
  
  -- Try definition
  info("Calling vim.lsp.buf.definition()...")
  local success_call, result = pcall(function()
    vim.lsp.buf.definition()
  end)
  
  if not success_call then
    error_msg("definition() call failed with error: " .. tostring(result))
    vim.lsp.log.set_level(original_level)
    return
  end
  
  -- Wait a moment for async operation
  vim.defer_fn(function()
    local after_pos = vim.api.nvim_win_get_cursor(0)
    local after_buf = vim.api.nvim_get_current_buf()
    
    info(string.format("After: buf=%d, line=%d, col=%d", after_buf, after_pos[1], after_pos[2]))
    
    if before_buf ~= after_buf or before_pos[1] ~= after_pos[1] or before_pos[2] ~= after_pos[2] then
      success("CURSOR MOVED - definition() is working!")
    else
      error_msg("CURSOR DID NOT MOVE - definition() is NOT working")
      warning("Check :messages for LSP errors")
      warning("Check LSP log: " .. vim.lsp.get_log_path())
    end
    
    vim.lsp.log.set_level(original_level)
  end, 500)
end

-- 5. Check recent messages and LSP log
function M.check_messages_and_logs()
  header("STEP 5: Recent Messages")
  
  info("Recent vim messages (last 10):")
  local messages = vim.api.nvim_exec2("messages", { output = true }).output
  local lines = vim.split(messages, "\n")
  local recent = {}
  for i = math.max(1, #lines - 10), #lines do
    table.insert(recent, lines[i])
  end
  for _, line in ipairs(recent) do
    info(line)
  end
  
  subheader("LSP Log Location")
  info("Log file: " .. vim.lsp.get_log_path())
  info("To view: :edit " .. vim.lsp.get_log_path())
  info("To tail: :terminal tail -f " .. vim.lsp.get_log_path())
end

-- 6. Check for conflicting plugins
function M.check_potential_conflicts()
  header("STEP 6: Checking for Potential Conflicts")
  
  -- Check for common LSP-related plugins that might interfere
  local plugins_to_check = {
    "lspsaga",
    "navigator",
    "navic",
    "nvim-navbuddy",
  }
  
  for _, plugin in ipairs(plugins_to_check) do
    local ok = pcall(require, plugin)
    if ok then
      warning(plugin .. " is loaded (might override keymaps)")
    else
      info(plugin .. " not loaded")
    end
  end
end

-- Main diagnostic function
function M.run_full_diagnostic()
  print("\n\n")
  print("╔" .. string.rep("═", 58) .. "╗")
  print("║" .. string.rep(" ", 10) .. "LSP DIAGNOSTIC TOOL" .. string.rep(" ", 29) .. "║")
  print("╚" .. string.rep("═", 58) .. "╝")
  
  M.check_keymaps()
  local has_lsp = M.check_lsp_clients()
  
  if has_lsp then
    M.test_lsp_functions()
    M.check_potential_conflicts()
    M.check_messages_and_logs()
    
    print("\n")
    subheader("Next Steps")
    info("1. Review the output above for any errors (✗) or warnings (⚠)")
    info("2. Test definition manually: :lua require('lsp-diagnostic').test_definition_with_logging()")
    info("3. If still broken, check LSP log: :edit " .. vim.lsp.get_log_path())
  end
  
  print("\n" .. string.rep("=", 60) .. "\n")
end

-- Quick test for definition on current word
function M.quick_test()
  M.test_definition_with_logging()
end

return M
