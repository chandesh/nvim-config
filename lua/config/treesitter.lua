-- ~/.config/nvim/lua/config/treesitter.lua
-- =============================================================================
-- Treesitter Configuration (Neovim 0.12+)
-- Highlight/indent are built-in; this ensures parsers are installed.
-- =============================================================================

local M = {}

local parsers = {
  "python", "typescript", "tsx", "javascript", "go",
  "html", "htmldjango", "css", "scss", "json",
  "yaml", "lua", "bash", "sql", "markdown", "markdown_inline",
  "dockerfile", "toml", "regex",
}

function M.setup()
  local installed = require('nvim-treesitter.config').get_installed('parsers')
  local to_install = vim.tbl_filter(function(p)
    return not vim.tbl_contains(installed, p)
  end, parsers)

  if #to_install > 0 then
    require('nvim-treesitter').install(to_install)
  end

  vim.api.nvim_create_autocmd('FileType', {
    group = vim.api.nvim_create_augroup('TreesitterStart', { clear = true }),
    callback = function(args)
      if vim.treesitter.language.get_lang(args.match) then
        pcall(vim.treesitter.start, args.buf)
      end
      vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
    end,
  })
end

return M
