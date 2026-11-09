-- ~/.config/nvim/lua/config/treesitter_context.lua
-- =============================================================================
-- nvim-treesitter-context — sticky scope header window.
-- The plugin is an opt plugin and is packadded on the first supported FileType
-- and on first use of [c / ]c.
-- =============================================================================

local M = {}

local loaded = false

local function ensure()
  if loaded then
    return require('treesitter-context')
  end

  vim.cmd('packadd nvim-treesitter-context')
  loaded = true
  return require('treesitter-context')
end

M.ensure = ensure

function M.setup()
  vim.keymap.set('n', '[c', function()
    ensure().go_to_context(vim.v.count1)
  end, { desc = 'Previous context' })

  -- The installed clone only exposes an upward go_to_context(depth); there is
  -- no downward API. Keep the paired key on the same documented direction.
  vim.keymap.set('n', ']c', function()
    ensure().go_to_context(vim.v.count1)
  end, { desc = 'Next context' })

  -- config.treesitter.setup() runs first and registers the Tree-sitter
  -- FileType handler, so by this point vim.treesitter.start has been tried.
  -- get_lang() falls back to the filetype for unknown types, so also require
  -- a loadable parser before pulling the plugin in.
  vim.api.nvim_create_autocmd('FileType', {
    group = vim.api.nvim_create_augroup('TreesitterContextLoad', { clear = true }),
    callback = function(args)
      local lang = vim.treesitter.language.get_lang(args.match)
      if not lang then
        return
      end
      local ok, loaded_parser = pcall(vim.treesitter.language.add, lang)
      if not ok or not loaded_parser then
        return
      end
      ensure()
    end,
  })
end

return M
