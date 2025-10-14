-- ========================================
-- File History and Versioning Configuration
-- ========================================

return {
  -- Enhanced undo tree visualization
  {
    "mbbill/undotree",
    keys = {
      { "<leader>u", "<cmd>UndotreeToggle<cr>", desc = "Toggle Undotree" },
    },
    config = function()
      -- Undotree configuration
      vim.g.undotree_WindowLayout = 2
      vim.g.undotree_SplitWidth = 40
      vim.g.undotree_SetFocusWhenToggle = 1
      vim.g.undotree_TreeNodeShape = '◉'
      vim.g.undotree_TreeVertShape = '│'
      vim.g.undotree_TreeSplitShape = '╱'
      vim.g.undotree_TreeReturnShape = '╲'
      vim.g.undotree_DiffAutoOpen = 1
      vim.g.undotree_DiffpanelHeight = 10
      vim.g.undotree_RelativeTimestamp = 1
      vim.g.undotree_HighlightChangedText = 1
      vim.g.undotree_HighlightSyntaxAdd = "DiffAdd"
      vim.g.undotree_HighlightSyntaxChange = "DiffChange"
      vim.g.undotree_HighlightSyntaxDel = "DiffDelete"
      
      -- Enable persistent undo
      vim.opt.undofile = true
      vim.opt.undodir = vim.fn.stdpath("data") .. "/undo"
      vim.opt.undolevels = 10000
      vim.opt.undoreload = 10000
      
      -- Create undo directory if it doesn't exist
      local undo_dir = vim.fn.stdpath("data") .. "/undo"
      if vim.fn.isdirectory(undo_dir) == 0 then
        vim.fn.mkdir(undo_dir, "p")
      end
    end,
  },

  -- Git commit browser and history (avoids conflicts with your existing git keybindings)
  {
    "junegunn/gv.vim",
    dependencies = { "tpope/vim-fugitive" },
    cmd = { "GV" },
    keys = {
      { "<leader>gv", "<cmd>GV<cr>", desc = "Git commit browser" },
      { "<leader>gV", "<cmd>GV!<cr>", desc = "Git commits for current file" }, -- Using capital V to avoid conflicts
      { "<leader>go", "<cmd>GV --oneline<cr>", desc = "Git commits (oneline)" }, -- Using 'o' for oneline
    },
  },

  -- Auto-save with smart triggers
  {
    "okuuva/auto-save.nvim",
    event = { "InsertEnter", "TextChanged" },
    config = function()
      require("auto-save").setup({
        enabled = true,
        trigger_events = {
          immediate_save = { "BufLeave", "FocusLost" },
          defer_save = { "InsertLeave", "TextChanged" },
          cancel_defered_save = { "InsertEnter" },
        },
        condition = function(buf)
          local fn = vim.fn
          local utils = require("auto-save.utils.data")
          
          -- Don't auto-save if file is not modifiable
          if fn.getbufvar(buf, "&modifiable") ~= 1 then
            return false
          end
          
          -- Don't auto-save for certain filetypes
          local filetype = fn.getbufvar(buf, "&filetype")
          local excluded_filetypes = {
            "oil",
            "alpha",
            "dashboard",
            "neo-tree",
            "Trouble",
            "trouble",
            "lazy",
            "mason",
            "notify",
            "toggleterm",
            "lazyterm",
            "fugitive",
            "gitcommit",
            "gitrebase",
          }
          
          if utils.not_in(filetype, excluded_filetypes) then
            return true
          end
          return false
        end,
        write_all_buffers = false,
        debounce_delay = 1000, -- 1 second
        execution_message = {
          enabled = true,
          message = function()
            return ("AutoSave: saved at " .. vim.fn.strftime("%H:%M:%S"))
          end,
          dim = 0.18,
          cleaning_interval = 1250,
        },
        callbacks = {
          enabling = nil,
          disabling = nil,
          before_asserting_save = nil,
          before_saving = nil,
          after_saving = function()
            -- Optional: Create a git commit for auto-saved files
            -- Uncomment the lines below if you want automatic commits
            -- WARNING: This will create many commits!
            
            -- local handle = io.popen("git rev-parse --is-inside-work-tree 2>/dev/null")
            -- local result = handle and handle:read("*l") or ""
            -- if handle then handle:close() end
            -- 
            -- if result == "true" then
            --   vim.fn.system("git add . && git commit -m 'Auto-save: " .. vim.fn.strftime("%Y-%m-%d %H:%M:%S") .. "' > /dev/null 2>&1 &")
            -- end
          end
        },
      })
    end,
  },

  -- Enhanced backup system
  {
    "rmagatti/goto-preview",
    config = function()
      require('goto-preview').setup({
        width = 120,
        height = 25,
        default_mappings = false,
        debug = false,
        opacity = nil,
        post_open_hook = nil
      })
      
      -- Keymaps for preview (avoiding conflicts with your existing keybindings)
      vim.keymap.set("n", "gpd", "<cmd>lua require('goto-preview').goto_preview_definition()<CR>", {desc = "Preview definition"})
      vim.keymap.set("n", "gpt", "<cmd>lua require('goto-preview').goto_preview_type_definition()<CR>", {desc = "Preview type definition"})
      vim.keymap.set("n", "gpi", "<cmd>lua require('goto-preview').goto_preview_implementation()<CR>", {desc = "Preview implementation"})
      vim.keymap.set("n", "gpD", "<cmd>lua require('goto-preview').goto_preview_declaration()<CR>", {desc = "Preview declaration"})
      vim.keymap.set("n", "gP", "<cmd>lua require('goto-preview').close_all_win()<CR>", {desc = "Close all preview windows"})
      vim.keymap.set("n", "gpr", "<cmd>lua require('goto-preview').goto_preview_references()<CR>", {desc = "Preview references"})
    end
  },

  -- History and version management keymaps (avoiding conflicts)
  {
    "folke/which-key.nvim",
    optional = true,
    opts = {
      spec = {
        { "<leader>h", group = "history" },
        { "<leader>hf", group = "file history" },
      },
    },
  },
}