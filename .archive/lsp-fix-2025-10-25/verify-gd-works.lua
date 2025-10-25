-- Verification script: Test gd actually jumps to definition
-- Run from command line: nvim -l verify-gd-works.lua

-- Minimal init to load our config
vim.opt.runtimepath:prepend(vim.fn.stdpath("data") .. "/lazy/lazy.nvim")

-- Load just the LSP config
require("lazy").setup("plugins", { performance = { rtp = { reset = false }}})

-- Wait for plugins to load
vim.defer_fn(function()
  -- Open test file
  vim.cmd('edit /tmp/test_lsp_python.py')
  
  print("=== Verification Test ===")
  print("File: /tmp/test_lsp_python.py")
  
  -- Wait for LSP to attach
  vim.defer_fn(function()
    local buf = vim.api.nvim_get_current_buf()
    local clients = vim.lsp.get_clients({ bufnr = buf })
    
    print("\n✓ LSP Clients: " .. #clients)
    for _, client in ipairs(clients) do
      print("  - " .. client.name)
    end
    
    -- Check keymaps
    local keymaps = vim.api.nvim_buf_get_keymap(buf, 'n')
    local has_gd = false
    for _, map in ipairs(keymaps) do
      if map.lhs == 'gd' then
        has_gd = true
        break
      end
    end
    
    if has_gd then
      print("\n✓ gd keymap is set")
    else
      print("\n✗ gd keymap NOT set")
      vim.cmd('qall! 1')
      return
    end
    
    -- Go to line 29 (hello_world function call)
    vim.cmd('29')
    vim.cmd('normal! w')  -- Move to hello_world
    
    local before_line = vim.fn.line('.')
    local word = vim.fn.expand('<cword>')
    
    print("\nTesting gd navigation:")
    print("  Current line: " .. before_line)
    print("  Word under cursor: " .. word)
    
    -- Try definition
    vim.lsp.buf.definition()
    
    -- Check after delay
    vim.defer_fn(function()
      local after_line = vim.fn.line('.')
      
      print("\n  After gd:")
      print("    Line: " .. after_line)
      
      if after_line ~= before_line then
        print("\n✓✓✓ SUCCESS! Cursor moved from line " .. before_line .. " to " .. after_line)
        print("✓✓✓ gd/gD IS WORKING!")
      else
        print("\n✗✗✗ FAILED: Cursor did not move")
        print("Check :messages for errors")
      end
      
      vim.cmd('qall!')
    end, 1000)
  end, 5000)
end, 1000)

-- Keep running
vim.cmd('aunmenu *')  -- Disable menus for clean output
