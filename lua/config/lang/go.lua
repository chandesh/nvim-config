-- ~/.config/nvim/lua/config/lang/go.lua
-- =============================================================================
-- Go Language Logic
-- Integration with gopher.nvim for a complete Go environment.
-- =============================================================================

vim.api.nvim_create_autocmd('FileType', {
  group = vim.api.nvim_create_augroup('GoExtras', { clear = true }),
  pattern = 'go',
  callback = function()
    vim.cmd('packadd gopher.nvim')

    require('gopher').setup({
      go_imports = true,
      go_test_func = 'Test',
      go_test_args = { '-v', '-run', 'Test' },
    })
  end,
})
