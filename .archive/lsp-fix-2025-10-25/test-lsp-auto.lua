-- Automated LSP Testing Script
-- This script tests gd/gD functionality programmatically

local M = {}

-- Test results storage
local results = {
  on_attach_called = false,
  keymaps_set = {},
  lsp_attached = false,
  definition_works = false,
  hover_works = false,
  errors = {},
}

function M.setup_test_environment()
  print("=" .. string.rep("=", 60))
  print("  Automated LSP Testing")
  print("=" .. string.rep("=", 60))
  
  -- Override print to capture debug messages
  local original_print = print
  _G.test_capture_print = function(...)
    local args = {...}
    local msg = table.concat(vim.tbl_map(tostring, args), " ")
    
    -- Check for debug messages
    if msg:match("%[LSP%] on_attach called") then
      results.on_attach_called = true
      original_print("[✓] " .. msg)
    elseif msg:match("%[LSP%] Set keymap") then
      local keymap = msg:match("Set keymap: (%S+)")
      if keymap then
        results.keymaps_set[keymap] = true
      end
      original_print("[✓] " .. msg)
    else
      original_print(msg)
    end
  end
end

function M.test_lsp_attachment()
  print("\n--- Test 1: LSP Attachment ---")
  
  local buf = vim.api.nvim_get_current_buf()
  local clients = vim.lsp.get_clients({ bufnr = buf })
  
  if #clients > 0 then
    results.lsp_attached = true
    print("[✓] LSP attached: " .. #clients .. " client(s)")
    for _, client in ipairs(clients) do
      print("    - " .. client.name)
    end
  else
    print("[✗] NO LSP clients attached")
    table.insert(results.errors, "No LSP clients attached to buffer")
  end
  
  return results.lsp_attached
end

function M.test_keymaps()
  print("\n--- Test 2: Keymap Verification ---")
  
  local buf = vim.api.nvim_get_current_buf()
  local keymaps = vim.api.nvim_buf_get_keymap(buf, 'n')
  
  local found_gd = false
  local found_gD = false
  
  for _, map in ipairs(keymaps) do
    if map.lhs == 'gd' then
      found_gd = true
      print("[✓] gd keymap exists: " .. (map.desc or "no description"))
    elseif map.lhs == 'gD' then
      found_gD = true
      print("[✓] gD keymap exists: " .. (map.desc or "no description"))
    end
  end
  
  if not found_gd then
    print("[✗] gd keymap NOT FOUND")
    table.insert(results.errors, "gd keymap not set")
  end
  
  if not found_gD then
    print("[✗] gD keymap NOT FOUND")
    table.insert(results.errors, "gD keymap not set")
  end
  
  return found_gd and found_gD
end

function M.test_lsp_capabilities()
  print("\n--- Test 3: LSP Capabilities ---")
  
  local buf = vim.api.nvim_get_current_buf()
  local clients = vim.lsp.get_clients({ bufnr = buf })
  
  if #clients == 0 then
    print("[✗] No clients to test capabilities")
    return false
  end
  
  for _, client in ipairs(clients) do
    local caps = client.server_capabilities
    print("Client: " .. client.name)
    
    if caps.definitionProvider then
      print("  [✓] definitionProvider: supported")
    else
      print("  [✗] definitionProvider: NOT supported")
      table.insert(results.errors, client.name .. " doesn't support definition")
    end
    
    if caps.declarationProvider then
      print("  [✓] declarationProvider: supported")
    else
      print("  [⚠] declarationProvider: NOT supported (will fallback to definition)")
    end
    
    if caps.hoverProvider then
      print("  [✓] hoverProvider: supported")
    else
      print("  [⚠] hoverProvider: NOT supported")
    end
  end
  
  return true
end

function M.test_hover()
  print("\n--- Test 4: Hover Function ---")
  
  local success, err = pcall(function()
    vim.lsp.buf.hover()
  end)
  
  if success then
    print("[✓] vim.lsp.buf.hover() executed without error")
    results.hover_works = true
    return true
  else
    print("[✗] vim.lsp.buf.hover() failed: " .. tostring(err))
    table.insert(results.errors, "hover failed: " .. tostring(err))
    return false
  end
end

function M.test_definition_programmatic()
  print("\n--- Test 5: Definition Function (Programmatic) ---")
  print("Testing vim.lsp.buf.definition() on current word...")
  
  local word = vim.fn.expand("<cword>")
  if word == "" then
    print("[⚠] No word under cursor - move to a symbol first")
    return false
  end
  
  print("Target word: '" .. word .. "'")
  
  local before_pos = vim.api.nvim_win_get_cursor(0)
  local before_buf = vim.api.nvim_get_current_buf()
  
  print(string.format("Before: buf=%d, line=%d, col=%d", before_buf, before_pos[1], before_pos[2]))
  
  local success, err = pcall(function()
    vim.lsp.buf.definition()
  end)
  
  if not success then
    print("[✗] vim.lsp.buf.definition() threw error: " .. tostring(err))
    table.insert(results.errors, "definition threw error: " .. tostring(err))
    return false
  end
  
  print("[✓] vim.lsp.buf.definition() executed without error")
  print("Waiting 500ms for async response...")
  
  -- Schedule check after async operation
  vim.defer_fn(function()
    local after_pos = vim.api.nvim_win_get_cursor(0)
    local after_buf = vim.api.nvim_get_current_buf()
    
    print(string.format("After: buf=%d, line=%d, col=%d", after_buf, after_pos[1], after_pos[2]))
    
    if before_buf ~= after_buf or before_pos[1] ~= after_pos[1] or before_pos[2] ~= after_pos[2] then
      print("[✓✓✓] SUCCESS: Cursor moved - definition() is WORKING!")
      results.definition_works = true
    else
      print("[✗✗✗] FAILED: Cursor did not move - definition() is NOT working")
      table.insert(results.errors, "definition did not move cursor")
    end
    
    M.print_summary()
  end, 500)
  
  return true
end

function M.print_summary()
  print("\n" .. string.rep("=", 60))
  print("  TEST SUMMARY")
  print(string.rep("=", 60))
  
  print("\n[Results]")
  print("  on_attach called:  " .. (results.on_attach_called and "✓ YES" or "✗ NO"))
  print("  LSP attached:      " .. (results.lsp_attached and "✓ YES" or "✗ NO"))
  print("  gd keymap set:     " .. (results.keymaps_set['gd'] and "✓ YES" or "✗ NO"))
  print("  gD keymap set:     " .. (results.keymaps_set['gD'] and "✓ YES" or "✗ NO"))
  print("  hover() works:     " .. (results.hover_works and "✓ YES" or "✗ NO"))
  print("  definition() works: " .. (results.definition_works and "✓ YES" or "✗ NO"))
  
  if #results.errors > 0 then
    print("\n[Errors Detected]")
    for i, err in ipairs(results.errors) do
      print("  " .. i .. ". " .. err)
    end
  else
    print("\n[✓] No errors detected")
  end
  
  print("\n" .. string.rep("=", 60))
  
  -- Overall verdict
  if results.definition_works then
    print("  ✓✓✓ OVERALL: gd/gD IS WORKING! ✓✓✓")
  else
    print("  ✗✗✗ OVERALL: gd/gD IS BROKEN ✗✗✗")
    print("\n  Next steps:")
    print("  1. Check :messages for LSP errors")
    print("  2. Check LSP log: " .. vim.lsp.get_log_path())
    print("  3. Run :checkhealth lsp")
  end
  print(string.rep("=", 60) .. "\n")
end

function M.run_all_tests()
  M.setup_test_environment()
  
  print("\nWaiting 3 seconds for LSP to attach...")
  vim.defer_fn(function()
    M.test_lsp_attachment()
    M.test_keymaps()
    M.test_lsp_capabilities()
    M.test_hover()
    
    print("\n[Action Required]")
    print("Place cursor on a function name (e.g., hello_world on line 29)")
    print("Then run: :lua require('test-lsp-auto').test_definition_programmatic()")
  end, 3000)
end

return M
