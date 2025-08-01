-- Auto commands for better development experience
local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

-- Python specific configurations
local python_group = augroup("PythonSettings", { clear = true })

autocmd("FileType", {
  group = python_group,
  pattern = "python",
  callback = function()
    -- Activate pyenv environment for current buffer
    local pyenv = require("cm.core.pyenv")
    pyenv.activate()
    
    -- Set Python-specific options
    vim.opt_local.tabstop = 4
    vim.opt_local.shiftwidth = 4
    vim.opt_local.softtabstop = 4
    vim.opt_local.expandtab = true
    vim.opt_local.textwidth = 88 -- Black formatter standard
    vim.opt_local.colorcolumn = "88"
    
    -- Python-specific folding (start with functions/classes folded)
    vim.opt_local.foldlevelstart = 1
    
    -- Apply initial folding after a short delay to let treesitter parse
    vim.defer_fn(function()
      if vim.bo.filetype == "python" then
        -- Close folds for functions and classes by default
        vim.cmd("silent! %foldclose")
        -- Then open top level to show class/function signatures
        vim.cmd("normal! zR")
        vim.cmd("normal! zm")
      end
    end, 100)
    
    -- Auto-import on save disabled - use manual keybindings instead
    -- Uncomment the following block if you want auto-import on save:
    --[[
    vim.api.nvim_create_autocmd("BufWritePre", {
      buffer = 0,
      callback = function()
        -- Organize imports before formatting
        vim.lsp.buf.code_action({
          filter = function(action)
            return action.title:match("Organize imports") or action.title:match("Sort imports")
          end,
          apply = true,
        })
        
        -- Format with timeout
        vim.defer_fn(function()
          if vim.lsp.buf.format then
            vim.lsp.buf.format({ timeout_ms = 2000 })
          end
        end, 100)
      end,
    })
    --]]
  end,
})

-- Django template files
autocmd({ "BufRead", "BufNewFile" }, {
  group = python_group,
  pattern = { "*.html", "*.djhtml" },
  callback = function()
    -- Detect Django templates
    local content = vim.api.nvim_buf_get_lines(0, 0, 50, false)
    for _, line in ipairs(content) do
      if line:match("{{.*}}") or line:match("{%.*%}") then
        vim.bo.filetype = "htmldjango"
        break
      end
    end
  end,
})

-- General improvements
local general_group = augroup("GeneralSettings", { clear = true })

-- Highlight yanked text
autocmd("TextYankPost", {
  group = general_group,
  callback = function()
    vim.hl.on_yank({ higroup = "Visual", timeout = 200 })
  end,
})

-- Remove trailing whitespace on save
autocmd("BufWritePre", {
  group = general_group,
  pattern = { "*.py", "*.js", "*.ts", "*.jsx", "*.tsx", "*.lua", "*.sh" },
  callback = function()
    local save_cursor = vim.fn.getpos(".")
    vim.cmd([[%s/\s\+$//e]])
    vim.fn.setpos(".", save_cursor)
  end,
})

-- Auto reload files changed outside of Neovim
autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI" }, {
  group = general_group,
  callback = function()
    if vim.fn.mode() ~= "c" then
      vim.cmd("checktime")
    end
  end,
})

-- Close certain windows with 'q'
autocmd("FileType", {
  group = general_group,
  pattern = {
    "qf",
    "help",
    "man",
    "notify",
    "lspinfo",
    "spectre_panel",
    "startuptime",
    "tsplayground",
  },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = event.buf, silent = true })
  end,
})

-- LSP-specific autocmds
local lsp_group = augroup("LspFormatting", { clear = true })

-- Show line diagnostics on cursor hold (disabled by default to avoid noise)
-- Uncomment the following if you want automatic diagnostic popups
--[[
autocmd({ "CursorHold", "CursorHoldI" }, {
  group = lsp_group,
  callback = function()
    local opts = {
      focusable = false,
      close_events = { "BufLeave", "CursorMoved", "InsertEnter", "FocusLost" },
      border = "rounded",
      source = "always",
      prefix = " 󰌪 ",
      scope = "cursor",
    }
    vim.diagnostic.open_float(nil, opts)
  end,
})
--]]

-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

-- Turn off paste mode when leaving insert mode.
vim.api.nvim_create_autocmd("InsertLeave", {
	pattern = "*",
	command = "set nopaste",
})
