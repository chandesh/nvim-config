-- ========================================
-- Core Plugins Configuration
-- ========================================

return {
  -- Essential library for many plugins
  {
    "nvim-lua/plenary.nvim",
    lazy = true,
  },

  -- Icons
  {
    "nvim-tree/nvim-web-devicons",
    lazy = true,
  },

  -- Which-key for keybinding hints
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    init = function()
      vim.o.timeout = true
      vim.o.timeoutlen = 300
    end,
    config = function()
      local wk = require("which-key")
      wk.setup({
        preset = "modern",
        delay = 300,
        filter = function(mapping)
          -- example to exclude mappings without a description
          return mapping.desc and mapping.desc ~= ""
        end,
        spec = {},
        notify = true,
        triggers = {
          { "<auto>", mode = "nixsotc" },
          { "a", mode = { "n", "v" } },
        },
      })

      -- Register key mappings (updated for which-key v3)
      wk.add({
        { "<leader>f", group = "file/find" },
        { "<leader>g", group = "git" },
        { "<leader>l", group = "lsp" },
        { "<leader>s", group = "search" },
        { "<leader>t", group = "toggle/tree-sitter" },
        { "<leader>w", group = "windows" },
        { "<leader>x", group = "diagnostics/quickfix" },
        { "<leader>c", group = "code" },
        { "<leader>d", group = "debug" },
        { "<leader><tab>", group = "tabs" },
      })
    end,
  },

  -- Better UI components
  {
    "stevearc/dressing.nvim",
    lazy = true,
    init = function()
      vim.ui.select = function(...)
        require("lazy").load({ plugins = { "dressing.nvim" } })
        return vim.ui.select(...)
      end
      vim.ui.input = function(...)
        require("lazy").load({ plugins = { "dressing.nvim" } })
        return vim.ui.input(...)
      end
    end,
    config = function()
      require("dressing").setup({
        input = {
          enabled = true,
          default_prompt = "Input:",
          prompt_align = "left",
          insert_only = true,
          border = "rounded",
          relative = "cursor",
          prefer_width = 40,
          width = nil,
          max_width = { 140, 0.9 },
          min_width = { 20, 0.2 },
          winblend = 10,
        },
        select = {
          enabled = true,
          backend = { "telescope", "fzf_lua", "fzf", "builtin", "nui" },
          builtin = {
            border = "rounded",
            relative = "editor",
            winblend = 10,
          },
        },
      })
    end,
  },

  -- Notification manager
  {
    "rcarriga/nvim-notify",
    keys = {
      {
        "<leader>un",
        function()
          require("notify").dismiss({ silent = true, pending = true })
        end,
        desc = "Dismiss all Notifications",
      },
    },
    config = function()
      require("notify").setup({
        timeout = 3000,
        max_height = function()
          return math.floor(vim.o.lines * 0.75)
        end,
        max_width = function()
          return math.floor(vim.o.columns * 0.75)
        end,
        background_colour = "#000000",
        render = "default",
        stages = "fade_in_slide_out",
      })
      vim.notify = require("notify")
    end,
  },

  -- Better input/output
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    dependencies = {
      "MunifTanjim/nui.nvim",
      "rcarriga/nvim-notify",
    },
    config = function()
      require("noice").setup({
        lsp = {
          override = {
            ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
            ["vim.lsp.util.stylize_markdown"] = true,
            ["cmp.entry.get_documentation"] = true,
          },
        },
        routes = {
          -- Filter out common LSP progress messages and warnings
          {
            filter = {
              event = "msg_show",
              any = {
                { find = "progress reporting" },
                { find = "TimeoutError" },
                { find = "stubPath.*is not a valid directory" },
              },
            },
            opts = { skip = true },
          },
          {
            filter = {
              event = "msg_show",
              any = {
                { find = "%d+L, %d+B" },
                { find = "; after #%d+" },
                { find = "; before #%d+" },
              },
            },
            view = "mini",
          },
        },
        presets = {
          bottom_search = true,
          command_palette = true,
          long_message_to_split = true,
          inc_rename = false,
          lsp_doc_border = false,
        },
      })
    end,
  },

  -- Session management
  {
    "folke/persistence.nvim",
    event = "BufReadPre",
    config = function()
      require("persistence").setup({
        dir = vim.fn.expand(vim.fn.stdpath("state") .. "/sessions/"),
        options = { "buffers", "curdir", "tabpages", "winsize" },
      })
      vim.keymap.set("n", "<leader>qs", [[<cmd>lua require("persistence").load()<cr>]], { desc = "Restore Session" })
      vim.keymap.set("n", "<leader>ql", [[<cmd>lua require("persistence").load({ last = true })<cr>]], { desc = "Restore Last Session" })
      vim.keymap.set("n", "<leader>qd", [[<cmd>lua require("persistence").stop()<cr>]], { desc = "Don't Save Current Session" })
    end,
  },

  -- Buffer management
  {
    "akinsho/bufferline.nvim",
    event = "VeryLazy",
    keys = {
      { "<leader>bp", "<Cmd>BufferLineTogglePin<CR>", desc = "Toggle pin" },
      { "<leader>bP", "<Cmd>BufferLineGroupClose ungrouped<CR>", desc = "Delete non-pinned buffers" },
      { "<leader>bo", "<Cmd>BufferLineCloseOthers<CR>", desc = "Delete other buffers" },
      { "<leader>br", "<Cmd>BufferLineCloseRight<CR>", desc = "Delete buffers to the right" },
      { "<leader>bl", "<Cmd>BufferLineCloseLeft<CR>", desc = "Delete buffers to the left" },
      { "[b", "<cmd>BufferLineCyclePrev<cr>", desc = "Prev buffer" },
      { "]b", "<cmd>BufferLineCycleNext<cr>", desc = "Next buffer" },
    },
    config = function()
      require("bufferline").setup({
        options = {
          close_command = "bdelete! %d",
          right_mouse_command = "bdelete! %d",
          diagnostics = "nvim_lsp",
          always_show_bufferline = false,
          diagnostics_update_in_insert = false,
          offsets = {
            {
              filetype = "neo-tree",
              text = "Neo-tree",
              highlight = "Directory",
              text_align = "left",
            },
          },
        },
      })
    end,
  },

  -- Better buffer deletion
  {
    "echasnovski/mini.bufremove",
    keys = {
      { "<leader>bd", function() require("mini.bufremove").delete(0, false) end, desc = "Delete Buffer" },
      { "<leader>bD", function() require("mini.bufremove").delete(0, true) end, desc = "Delete Buffer (Force)" },
    },
    config = function()
      require("mini.bufremove").setup()
    end,
  },
}
