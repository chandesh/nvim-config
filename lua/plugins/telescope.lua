return {
  "nvim-telescope/telescope.nvim",
  branch = "0.1.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    "nvim-tree/nvim-web-devicons",
    "folke/todo-comments.nvim",
    "nvim-telescope/telescope-ui-select.nvim",
  },
  config = function()
    local telescope = require("telescope")
    local actions = require("telescope.actions")

    telescope.setup({
      defaults = {
        -- Performance optimizations
        cache_picker = {
          num_pickers = 10,
          limit_entries = 1000,
        },
        dynamic_preview_title = true,
        results_title = false,
        border = true,
        borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
        color_devicons = true,
        use_less = true,
        set_env = { ["COLORTERM"] = "truecolor" },
        file_sorter = require("telescope.sorters").get_fuzzy_file,
        generic_sorter = require("telescope.sorters").get_generic_fuzzy_sorter,
        path_display = { "smart" },
        winblend = 0,
        layout_strategy = "horizontal",
        layout_config = {
          width = 0.95,
          height = 0.85,
          preview_cutoff = 120,
          horizontal = {
            preview_width = function(_, cols, _)
              return math.floor(cols * 0.6)
            end,
          },
          vertical = {
            width = 0.9,
            height = 0.95,
            preview_height = 0.5,
          },
          flex = {
            horizontal = {
              preview_width = 0.9,
            },
          },
        },
        mappings = {
          i = {
            ["<C-k>"] = actions.move_selection_previous,
            ["<C-j>"] = actions.move_selection_next,
            ["<C-n>"] = actions.cycle_history_next,
            ["<C-p>"] = actions.cycle_history_prev,
            ["<C-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
            ["<C-l>"] = actions.complete_tag,
            ["<C-_>"] = actions.which_key, -- keys from pressing <C-/>
            ["<C-w>"] = {"<c-s-w>", type = "key"},
          },
          n = {
            ["<esc>"] = actions.close,
            ["<CR>"] = actions.select_default,
            ["<C-x>"] = actions.select_horizontal,
            ["<C-v>"] = actions.select_vertical,
            ["<C-t>"] = actions.select_tab,
            ["<Tab>"] = actions.toggle_selection + actions.move_selection_worse,
            ["<S-Tab>"] = actions.toggle_selection + actions.move_selection_better,
            ["<C-q>"] = actions.send_to_qflist + actions.open_qflist,
            ["<M-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
            j = actions.move_selection_next,
            k = actions.move_selection_previous,
            H = actions.move_to_top,
            M = actions.move_to_middle,
            L = actions.move_to_bottom,
            ["<Down>"] = actions.move_selection_next,
            ["<Up>"] = actions.move_selection_previous,
            gg = actions.move_to_top,
            G = actions.move_to_bottom,
            ["<C-u>"] = actions.preview_scrolling_up,
            ["<C-d>"] = actions.preview_scrolling_down,
            ["?"] = actions.which_key,
          },
        },
        file_ignore_patterns = {
          -- Directories
          "node_modules/",
          "__pycache__/",
          ".mypy_cache/",
          ".pytest_cache/",
          ".git/",
          "vendor/",
          "build/",
          "dist/",
          "target/",
          "coverage/",
          ".coverage/",
          ".nyc_output/",
          ".cache/",
          ".temp/",
          ".tmp/",
          "tmp/",
          -- File extensions
          "%.pyc",
          "%.pyo",
          "%.pyd",
          "%.so",
          "%.dylib",
          "%.dll",
          "%.class",
          "%.jar",
          "%.war",
          "%.ear",
          "%.zip",
          "%.tar",
          "%.tar.gz",
          "%.rar",
          "%.7z",
          -- Images
          "%.jpg",
          "%.jpeg",
          "%.png",
          "%.gif",
          "%.bmp",
          "%.tiff",
          "%.ico",
          "%.svg",
          -- Documents
          "%.pdf",
          "%.doc",
          "%.docx",
          "%.ppt",
          "%.pptx",
          "%.xls",
          "%.xlsx",
          -- Logs and temporary files
          "%.log",
          "%.prof",
          "%.out",
          "%.lock",
          -- Common ignore patterns
          "Thumbs.db",
          ".DS_Store",
          "desktop.ini",
          "*.tmp",
          "*.temp",
        },
        hidden = true,
      },
      pickers = {
        -- Optimized file finder
        find_files = {
          find_command = { "fd", "--type", "f", "--hidden", "--follow", "--exclude", ".git" },
          follow = true,
          hidden = true,
          no_ignore = false,
          no_ignore_parent = false,
        },
        -- Optimized live grep
        live_grep = {
          additional_args = function(opts)
            return {"--hidden", "--follow"}
          end,
          file_encoding = "utf-8",
          grep_open_files = false,
        },
        -- Optimized grep string
        grep_string = {
          additional_args = function(opts)
            return {"--hidden", "--follow"}
          end,
        },
        -- Other optimized pickers
        buffers = {
          ignore_current_buffer = true,
          sort_lastused = true,
          sort_mru = true,
          show_all_buffers = true,
        },
        git_files = {
          follow = true,
          hidden = true,
          show_untracked = true,
        },
        oldfiles = {
          cwd_only = true,
        },
        lsp_references = {
          show_line = false,
        },
        lsp_definitions = {
          show_line = false,
        },
      },
      extensions = {
        fzf = {
          fuzzy = true,
          override_generic_sorter = true,
          override_file_sorter = true,
          case_mode = "smart_case",
        },
        ["ui-select"] = {
          require("telescope.themes").get_dropdown({
            -- Additional options can be configured here
          }),
        },
      },
    })

    -- Load the extensions
    telescope.load_extension("fzf")
    telescope.load_extension("ui-select")
  end,
}
