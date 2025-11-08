-- ========================================
-- Theme and UI Enhancements Configuration
-- ========================================

return {
  -- Your favorite Solarized Osaka theme (from backup)
  {
    "craftzdog/solarized-osaka.nvim",
    lazy = false,
    priority = 1000, -- make sure to load this before all the other start plugins
    config = function()
      require("solarized-osaka").setup({
        transparent = true, -- Transparent background
        terminal_colors = true, -- Configure terminal colors
        styles = {
          comments = { italic = true },
          keywords = { italic = true },
          functions = {},
          variables = {},
          sidebars = "dark", -- Can be "dark", "transparent", or "normal"
          floats = "dark", -- Can be "dark", "transparent", or "normal"
        },
        sidebars = { "qf", "help", "neo-tree", "Trouble" },
        day_brightness = 0.3,
        hide_inactive_statusline = false,
        dim_inactive = false,
        lualine_bold = false,

        -- Performance optimization
        cache = true, -- Enable caching for faster load times

        -- Enhanced plugin integrations (latest updates)
        plugins = {
          all = true, -- Enable all plugin integrations
          auto = true, -- Auto-detect and enable plugins
        },

        -- Override specific color groups
        on_colors = function(colors)
          -- Example of custom color adjustments
          colors.hint = colors.orange
          colors.error = "#ff0000"
        end,

        -- Override specific highlights
        on_highlights = function(highlights, colors)
          -- Custom Telescope styling (from your backup)
          local prompt = "#2d3149"
          highlights.TelescopeNormal = {
            bg = colors.bg_dark,
            fg = colors.fg_dark,
          }
          highlights.TelescopeBorder = {
            bg = colors.bg_dark,
            fg = colors.bg_dark,
          }
          highlights.TelescopePromptNormal = {
            bg = prompt,
          }
          highlights.TelescopePromptBorder = {
            bg = prompt,
            fg = prompt,
          }
          highlights.TelescopePromptTitle = {
            bg = prompt,
            fg = prompt,
          }
          highlights.TelescopePreviewTitle = {
            bg = colors.bg_dark,
            fg = colors.bg_dark,
          }
          highlights.TelescopeResultsTitle = {
            bg = colors.bg_dark,
            fg = colors.bg_dark,
          }
          
          -- Additional highlights for better integration
          highlights.CmpGhostText = { fg = colors.comment }
          highlights.GitSignsAdd = { fg = colors.green }
          highlights.GitSignsChange = { fg = colors.yellow }
          highlights.GitSignsDelete = { fg = colors.red }

          -- Enhanced modern plugin support
          highlights.BlinkCmpKind = { fg = colors.blue }
          highlights.BlinkCmpMenu = { bg = colors.bg_dark }
          highlights.BufferLineIndicatorSelected = { fg = colors.blue }

          -- Better Neo-tree integration
          highlights.NeoTreeNormal = { bg = colors.bg_dark }
          highlights.NeoTreeNormalNC = { bg = colors.bg_dark }
        end,
      })

      -- Load the colorscheme
      vim.cmd([[colorscheme solarized-osaka]])
      -- Note: Custom background override removed to respect theme's transparent setting
    end,
  },

  -- Tokyo Night as backup option
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 900,
    config = function()
      require("tokyonight").setup({
        style = "night", -- night, storm, day, moon
        light_style = "day",
        transparent = false,
        terminal_colors = true,
        styles = {
          comments = { italic = true },
          keywords = { italic = true },
          functions = {},
          variables = {},
          sidebars = "dark",
          floats = "dark",
        },
        sidebars = { "qf", "help", "neo-tree", "Trouble" },
        day_brightness = 0.3,
        hide_inactive_statusline = false,
        dim_inactive = false,
        lualine_bold = false,
        use_background = true,
        
        on_colors = function(colors)
          colors.border = colors.blue7
        end,
        
        on_highlights = function(highlights, colors)
          -- Custom highlights
          highlights.CmpGhostText = { fg = colors.terminal_black }
          highlights.GitSignsAdd = { fg = colors.green }
          highlights.GitSignsChange = { fg = colors.yellow }
          highlights.GitSignsDelete = { fg = colors.red }
        end,
      })
    end,
  },

  -- Gruvbox theme
  {
    "ellisonleao/gruvbox.nvim",
    lazy = false,
    priority = 900,
    config = function()
      require("gruvbox").setup({
        terminal_colors = true,
        undercurl = true,
        underline = true,
        bold = true,
        italic = {
          strings = true,
          emphasis = true,
          comments = true,
          operators = false,
          folds = true,
        },
        strikethrough = true,
        invert_selection = false,
        invert_signs = false,
        invert_tabline = false,
        invert_intend_guides = false,
        inverse = true,
        contrast = "", -- can be "hard", "soft" or empty string
        palette_overrides = {},
        overrides = {},
        dim_inactive = false,
        transparent_mode = false,
      })
    end,
  },

  -- Oceanic Material theme
  {
    "nvimdev/oceanic-material",
    lazy = false,
    priority = 900,
    config = function()
      -- Oceanic Material is a simple theme, just load it
      vim.g.oceanic_material_background = "ocean" -- options: ocean, deep, darker, palenight
      vim.g.oceanic_material_allow_bold = 1
      vim.g.oceanic_material_allow_italic = 1
      vim.g.oceanic_material_allow_underline = 1
      vim.g.oceanic_material_allow_undercurl = 1
    end,
  },

  -- Alternative colorschemes
  {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = false,
    priority = 900,
    config = function()
      require("catppuccin").setup({
        flavour = "mocha", -- latte, frappe, macchiato, mocha
        background = {
          light = "latte",
          dark = "mocha",
        },
        transparent_background = false,
        show_end_of_buffer = false,
        term_colors = true,
        dim_inactive = {
          enabled = false,
          shade = "dark",
          percentage = 0.15,
        },
        no_italic = false,
        no_bold = false,
        no_underline = false,
        styles = {
          comments = { "italic" },
          conditionals = { "italic" },
          loops = {},
          functions = {},
          keywords = {},
          strings = {},
          variables = {},
          numbers = {},
          booleans = {},
          properties = {},
          types = {},
          operators = {},
        },
        integrations = {
          cmp = true,
          gitsigns = true,
          nvimtree = true,
          telescope = true,
          notify = true,
          mason = true,
          neotree = true,
          treesitter = true,
          treesitter_context = true,
          which_key = true,
          indent_blankline = {
            enabled = true,
            colored_indent_levels = false,
          },
          native_lsp = {
            enabled = true,
            virtual_text = {
              errors = { "italic" },
              hints = { "italic" },
              warnings = { "italic" },
              information = { "italic" },
            },
            underlines = {
              errors = { "underline" },
              hints = { "underline" },
              warnings = { "underline" },
              information = { "underline" },
            },
            inlay_hints = {
              background = true,
            },
          },
        },
      })
    end,
  },

  -- Statusline
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    dependencies = {
      "github/copilot.vim",
    },
    init = function()
      vim.g.lualine_laststatus = vim.o.laststatus
      if vim.fn.argc(-1) > 0 then
        vim.o.statusline = " "
      else
        vim.o.laststatus = 0
      end
    end,
    config = function()
      local lualine = require("lualine")

      -- Custom components
      local function show_macro_recording()
        local recording_register = vim.fn.reg_recording()
        if recording_register == "" then
          return ""
        else
          return "Recording @" .. recording_register
        end
      end

      local function lsp_status()
        local clients = vim.lsp.get_active_clients({ bufnr = 0 })
        if #clients == 0 then
          return ""
        end

        local names = {}
        for _, client in ipairs(clients) do
          table.insert(names, client.name)
        end
        return " " .. table.concat(names, ", ")
      end

      local function python_env()
        if vim.bo.filetype == "python" then
          local venv = vim.env.VIRTUAL_ENV
          if venv then
            return " " .. vim.fn.fnamemodify(venv, ":t")
          end
        end
        return ""
      end

      local function window_width_check_for_section()
        -- function to hide a section if the window size is less than 75 chars.
        return vim.fn.winwidth(0) > 75
      end

      local function copilot_status()
        -- Check if Copilot plugin exists
        if vim.fn.exists('g:copilot_enabled') == 0 then
          return ""
        end
        
        -- Check if Copilot is enabled (handle both boolean and number values)
        if vim.g.copilot_enabled == true or vim.g.copilot_enabled == 1 then
          -- Simple status check - if we can call copilot functions, it's working
          if vim.fn.exists('*copilot#Enabled') == 1 then
            local enabled = vim.fn['copilot#Enabled']()
            if enabled == 1 then
              return "󰚩" -- Copilot enabled and ready
            else
              return "󰚩" -- Copilot disabled
            end
          else
            return "󰚩" -- Copilot not loaded properly
          end
        else
          return "" -- Copilot completely disabled
        end
      end

      -- Beautiful custom theme with background colors (from backup)
      local colors = {
        custom = "#979a29",
        blue = "#65D1FF",
        green = "#3EFFDC",
        violet = "#FF61EF",
        yellow = "#FFDA7B",
        red = "#FF4A4A",
        fg = "#c3ccdc",
        bg = "#101010",
        inactive_bg = "#28292e",
      }

      local my_lualine_theme = {
        normal = {
          a = { bg = colors.custom, fg = colors.bg, gui = "bold" },
          b = { bg = colors.bg, fg = colors.fg },
          c = { bg = colors.bg, fg = colors.fg },
        },
        insert = {
          a = { bg = colors.green, fg = colors.bg, gui = "bold" },
          b = { bg = colors.bg, fg = colors.fg },
          c = { bg = colors.bg, fg = colors.fg },
        },
        visual = {
          a = { bg = colors.violet, fg = colors.bg, gui = "bold" },
          b = { bg = colors.bg, fg = colors.fg },
          c = { bg = colors.bg, fg = colors.fg },
        },
        command = {
          a = { bg = colors.yellow, fg = colors.bg, gui = "bold" },
          b = { bg = colors.bg, fg = colors.fg },
          c = { bg = colors.bg, fg = colors.fg },
        },
        replace = {
          a = { bg = colors.red, fg = colors.bg, gui = "bold" },
          b = { bg = colors.bg, fg = colors.fg },
          c = { bg = colors.bg, fg = colors.fg },
        },
        inactive = {
          a = { bg = colors.inactive_bg, fg = colors.fg, gui = "bold" },
          b = { bg = colors.inactive_bg, fg = colors.fg },
          c = { bg = colors.inactive_bg, fg = colors.fg },
        },
      }

      lualine.setup({
        options = {
          theme = my_lualine_theme,
          globalstatus = false, -- Set to false so each split window shows its own filename
          disabled_filetypes = { statusline = { "dashboard", "alpha", "starter" } },
          component_separators = { left = "", right = "" },
          section_separators = { left = "", right = "" },
        },
        sections = {
          lualine_a = { "mode" },
          lualine_b = {
            {
              python_env,
              color = { fg = "#1c1c1c", bg = "#03a678" },
            },
            {
              "filename",
              path = 1, -- relative path
              file_status = true,
              color = { fg = "#e4b622", bg = "#024554" },
              symbols = { modified = "  ", readonly = "", unnamed = "" },
            },
          },
          lualine_c = {
            {
              "branch",
              color = { fg = "#1c1c1c", bg = "#b5663d" },
            },
            {
              "diff",
              color = { fg = "#c1c1c1", bg = "#02383e" },
            },
            {
              "diagnostics",
              symbols = {
                error = " ",
                warn = " ",
                info = " ",
                hint = " ",
              },
              color = { bg = "#313C37" },
              always_visible = false,
              cond = window_width_check_for_section,
            },
          },
          lualine_x = {
            { show_macro_recording, color = { fg = "#ff9e64", bg = "#2a2a2a" } },
            {
              copilot_status,
              color = { fg = "#00f5ff", bg = "#0d4f3c" },
            },
            { lsp_status, color = { fg = "#7dcfff", bg = "#1a3a4a" } },
            {
              function()
                return require("noice").api.status.command.get()
              end,
              cond = function()
                return package.loaded["noice"] and require("noice").api.status.command.has()
              end,
              color = { fg = "#ff9e64", bg = "#3a2a1a" },
            },
            {
              function()
                return require("noice").api.status.mode.get()
              end,
              cond = function()
                return package.loaded["noice"] and require("noice").api.status.mode.has()
              end,
              color = { fg = "#ff9e64", bg = "#3a2a1a" },
            },
            {
              function()
                return "  " .. require("dap").status()
              end,
              cond = function()
                return package.loaded["dap"] and require("dap").status() ~= ""
              end,
              color = { fg = "#ff9e64", bg = "#4a1a1a" },
            },
          },
          lualine_y = {
            {
              "progress", 
              color = { fg = "#1c1c1c", bg = "#e4b622" },
              separator = " ", 
              padding = { left = 1, right = 0 },
            },
            {
              "location", 
              color = { fg = "#c3ccdc", bg = "#424242" },
              padding = { left = 0, right = 1 },
            },
            {
              function()
                return require("lazy.status").updates()
              end,
              cond = function()
                return require("lazy.status").has_updates()
              end,
              color = { fg = "#ff9e64", bg = "#004851" },
            },
          },
          lualine_z = {},
        },
        inactive_sections = {
          lualine_a = {},
          lualine_b = {},
          lualine_c = {
            {
              "filename",
              path = 1,
              color = { fg = "#1c1c1c", bg = "#4d594d" },
            },
          },
          lualine_x = {
            {
              "location",
              color = { fg = "#1c1c1c", bg = "#4d594d" },
            },
          },
          lualine_y = {},
          lualine_z = {},
        },
        extensions = { "neo-tree", "lazy", "fugitive", "mason", "trouble" },
      })
      
      -- Refresh lualine when Copilot status changes
      vim.api.nvim_create_autocmd({"User"}, {
        pattern = "CopilotEnabled",
        callback = function()
          require('lualine').refresh()
        end,
      })
    end,
  },

  -- Indent guides
  {
    "lukas-reineke/indent-blankline.nvim",
    event = { "BufReadPost", "BufNewFile" },
    main = "ibl",
    config = function()
      local highlight = {
        "RainbowRed",
        "RainbowYellow",
        "RainbowBlue",
        "RainbowOrange",
        "RainbowGreen",
        "RainbowViolet",
        "RainbowCyan",
      }

      local hooks = require("ibl.hooks")
      hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
        vim.api.nvim_set_hl(0, "RainbowRed", { fg = "#E06C75" })
        vim.api.nvim_set_hl(0, "RainbowYellow", { fg = "#E5C07B" })
        vim.api.nvim_set_hl(0, "RainbowBlue", { fg = "#61AFEF" })
        vim.api.nvim_set_hl(0, "RainbowOrange", { fg = "#D19A66" })
        vim.api.nvim_set_hl(0, "RainbowGreen", { fg = "#98C379" })
        vim.api.nvim_set_hl(0, "RainbowViolet", { fg = "#C678DD" })
        vim.api.nvim_set_hl(0, "RainbowCyan", { fg = "#56B6C2" })
      end)

      require("ibl").setup({
        indent = {
          highlight = highlight,
          char = "│",
          tab_char = "│",
        },
        whitespace = {
          highlight = highlight,
          remove_blankline_trail = false,
        },
        scope = { enabled = false },
        exclude = {
          filetypes = {
            "help",
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
          },
        },
      })
    end,
  },

  -- Better vim.ui
  {
    "stevearc/dressing.nvim",
    lazy = true,
    config = function()
      require("dressing").setup({
        input = {
          enabled = true,
          default_prompt = "Input:",
          prompt_align = "left",
          insert_only = true,
          start_in_insert = true,
          anchor = "SW",
          border = "rounded",
          relative = "cursor",
          prefer_width = 40,
          width = nil,
          max_width = { 140, 0.9 },
          min_width = { 20, 0.2 },
          buf_options = {},
          win_options = {
            winblend = 10,
            wrap = false,
            list = true,
            listchars = "precedes:…,extends:…",
            sidescrolloff = 0,
          },
          mappings = {
            n = {
              ["<Esc>"] = "Close",
              ["<CR>"] = "Confirm",
            },
            i = {
              ["<C-c>"] = "Close",
              ["<CR>"] = "Confirm",
              ["<Up>"] = "HistoryPrev",
              ["<Down>"] = "HistoryNext",
            },
          },
          override = function(conf)
            return conf
          end,
          get_config = nil,
        },
        select = {
          enabled = true,
          backend = { "telescope", "fzf_lua", "fzf", "builtin", "nui" },
          trim_prompt = true,
          telescope = nil,
          fzf = {
            window = {
              width = 0.5,
              height = 0.4,
            },
          },
          fzf_lua = {},
          nui = {
            position = "50%",
            size = nil,
            relative = "editor",
            border = {
              style = "rounded",
            },
            buf_options = {
              swapfile = false,
              filetype = "DressingSelect",
            },
            win_options = {
              winblend = 10,
            },
            max_width = 80,
            max_height = 40,
            min_width = 40,
            min_height = 10,
          },
          builtin = {
            show_numbers = true,
            border = "rounded",
            relative = "editor",
            buf_options = {},
            win_options = {
              winblend = 10,
            },
            width = nil,
            max_width = { 140, 0.8 },
            min_width = { 40, 0.2 },
            height = nil,
            max_height = 0.9,
            min_height = { 10, 0.2 },
            mappings = {
              ["<Esc>"] = "Close",
              ["<C-c>"] = "Close",
              ["<CR>"] = "Confirm",
            },
            override = function(conf)
              return conf
            end,
          },
          format_item_override = {},
          get_config = nil,
        },
      })
    end,
  },

  -- Dashboard
  {
    "goolord/alpha-nvim",
    event = "VimEnter",
    config = function()
      local alpha = require("alpha")
      local dashboard = require("alpha.themes.dashboard")

      -- Header
      dashboard.section.header.val = {
        "                                                     ",
        "  ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗ ",
        "  ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║ ",
        "  ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║ ",
        "  ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║ ",
        "  ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║ ",
        "  ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝ ",
        "                                                     ",
        "          🐍 Full-Stack Development Ready 🚀          ",
        "                                                     ",
      }

      -- Menu (using your familiar keybindings from backup)
      dashboard.section.buttons.val = {
        dashboard.button("e", "  > New File", "<cmd>ene<CR>"),
        dashboard.button("SPC ee", "  > Toggle file explorer", "<cmd>Neotree toggle<CR>"),
        dashboard.button("SPC ff", "󰱼 > Find File", "<cmd>Telescope find_files<CR>"),
        dashboard.button("SPC fs", "  > Find Word", "<cmd>Telescope live_grep<CR>"),
        dashboard.button("SPC wr", "󰁯  > Restore Session For Current Directory", [[:lua require("persistence").load()<CR>]]),
        dashboard.button("r", " " .. " Recent files", ":Telescope oldfiles <CR>"),
        dashboard.button("c", " " .. " Config", ":e $MYVIMRC <CR>"),
        dashboard.button("l", "󰒲 " .. " Lazy", ":Lazy<CR>"),
        dashboard.button("q", " > Quit NVIM", "<cmd>qa<CR>"),
      }

      -- Footer
      local function footer()
        local total_plugins = #vim.tbl_keys(require("lazy").plugins())
        local datetime = os.date(" %d-%m-%Y   %H:%M:%S")
        local version = vim.version()
        local nvim_version_info = "   v" .. version.major .. "." .. version.minor .. "." .. version.patch

        return datetime .. "   " .. total_plugins .. " plugins" .. nvim_version_info
      end

      dashboard.section.footer.val = footer()

      dashboard.config.opts.noautocmd = true
      alpha.setup(dashboard.config)

      vim.api.nvim_create_autocmd("User", {
        pattern = "LazyVimStarted",
        callback = function()
          local stats = require("lazy").stats()
          local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100)
          dashboard.section.footer.val = "⚡ Neovim loaded " .. stats.count .. " plugins in " .. ms .. "ms"
          pcall(vim.cmd.AlphaRedraw)
        end,
      })
    end,
  },

  -- Smooth scrolling
  {
    "karb94/neoscroll.nvim",
    event = "VeryLazy",
    config = function()
      require("neoscroll").setup({
        mappings = { "<C-u>", "<C-d>", "<C-b>", "<C-f>", "<C-y>", "<C-e>", "zt", "zz", "zb" },
        hide_cursor = true,
        stop_eof = true,
        respect_scrolloff = false,
        cursor_scrolls_alone = true,
        easing_function = nil,
        pre_hook = nil,
        post_hook = nil,
      })
    end,
  },

  -- Highlight colors
  {
    "NvChad/nvim-colorizer.lua",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require("colorizer").setup({
        filetypes = { "*" },
        user_default_options = {
          RGB = true,
          RRGGBB = true,
          names = true,
          RRGGBBAA = false,
          AARRGGBB = false,
          rgb_fn = false,
          hsl_fn = false,
          css = false,
          css_fn = false,
          mode = "background",
          tailwind = false,
          sass = { enable = false, parsers = { "css" } },
          virtualtext = "■",
          always_update = false,
        },
        buftypes = {},
      })
    end,
  },

  -- Winbar with navic
  {
    "SmiteshP/nvim-navic",
    lazy = true,
    config = function()
      local icons = {
        File = " ",
        Module = " ",
        Namespace = " ",
        Package = " ",
        Class = " ",
        Method = " ",
        Property = " ",
        Field = " ",
        Constructor = " ",
        Enum = " ",
        Interface = " ",
        Function = " ",
        Variable = " ",
        Constant = " ",
        String = " ",
        Number = " ",
        Boolean = " ",
        Array = " ",
        Object = " ",
        Key = " ",
        Null = " ",
        EnumMember = " ",
        Struct = " ",
        Event = " ",
        Operator = " ",
        TypeParameter = " ",
      }

      require("nvim-navic").setup({
        icons = icons,
        lsp = {
          auto_attach = true,
          preference = nil,
        },
        highlight = false,
        separator = " > ",
        depth_limit = 0,
        depth_limit_indicator = "..",
        safe_output = true,
        lazy_update_context = false,
        click = false,
      })
    end,
  },
}
