-- ~/.config/nvim/lua/config/lang/typescript.lua
-- =============================================================================
-- TypeScript / JavaScript / Angular Logic
-- Handles tsc.nvim for type checking and autotag for JSX/TSX.
-- =============================================================================

local setup_done = false

vim.api.nvim_create_autocmd('FileType', {
  group = vim.api.nvim_create_augroup('TypeScriptExtras', { clear = true }),
  pattern = { 'typescript', 'typescriptreact', 'javascript', 'javascriptreact' },
  callback = function()
    if not setup_done then
      vim.cmd('packadd tsc.nvim')
      vim.cmd('packadd nvim-ts-autotag')

      -- Configure tsc.nvim for asynchronous type checking
      require('tsc').setup({
        always_run_at_start = false,
        on_close_diagnostics = false,
      })

      require('nvim-ts-autotag').setup()
      setup_done = true
    end
  end,
})
