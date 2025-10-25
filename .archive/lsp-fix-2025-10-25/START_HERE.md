# 🚀 Quick Start - Test LSP gd/gD Fix

## TL;DR - Run This Now

```bash
cd ~/.config/nvim
./run-lsp-test.sh
```

Follow the on-screen instructions. Takes 2 minutes.

---

## What Was Fixed

1. **Added custom LSP handlers** that force `gd`/`gD` to jump reliably
2. **Added debug logging** to see what's happening
3. **Created automated tests** to verify the fix

---

## Expected Behavior

When you open a Python/TypeScript file:

1. You'll see debug messages:
   ```
   [LSP] on_attach called: pyright on buffer 1
   [LSP] Set keymap: gd -> Go to Definition
   [LSP] Set keymap: gD -> Go to Declaration
   ```

2. Pressing `gd` on a symbol → jumps to definition
3. Pressing `gD` on a symbol → jumps to declaration

---

## If It Works

🎉 **Congrats!** You're done.

Test it in your real projects now.

---

## If It Doesn't Work

### Scenario 1: No Debug Messages
**Problem**: `on_attach` not being called

**Fix**:
```bash
# Check if pyright is installed
nvim +Mason

# Check Python environment
pyenv version
which python
```

### Scenario 2: Debug Messages But gd Doesn't Work
**Problem**: LSP server not responding

**Check**:
```vim
:messages
:edit ~/.local/state/nvim/lsp.log
```

Look for errors related to "textDocument/definition"

### Scenario 3: Still Stuck

Run full diagnostic:
```vim
:lua require('lsp-diagnostic').run_full_diagnostic()
```

Copy the output and share it.

---

## Quick Commands

| Command | What It Does |
|---------|-------------|
| `./run-lsp-test.sh` | Run automated test |
| `:lua require('test-lsp-auto').run_all_tests()` | Test from within Neovim |
| `:nmap gd` | Check if gd keymap exists |
| `:LspInfo` | Check LSP status |
| `:checkhealth lsp` | Full LSP health check |

---

## Files to Know

- **FINAL_FIX_SUMMARY.md** - Detailed explanation of all changes
- **TEST_LSP_INSTRUCTIONS.md** - Step-by-step manual testing
- **QUICK_TEST.md** - 2-minute quick test guide

---

## Need Help?

1. Run: `./run-lsp-test.sh`
2. Share the results (did you see debug messages? did gd work?)
3. Share any errors from `:messages`

That's all I need to help further!
