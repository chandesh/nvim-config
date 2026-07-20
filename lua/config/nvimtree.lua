-- ~/.config/nvim/lua/config/nvimtree.lua
-- =============================================================================
-- NvimTree Configuration
-- High-performance file explorer with custom filtering.
-- =============================================================================

local M = {}

function M.setup()
  -- Disable netrw to avoid conflicts
  vim.g.loaded_netrw = 1
  vim.g.loaded_netrwPlugin = 1

  require('nvim-tree').setup({
    sort_by = "case_sensitive",
    view = {
      width = 30,
      side = "left",
    },
    filters = {
      custom = { 
        "__pycache__", ".pyc", "node_modules", ".git", "dist", ".next" 
      },
    },
    git = {
      enable = true,
      ignore = false,
    },
    renderer = {
      indent_markers = { enable = true },
      highlight_opened_files = "all",
      icons = {
        glyphs = {
          folder = {
            arrow_closed = ' ',
            arrow_open = ' ',
          },
        },
      },
    },
    actions = {
      open_file = {
        window_picker = { enable = false },
      },
      change_dir = {
        enable = true,
        global = false,
        restrict_above_cwd = false,
      },
    },
    update_focused_file = {
      enable = true,
      update_root = false,
      ignore_list = {},
    },
    hijack_directories = {
      enable = true,
      auto_open = true,
    },
  })

  -- NvimTree keymaps (matches backup)
  local api = require("nvim-tree.api")
  local keymap = vim.keymap

  keymap.set("n", "<leader>ee", function()
    if api.tree.is_visible() then
      api.tree.close()
    else
      api.tree.open({ path = vim.fn.getcwd() })
    end
  end, { desc = "Toggle file explorer (cwd)" })

  keymap.set("n", "<leader>ef", "<cmd>NvimTreeFindFileToggle<CR>", { desc = "Toggle file explorer on current file" })
  keymap.set("n", "<leader>ec", "<cmd>NvimTreeCollapse<CR>", { desc = "Collapse file explorer" })
  keymap.set("n", "<leader>er", "<cmd>NvimTreeRefresh<CR>", { desc = "Refresh file explorer" })
  keymap.set("n", "<leader>ew", function()
    api.tree.change_root(vim.fn.getcwd())
    vim.notify("NvimTree root changed to: " .. vim.fn.getcwd(), vim.log.levels.INFO)
  end, { desc = "Root tree to working directory" })
end

return M
