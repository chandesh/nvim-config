# LSP Keymap Fixes - Summary

## Problem
`gd` and `gD` were not working properly - they were navigating to import lines instead of actual function definitions.

## Root Cause
The LSP `on_attach` function was being stored in a global variable (`vim.g.nvim_lsp_on_attach`) but mason-lspconfig was trying to use it before it was defined, causing keymaps to never be set.

## Solution Applied

### 1. Fixed Configuration Order
- Moved Python environment detection before `on_attach` definition
- Defined `on_attach` function before mason-lspconfig setup
- Moved mason-lspconfig setup into the lspconfig config function
- This ensures `on_attach` is available when servers are configured

### 2. Updated LSP Keymaps

| Keymap | Action | Notes |
|--------|--------|-------|
| `gd` | Go to Definition | Works with all LSP servers |
| `gD` | Go to Declaration | Falls back to definition if not supported |
| `gi` | Go to Implementation | Standard LSP navigation |
| `gy` | Go to Type Definition | **Changed from `gt`** to avoid conflict with default "go to next tab" |
| `gr` | Go to References | Show all references |
| `K` | Hover Documentation | Standard LSP hover |
| `<C-k>` | Signature Help | Function signature hints |

### 3. Which-Key Integration
Added which-key registration so LSP keymaps show up in the which-key menu with `[LSP]` prefix for easy identification.

### 4. Tab Navigation Preserved
- Default Vim `gt` (go to next tab) and `gT` (go to previous tab) remain functional
- Additional tab navigation available via:
  - `<leader><tab>]` - Next tab
  - `<leader><tab>[` - Previous tab
  - `<leader>tn` - Next tab
  - `<leader>tp` - Previous tab

## Files Modified
1. `/Users/chandesh/.config/nvim/lua/plugins/lsp.lua` - Main LSP configuration
2. `/Users/chandesh/.config/nvim/lua/debug-gd.lua` - Created diagnostic helper

## Testing Commands

### Check if LSP is attached and keymaps are set:
```vim
:lua require('debug-gd').full_diagnostic()
```

### Test navigation:
1. Open a Python/TypeScript file
2. Place cursor on a function call
3. Press `gd` - should jump to definition
4. Press `gD` - should jump to declaration
5. Press `gr` - should show references
6. Press `gy` - should show type definition

### Expected Output:
```
=== Checking LSP status ===
Client: pyright (id: 2)
  Capabilities:
    definitionProvider: yes
    declarationProvider: yes
    implementationProvider: no
    referencesProvider: yes

=== Checking gd/gD keymaps ===
Buffer-local keymaps:
  gd -> no rhs (callback: yes)
  gD -> no rhs (callback: yes)
  gi -> no rhs (callback: yes)
  gy -> no rhs (callback: yes)
  gr -> no rhs (callback: yes)
```

## Next Steps
1. Restart Neovim: `nvim`
2. Open a Python or TypeScript file
3. You should see "LSP attached: pyright" notification
4. Press `g` to see all g-prefixed keymaps in which-key menu
5. Test `gd` and `gD` on function calls

## Troubleshooting

### If keymaps still don't show:
```vim
:LspInfo
:checkhealth lsp
:lua =vim.lsp.get_clients()
```

### If LSP doesn't attach:
- Check Python environment is activated
- Verify LSP server is installed: `:Mason`
- Check for errors: `:messages`

### Force reload configuration:
```vim
:source ~/.config/nvim/init.lua
:LspRestart
```
