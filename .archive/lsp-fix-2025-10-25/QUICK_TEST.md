# Quick LSP Test - 2 Minutes

## 1. Restart Neovim
```bash
pkill nvim && nvim /tmp/test_lsp_python.py
```

## 2. Watch for Debug Messages
You should see:
```
[LSP] on_attach called: pyright on buffer 1
[LSP] Set keymap: gd -> Go to Definition
[LSP] Set keymap: gD -> Go to Declaration
...
```

✅ **If you see these**: Keymaps are being set (good!)
❌ **If you don't**: on_attach is not being called (problem!)

## 3. Test `gd` Keymap
1. Place cursor on `hello_world` (line 29)
2. Press `gd`
3. Did cursor jump to line 7? **YES / NO**

## 4. If Broken - Run Diagnostic
```vim
:lua require('lsp-diagnostic').run_full_diagnostic()
```

**Copy and paste the output here:**
```
[paste output]
```

## 5. Check Messages
```vim
:messages
```

**Any LSP errors?**
```
[paste errors if any]
```

---

## That's it! Report back with:
- ✅/❌ Saw debug messages on startup
- ✅/❌ `gd` works
- Output from diagnostic (if broken)
- Any error messages
