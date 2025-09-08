return {
  "nvim-pack/nvim-spectre",
  event = "VeryLazy",
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  config = function()
    require("spectre").setup({
      color_devicons = true,
      open_cmd = "call SpectreFloatingWindow()",
      live_update = false, -- auto execute search again when you write any file
      line_sep_start = '┌-----------------------------------------',
      result_padding = '¦  ',
      line_sep       = '└-----------------------------------------',
      highlight = {
        ui = "String",
        search = "DiffChange",
        replace = "DiffDelete"
      },
      mapping={
        ['toggle_line'] = {
          map = "dd",
          cmd = "<cmd>lua require('spectre').toggle_line()<CR>",
          desc = "toggle current item"
        },
        ['enter_file'] = {
          map = "<cr>",
          cmd = "<cmd>lua require('spectre.actions').select_entry()<CR>",
          desc = "goto current file"
        },
        ['send_to_qf'] = {
          map = "<leader>q",
          cmd = "<cmd>lua require('spectre.actions').send_to_qf()<CR>",
          desc = "send all item to quickfix"
        },
        ['replace_cmd'] = {
          map = "<leader>c",
          cmd = "<cmd>lua require('spectre.actions').replace_cmd()<CR>",
          desc = "input replace vim command"
        },
        ['show_option_menu'] = {
          map = "<leader>o",
          cmd = "<cmd>lua require('spectre').show_options()<CR>",
          desc = "show option"
        },
        ['run_current_replace'] = {
          map = "<leader>rc",
          cmd = "<cmd>lua require('spectre.actions').run_current_replace()<CR>",
          desc = "replace current line"
        },
        ['run_replace'] = {
          map = "<leader>R",
          cmd = "<cmd>lua require('spectre.actions').run_replace()<CR>",
          desc = "replace all"
        },
        ['change_view_mode'] = {
          map = "<leader>v",
          cmd = "<cmd>lua require('spectre').change_view()<CR>",
          desc = "change result view mode"
        },
        ['change_replace_sed'] = {
          map = "trs",
          cmd = "<cmd>lua require('spectre').change_engine_replace('sed')<CR>",
          desc = "use sed to replace"
        },
        ['change_replace_oxi'] = {
          map = "tro",
          cmd = "<cmd>lua require('spectre').change_engine_replace('oxi')<CR>",
          desc = "use oxi to replace"
        },
        ['toggle_live_update']= {
          map = "tu",
          cmd = "<cmd>lua require('spectre').toggle_live_update()<CR>",
          desc = "update change when vim write file."
        },
        ['toggle_ignore_case'] = {
          map = "ti",
          cmd = "<cmd>lua require('spectre').change_options('ignore-case')<CR>",
          desc = "toggle ignore case"
        },
        ['toggle_ignore_hidden'] = {
          map = "th",
          cmd = "<cmd>lua require('spectre').change_options('hidden')<CR>",
          desc = "toggle search hidden"
        },
        ['resume_last_search'] = {
          map = "<leader>l",
          cmd = "<cmd>lua require('spectre').resume_last_search()<CR>",
          desc = "resume last search before close"
        },
      },
      find_engine = {
        -- rg is map with rg command
        ['rg'] = {
          cmd = "rg",
          -- default args
          args = {
            '--color=never',
            '--no-heading',
            '--with-filename',
            '--line-number',
            '--column',
          } ,
          options = {
            ['ignore-case'] = {
              value= "--ignore-case",
              icon="[I]",
              desc="ignore case"
            },
            ['hidden'] = {
              value="--hidden",
              desc="hidden file",
              icon="[H]"
            },
            -- you can put any rg search option you want here it can toggle with
            -- show_option function
          }
        },
        ['ag'] = {
          cmd = "ag",
          args = {
            '--vimgrep',
            '-s'
          } ,
          options = {
            ['ignore-case'] = {
              value= "-i",
              icon="[I]",
              desc="ignore case"
            },
            ['hidden'] = {
              value="--hidden",
              desc="hidden file",
              icon="[H]"
            },
          },
        },
      },
      replace_engine = {
        ['sed'] = {
          cmd = "gsed",
          args = nil,
          options = {
            ['ignore-case'] = {
              value= "--ignore-case",
              icon="[I]",
              desc="ignore case"
            },
          }
        },
        -- call rust code by nvim-oxi to replace
        ['oxi'] = {
          cmd = 'oxi',
          args = {},
          options = {
            ['ignore-case'] = {
              value = "i",
              icon = "[I]",
              desc = "ignore case"
            },
          }
        }
      },
      default = {
          find = {
              --pick one of item in find_engine
              cmd = "rg",
              options = {"ignore-case"}
          },
          replace={
              --pick one of item in replace_engine
              cmd = "sed"
          }
      },
      replace_vim_cmd = "cdo",
      is_open_target_win = true, --open file on opener window
      is_insert_mode = false  -- start open panel on is_insert_mode
    })

    -- Create a custom vim command for floating window
    vim.cmd([[
      function! SpectreFloatingWindow()
        let width = float2nr(&columns * 0.8)
        let height = float2nr(&lines * 0.6)
        let row = float2nr(&lines * 0.2)
        let col = float2nr(&columns * 0.1)
        
        let opts = {
          \ 'relative': 'editor',
          \ 'width': width,
          \ 'height': height,
          \ 'row': row,
          \ 'col': col,
          \ 'style': 'minimal',
          \ 'border': 'rounded'
          \ }
        
        let buf = nvim_create_buf(v:false, v:true)
        let win = nvim_open_win(buf, v:true, opts)
        
        return buf
      endfunction
    ]])
    
    -- Since open_cmd is set to floating window, we don't need a custom function
  end,
  keys = {
    { "<leader>sr", function() require("spectre").open() end, desc = "Open Spectre (search & replace)" },
    { "<leader>sw", function() require("spectre").open_visual({select_word=true}) end, desc = "Search current word" },
    { "<leader>sw", function() require("spectre").open_visual() end, mode = "v", desc = "Search current selection" },
    { "<leader>sp", function() require("spectre").open_file_search({select_word=true}) end, desc = "Search in current file" },
  },
}
