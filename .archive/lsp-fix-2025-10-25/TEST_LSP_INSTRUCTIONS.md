# LSP Go-to-Definition Testing Instructions

## Phase 1: Run the Diagnostic Script

1. **Restart Neovim completely**:
   ```bash
   # Close all Neovim instances
   pkill nvim
   
   # Start fresh
   nvim /tmp/test_lsp_python.py
   ```

2. **Wait for LSP to attach** (should take 2-5 seconds)
   - You should see a notification about Pyright attaching

3. **Run the diagnostic script**:
   ```vim
   :lua require('lsp-diagnostic').run_full_diagnostic()
   ```

4. **Review the output** and note:
   - ✗ Any errors (things that are broken)
   - ⚠ Any warnings (things that might be issues)
   - ✓ Things that are working correctly

5. **Paste the full output** into your response

---

## Phase 2: Manual Testing of Individual Components

### Test 1: Check Keymaps Explicitly

In the test Python file, run:
```vim
:nmap gd
:nmap gD
```

**Expected output**:
- Should show buffer-local mappings to LSP functions
- Example: `gd    * Go to Definition`

**Paste the actual output**

---

### Test 2: Test LSP Hover (Non-intrusive)

1. Place cursor on `hello_world` (line 29 in test file)
2. Press `K` (capital K)

**Expected**: A hover window should appear showing the function definition

**Result**: Did hover window appear? (Yes/No)

---

### Test 3: Test Definition Manually

1. Place cursor on `hello_world` (line 29 in test file)
2. Run:
   ```vim
   :lua vim.lsp.buf.definition()
   ```

**Expected**: Cursor should jump to line 7 (function definition)

**Result**: 
- Did cursor move? (Yes/No)
- If yes, what line did it jump to?
- If no, check `:messages` - paste any LSP errors

---

### Test 4: Test Definition with Logging

1. Place cursor on `hello_world` again (line 29)
2. Run:
   ```vim
   :lua require('lsp-diagnostic').test_definition_with_logging()
   ```

3. Wait 1 second for results

**Paste the output**

---

### Test 5: Check LSP Capabilities

Run:
```vim
:lua =vim.lsp.get_clients()[1].server_capabilities.definitionProvider
```

**Expected**: Should print `true`

**Paste the actual output**

---

### Test 6: Check for LSP Errors in Messages

Run:
```vim
:messages
```

**Look for**:
- Any lines starting with "LSP"
- Any error messages
- Any warnings

**Paste any relevant messages**

---

## Phase 3: Test with TypeScript (if Python works)

Repeat tests 2-4 with the TypeScript test file:
```bash
nvim /tmp/test_lsp_typescript.ts
```

---

## Phase 4: Check LSP Log

If definition still doesn't work:

1. Open the LSP log:
   ```vim
   :edit ~/.local/state/nvim/lsp.log
   ```

2. Go to the end of the file: `G`

3. Look for recent errors related to "textDocument/definition"

4. **Paste any relevant error messages**

---

## Phase 5: Minimal Config Test (if still broken)

Create a minimal test config:

```bash
# Save your current config
mv ~/.config/nvim ~/.config/nvim.backup

# Create minimal config
mkdir -p ~/.config/nvim/lua
```

Create `~/.config/nvim/init.lua`:
```lua
-- Minimal LSP config for testing
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  {
    "neovim/nvim-lspconfig",
    config = function()
      local lspconfig = require("lspconfig")
      
      -- Simple on_attach
      local on_attach = function(client, bufnr)
        vim.keymap.set("n", "gd", vim.lsp.buf.definition, { buffer = bufnr })
        vim.keymap.set("n", "K", vim.lsp.buf.hover, { buffer = bufnr })
        print("LSP attached: " .. client.name)
      end
      
      -- Setup pyright
      lspconfig.pyright.setup({
        on_attach = on_attach,
      })
      
      -- Setup ts_ls
      lspconfig.ts_ls.setup({
        on_attach = on_attach,
      })
    end,
  },
})

print("Minimal config loaded")
```

Test:
```bash
nvim /tmp/test_lsp_python.py
```

Does `gd` work now? (Yes/No)

If yes: **The issue is in your full config**
If no: **The issue might be with LSP installation or environment**

---

## What to Report Back

Please provide:
1. Output from Phase 1 (diagnostic script)
2. Results from all tests in Phase 2
3. Any error messages from `:messages` or `lsp.log`
4. Whether the minimal config test worked (Phase 5)

This will help identify the exact failure point.
