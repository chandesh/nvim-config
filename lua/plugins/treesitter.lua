-- ========================================
-- Treesitter Configuration for Syntax Highlighting
-- ========================================

return {
  -- Treesitter for syntax highlighting and parsing
  {
    "nvim-treesitter/nvim-treesitter",
    version = false, -- last release is way too old and doesn't work on Windows
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = {
      "nvim-treesitter/nvim-treesitter-textobjects",
      "nvim-treesitter/nvim-treesitter-context",
    },
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = {
          -- Web languages
          "html",
          "css",
          "scss",
          "javascript",
          "typescript",
          "tsx",
          "jsx",
          "json",
          "yaml",
          
          -- Python and Django
          "python",
          "htmldjango",
          
          -- Configuration languages
          "lua",
          "vim",
          "vimdoc",
          "toml",
          
          -- Markup
          "markdown",
          "markdown_inline",
          
          -- Shell
          "bash",
          
          -- Git
          "gitignore",
          "git_config",
          "git_rebase",
          "gitcommit",
          
          -- Other useful
          "regex",
          "dockerfile",
          "sql",
        },
        
        auto_install = true,
        sync_install = false,
        
        highlight = {
          enable = true,
          use_languagetree = true,
          additional_vim_regex_highlighting = false,
        },
        
        indent = {
          enable = true,
          disable = { "yaml", "python" }, -- These can be problematic
        },
        
        incremental_selection = {
          enable = true,
          keymaps = {
            init_selection = "<C-space>",
            node_incremental = "<C-space>",
            scope_incremental = false,
            node_decremental = "<bs>",
          },
        },

        -- Treesitter textobjects for better navigation
        textobjects = {
          select = {
            enable = true,
            lookahead = true,
            keymaps = {
              -- You can use the capture groups defined in textobjects.scm
              ["af"] = "@function.outer",
              ["if"] = "@function.inner",
              ["ac"] = "@class.outer",
              ["ic"] = "@class.inner",
              ["aa"] = "@parameter.outer",
              ["ia"] = "@parameter.inner",
              ["ab"] = "@block.outer",
              ["ib"] = "@block.inner",
              ["as"] = "@statement.outer",
              ["is"] = "@statement.inner",
              ["al"] = "@loop.outer",
              ["il"] = "@loop.inner",
              ["ad"] = "@conditional.outer",
              ["id"] = "@conditional.inner",
            },
            selection_modes = {
              ['@parameter.outer'] = 'v', -- charwise
              ['@function.outer'] = 'V', -- linewise
              ['@class.outer'] = '<c-v>', -- blockwise
            },
            include_surrounding_whitespace = true,
          },
          
          move = {
            enable = true,
            set_jumps = true, -- whether to set jumps in the jumplist
            goto_next_start = {
              ["]f"] = "@function.outer",
              ["]c"] = "@class.outer",
              ["]a"] = "@parameter.inner",
              ["]b"] = "@block.outer",
              ["]s"] = "@statement.outer",
              ["]l"] = "@loop.outer",
              ["]d"] = "@conditional.outer",
            },
            goto_next_end = {
              ["]F"] = "@function.outer",
              ["]C"] = "@class.outer",
              ["]A"] = "@parameter.inner",
              ["]B"] = "@block.outer",
              ["]S"] = "@statement.outer",
              ["]L"] = "@loop.outer",
              ["]D"] = "@conditional.outer",
            },
            goto_previous_start = {
              ["[f"] = "@function.outer",
              ["[c"] = "@class.outer",
              ["[a"] = "@parameter.inner",
              ["[b"] = "@block.outer",
              ["[s"] = "@statement.outer",
              ["[l"] = "@loop.outer",
              ["[d"] = "@conditional.outer",
            },
            goto_previous_end = {
              ["[F"] = "@function.outer",
              ["[C"] = "@class.outer",
              ["[A"] = "@parameter.inner",
              ["[B"] = "@block.outer",
              ["[S"] = "@statement.outer",
              ["[L"] = "@loop.outer",
              ["[D"] = "@conditional.outer",
            },
          },
          
          swap = {
            enable = true,
            swap_next = {
              ["<leader>na"] = "@parameter.inner",
              ["<leader>nf"] = "@function.outer",
            },
            swap_previous = {
              ["<leader>pa"] = "@parameter.inner",
              ["<leader>pf"] = "@function.outer",
            },
          },
        },
      })

      -- Folding based on treesitter
      vim.opt.foldmethod = "expr"
      vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
      vim.opt.foldenable = false -- Don't fold by default
    end,
  },

  -- Treesitter textobjects
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    lazy = true,
  },

  -- Show context of current function/class
  {
    "nvim-treesitter/nvim-treesitter-context",
    event = { "BufReadPost", "BufNewFile" },
    keys = {
      {
        "<leader>ut",
        function()
          require("treesitter-context").toggle()
        end,
        desc = "Toggle Treesitter Context",
      },
    },
    config = function()
      require("treesitter-context").setup({
        enable = true,
        max_lines = 0, -- How many lines the window should span. Values <= 0 mean no limit.
        min_window_height = 0, -- Minimum editor window height to enable context. Values <= 0 mean no limit.
        line_numbers = true,
        multiline_threshold = 20, -- Maximum number of lines to collapse for a single context line
        trim_scope = 'outer', -- Which context lines to discard if `max_lines` is exceeded. Choices: 'inner', 'outer'
        mode = 'cursor', -- Line used to calculate context. Choices: 'cursor', 'topline'
        separator = nil, -- Separator between context and content. Should be a single character string, like '-'.
        zindex = 20, -- The Z-index of the context window
      })
    end,
  },

  -- Rainbow parentheses
  {
    "HiPhish/rainbow-delimiters.nvim",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      local rainbow_delimiters = require("rainbow-delimiters")

      vim.g.rainbow_delimiters = {
        strategy = {
          [''] = rainbow_delimiters.strategy['global'],
          vim = rainbow_delimiters.strategy['local'],
        },
        query = {
          [''] = 'rainbow-delimiters',
          lua = 'rainbow-blocks',
        },
        highlight = {
          'RainbowDelimiterRed',
          'RainbowDelimiterYellow',
          'RainbowDelimiterBlue',
          'RainbowDelimiterOrange',
          'RainbowDelimiterGreen',
          'RainbowDelimiterViolet',
          'RainbowDelimiterCyan',
        },
      }
    end,
  },

  -- Auto-close and auto-rename HTML tags
  {
    "windwp/nvim-ts-autotag",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    config = function()
      require("nvim-ts-autotag").setup({
        filetypes = {
          'html', 'javascript', 'typescript', 'javascriptreact', 'typescriptreact',
          'svelte', 'vue', 'tsx', 'jsx', 'rescript', 'xml', 'php', 'markdown',
          'astro', 'glimmer', 'handlebars', 'hbs', 'htmldjango'
        },
        skip_tags = {
          'area', 'base', 'br', 'col', 'command', 'embed', 'hr', 'img', 'slot',
          'input', 'keygen', 'link', 'meta', 'param', 'source', 'track', 'wbr',
          'menuitem'
        },
      })
    end,
  },

  -- Better commenting with treesitter support
  {
    "numToStr/Comment.nvim",
    keys = {
      { "gc", mode = { "n", "v" }, desc = "Comment toggle linewise" },
      { "gb", mode = { "n", "v" }, desc = "Comment toggle blockwise" },
    },
    config = function()
      require("Comment").setup({
        pre_hook = require("ts_context_commentstring.integrations.comment_nvim").create_pre_hook(),
      })
    end,
  },

  -- Context-aware commenting for embedded languages
  {
    "JoosepAlviste/nvim-ts-context-commentstring",
    lazy = true,
    config = function()
      require("ts_context_commentstring").setup({
        enable_autocmd = false,
        languages = {
          typescript = "// %s",
          css = "/* %s */",
          scss = "/* %s */",
          html = "<!-- %s -->",
          svelte = "<!-- %s -->",
          vue = "<!-- %s -->",
          json = "",
          htmldjango = "{# %s #}",
        },
      })
    end,
  },
}
