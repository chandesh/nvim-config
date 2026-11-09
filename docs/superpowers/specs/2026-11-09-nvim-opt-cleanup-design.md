# Neovim opt-cleanup and 2026 plugin gaps

## Intent

Make the existing Neovim 0.12 config cheaper to start and cheaper to redraw, delete dead duplication, and add the three missing daily-driver plugins. Do this without changing a key the user already has, and without dropping a feature that currently works.

## Goals

- Heavy plugins leave `pack/*/start` and load on the event that needs them.
- One installer pull flag, one Python project resolver, one `gd` implementation, one session setup table.
- Statusline and navic stop doing `require` / full context walks on every redraw.
- Add neotest, CopilotChat, and nvim-treesitter-context.
- Restore `angularls` and `tailwindcss`, which the README already claims.

## Non-goals

- Migrating to lazy.nvim or calling `vim.pack.add`.
- Changing `updatetime`, `colorcolumn`, `relativenumber`, or gitsigns `current_line_blame`.
- Removing which-key. Snacks does not draw the leader menu; the comments that say it does are stale.
- Adding `dartls` to Mason. flutter-tools owns it.
- Adding `copilot.lua` or `copilot.vim`. Inline Copilot stays the existing `vim.lsp.enable('copilot')` plus blink-copilot client.
- Enabling CopilotChat tool auto-approval (`trusted_tools = true`).
- Adding lazydev.nvim. Out of this pass.

## Constraints

- Do not break existing functionality.
- Do not override an existing keybinding. A change to the rhs of `<leader>pv` is the one allowed repair: the lhs and desc stay, the dead `swenv` require becomes venv-selector.
- Before any new keymap is written, re-run the ledger check from the plan. If a proposed lhs is already mapped, stop. Do not pick a different key.
- `s` stays `<nop>`. `<Tab>`, `<S-Tab>`, `<CR>`, and `<C-space>` stay blink's. `<C-s>` stays save. `<F5>` `<F10>` `<F11>` `<F12>` stay dart-buffer DAP. `<leader>fl*` stays Flutter. `<leader>tt` stays the Pyright diagnostic toggle.
- Do not remap bare `a` or `i`. Insert stays on `i`. Append stays on bare `a` when the leader was not pressed.
- `<leader>a` must be mapped to `<Nop>` in normal and visual before any `<leader>a*` child is added. It must not be `nowait`. An unmapped `<leader>a` falls through to builtin `a` (append), which enters insert mode, and every following key is then text, not a leader map. `timeoutlen` is 300. which-key 3.17 uses `<auto>` triggers, so an unknown key after `<leader>` is also fed through as a normal command.

## Approach

Stay on the current registry (`lua/config/plugins.lua`) and `packadd` opt plugins on the event that needs them. lazy.nvim would be a second loader on top of `pkg_manager.lua`, `install.sh`, and `update.sh`. `vim.pack.add` would be a fourth. Neither is required to get event loading.

which-key stays in `start`. Its plugin script was 0.039 ms. Removing it would delete the leader menu.

## New keys (audited 2026-11-09, no matches in `*.lua`)

These are the only new global keymaps this work may add.

| Mode | Lhs | Owner |
|---|---|---|
| n, x | `<leader>a` | Prefix only. `<Nop>`, desc `AI`. Not nowait. Never `startinsert`. which-key group `AI`. |
| n | `<leader>aa` | CopilotChat toggle |
| n, x | `<leader>ae` | CopilotChat explain |
| n | `<leader>aq` | CopilotChat quick chat |
| n | `<leader>tr` | Neotest nearest |
| n | `<leader>tF` | Neotest file |
| n | `<leader>tS` | Neotest summary |
| n | `<leader>tl` | Neotest last |
| n | `<leader>tq` | Neotest stop |
| n | `<leader>td` | Neotest debug nearest |
| n | `<leader>js` | Flash jump only |
| n | `[c` | Previous treesitter context |
| n | `]c` | Next treesitter context |

Occupied chords that look similar and must not be reused: `<leader>tt`, `<leader>tc`, `<leader>tC`, `<leader>to`, `<leader>tx`, `<leader>tn`, `<leader>tp`, `<leader>tv`, `<leader>term`, `<leader>T`, `<leader>jt`, `<leader>ca`, `<leader>cd`, `<leader>cr`, `<leader>cf`, `<leader>ci`, `<leader>sw`, `<leader>sr`, `<leader>sm`.
