# LSP Go-to-Definition Fix - Investigation Summary

## Changes Applied

### 1. Removed Duplicate LSP Attachment Logic (Previous Session)
**Problem**: Your config had duplicate `on_attach` calls via LspAttach autocmd
**Fix**: Removed the redundant autocmd (lines 332-361 in lsp.lua)

### 2. Added Debug Logging (Current Session)
**Addition**: Added debug print statements to:
- Confirm `on_attach` is being called
- Confirm each keymap is being set
- Help diagnose where the flow breaks

## Files Modified

1. **`lua/plugins/lsp.lua`**:
   - Removed duplicate LspAttach autocmd
   - Removed excessive notifications
   - Added debug logging to `on_attach` function

## New Diagnostic Tools Created

1. **`lua/lsp-diagnostic.lua`** - Comprehensive diagnostic script
   - Checks keymaps (gd/gD) in all modes
   - Verifies LSP client attachment and capabilities
   - Tests LSP functions (hover, definition)
   - Checks for conflicting plugins
   - Reviews messages and LSP log

2. **`/tmp/test_lsp_python.py`** - Test Python file
3. **`/tmp/test_lsp_typescript.ts`** - Test TypeScript file
4. **`TEST_LSP_INSTRUCTIONS.md`** - Step-by-step testing guide

## Current Status: NEEDS TESTING

The config has been fixed based on common LSP keymap issues, but we need you to test it to confirm the fix works.

## Next Steps for You

### Step 1: Restart Neovim
```bash
# Completely close Neovim
pkill nvim

# Start fresh with test file
nvim /tmp/test_lsp_python.py
```

### Step 2: Check Debug Output
When Neovim opens, you should see debug messages like:
```
[LSP] on_attach called: pyright on buffer 1
[LSP] Set keymap: gd -> Go to Definition
[LSP] Set keymap: gD -> Go to Declaration
[LSP] Set keymap: gi -> Go to Implementation
...
```

**If you DON'T see these messages**: The `on_attach` function is not being called - this is the root cause.

**If you DO see these messages**: The keymaps are being set, but definition might not be working for other reasons.

### Step 3: Test gd Keymap
1. Place cursor on `hello_world` (line 29)
2. Press `gd`
3. **Expected**: Cursor jumps to line 7 (function definition)

**Result**: (Did it work? Yes/No)

### Step 4: If Still Broken - Run Full Diagnostic
```vim
:lua require('lsp-diagnostic').run_full_diagnostic()
```

Copy and paste the entire output.

### Step 5: Test Definition Function Directly
```vim
" Place cursor on hello_world again
:lua vim.lsp.buf.definition()
```

**Result**: (Did cursor move? Yes/No)

---

## Possible Root Causes (Based on Common Issues)

### Scenario A: on_attach Never Called
**Symptoms**: No debug messages appear
**Cause**: LSP server not attaching, or on_attach not passed to setup
**Solution**: Check that mason-lspconfig is working, LSP server is installed

### Scenario B: Keymaps Set But Don't Work
**Symptoms**: Debug messages appear, but `gd` does nothing
**Causes**:
1. Another plugin/keymap overriding `gd` after LSP sets it
2. LSP server doesn't support definition (unlikely for pyright/ts_ls)
3. LSP communication issue (server crash, wrong buffer, etc.)

### Scenario C: vim.lsp.buf.definition() Doesn't Work
**Symptoms**: Even manual `:lua vim.lsp.buf.definition()` doesn't jump
**Causes**:
1. LSP server not responding to textDocument/definition requests
2. LSP server crashed or not properly initialized
3. Python environment issues (for pyright)
4. Symbol not resolvable (e.g., builtin function)

### Scenario D: Works in Test File, Broken in Real Project
**Symptoms**: `gd` works in /tmp files, fails in project
**Causes**:
1. Project-specific LSP configuration issue
2. LSP server can't find dependencies/imports
3. Python virtual environment not activated (for Python projects)

---

## Quick Commands Reference

```vim
" Check if keymaps exist
:nmap gd
:nmap gD

" Check LSP clients attached
:lua =vim.lsp.get_clients()

" Test definition manually
:lua vim.lsp.buf.definition()

" Run full diagnostic
:lua require('lsp-diagnostic').run_full_diagnostic()

" Test with logging
:lua require('lsp-diagnostic').test_definition_with_logging()

" Check recent messages
:messages

" View LSP log
:edit ~/.local/state/nvim/lsp.log

" Check LSP info
:LspInfo
```

---

## What to Report Back

Please provide:

1. **Debug output when opening test file**
   - Did you see `[LSP] on_attach called` messages?
   - Did you see `[LSP] Set keymap` messages?

2. **Test results**:
   - Does `gd` work? (Yes/No)
   - Does `:lua vim.lsp.buf.definition()` work? (Yes/No)
   - Does `K` (hover) work? (Yes/No)

3. **Output from diagnostic script**:
   ```vim
   :lua require('lsp-diagnostic').run_full_diagnostic()
   ```

4. **Any error messages from**:
   - `:messages`
   - `:LspInfo`

5. **Test in your real project**:
   - Does it work in your actual Python/TypeScript projects?
   - Or only in the test files?

---

## If Still Broken After Testing

If the issue persists after following the testing instructions:

1. **Share the diagnostic output** (from step 4 above)
2. **Try the minimal config test** (Phase 5 in TEST_LSP_INSTRUCTIONS.md)
3. **Check `:checkhealth lsp`** output
4. **Verify LSP servers are installed**: `:Mason` and check for pyright, ts_ls

This will help pinpoint whether it's:
- A configuration issue
- A plugin conflict
- An LSP server issue
- An environment/installation issue
