-- ~/.config/nvim/lua/config/copilot.lua
-- =============================================================================
-- Copilot AI Integration — Native LSP (Neovim 0.12+)
-- Uses vim.lsp.config + vim.lsp.enable + vim.lsp.inline_completion
-- =============================================================================

local M = {}

function M.setup()
  vim.lsp.config('copilot', {
    cmd = { 'copilot-language-server', '--stdio' },
    root_markers = { '.git' },
    init_options = {
      editorInfo = {
        name = 'Neovim',
        version = tostring(vim.version()),
      },
      editorPluginInfo = {
        name = 'Neovim',
        version = tostring(vim.version()),
      },
    },
  })

  vim.lsp.enable('copilot')
  vim.lsp.inline_completion.enable()
end

return M
