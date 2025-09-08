-- ========================================
-- Neovim Keymaps Configuration
-- ========================================

local keymap = vim.keymap

-- Better up/down
keymap.set({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
keymap.set({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })

-- Move to window using the <ctrl> hjkl keys
keymap.set("n", "<C-h>", "<C-w>h", { desc = "Go to left window" })
keymap.set("n", "<C-j>", "<C-w>j", { desc = "Go to lower window" })
keymap.set("n", "<C-k>", "<C-w>k", { desc = "Go to upper window" })
keymap.set("n", "<C-l>", "<C-w>l", { desc = "Go to right window" })

-- Resize window using <ctrl> arrow keys
keymap.set("n", "<C-Up>", "<cmd>resize +2<cr>", { desc = "Increase window height" })
keymap.set("n", "<C-Down>", "<cmd>resize -2<cr>", { desc = "Decrease window height" })
keymap.set("n", "<C-Left>", "<cmd>vertical resize -2<cr>", { desc = "Decrease window width" })
keymap.set("n", "<C-Right>", "<cmd>vertical resize +2<cr>", { desc = "Increase window width" })

-- Move Lines
keymap.set("n", "<A-j>", "<cmd>m .+1<cr>==", { desc = "Move line down" })
keymap.set("n", "<A-k>", "<cmd>m .-2<cr>==", { desc = "Move line up" })
keymap.set("i", "<A-j>", "<esc><cmd>m .+1<cr>==gi", { desc = "Move line down" })
keymap.set("i", "<A-k>", "<esc><cmd>m .-2<cr>==gi", { desc = "Move line up" })
keymap.set("v", "<A-j>", ":m '>+1<cr>gv=gv", { desc = "Move selection down" })
keymap.set("v", "<A-k>", ":m '<-2<cr>gv=gv", { desc = "Move selection up" })

-- Buffer navigation
keymap.set("n", "<S-h>", "<cmd>bprevious<cr>", { desc = "Prev buffer" })
keymap.set("n", "<S-l>", "<cmd>bnext<cr>", { desc = "Next buffer" })
keymap.set("n", "[b", "<cmd>bprevious<cr>", { desc = "Prev buffer" })
keymap.set("n", "]b", "<cmd>bnext<cr>", { desc = "Next buffer" })

-- Clear search with <esc>
keymap.set({ "i", "n" }, "<esc>", "<cmd>noh<cr><esc>", { desc = "Escape and clear hlsearch" })

-- Better indenting
keymap.set("v", "<", "<gv")
keymap.set("v", ">", ">gv")

-- Save file
keymap.set({ "i", "v", "n", "s" }, "<C-s>", "<cmd>w<cr><esc>", { desc = "Save file" })

-- Quit
keymap.set("n", "<leader>qq", "<cmd>qa<cr>", { desc = "Quit all" })

-- Highlights under cursor
if vim.fn.has("nvim-0.9.0") == 1 then
  keymap.set("n", "<leader>ui", vim.show_pos, { desc = "Inspect Pos" })
end

-- Terminal (moved to avoid conflict with todo telescope)
keymap.set("n", "<leader>T", "<cmd>terminal<cr>", { desc = "Terminal" })
keymap.set("n", "<c-/>", "<cmd>terminal<cr>", { desc = "Terminal" })
keymap.set("n", "<c-_>", "<cmd>terminal<cr>", { desc = "which_key_ignore" })

-- Terminal mappings
keymap.set("t", "<esc><esc>", "<c-\\><c-n>", { desc = "Enter Normal Mode" })
keymap.set("t", "<C-h>", "<cmd>wincmd h<cr>", { desc = "Go to left window" })
keymap.set("t", "<C-j>", "<cmd>wincmd j<cr>", { desc = "Go to lower window" })
keymap.set("t", "<C-k>", "<cmd>wincmd k<cr>", { desc = "Go to upper window" })
keymap.set("t", "<C-l>", "<cmd>wincmd l<cr>", { desc = "Go to right window" })
keymap.set("t", "<C-/>", "<cmd>close<cr>", { desc = "Hide Terminal" })
keymap.set("t", "<c-_>", "<cmd>close<cr>", { desc = "which_key_ignore" })

-- Windows
keymap.set("n", "<leader>ww", "<C-W>p", { desc = "Other window" })
keymap.set("n", "<leader>wd", "<C-W>c", { desc = "Delete window" })
keymap.set("n", "<leader>w-", "<C-W>s", { desc = "Split window below" })
keymap.set("n", "<leader>w|", "<C-W>v", { desc = "Split window right" })
keymap.set("n", "<leader>-", "<C-W>s", { desc = "Split window below" })
keymap.set("n", "<leader>|", "<C-W>v", { desc = "Split window right" })

-- Tabs
keymap.set("n", "<leader><tab>l", "<cmd>tablast<cr>", { desc = "Last Tab" })
keymap.set("n", "<leader><tab>f", "<cmd>tabfirst<cr>", { desc = "First Tab" })
keymap.set("n", "<leader><tab><tab>", "<cmd>tabnew<cr>", { desc = "New Tab" })
keymap.set("n", "<leader><tab>]", "<cmd>tabnext<cr>", { desc = "Next Tab" })
keymap.set("n", "<leader><tab>d", "<cmd>tabclose<cr>", { desc = "Close Tab" })
keymap.set("n", "<leader><tab>[", "<cmd>tabprevious<cr>", { desc = "Previous Tab" })

-- Code folding (basic Vim folding)
keymap.set("n", "zR", "zR", { desc = "Open all folds" })
keymap.set("n", "zM", "zM", { desc = "Close all folds" })
keymap.set("n", "za", "za", { desc = "Toggle fold" })

-- Quick fix list navigation
keymap.set("n", "[q", vim.cmd.cprev, { desc = "Previous quickfix" })
keymap.set("n", "]q", vim.cmd.cnext, { desc = "Next quickfix" })

-- Location list navigation
keymap.set("n", "[l", vim.cmd.lprev, { desc = "Previous location" })
keymap.set("n", "]l", vim.cmd.lnext, { desc = "Next location" })

-- Diagnostic navigation
local diagnostic_goto = function(next, severity)
  local go = next and vim.diagnostic.goto_next or vim.diagnostic.goto_prev
  severity = severity and vim.diagnostic.severity[severity] or nil
  return function()
    go({ severity = severity })
  end
end

keymap.set("n", "<leader>cd", vim.diagnostic.open_float, { desc = "Line Diagnostics" })
keymap.set("n", "]d", diagnostic_goto(true), { desc = "Next Diagnostic" })
keymap.set("n", "[d", diagnostic_goto(false), { desc = "Prev Diagnostic" })
keymap.set("n", "]e", diagnostic_goto(true, "ERROR"), { desc = "Next Error" })
keymap.set("n", "[e", diagnostic_goto(false, "ERROR"), { desc = "Prev Error" })
keymap.set("n", "]w", diagnostic_goto(true, "WARN"), { desc = "Next Warning" })
keymap.set("n", "[w", diagnostic_goto(false, "WARN"), { desc = "Prev Warning" })

-- ============================
-- EXTENDED KEYMAPS FROM BACKUP
-- ============================

-- clear search highlights
keymap.set("n", "<leader>nh", ":nohl<CR>", { desc = "Clear search highlights" })

-- Delete a word backwards
keymap.set("n", "dw", 'vb"_d', { desc = "Delete word backwards" })

-- ============================
-- TELESCOPE KEYMAPS - Lightning fast search optimized
-- ============================

-- Primary file finder - uses git when possible, falls back to fd
keymap.set("n", "<leader>ff", function()
  local is_git_repo = vim.fn.system("git rev-parse --is-inside-work-tree 2>/dev/null"):find("true")
  if is_git_repo then
    require("telescope.builtin").git_files({
      show_untracked = true,
      hidden = true,
      follow = true,
    })
  else
    require("telescope.builtin").find_files({
      hidden = true,
      no_ignore = false,
      follow = true,
    })
  end
end, { desc = "Smart find files (git-aware)" })

-- Fast file finder (always uses fd, ignores gitignore)
keymap.set("n", "<leader>fF", function()
  require("telescope.builtin").find_files({
    hidden = true,
    no_ignore = true,
    follow = true,
  })
end, { desc = "Find all files (ignore gitignore)" })

-- Git files only
keymap.set("n", "<leader>fg", "<cmd>Telescope git_files<cr>", { desc = "Find git files" })

-- Recent files with better filtering
keymap.set("n", "<leader>fr", function()
  require("telescope.builtin").oldfiles({
    cwd_only = true,
  })
end, { desc = "Find recent files (cwd only)" })

-- Lightning fast string search - uses ripgrep with optimizations
keymap.set("n", "<leader>fs", function()
  require("telescope.builtin").live_grep({
    additional_args = function()
      return {"--hidden", "--follow", "--smart-case"}
    end,
  })
end, { desc = "Live grep (fast)" })

-- Search in open buffers only (super fast)
keymap.set("n", "<leader>fb", function()
  require("telescope.builtin").live_grep({
    grep_open_files = true,
    prompt_title = "Live Grep in Open Files",
  })
end, { desc = "Search in open buffers" })

-- Fast grep current word under cursor
keymap.set("n", "<leader>fc", function()
  require("telescope.builtin").grep_string({
    additional_args = function()
      return {"--hidden", "--follow", "--smart-case"}
    end,
  })
end, { desc = "Find string under cursor" })

-- Search with type filtering (fast for specific file types)
keymap.set("n", "<leader>fp", function()
  require("telescope.builtin").live_grep({
    additional_args = function()
      return {"--hidden", "--follow", "--type", "py"}
    end,
    prompt_title = "Live Grep Python Files",
  })
end, { desc = "Search Python files" })

keymap.set("n", "<leader>fj", function()
  require("telescope.builtin").live_grep({
    additional_args = function()
      return {"--hidden", "--follow", "--type", "js", "--type", "ts", "--type", "jsx", "--type", "tsx"}
    end,
    prompt_title = "Live Grep JS/TS Files",
  })
end, { desc = "Search JS/TS files" })

-- Buffer picker (very fast)
keymap.set("n", "<leader>fB", "<cmd>Telescope buffers<cr>", { desc = "Find buffers" })

-- Todos
keymap.set("n", "<leader>ft", "<cmd>TodoTelescope<cr>", { desc = "Find todos" })

-- Help tags (useful for quick reference)
keymap.set("n", "<leader>fh", "<cmd>Telescope help_tags<cr>", { desc = "Find help" })

-- Advanced smart search functions (project-size aware)
local telescope_perf = require('config.telescope-performance')
keymap.set("n", "<leader>fS", telescope_perf.smart_find_files, { desc = "Smart find files (adaptive)" })
keymap.set("n", "<leader>fG", telescope_perf.smart_live_grep, { desc = "Smart live grep (adaptive)" })

-- Quick directory-specific searches
keymap.set("n", "<leader>fds", telescope_perf.search_src, { desc = "Search src directories" })
keymap.set("n", "<leader>fdt", telescope_perf.search_tests, { desc = "Search test directories" })
keymap.set("n", "<leader>fdc", telescope_perf.search_config, { desc = "Search config directories" })

-- ============================
-- WINDOW MANAGEMENT - Extended
-- ============================

-- window management
keymap.set("n", "<leader>sv", "<C-w>v", { desc = "Split window vertically" })
keymap.set("n", "<leader>sh", "<C-w>s", { desc = "Split window horizontally" })
keymap.set("n", "<leader>se", "<C-w>=", { desc = "Make splits equal size" })
keymap.set("n", "<leader>sx", "<cmd>close<CR>", { desc = "Close current split" })

keymap.set("n", "<leader>to", "<cmd>tabnew<CR>", { desc = "Open new tab" })
keymap.set("n", "<leader>tx", "<cmd>tabclose<CR>", { desc = "Close current tab" })
keymap.set("n", "<leader>tn", "<cmd>tabn<CR>", { desc = "Go to next tab" })
keymap.set("n", "<leader>tp", "<cmd>tabp<CR>", { desc = "Go to previous tab" })

-- ============================
-- MANUAL FORMATTING KEYMAPS 
-- ============================
-- (Auto-formatting on save is DISABLED)
-- FOLDING IS COMPLETELY MANUAL - No automatic fold operations during formatting

-- Primary formatting keymap - formats current file or selected range
keymap.set({ "n", "v" }, "<leader>mp", function() 
  require("conform").format({ 
    lsp_fallback = true, 
    async = false, 
    timeout_ms = 2000 
  })
end, { desc = "Format file or range (manual)" })

-- Lint current file
keymap.set("n", "<leader>ll", function() 
  require("lint").try_lint() 
end, { desc = "Trigger linting for current file" })

-- Format + Lint combo (for thorough cleanup)
keymap.set("n", "<leader>mf", function()
  -- Format first
  require("conform").format({ 
    lsp_fallback = true, 
    async = false, 
    timeout_ms = 2000 
  })
  
  -- Then lint after format completes
  vim.defer_fn(function()
    require("lint").try_lint()
  end, 100)
  
  vim.notify("Format + Lint completed", vim.log.levels.INFO)
end, { desc = "Format and lint current file" })

-- Quick format without LSP fallback (Conform formatters only)
keymap.set({ "n", "v" }, "<leader>mq", function() 
  require("conform").format({ 
    lsp_fallback = false,  -- Use only Conform formatters
    async = false, 
    timeout_ms = 2000 
  })
end, { desc = "Quick format (formatters only, no LSP)" })

-- Enable auto-formatting for current session (temporary)
keymap.set("n", "<leader>ma", function()
  vim.g.manual_format_session = not vim.g.manual_format_session
  local status = vim.g.manual_format_session and "ENABLED" or "DISABLED"
  vim.notify("Auto-format for session: " .. status, vim.log.levels.INFO)
  
  if vim.g.manual_format_session then
    vim.notify("Warning: This will format files on save until you restart Neovim", vim.log.levels.WARN)
  end
end, { desc = "Toggle auto-format for current session" })

-- ============================
-- TECH STACK SPECIFIC KEYMAPS
-- ============================

-- Python/Django keymaps
keymap.set("n", "<leader>pr", ":!python %<CR>", { desc = "Run Python file" })
keymap.set("n", "<leader>pm", ":!python manage.py", { desc = "Django manage.py command" })
keymap.set("n", "<leader>ps", ":!python manage.py runserver<CR>", { desc = "Start Django dev server" })
keymap.set("n", "<leader>psh", ":!python manage.py shell<CR>", { desc = "Django shell" })
keymap.set("n", "<leader>pdb", ":!python manage.py dbshell<CR>", { desc = "Django database shell" })

-- JavaScript/TypeScript keymaps
keymap.set("n", "<leader>jr", ":!node %<CR>", { desc = "Run JavaScript file" })
keymap.set("n", "<leader>jt", ":!npm test<CR>", { desc = "Run npm tests" })
keymap.set("n", "<leader>jd", ":!npm run dev<CR>", { desc = "Run npm dev server" })
keymap.set("n", "<leader>jb", ":!npm run build<CR>", { desc = "Build project" })
keymap.set("n", "<leader>ji", ":!npm install<CR>", { desc = "Install npm packages" })

-- Quick access to common config files
keymap.set("n", "<leader>ep", ":e pyproject.toml<CR>", { desc = "Edit pyproject.toml" })
keymap.set("n", "<leader>eR", ":e requirements.txt<CR>", { desc = "Edit requirements.txt" })
keymap.set("n", "<leader>ej", ":e package.json<CR>", { desc = "Edit package.json" })
keymap.set("n", "<leader>ed", ":e docker-compose.yml<CR>", { desc = "Edit docker-compose.yml" })
keymap.set("n", "<leader>edf", ":e Dockerfile<CR>", { desc = "Edit Dockerfile" })

-- Database and SQL keymaps
keymap.set("n", "<leader>sq", ":split | terminal sqlite3<CR>", { desc = "Open SQLite" })
keymap.set("n", "<leader>sp", ":split | terminal psql<CR>", { desc = "Open PostgreSQL" })

-- Quick terminal for development  
keymap.set("n", "<leader>term", ":split | terminal<CR>", { desc = "Open terminal" })
keymap.set("n", "<leader>tv", ":vsplit | terminal<CR>", { desc = "Open vertical terminal" })

-- ============================
-- DAP (Debug Adapter Protocol) KEYMAPS
-- ============================
-- Breakpoint management
keymap.set("n", "<leader>db", function() require('dap').toggle_breakpoint() end, { desc = "Toggle breakpoint" })
keymap.set("n", "<leader>dbc", function() 
  require('dap').set_breakpoint(vim.fn.input('Breakpoint condition: '))
end, { desc = "Set conditional breakpoint" })
keymap.set("n", "<leader>dbl", function() require('dap').list_breakpoints() end, { desc = "List breakpoints" })
keymap.set("n", "<leader>dca", function() require('dap').clear_breakpoints() end, { desc = "Clear all breakpoints" })

-- Debug session control
keymap.set("n", "<leader>dc", function() require('dap').continue() end, { desc = "Continue/Start debugging" })
keymap.set("n", "<leader>dso", function() require('dap').step_over() end, { desc = "Step over" })
keymap.set("n", "<leader>dsi", function() require('dap').step_into() end, { desc = "Step into" })
keymap.set("n", "<leader>dse", function() require('dap').step_out() end, { desc = "Step out" })
keymap.set("n", "<leader>dt", function() require('dap').terminate() end, { desc = "Terminate debug session" })
keymap.set("n", "<leader>dr", function() require('dap').restart() end, { desc = "Restart debug session" })

-- Debug UI
keymap.set("n", "<leader>du", function() require('dapui').toggle() end, { desc = "Toggle debug UI" })
keymap.set("n", "<leader>de", function() require('dapui').eval() end, { desc = "Evaluate expression" })
keymap.set("v", "<leader>de", function() require('dapui').eval() end, { desc = "Evaluate selection" })

-- REPL
keymap.set("n", "<leader>dre", function() require('dap').repl.toggle() end, { desc = "Toggle REPL" })
keymap.set("n", "<leader>drl", function() require('dap').run_last() end, { desc = "Run last debug configuration" })

-- Python-specific debugging
keymap.set("n", "<leader>dpt", function() require('dap-python').test_method() end, { desc = "Debug Python test method" })
keymap.set("n", "<leader>dpc", function() require('dap-python').test_class() end, { desc = "Debug Python test class" })
keymap.set("v", "<leader>dps", function() require('dap-python').debug_selection() end, { desc = "Debug Python selection" })

-- ============================
-- PYTHON ENVIRONMENT KEYMAPS
-- ============================

-- Pyright type checking toggle (works globally)
local pyright_diagnostics_enabled = true -- Start enabled by default

keymap.set("n", "<leader>tt", function()
  local clients = vim.lsp.get_clients({ name = "pyright" })
  if #clients == 0 then
    vim.notify("Pyright LSP not found. Make sure pyright is running for Python files.", vim.log.levels.WARN)
    return
  end
  
  -- Toggle the state
  pyright_diagnostics_enabled = not pyright_diagnostics_enabled
  
  -- Apply the new configuration to all pyright clients
  for _, client in ipairs(clients) do
    if pyright_diagnostics_enabled then
      -- Enable type checking diagnostics
      vim.diagnostic.config({
        virtual_text = {
          source = "if_many",
          prefix = "■",
        },
        signs = true,
        underline = true,
        update_in_insert = false,
        severity_sort = true,
      }, client.id)
      
      -- Show diagnostics for all Python buffers attached to this client
      for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].filetype == "python" then
          -- Check if this client is attached to this buffer
          local buf_clients = vim.lsp.get_clients({ bufnr = buf, name = "pyright" })
          if #buf_clients > 0 then
            vim.diagnostic.show(client.id, buf)
          end
        end
      end
    else
      -- Disable type checking diagnostics
      vim.diagnostic.config({
        virtual_text = false,
        signs = false,
        underline = false,
        update_in_insert = false,
      }, client.id)
      
      -- Hide diagnostics from all Python buffers attached to this client
      for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].filetype == "python" then
          local buf_clients = vim.lsp.get_clients({ bufnr = buf, name = "pyright" })
          if #buf_clients > 0 then
            vim.diagnostic.hide(client.id, buf)
          end
        end
      end
    end
  end
  
  -- Show status notification
  local status = pyright_diagnostics_enabled and "ON" or "OFF"
  vim.notify("Pyright type checking diagnostics: " .. status, vim.log.levels.INFO)
end, { desc = "Toggle Pyright type checking diagnostics" })

-- Python virtual environment keymaps (requires swenv plugin)
keymap.set("n", "<leader>pv", function() require("swenv").pick_venv() end, { desc = "Pick Python virtual environment" })

-- Python testing (requires neotest)
keymap.set("n", "<leader>tr", function() require("neotest").run.run() end, { desc = "Run nearest test" })
keymap.set("n", "<leader>tf", function() require("neotest").run.run(vim.fn.expand("%")) end, { desc = "Run test file" })
keymap.set("n", "<leader>td", function() require("neotest").run.run({strategy = "dap"}) end, { desc = "Debug nearest test" })
keymap.set("n", "<leader>ts", function() require("neotest").summary.toggle() end, { desc = "Toggle test summary" })
keymap.set("n", "<leader>tO", function() require("neotest").output.open({ enter = true }) end, { desc = "Show test Output" })
