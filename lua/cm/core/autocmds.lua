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
    
-- Python-specific folding: start closed, preserve state during session
    vim.opt_local.foldlevelstart = 0  -- Start with folds closed for Python files
    
    -- Apply initial folding only on first load (not on buffer switches or saves)
    -- Use buffer-local variable to track initialization state
    local buf = vim.api.nvim_get_current_buf()
    
    -- Check if this is truly the first time this buffer is being set up
    -- by checking both the flag and if folding has been manually modified
    if not vim.b[buf].python_folds_initialized then
      vim.b[buf].python_folds_initialized = true
      
      -- Defer initial folding to let treesitter/ufo set up properly
      vim.defer_fn(function()
        -- Double-check we're still in the same buffer and it's still Python
        if vim.api.nvim_get_current_buf() == buf and vim.bo[buf].filetype == "python" then
          -- Only apply initial folding if no manual fold operations have occurred
          if not vim.b[buf].manual_fold_operation then
            -- Close all folds initially, then open to show function/class signatures
            vim.cmd("silent! normal! zM")
            vim.cmd("silent! normal! zr")
            
            -- Mark that we've applied the initial fold state
            vim.b[buf].initial_folds_applied = true
          end
        end
      end, 300)  -- Increased delay to ensure UFO is fully loaded
    end
    
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

-- Remove trailing whitespace on save (runs before formatters)
autocmd("BufWritePre", {
  group = general_group,
  pattern = { "*.py", "*.js", "*.ts", "*.jsx", "*.tsx", "*.css", "*.scss", "*.sass", "*.less", "*.lua", "*.sh", "*.bash", "*.zsh" },
  callback = function()
    -- Only remove trailing whitespace, don't interfere with formatters
    local ok, err = pcall(function()
      -- Save cursor position
      local save_cursor = vim.fn.getpos(".")
      local save_view = vim.fn.winsaveview()
      
      -- Remove trailing whitespace silently
      vim.cmd([[silent! %s/\s\+$//e]])
      
      -- Restore cursor and view
      vim.fn.winrestview(save_view)
      vim.fn.setpos(".", save_cursor)
    end)
    if not ok then
      vim.notify("Error removing trailing whitespace: " .. tostring(err), vim.log.levels.WARN)
    end
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

-- Shell-specific configurations
local shell_group = augroup("ShellSettings", { clear = true })

-- Handle shell files specifically to avoid conflicts
autocmd("FileType", {
  group = shell_group,
  pattern = { "sh", "bash", "zsh" },
  callback = function()
    -- Set shell-specific options
    vim.opt_local.tabstop = 4
    vim.opt_local.shiftwidth = 4
    vim.opt_local.expandtab = true

    -- Note: Folding configuration moved to BufReadPost to avoid reapplication on save

    -- Ensure Conform uses the correct formatter for shell files
    -- This overrides any LSP fallback that might try to use Python formatters
    local ok, conform = pcall(require, "conform")
    if ok then
      -- Clear any conflicting formatters and set shell-specific ones
      conform.formatters_by_ft = conform.formatters_by_ft or {}
      local filetype = vim.bo.filetype
      if filetype == "sh" or filetype == "bash" or filetype == "zsh" then
        conform.formatters_by_ft[filetype] = { "shfmt" }
      end
    end
  end,
})

-- Explicit filetype detection for shell scripts
autocmd({ "BufRead", "BufNewFile" }, {
  group = shell_group,
  pattern = { "*.sh", "*.bash", "*.zsh" },
  callback = function()
    local filename = vim.fn.expand("%:t")
    local filepath = vim.fn.expand("%:p")
    
    -- Set filetype based on extension or shebang
    if filename:match("%.sh$") then
      vim.bo.filetype = "sh"
    elseif filename:match("%.bash$") then
      vim.bo.filetype = "bash"
    elseif filename:match("%.zsh$") then
      vim.bo.filetype = "zsh"
    else
      -- Check shebang for files without clear extensions
      local first_line = vim.fn.getline(1)
      if first_line:match("^#!/.*bash") then
        vim.bo.filetype = "bash"
      elseif first_line:match("^#!/.*zsh") then
        vim.bo.filetype = "zsh"
      elseif first_line:match("^#!/.*sh") or first_line:match("^#!/bin/sh") then
        vim.bo.filetype = "sh"
      end
    end
    
    -- Debug output (can be removed in production)
    if vim.env.DEBUG_FILETYPE then
      vim.notify(string.format("Shell file detected: %s -> filetype: %s", filename, vim.bo.filetype), vim.log.levels.INFO)
    end
  end,
})

-- LSP-specific autocmds (renamed to avoid conflict with none-ls)
local lsp_group = augroup("LspDiagnostics", { clear = true })

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

-- Reset fold initialization state when Python buffer is closed
-- This ensures folds start closed again when file is reopened
autocmd({ "BufWinLeave", "BufUnload" }, {
  group = python_group,
  pattern = "*.py",
  callback = function()
    -- Reset the fold initialization flag so folds start closed on next open
    vim.b.python_folds_initialized = nil
  end,
})

-- JavaScript/TypeScript specific configurations
local js_group = augroup("JavaScriptSettings", { clear = true })

autocmd("FileType", {
  group = js_group,
  pattern = { "javascript", "typescript", "javascriptreact", "typescriptreact" },
  callback = function()
    -- Set JavaScript-specific options
    vim.opt_local.tabstop = 2
    vim.opt_local.shiftwidth = 2
    vim.opt_local.softtabstop = 2
    vim.opt_local.expandtab = true
    vim.opt_local.textwidth = 100
    vim.opt_local.colorcolumn = "100"

    -- Note: Folding configuration moved to BufReadPost to avoid reapplication on save
  end,
})

-- CSS specific configurations
local css_group = augroup("CSSSettings", { clear = true })

autocmd("FileType", {
  group = css_group,
  pattern = { "css", "scss", "sass", "less" },
  callback = function()
    -- Set CSS-specific options
    vim.opt_local.tabstop = 2
    vim.opt_local.shiftwidth = 2
    vim.opt_local.softtabstop = 2
    vim.opt_local.expandtab = true
    vim.opt_local.textwidth = 120
    vim.opt_local.colorcolumn = "120"
    
    -- Note: Folding configuration moved to BufReadPost to avoid reapplication on save
  end,
})

-- Reset fold initialization state for shell files
autocmd({ "BufWinLeave", "BufUnload" }, {
  group = shell_group,
  pattern = { "*.sh", "*.bash", "*.zsh" },
  callback = function()
    vim.b.shell_folds_initialized = nil
  end,
})

-- Reset fold initialization state for JavaScript files
autocmd({ "BufWinLeave", "BufUnload" }, {
  group = js_group,
  pattern = { "*.js", "*.ts", "*.jsx", "*.tsx" },
  callback = function()
    vim.b.js_folds_initialized = nil
  end,
})

-- Reset fold initialization state for CSS files
autocmd({ "BufWinLeave", "BufUnload" }, {
  group = css_group,
  pattern = { "*.css", "*.scss", "*.sass", "*.less" },
  callback = function()
    vim.b.css_folds_initialized = nil
  end,
})

-- Folding configurations temporarily disabled to debug the save-triggered folding issue
-- TODO: Re-enable after identifying the root cause
