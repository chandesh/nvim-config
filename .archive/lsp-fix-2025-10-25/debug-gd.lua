-- Debug script to check gd/gD behavior and LSP status
local M = {}

function M.check_keymaps()
  print("=== Checking gd/gD keymaps ===")
  
  -- Check current buffer's keymaps
  local buf = vim.api.nvim_get_current_buf()
  local keymaps_gd = vim.api.nvim_buf_get_keymap(buf, 'n')
  
  print("\nBuffer-local keymaps:")
  for _, map in ipairs(keymaps_gd) do
    if map.lhs == 'gd' or map.lhs == 'gD' then
      print(string.format("  %s -> %s (callback: %s)", 
        map.lhs, 
        map.rhs or "no rhs", 
        map.callback and "yes" or "no"))
    end
  end
  
  -- Check global keymaps
  local global_keymaps = vim.api.nvim_get_keymap('n')
  print("\nGlobal keymaps:")
  for _, map in ipairs(global_keymaps) do
    if map.lhs == 'gd' or map.lhs == 'gD' then
      print(string.format("  %s -> %s (callback: %s)", 
        map.lhs, 
        map.rhs or "no rhs", 
        map.callback and "yes" or "no"))
    end
  end
end

function M.check_lsp()
  print("\n=== Checking LSP status ===")
  
  local buf = vim.api.nvim_get_current_buf()
  local clients = vim.lsp.get_clients({ bufnr = buf })
  
  if #clients == 0 then
    print("No LSP clients attached to current buffer")
    return
  end
  
  for _, client in ipairs(clients) do
    print(string.format("\nClient: %s (id: %d)", client.name, client.id))
    print("  Capabilities:")
    print(string.format("    definitionProvider: %s", 
      client.server_capabilities.definitionProvider and "yes" or "no"))
    print(string.format("    declarationProvider: %s", 
      client.server_capabilities.declarationProvider and "yes" or "no"))
    print(string.format("    implementationProvider: %s", 
      client.server_capabilities.implementationProvider and "yes" or "no"))
    print(string.format("    referencesProvider: %s", 
      client.server_capabilities.referencesProvider and "yes" or "no"))
  end
end

function M.test_definition()
  print("\n=== Testing vim.lsp.buf.definition() ===")
  local word = vim.fn.expand("<cword>")
  print("Word under cursor: " .. word)
  
  -- Get current position
  local pos = vim.api.nvim_win_get_cursor(0)
  print(string.format("Current position: line %d, col %d", pos[1], pos[2]))
  
  -- Try to go to definition
  print("\nAttempting to go to definition...")
  vim.lsp.buf.definition()
end

function M.full_diagnostic()
  M.check_lsp()
  M.check_keymaps()
  print("\n=== To test definition, use :lua require('debug-gd').test_definition() ===")
end

return M
