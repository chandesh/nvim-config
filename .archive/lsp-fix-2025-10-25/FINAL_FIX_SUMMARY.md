# LSP Go-to-Definition Fix - Final Summary

## Changes Applied (Session 2)

### 1. **Added Custom LSP Handlers** (Critical Fix)
**File**: `lua/plugins/lsp.lua` (lines 53-86)

**What**: Custom handlers for `textDocument/definition` and `textDocument/declaration`

**Why**: The default Neovim LSP handlers might not properly jump to locations in all cases. Our custom handlers:
- Explicitly handle error cases with clear messages
- Normalize LocationLink to Location format
- Force jump to the first result
- Show "No locations found" if LSP returns empty results

**Code Added**:
```lua
local function jump_to_first_location(result)
  if not result or (type(result) == 'table' and vim.tbl_isempty(result)) then
    vim.notify("No locations found", vim.log.levels.WARN)
    return
  end
  local loc
  if vim.tbl_islist(result) then
    loc = result[1]
  else
    loc = result
  end
  -- Normalize LocationLink to Location
  if loc.targetUri then
    loc = { uri = loc.targetUri, range = loc.targetSelectionRange or loc.targetRange }
  end
  vim.lsp.util.jump_to_location(loc, "utf-8")
end

vim.lsp.handlers["textDocument/definition"] = function(err, result, ctx, config)
  if err then
    vim.notify("LSP definition error: " .. (err.message or vim.inspect(err)), vim.log.levels.ERROR)
    return
  end
  jump_to_first_location(result)
end

vim.lsp.handlers["textDocument/declaration"] = function(err, result, ctx, config)
  if err then
    vim.notify("LSP declaration error: " .. (err.message or vim.inspect(err)), vim.log.levels.ERROR)
    return
  end
  jump_to_first_location(result)
end
```

### 2. **Debug Logging** (Already in place from Session 1)
**File**: `lua/plugins/lsp.lua` (lines 117-122)

Debug statements that confirm:
- `on_attach` is being called
- Each keymap is being set

### 3. **Previous Fixes** (Session 1)
- Removed duplicate LspAttach autocmd (was causing keymaps to be overwritten)
- Removed excessive notifications
- Cleaned up config structure

## New Tools Created

### 1. **Automated Test Script** - `test-lsp-auto.lua`
Comprehensive automated testing that checks:
- LSP attachment
- Keymap registration
- LSP capabilities
- Hover functionality
- Definition navigation

**Usage**:
```vim
:lua require('test-lsp-auto').run_all_tests()
```

### 2. **Interactive Diagnostic Script** - `lsp-diagnostic.lua`
User-friendly diagnostic tool with detailed output

**Usage**:
```vim
:lua require('lsp-diagnostic').run_full_diagnostic()
```

### 3. **Bash Test Runner** - `run-lsp-test.sh`
Fully automated bash script that:
- Creates test file if needed
- Opens Neovim with test file
- Provides step-by-step instructions
- Collects results
- Provides next steps based on results

**Usage**:
```bash
cd ~/.config/nvim
./run-lsp-test.sh
```

### 4. **Test Files**
- `/tmp/test_lsp_python.py` - Python test file
- `/tmp/test_lsp_typescript.ts` - TypeScript test file

## How to Test

### Quick Method (2 minutes)
```bash
cd ~/.config/nvim
./run-lsp-test.sh
```

Follow the on-screen instructions.

### Manual Method
```bash
# 1. Close all Neovim instances
pkill nvim

# 2. Open test file
nvim /tmp/test_lsp_python.py

# 3. Wait 3-5 seconds, watch for:
#    [LSP] on_attach called: pyright on buffer 1
#    [LSP] Set keymap: gd -> Go to Definition
#    [LSP] Set keymap: gD -> Go to Declaration

# 4. Place cursor on 'hello_world' (line 29)

# 5. Press: gd

# 6. Expected: Jump to line 7 (function definition)
```

### Diagnostic Method
In Neovim:
```vim
:lua require('test-lsp-auto').run_all_tests()

" After 3 seconds, move cursor to a symbol and run:
:lua require('test-lsp-auto').test_definition_programmatic()
```

## What Should Happen

### ✅ Success Scenario
1. **Debug messages appear**:
   ```
   [LSP] on_attach called: pyright on buffer 1
   [LSP] Set keymap: gd -> Go to Definition
   [LSP] Set keymap: gD -> Go to Declaration
   ...
   ```

2. **Pressing `gd` jumps to definition**
3. **No error messages in `:messages`**
4. **Test script reports**: "✓✓✓ SUCCESS: Cursor moved - definition() is WORKING!"

### ⚠️ Partial Success (Keymaps set but not working)
1. **Debug messages appear** (on_attach is called)
2. **Pressing `gd` does nothing** or shows error
3. **Possible causes**:
   - LSP server not responding to definition requests
   - Python environment issue (no venv activated)
   - Symbol not resolvable

**Next steps**:
- Check `:messages` for LSP errors
- Check LSP log: `:edit ~/.local/state/nvim/lsp.log`
- Verify Python venv: `pyenv version`

### ❌ Failure Scenario (on_attach not called)
1. **No debug messages appear**
2. **Keymaps not set**
3. **Possible causes**:
   - LSP server not installed
   - LSP server failed to start
   - Python environment issue preventing Pyright

**Next steps**:
- Check `:Mason` - verify pyright is installed
- Check `:checkhealth lsp`
- Check Python: `pyenv version` and `which python`

## Technical Explanation

### Why the Custom Handlers Fix the Issue

The problem you were experiencing is likely due to one of these LSP protocol edge cases:

1. **LocationLink vs Location**: Some LSP servers return `LocationLink` objects instead of `Location` objects. The default handler might not normalize these properly.

2. **Empty Results**: When LSP returns an empty array, the default handler might not provide feedback.

3. **Multiple Results**: When multiple locations exist, the default handler might try to show a list instead of jumping directly.

Our custom handler:
- Normalizes LocationLink → Location
- Always jumps to the FIRST location
- Provides explicit error/warning messages
- Uses `vim.lsp.util.jump_to_location()` directly (most reliable method)

### Why Debug Logging Matters

The debug logging tells us EXACTLY where the process breaks:
- If we see debug messages → `on_attach` works, keymaps are set
- If we don't see debug messages → `on_attach` never executes (config issue)

This eliminates guesswork.

## Files Modified

| File | Changes | Purpose |
|------|---------|---------|
| `lua/plugins/lsp.lua` | Added custom LSP handlers, debug logging | Fix definition jumping |
| `lua/test-lsp-auto.lua` | New file | Automated testing |
| `lua/lsp-diagnostic.lua` | New file | Interactive diagnostics |
| `run-lsp-test.sh` | New file | Bash test runner |

## Commit Changes

To save these fixes:
```bash
cd ~/.config/nvim
git add lua/plugins/lsp.lua
git add lua/test-lsp-auto.lua
git add lua/lsp-diagnostic.lua
git add run-lsp-test.sh
git commit -m "fix(lsp): add custom handlers for reliable gd/gD navigation

- Add custom textDocument/definition handler
- Add custom textDocument/declaration handler
- Normalize LocationLink to Location format
- Add comprehensive testing tools
- Add debug logging for on_attach"
```

## Next Steps

1. **Run the test**: `./run-lsp-test.sh`
2. **Report results**: Let me know if:
   - ✅ It works!
   - ⚠️ Debug messages appear but gd doesn't work
   - ❌ No debug messages appear

3. **If it works**: Test in your real projects
4. **If it doesn't work**: Share the diagnostic output

## Quick Reference

```bash
# Test script
cd ~/.config/nvim && ./run-lsp-test.sh

# In Neovim - automated test
:lua require('test-lsp-auto').run_all_tests()

# In Neovim - full diagnostic
:lua require('lsp-diagnostic').run_full_diagnostic()

# Check keymaps
:nmap gd
:nmap gD

# Check LSP status
:LspInfo
:checkhealth lsp

# Check messages
:messages

# View LSP log
:edit ~/.local/state/nvim/lsp.log
```

## Support

If issues persist:
1. Run full diagnostic
2. Check `:messages` and LSP log
3. Share output with relevant errors
4. We'll dig deeper based on specific error messages
