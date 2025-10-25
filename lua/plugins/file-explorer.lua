return {
  "nvim-tree/nvim-tree.lua",
  dependencies = "nvim-tree/nvim-web-devicons",
  config = function()
    local nvimtree = require("nvim-tree")

    -- recommended settings from nvim-tree documentation
    vim.g.loaded_netrw = 1
    vim.g.loaded_netrwPlugin = 1

    nvimtree.setup({
      view = {
        width = 30,
        relativenumber = false,
      },
      renderer = {
        indent_markers = {
          enable = true,
        },
        icons = {
          glyphs = {
            folder = {
              arrow_closed = "", -- arrow when folder is closed
              arrow_open = "", -- arrow when folder is open
            },
          },
        },
      },
      actions = {
        open_file = {
          window_picker = {
            enable = false,
          },
        },
        change_dir = {
          enable = true,
          global = false, -- only change nvim-tree root, not vim's cwd
          restrict_above_cwd = false,
        },
      },
      filters = {
        custom = {
          ".DS_Store",
          "*.pyc",
          "__pycache__",
          ".python-version",
          ".pytest_cache",
          ".ruff_cache",
          "logs",
        },
        dotfiles = false,
      },
      git = {
        ignore = false,
      },
      -- Ensure nvim-tree respects current working directory
      update_focused_file = {
        enable = true,
        update_root = false, -- don't auto-change root to follow file
        ignore_list = {},
      },
      hijack_directories = {
        enable = true,
        auto_open = true,
      },
    })

    -- Keymaps
    local keymap = vim.keymap
    -- Toggle with current working directory as root
    keymap.set("n", "<leader>ee", function()
      local api = require("nvim-tree.api")
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
      local api = require("nvim-tree.api")
      api.tree.change_root(vim.fn.getcwd())
      vim.notify("NvimTree root changed to: " .. vim.fn.getcwd(), vim.log.levels.INFO)
    end, { desc = "Root tree to working directory" })
  end,
}
