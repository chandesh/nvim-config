-- ~/.config/nvim/lua/config/keymaps.lua
-- =============================================================================
-- Neovim Keymaps Configuration
-- Organized by functional groups.
-- =============================================================================

local keymap = vim.keymap

local Snacks = require('snacks')
local popup = require('config.popup')
local local_history = require('config.local_history')

-- ── General Navigation ──────────────────────────────────────────────────────
-- Better up/down (handles wrapped lines)
keymap.set({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
keymap.set({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })

-- Window navigation (Ctrl + hjkl)
keymap.set("n", "<C-h>", "<C-w>h", { desc = "Go to left window" })
keymap.set("n", "<C-j>", "<C-w>j", { desc = "Go to lower window" })
keymap.set("n", "<C-k>", "<C-w>k", { desc = "Go to upper window" })
keymap.set("n", "<C-l>", "<C-w>l", { desc = "Go to right window" })

-- Window resizing (Ctrl + arrows)
keymap.set("n", "<C-Up>", "<cmd>resize +2<cr>", { desc = "Increase window height" })
keymap.set("n", "<C-Down>", "<cmd>resize -2<cr>", { desc = "Decrease window height" })
keymap.set("n", "<C-Left>", "<cmd>vertical resize -2<cr>", { desc = "Decrease window width" })
keymap.set("n", "<C-Right>", "<cmd>vertical resize +2<cr>", { desc = "Increase window width" })

-- Buffer navigation
keymap.set("n", "<S-h>", "<cmd>bprevious<cr>", { desc = "Prev buffer" })
keymap.set("n", "<S-l>", "<cmd>bnext<cr>", { desc = "Next buffer" })
keymap.set("n", "[b", "<cmd>bprevious<cr>", { desc = "Prev buffer" })
keymap.set("n", "]b", "<cmd>bnext<cr>", { desc = "Next buffer" })

-- ── Editing & Utility ─────────────────────────────────────────────────────────
-- Clear search highlights on Esc
keymap.set({ "i", "n" }, "<esc>", "<cmd>noh<cr><esc>", { desc = "Escape and clear hlsearch" })

-- Better indenting in visual mode
keymap.set("v", "<", "<gv")
keymap.set("v", ">", ">gv")

-- Save file (Ctrl + s)
keymap.set({ "i", "v", "n", "s" }, "<C-s>", "<cmd>w<cr><esc>", { desc = "Save file" })

-- Quit Neovim
keymap.set("n", "<leader>qq", "<cmd>qa<cr>", { desc = "Quit all" })

-- Inspect position
if vim.fn.has("nvim-0.9.0") == 1 then
  keymap.set("n", "<leader>ui", vim.show_pos, { desc = "Inspect Pos" })
end

-- ── Terminal ────────────────────────────────────────────────────────────────
keymap.set("n", "<leader>T", function() Snacks.terminal() end, { desc = "Terminal" })
keymap.set("n", "<c-/>", function() Snacks.terminal() end, { desc = "Terminal" })

-- Terminal mode mappings
keymap.set("t", "<esc><esc>", "<c-\\><c-n>", { desc = "Enter Normal Mode" })
keymap.set("t", "<C-h>", "<cmd>wincmd h<cr>", { desc = "Go to left window" })
keymap.set("t", "<C-j>", "<cmd>wincmd j<cr>", { desc = "Go to lower window" })
keymap.set("t", "<C-k>", "<cmd>wincmd k<cr>", { desc = "Go to upper window" })
keymap.set("t", "<C-l>", "<cmd>wincmd l<cr>", { desc = "Go to right window" })
keymap.set("t", "<C-/>", "<cmd>close<cr>", { desc = "Hide Terminal" })

-- ── Window & Tab Management ─────────────────────────────────────────────────
keymap.set("n", "<leader>ww", "<C-W>p", { desc = "Other window" })
keymap.set("n", "<leader>wd", "<C-W>c", { desc = "Delete window" })
keymap.set("n", "<leader>w-", "<C-W>s", { desc = "Split window below" })
keymap.set("n", "<leader>w|", "<C-W>v", { desc = "Split window right" })
keymap.set("n", "<leader>-", "<C-W>s", { desc = "Split window below" })
keymap.set("n", "<leader>|", "<C-W>v", { desc = "Split window right" })
keymap.set("n", "<leader>ee", function() Snacks.explorer() end, { desc = "Toggle file explorer" })

keymap.set("n", "<leader><tab>l", "<cmd>tablast<cr>", { desc = "Last Tab" })
keymap.set("n", "<leader><tab>f", "<cmd>tabfirst<cr>", { desc = "First Tab" })
keymap.set("n", "<leader><tab><tab>", "<cmd>tabnew<cr>", { desc = "New Tab" })
keymap.set("n", "<leader><tab>]", "<cmd>tabnext<cr>", { desc = "Next Tab" })
keymap.set("n", "<leader><tab>d", "<cmd>tabclose<cr>", { desc = "Close Tab" })
keymap.set("n", "<leader><tab>[", "<cmd>tabprevious<cr>", { desc = "Previous Tab" })

-- ── Folding & Quickfix ───────────────────────────────────────────────────────
keymap.set("n", "zR", "zR", { desc = "Open all folds" })
keymap.set("n", "zM", "zM", { desc = "Close all folds" })
keymap.set("n", "za", "za", { desc = "Toggle fold" })

keymap.set("n", "[q", vim.cmd.cprev, { desc = "Previous quickfix" })
keymap.set("n", "]q", vim.cmd.cnext, { desc = "Next quickfix" })
keymap.set("n", "[l", vim.cmd.lprev, { desc = "Previous location" })
keymap.set("n", "]l", vim.cmd.lnext, { desc = "Next location" })

-- ── Diagnostics ─────────────────────────────────────────────────────────────
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

-- ── Snacks Picker (Fast Search) ────────────────────────────────────────────
keymap.set("n", "<leader>ff", function() Snacks.picker.files() end, { desc = "Smart find files" })
keymap.set("n", "<leader>fF", function() Snacks.picker.files({ ignored = true }) end, { desc = "Find all files (ignore gitignore)" })
keymap.set("n", "<leader>fg", function() Snacks.picker.git_files() end, { desc = "Find git files" })
keymap.set("n", "<leader>fr", function() Snacks.picker.recent({ filter = { cwd = true } }) end, { desc = "Find recent files (cwd only)" })
keymap.set("n", "<leader>fs", function() Snacks.picker.grep() end, { desc = "Live grep (fast)" })
keymap.set("n", "<leader>fb", function() Snacks.picker.grep_buffers() end, { desc = "Search in open buffers" })
keymap.set("n", "<leader>fc", function() Snacks.picker.grep_word() end, { desc = "Find string under cursor" })
keymap.set("n", "<leader>fp", function() Snacks.picker.grep({ glob = "*.py" }) end, { desc = "Search Python files" })
keymap.set("n", "<leader>fj", function() Snacks.picker.grep({ glob = "*.{js,ts,jsx,tsx}" }) end, { desc = "Search JS/TS files" })
keymap.set("n", "<leader>fB", function() Snacks.picker.buffers() end, { desc = "Find buffers" })
keymap.set("n", "<leader>ft", function() Snacks.picker.grep({ search = "TODO|FIXME|HACK|WARN|PERF|NOTE" }) end, { desc = "Find TODOs" })
keymap.set("n", "<leader>fT", function() Snacks.picker.colorschemes() end, { desc = "Switch themes" })
keymap.set("n", "<leader>fh", function() Snacks.picker.help() end, { desc = "Find help" })

-- ── Formatting & Linting ────────────────────────────────────────────────────
keymap.set({ "n", "v" }, "<leader>mp", function() 
  require("conform").format({ lsp_fallback = true, async = false, timeout_ms = 2000 })
end, { desc = "Format file or range (manual)" })

keymap.set("n", "<leader>ll", function() 
  require("lint").try_lint() 
end, { desc = "Trigger linting for current file" })

keymap.set("n", "<leader>mf", function()
  require("conform").format({ lsp_fallback = true, async = false, timeout_ms = 2000 })
  vim.defer_fn(function() require("lint").try_lint() end, 100)
  vim.notify("Format + Lint completed", vim.log.levels.INFO)
end, { desc = "Format and lint current file" })

-- ── Tech Stack Specific ──────────────────────────────────────────────────────
-- Python/Django
keymap.set("n", "<leader>pr", ":!python %<CR>", { desc = "Run Python file" })
keymap.set("n", "<leader>pm", ":!python manage.py", { desc = "Django manage.py command" })
keymap.set("n", "<leader>ps", ":!python manage.py runserver<CR>", { desc = "Start Django dev server" })
keymap.set("n", "<leader>psh", ":!python manage.py shell<CR>", { desc = "Django shell" })
keymap.set("n", "<leader>pdb", ":!python manage.py dbshell<CR>", { desc = "Django database shell" })

-- JS/TS/Node
keymap.set("n", "<leader>jr", ":!node %<CR>", { desc = "Run JavaScript file" })
keymap.set("n", "<leader>jt", ":!npm test<CR>", { desc = "Run npm tests" })
keymap.set("n", "<leader>jd", ":!npm run dev<CR>", { desc = "Run npm dev server" })
keymap.set("n", "<leader>jb", ":!npm run build<CR>", { desc = "Build project" })
keymap.set("n", "<leader>ji", ":!npm install<CR>", { desc = "Install npm packages" })

-- Quick access to config files
keymap.set("n", "<leader>ep", ":e pyproject.toml<CR>", { desc = "Edit pyproject.toml" })
keymap.set("n", "<leader>eR", ":e requirements.txt<CR>", { desc = "Edit requirements.txt" })
keymap.set("n", "<leader>ej", ":e package.json<CR>", { desc = "Edit package.json" })
keymap.set("n", "<leader>ed", ":e docker-compose.yml<CR>", { desc = "Edit docker-compose.yml" })
keymap.set("n", "<leader>edf", ":e Dockerfile<CR>", { desc = "Edit Dockerfile" })

-- ── Debugger (DAP) ───────────────────────────────────────────────────────────
local pack_map = {
  dap = "nvim-dap",
  dapui = "nvim-dap-ui",
  ["dap-python"] = "nvim-dap-python",
}

local function safe_require(mod, fn)
  return function()
    local ok, m = pcall(require, mod)
    if not ok then
      local pack_name = pack_map[mod] or "nvim-" .. mod
      pcall(vim.cmd, "packadd " .. pack_name)
      ok, m = pcall(require, mod)
    end
    if not ok then
      vim.notify(mod .. " not installed", vim.log.levels.WARN)
      return
    end
    return fn(m)
  end
end

keymap.set("n", "<leader>db", safe_require('dap', function(d) d.toggle_breakpoint() end), { desc = "Toggle breakpoint" })
keymap.set("n", "<leader>dbc", safe_require('dap', function(d) d.set_breakpoint(vim.fn.input('Breakpoint condition: ')) end), { desc = "Set conditional breakpoint" })
keymap.set("n", "<leader>dbl", safe_require('dap', function(d) d.list_breakpoints() end), { desc = "List breakpoints" })
keymap.set("n", "<leader>dca", safe_require('dap', function(d) d.clear_breakpoints() end), { desc = "Clear all breakpoints" })
keymap.set("n", "<leader>dc", safe_require('dap', function(d) d.continue() end), { desc = "Continue/Start debugging" })
keymap.set("n", "<leader>dso", safe_require('dap', function(d) d.step_over() end), { desc = "Step over" })
keymap.set("n", "<leader>dsi", safe_require('dap', function(d) d.step_into() end), { desc = "Step into" })
keymap.set("n", "<leader>dse", safe_require('dap', function(d) d.step_out() end), { desc = "Step out" })
keymap.set("n", "<leader>dre", safe_require('dap', function(d) d.repl.toggle() end), { desc = "Toggle REPL" })
keymap.set("n", "<leader>drl", safe_require('dap', function(d) d.run_last() end), { desc = "Run last debug configuration" })
keymap.set("n", "<leader>dt", safe_require('dap', function(d) d.terminate() end), { desc = "Terminate debug session" })
keymap.set("n", "<leader>dr", safe_require('dap', function(d) d.restart() end), { desc = "Restart debug session" })
keymap.set("n", "<leader>du", safe_require('dapui', function(d) d.toggle() end), { desc = "Toggle debug UI" })
keymap.set("n", "<leader>de", safe_require('dapui', function(d) d.eval() end), { desc = "Evaluate expression" })
keymap.set("v", "<leader>de", safe_require('dapui', function(d) d.eval() end), { desc = "Evaluate selection" })
keymap.set("n", "<leader>dpt", safe_require('dap-python', function(d) d.test_method() end), { desc = "Debug Python test method" })
keymap.set("n", "<leader>dpc", safe_require('dap-python', function(d) d.test_class() end), { desc = "Debug Python test class" })
keymap.set("v", "<leader>dps", safe_require('dap-python', function(d) d.debug_selection() end), { desc = "Debug Python selection" })

-- ── Pyright Diagnostics Toggle ──────────────────────────────────────────────
local pyright_diagnostics_enabled = true
keymap.set("n", "<leader>tt", function()
  local pyright_clients = vim.lsp.get_clients({ name = "pyright" })
  if #pyright_clients == 0 then
    vim.notify("No Pyright LSP server found.", vim.log.levels.WARN)
    return
  end
  pyright_diagnostics_enabled = not pyright_diagnostics_enabled
  for _, client in ipairs(pyright_clients) do
    if pyright_diagnostics_enabled then
      vim.diagnostic.config({ virtual_text = true, signs = true, underline = true }, client.id)
    else
      vim.diagnostic.config({ virtual_text = false, signs = false, underline = false }, client.id)
    end
  end
  vim.notify("Pyright diagnostics: " .. (pyright_diagnostics_enabled and "ON" or "OFF"), vim.log.levels.INFO)
end, { desc = "Toggle Pyright diagnostics" })

-- ── Git Integration (<leader>g) via LazyGit + Snacks pickers ──────────────
keymap.set("n", "<leader>gg", function() Snacks.lazygit() end, { desc = "LazyGit" })
keymap.set("n", "<leader>gs", function() Snacks.lazygit() end, { desc = "LazyGit status" })
keymap.set("n", "<leader>gl", function() Snacks.picker.git_log() end, { desc = "Git Log" })
keymap.set("n", "<leader>gB", function() Snacks.picker.git_branches() end, { desc = "Git Branches" })
keymap.set("n", "<leader>gS", function() Snacks.picker.git_stash() end, { desc = "Git Stash" })
keymap.set("n", "<leader>gd", function() Snacks.picker.git_diff() end, { desc = "Git Diff (Hunks)" })
keymap.set("n", "<leader>gf", function() Snacks.picker.git_log_file() end, { desc = "Git Log File" })
keymap.set("n", "<leader>gp", function() Snacks.lazygit() end, { desc = "LazyGit (push)" })
keymap.set("n", "<leader>gP", function() Snacks.lazygit() end, { desc = "LazyGit (pull)" })

-- ── History & Backups ────────────────────────────────────────────────────────
keymap.set("n", "<leader>hf", local_history.show_history, { desc = "Local file history (snapshots)" })
keymap.set("n", "<leader>hs", local_history.create_manual_snapshot, { desc = "Create manual snapshot" })
keymap.set("n", "<leader>hL", local_history.list_files, { desc = "List tracked files" })
keymap.set("n", "<leader>hl", function() Snacks.picker.undo() end, { desc = "Undo history" })
keymap.set("n", "<leader>hr", function() Snacks.picker.recent({ filter = { cwd = true } }) end, { desc = "Recent files" })
keymap.set("n", "<leader>hR", function() Snacks.picker.recent() end, { desc = "All recent files" })
keymap.set("n", "<leader>hS", function()
  vim.cmd("write")
  vim.notify("File saved at " .. vim.fn.strftime("%H:%M:%S"), vim.log.levels.INFO)
end, { desc = "Save file with timestamp" })
keymap.set("n", "<leader>ha", function()
  vim.g.auto_save_enabled = not vim.g.auto_save_enabled
  local status = vim.g.auto_save_enabled and "ENABLED" or "DISABLED"
  vim.notify("Auto-save: " .. status, vim.log.levels.INFO)
end, { desc = "Toggle auto-save" })
keymap.set("n", "<leader>hb", function()
  local backup_dir = vim.fn.stdpath("data") .. "/backups"
  if vim.fn.isdirectory(backup_dir) == 0 then
    vim.fn.mkdir(backup_dir, "p")
  end
  local current_file = vim.fn.expand("%:p")
  local filename = vim.fn.expand("%:t")
  local timestamp = vim.fn.strftime("%Y%m%d_%H%M%S")
  local backup_file = backup_dir .. "/" .. filename .. "_" .. timestamp .. ".bak"
  vim.fn.writefile(vim.fn.readfile(current_file), backup_file)
  vim.notify("Backup created: " .. backup_file, vim.log.levels.INFO)
end, { desc = "Create timestamped backup" })

-- ── Window Splits ──────────────────────────────────────────────────────────
keymap.set("n", "<leader>sv", "<C-w>v", { desc = "Split window vertically" })
keymap.set("n", "<leader>sh", "<C-w>s", { desc = "Split window horizontally" })
keymap.set("n", "<leader>se", "<C-w>=", { desc = "Make splits equal size" })
keymap.set("n", "<leader>sx", "<cmd>close<cr>", { desc = "Close current window" })

-- ── LSP Navigation (via picker) ────────────────────────────────────────────
keymap.set("n", "gd", function() Snacks.picker.lsp_definitions() end, { desc = "Go to Definition" })
keymap.set("n", "gD", function() Snacks.picker.lsp_declarations() end, { desc = "Go to Declaration" })
keymap.set("n", "gi", function() Snacks.picker.lsp_implementations() end, { desc = "Go to Implementation" })
keymap.set("n", "gy", function() Snacks.picker.lsp_type_definitions() end, { desc = "Go to Type Definition" })
keymap.set("n", "gr", function() Snacks.picker.lsp_references() end, { desc = "Go to References" })

-- ── Tab Management ─────────────────────────────────────────────────────────
keymap.set("n", "<leader>to", "<cmd>tabnew<CR>", { desc = "Open new tab" })
keymap.set("n", "<leader>tx", "<cmd>tabclose<CR>", { desc = "Close current tab" })
keymap.set("n", "<leader>tn", "<cmd>tabn<CR>", { desc = "Go to next tab" })
keymap.set("n", "<leader>tp", "<cmd>tabp<CR>", { desc = "Go to previous tab" })

-- ── Terminal (additional) ──────────────────────────────────────────────────
keymap.set("n", "<leader>term", ":split | terminal<CR>", { desc = "Open terminal" })
keymap.set("n", "<leader>tv", ":vsplit | terminal<CR>", { desc = "Open vertical terminal" })

-- ── Format & Lint (additional) ─────────────────────────────────────────────
keymap.set({ "n", "v" }, "<leader>mq", function()
  require("conform").format({ lsp_fallback = false, async = false, timeout_ms = 2000 })
end, { desc = "Quick format (formatters only, no LSP)" })
keymap.set("n", "<leader>ma", function()
  vim.g.manual_format_session = not vim.g.manual_format_session
  local status = vim.g.manual_format_session and "ENABLED" or "DISABLED"
  vim.notify("Auto-format for session: " .. status, vim.log.levels.INFO)
end, { desc = "Toggle auto-format for current session" })

-- ── Python Environment ─────────────────────────────────────────────────────
keymap.set("n", "<leader>pv", function()
  local ok, swenv = pcall(require, "swenv")
  if ok then swenv.pick_venv() end
end, { desc = "Pick Python virtual environment" })

-- ── Database & SQL ─────────────────────────────────────────────────────────
keymap.set("n", "<leader>sq", ":split | terminal sqlite3<CR>", { desc = "Open SQLite" })
keymap.set("n", "<leader>sp", ":split | terminal psql<CR>", { desc = "Open PostgreSQL" })

-- ── Tree-sitter Maintenance ────────────────────────────────────────────────
keymap.set("n", "<leader>tc", "<cmd>TSCheck<cr>", { desc = "Check Tree-sitter parsers" })
keymap.set("n", "<leader>tC", "<cmd>TSCleanup<cr>", { desc = "Cleanup Tree-sitter temp files" })

-- ── Spectre (Search & Replace) ──────────────────────────────────────────────
local function register_spectre()
  vim.defer_fn(function()
    for _, win in ipairs(vim.api.nvim_list_wins()) do
      if vim.api.nvim_win_get_config(win).relative ~= '' then
        popup.register_popup(win, 'spectre')
      end
    end
  end, 100)
end

keymap.set("n", "<leader>sr", function()
  popup.save_origin()
  require("spectre").open()
  register_spectre()
end, { desc = "Open Spectre (search & replace)" })
keymap.set("n", "<leader>sw", function()
  popup.save_origin()
  require("spectre").open_visual({ select_word = true })
  register_spectre()
end, { desc = "Search current word" })
keymap.set("v", "<leader>sw", function()
  popup.save_origin()
  require("spectre").open_visual()
  register_spectre()
end, { desc = "Search current selection" })

-- ── Window Maximize (Zoom) ──────────────────────────────────────────────────
keymap.set("n", "<leader>sm", function() Snacks.zen.zoom() end, { desc = "Toggle zoom" })

-- ── Misc ──────────────────────────────────────────────────────────────────
keymap.set("n", "<leader>nh", ":nohl<CR>", { desc = "Clear search highlights" })
keymap.set("n", "dw", 'vb"_d', { desc = " " })
keymap.set("n", "s", "<nop>", { desc = "Disabled substitute" })
