return {
  "stevearc/conform.nvim",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    local conform = require("conform")

    -- Enable line wrappring
    vim.opt.wrap = true

    conform.setup({
      formatters_by_ft = {
        -- JavaScript/TypeScript stack
        javascript = { "prettier" },
        typescript = { "prettier" },
        javascriptreact = { "prettier" },
        typescriptreact = { "prettier" },
        
        -- CSS and related
        css = { "prettier" },
        scss = { "prettier" },
        sass = { "prettier" },
        less = { "prettier" },
        
        -- HTML for Django templates
        html = { "prettier" },
        htmldjango = { "djlint" }, -- Django templates
        
        -- Python/Django stack
        python = { "ruff_format" }, -- Use ruff for formatting (modern replacement for black/isort)
        
        -- Shell scripting
        sh = { "shfmt" },
        bash = { "shfmt" },
        zsh = { "shfmt" },
        
        -- SQL
        sql = { "sqlfluff" },
        
        -- Configuration files
        json = { "prettier" },
        yaml = { "prettier" },
        yml = { "prettier" },
        
        -- Lua (for Neovim config)
        lua = { "stylua" },
      },
      format_on_save = function(bufnr)
        -- Get the filetype of the current buffer
        local filetype = vim.bo[bufnr].filetype
        
        -- Check if this looks like a shell script based on filename, even if filetype is wrong
        local bufname = vim.api.nvim_buf_get_name(bufnr)
        local filename = vim.fn.fnamemodify(bufname, ":t")
        local is_shell_script = filename:match("%.sh$") or filename:match("%.bash$") or filename:match("%.zsh$")
        
        -- For shell scripts and CSS (by filetype or filename), disable LSP fallback for consistent formatting
        local is_css_file = filename:match("%.css$") or filename:match("%.scss$") or filename:match("%.sass$") or filename:match("%.less$")
        if filetype == "sh" or filetype == "bash" or filetype == "zsh" or is_shell_script or 
           filetype == "css" or filetype == "scss" or filetype == "sass" or filetype == "less" or is_css_file then
          return {
            lsp_fallback = false, -- Explicitly disable LSP fallback for shell scripts
            async = false,
            timeout_ms = 2000,
          }
        end
        
        -- For other filetypes, use normal behavior
        return {
          lsp_fallback = true,
          async = false,
          timeout_ms = 2000,
        }
      end,
    })

    -- Keymaps are now managed in lua/cm/core/keymaps.lua
  end,
}
