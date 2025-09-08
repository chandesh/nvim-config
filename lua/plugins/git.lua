-- ========================================
-- Git Integration Configuration
-- ========================================

return {
  -- Git signs in the sign column
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require("gitsigns").setup({
        signs = {
          add = { text = "▎" },
          change = { text = "▎" },
          delete = { text = "" },
          topdelete = { text = "" },
          changedelete = { text = "▎" },
          untracked = { text = "▎" },
        },
        signs_staged = {
          add = { text = "▎" },
          change = { text = "▎" },
          delete = { text = "" },
          topdelete = { text = "" },
          changedelete = { text = "▎" },
        },
        on_attach = function(buffer)
          local gs = package.loaded.gitsigns

          local function map(mode, l, r, desc)
            vim.keymap.set(mode, l, r, { buffer = buffer, desc = desc })
          end

          -- Navigation
          map("n", "]h", gs.next_hunk, "Next Hunk")
          map("n", "[h", gs.prev_hunk, "Prev Hunk")
          map("n", "]H", function() gs.nav_hunk("last") end, "Last Hunk")
          map("n", "[H", function() gs.nav_hunk("first") end, "First Hunk")

          -- Actions
          map({ "n", "v" }, "<leader>ghs", ":Gitsigns stage_hunk<CR>", "Stage Hunk")
          map({ "n", "v" }, "<leader>ghr", ":Gitsigns reset_hunk<CR>", "Reset Hunk")
          map("n", "<leader>ghS", gs.stage_buffer, "Stage Buffer")
          map("n", "<leader>ghu", gs.undo_stage_hunk, "Undo Stage Hunk")
          map("n", "<leader>ghR", gs.reset_buffer, "Reset Buffer")
          map("n", "<leader>ghp", gs.preview_hunk, "Preview Hunk")
          map("n", "<leader>ghb", function() gs.blame_line({ full = true }) end, "Blame Line")
          map("n", "<leader>ghd", gs.diffthis, "Diff This")
          map("n", "<leader>ghD", function() gs.diffthis("~") end, "Diff This ~")

          -- Text object
          map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", "GitSigns Select Hunk")
        end,
        preview_config = {
          border = "rounded",
          style = "minimal",
          relative = "cursor",
          row = 0,
          col = 1,
        },
        current_line_blame = true,
        current_line_blame_opts = {
          virt_text = true,
          virt_text_pos = "eol",
          delay = 1000,
          ignore_whitespace = false,
        },
        current_line_blame_formatter = "<author>, <author_time:%Y-%m-%d> - <summary>",
        update_debounce = 200,
        max_file_length = 40000,
        watch_gitdir = {
          follow_files = true,
        },
        attach_to_untracked = true,
        sign_priority = 6,
        status_formatter = nil,
      })
    end,
  },

  -- Advanced git operations
  {
    "tpope/vim-fugitive",
    cmd = {
      "G",
      "Git",
      "Gdiffsplit",
      "Gread",
      "Gwrite",
      "Ggrep",
      "GMove",
      "GDelete",
      "GBrowse",
      "GRemove",
      "GRename",
      "Glgrep",
      "Gedit",
    },
    ft = { "fugitive" },
    keys = {
      { "<leader>gg", "<cmd>Git<cr>", desc = "Git status" },
      { "<leader>gG", "<cmd>Git ++curwin<cr>", desc = "Git status (current window)" },
      { "<leader>gd", "<cmd>Gdiffsplit<cr>", desc = "Git diff" },
      { "<leader>gc", "<cmd>Git commit<cr>", desc = "Git commit" },
      { "<leader>gC", "<cmd>Git commit --amend<cr>", desc = "Git commit amend" },
      { "<leader>gp", "<cmd>Git push<cr>", desc = "Git push" },
      { "<leader>gP", "<cmd>Git pull<cr>", desc = "Git pull" },
      { "<leader>gb", "<cmd>Git blame<cr>", desc = "Git blame" },
      { "<leader>gl", "<cmd>Git log --oneline<cr>", desc = "Git log" },
      { "<leader>gL", "<cmd>Git log<cr>", desc = "Git log (detailed)" },
      { "<leader>gf", "<cmd>Git fetch<cr>", desc = "Git fetch" },
      { "<leader>gr", "<cmd>Git rebase<cr>", desc = "Git rebase" },
      { "<leader>gR", "<cmd>Git rebase --interactive<cr>", desc = "Git rebase interactive" },
      { "<leader>gm", "<cmd>Git merge<cr>", desc = "Git merge" },
      { "<leader>ga", "<cmd>Git add %<cr>", desc = "Git add current file" },
      { "<leader>gA", "<cmd>Git add .<cr>", desc = "Git add all" },
    },
  },

  -- Git blame and history
  {
    "f-person/git-blame.nvim",
    event = "BufReadPre",
    config = function()
      vim.g.gitblame_enabled = 0 -- Disable by default, toggle with <leader>gb
      vim.g.gitblame_message_template = "<summary> • <date> • <author>"
      vim.g.gitblame_date_format = "%r"
      vim.g.gitblame_display_virtual_text = 0 -- Use floating window instead
      
      vim.keymap.set("n", "<leader>gb", "<cmd>GitBlameToggle<cr>", { desc = "Toggle Git Blame" })
      vim.keymap.set("n", "<leader>gB", "<cmd>GitBlameOpenCommitURL<cr>", { desc = "Open commit URL" })
    end,
  },

  -- Enhanced diff view
  {
    "sindrets/diffview.nvim",
    cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewToggleFiles", "DiffviewFocusFiles" },
    keys = {
      { "<leader>gdo", "<cmd>DiffviewOpen<cr>", desc = "Open Diffview" },
      { "<leader>gdc", "<cmd>DiffviewClose<cr>", desc = "Close Diffview" },
      { "<leader>gdh", "<cmd>DiffviewFileHistory<cr>", desc = "File History" },
      { "<leader>gdH", "<cmd>DiffviewFileHistory %<cr>", desc = "Current File History" },
    },
    config = function()
      require("diffview").setup({
        diff_binaries = false,
        enhanced_diff_hl = false,
        git_cmd = { "git" },
        use_icons = true,
        show_help_hints = true,
        watch_index = true,
        icons = {
          folder_closed = "",
          folder_open = "",
        },
        signs = {
          fold_closed = "",
          fold_open = "",
          done = "✓",
        },
        view = {
          default = {
            layout = "diff2_horizontal",
            winbar_info = false,
          },
          merge_tool = {
            layout = "diff3_horizontal",
            disable_diagnostics = true,
            winbar_info = true,
          },
          file_history = {
            layout = "diff2_horizontal",
            winbar_info = false,
          },
        },
        file_panel = {
          listing_style = "tree",
          tree_options = {
            flatten_dirs = true,
            folder_statuses = "only_folded",
          },
          win_config = {
            position = "left",
            width = 35,
            win_opts = {}
          },
        },
        file_history_panel = {
          log_options = {
            git = {
              single_file = {
                diff_merges = "combined",
              },
              multi_file = {
                diff_merges = "first-parent",
              },
            },
          },
          win_config = {
            position = "bottom",
            height = 16,
            win_opts = {}
          },
        },
        commit_log_panel = {
          win_config = {
            win_opts = {},
          }
        },
        default_args = {
          DiffviewOpen = {},
          DiffviewFileHistory = {},
        },
        hooks = {},
        keymaps = {
          disable_defaults = false,
          view = {
            { "n", "<tab>",       require("diffview.actions").select_next_entry,         { desc = "Open the diff for the next file" } },
            { "n", "<s-tab>",     require("diffview.actions").select_prev_entry,         { desc = "Open the diff for the previous file" } },
            { "n", "gf",          require("diffview.actions").goto_file_edit,           { desc = "Open the file in the previous tabpage" } },
            { "n", "<C-w><C-f>",  require("diffview.actions").goto_file_split,          { desc = "Open the file in a new split" } },
            { "n", "<C-w>gf",     require("diffview.actions").goto_file_tab,            { desc = "Open the file in a new tabpage" } },
            { "n", "<leader>e",   require("diffview.actions").focus_files,              { desc = "Bring focus to the file panel" } },
            { "n", "<leader>b",   require("diffview.actions").toggle_files,             { desc = "Toggle the file panel." } },
            { "n", "g<C-x>",      require("diffview.actions").cycle_layout,             { desc = "Cycle through available layouts." } },
            { "n", "[x",          require("diffview.actions").prev_conflict,            { desc = "In the merge-tool: jump to the previous conflict" } },
            { "n", "]x",          require("diffview.actions").next_conflict,            { desc = "In the merge-tool: jump to the next conflict" } },
            { "n", "<leader>co",  require("diffview.actions").conflict_choose("ours"),   { desc = "Choose the OURS version of a conflict" } },
            { "n", "<leader>ct",  require("diffview.actions").conflict_choose("theirs"), { desc = "Choose the THEIRS version of a conflict" } },
            { "n", "<leader>cb",  require("diffview.actions").conflict_choose("base"),   { desc = "Choose the BASE version of a conflict" } },
            { "n", "<leader>ca",  require("diffview.actions").conflict_choose("all"),    { desc = "Choose all the versions of a conflict" } },
            { "n", "dx",          require("diffview.actions").conflict_choose("none"),   { desc = "Delete the conflict region" } },
          },
          file_panel = {
            { "n", "j",              require("diffview.actions").next_entry,           { desc = "Bring the cursor to the next file entry" } },
            { "n", "<down>",         require("diffview.actions").next_entry,           { desc = "Bring the cursor to the next file entry" } },
            { "n", "k",              require("diffview.actions").prev_entry,           { desc = "Bring the cursor to the previous file entry" } },
            { "n", "<up>",           require("diffview.actions").prev_entry,           { desc = "Bring the cursor to the previous file entry" } },
            { "n", "<cr>",           require("diffview.actions").select_entry,         { desc = "Open the diff for the selected entry" } },
            { "n", "o",              require("diffview.actions").select_entry,         { desc = "Open the diff for the selected entry" } },
            { "n", "l",              require("diffview.actions").select_entry,         { desc = "Open the diff for the selected entry" } },
            { "n", "<2-LeftMouse>",  require("diffview.actions").select_entry,         { desc = "Open the diff for the selected entry" } },
            { "n", "-",              require("diffview.actions").toggle_stage_entry,   { desc = "Stage / unstage the selected entry" } },
            { "n", "S",              require("diffview.actions").stage_all,            { desc = "Stage all entries" } },
            { "n", "U",              require("diffview.actions").unstage_all,          { desc = "Unstage all entries" } },
            { "n", "X",              require("diffview.actions").restore_entry,        { desc = "Restore entry to the state on the left side" } },
            { "n", "L",              require("diffview.actions").open_commit_log,      { desc = "Open the commit log panel" } },
            { "n", "zo",             require("diffview.actions").open_fold,            { desc = "Expand fold" } },
            { "n", "h",              require("diffview.actions").close_fold,           { desc = "Collapse fold" } },
            { "n", "zc",             require("diffview.actions").close_fold,           { desc = "Collapse fold" } },
            { "n", "za",             require("diffview.actions").toggle_fold,          { desc = "Toggle fold" } },
            { "n", "zR",             require("diffview.actions").open_all_folds,       { desc = "Expand all folds" } },
            { "n", "zM",             require("diffview.actions").close_all_folds,      { desc = "Collapse all folds" } },
            { "n", "<c-b>",          require("diffview.actions").scroll_view(-0.25),   { desc = "Scroll the view up" } },
            { "n", "<c-f>",          require("diffview.actions").scroll_view(0.25),    { desc = "Scroll the view down" } },
            { "n", "<tab>",          require("diffview.actions").select_next_entry,    { desc = "Open the diff for the next file" } },
            { "n", "<s-tab>",        require("diffview.actions").select_prev_entry,    { desc = "Open the diff for the previous file" } },
            { "n", "gf",             require("diffview.actions").goto_file_edit,       { desc = "Open the file in the previous tabpage" } },
            { "n", "<C-w><C-f>",     require("diffview.actions").goto_file_split,      { desc = "Open the file in a new split" } },
            { "n", "<C-w>gf",        require("diffview.actions").goto_file_tab,        { desc = "Open the file in a new tabpage" } },
            { "n", "i",              require("diffview.actions").listing_style,        { desc = "Toggle between 'list' and 'tree' views" } },
            { "n", "f",              require("diffview.actions").toggle_flatten_dirs,  { desc = "Flatten empty subdirectories in tree listing style" } },
            { "n", "R",              require("diffview.actions").refresh_files,        { desc = "Update stats and entries in the file list" } },
            { "n", "<leader>e",      require("diffview.actions").focus_files,          { desc = "Bring focus to the file panel" } },
            { "n", "<leader>b",      require("diffview.actions").toggle_files,         { desc = "Toggle the file panel" } },
            { "n", "g<C-x>",         require("diffview.actions").cycle_layout,         { desc = "Cycle through available layouts" } },
            { "n", "[x",             require("diffview.actions").prev_conflict,        { desc = "Go to the previous conflict" } },
            { "n", "]x",             require("diffview.actions").next_conflict,        { desc = "Go to the next conflict" } },
          },
          file_history_panel = {
            { "n", "g!",            require("diffview.actions").options,            { desc = "Open the option panel" } },
            { "n", "<C-A-d>",       require("diffview.actions").open_in_diffview,   { desc = "Open the entry under the cursor in a diffview" } },
            { "n", "y",             require("diffview.actions").copy_hash,          { desc = "Copy the commit hash of the entry under the cursor" } },
            { "n", "L",             require("diffview.actions").open_commit_log,    { desc = "Show commit details" } },
            { "n", "zR",            require("diffview.actions").open_all_folds,     { desc = "Expand all folds" } },
            { "n", "zM",            require("diffview.actions").close_all_folds,    { desc = "Collapse all folds" } },
            { "n", "j",             require("diffview.actions").next_entry,         { desc = "Bring the cursor to the next file entry" } },
            { "n", "<down>",        require("diffview.actions").next_entry,         { desc = "Bring the cursor to the next file entry" } },
            { "n", "k",             require("diffview.actions").prev_entry,         { desc = "Bring the cursor to the previous file entry." } },
            { "n", "<up>",          require("diffview.actions").prev_entry,         { desc = "Bring the cursor to the previous file entry." } },
            { "n", "<cr>",          require("diffview.actions").select_entry,       { desc = "Open the diff for the selected entry." } },
            { "n", "o",             require("diffview.actions").select_entry,       { desc = "Open the diff for the selected entry." } },
            { "n", "<2-LeftMouse>", require("diffview.actions").select_entry,       { desc = "Open the diff for the selected entry." } },
            { "n", "<c-b>",         require("diffview.actions").scroll_view(-0.25), { desc = "Scroll the view up" } },
            { "n", "<c-f>",         require("diffview.actions").scroll_view(0.25),  { desc = "Scroll the view down" } },
            { "n", "<tab>",         require("diffview.actions").select_next_entry,  { desc = "Open the diff for the next file" } },
            { "n", "<s-tab>",       require("diffview.actions").select_prev_entry,  { desc = "Open the diff for the previous file" } },
            { "n", "gf",            require("diffview.actions").goto_file_edit,     { desc = "Open the file in the previous tabpage" } },
            { "n", "<C-w><C-f>",    require("diffview.actions").goto_file_split,    { desc = "Open the file in a new split" } },
            { "n", "<C-w>gf",       require("diffview.actions").goto_file_tab,      { desc = "Open the file in a new tabpage" } },
            { "n", "<leader>e",     require("diffview.actions").focus_files,        { desc = "Bring focus to the file panel" } },
            { "n", "<leader>b",     require("diffview.actions").toggle_files,       { desc = "Toggle the file panel" } },
            { "n", "g<C-x>",        require("diffview.actions").cycle_layout,       { desc = "Cycle through available layouts" } },
          },
          option_panel = {
            { "n", "<tab>", require("diffview.actions").select_entry,          { desc = "Change the current option" } },
            { "n", "q",     require("diffview.actions").close,                 { desc = "Close the panel" } },
            { "n", "o",     require("diffview.actions").select_entry,          { desc = "Change the current option" } },
            { "n", "<cr>",  require("diffview.actions").select_entry,          { desc = "Change the current option" } },
          },
          help_panel = {
            { "n", "q",     require("diffview.actions").close, { desc = "Close help menu" } },
            { "n", "<esc>", require("diffview.actions").close, { desc = "Close help menu" } },
          },
        },
      })
    end,
  },

  -- Git conflict resolution
  {
    "akinsho/git-conflict.nvim",
    event = "BufReadPre",
    config = function()
      require("git-conflict").setup({
        default_mappings = true,
        default_commands = true,
        disable_diagnostics = false,
        list_opener = 'copen',
        highlights = {
          incoming = 'DiffAdd',
          current = 'DiffText',
        }
      })

      -- Keymaps for conflict resolution
      vim.keymap.set('n', '<leader>gco', '<cmd>GitConflictChooseOurs<cr>', { desc = 'Choose Ours' })
      vim.keymap.set('n', '<leader>gct', '<cmd>GitConflictChooseTheirs<cr>', { desc = 'Choose Theirs' })
      vim.keymap.set('n', '<leader>gcb', '<cmd>GitConflictChooseBoth<cr>', { desc = 'Choose Both' })
      vim.keymap.set('n', '<leader>gc0', '<cmd>GitConflictChooseNone<cr>', { desc = 'Choose None' })
      vim.keymap.set('n', ']x', '<cmd>GitConflictNextConflict<cr>', { desc = 'Next Conflict' })
      vim.keymap.set('n', '[x', '<cmd>GitConflictPrevConflict<cr>', { desc = 'Previous Conflict' })
      vim.keymap.set('n', '<leader>gcl', '<cmd>GitConflictListQf<cr>', { desc = 'List Conflicts' })
    end,
  },
}
