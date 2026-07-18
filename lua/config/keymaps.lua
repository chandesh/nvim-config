-- ~/.config/nvim/lua/config/keymaps.lua
-- =============================================================================
-- Neovim Keymaps Configuration
-- Organized by functional groups.
-- =============================================================================

local keymap = vim.keymap

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
keymap.set("n", "<leader>T", "<cmd>terminal<cr>", { desc = "Terminal" })
keymap.set("n", "<c-/>", "<cmd>terminal<cr>", { desc = "Terminal" })

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

-- ── Telescope (Fast Search) ──────────────────────────────────────────────────
-- Primary find files (git-aware)
keymap.set("n", "<leader>ff", function()
  local is_git_repo = vim.fn.system("git rev-parse --is-inside-work-tree 2>/dev/null"):find("true")
  if is_git_repo then
    require("telescope.builtin").git_files({
      cwd = vim.fn.getcwd(),
      show_untracked = true,
      hidden = true,
      follow = true,
    })
  else
    require("telescope.builtin").find_files({
      cwd = vim.fn.getcwd(),
      hidden = true,
      no_ignore = false,
      follow = true,
    })
  end
end, { desc = "Smart find files (git-aware)" })

keymap.set("n", "<leader>fF", function()
  require("telescope.builtin").find_files({ hidden = true, no_ignore = true, follow = true })
end, { desc = "Find all files (ignore gitignore)" })

keymap.set("n", "<leader>fg", "<cmd>Telescope git_files<cr>", { desc = "Find git files" })
keymap.set("n", "<leader>fr", function()
  require("telescope.builtin").oldfiles({ cwd_only = true })
end, { desc = "Find recent files (cwd only)" })

keymap.set("n", "<leader>fs", function()
  require("telescope.builtin").live_grep({
    additional_args = function() return {"--hidden", "--follow", "--smart-case"} end,
  })
end, { desc = "Live grep (fast)" })

keymap.set("n", "<leader>fb", function()
  require("telescope.builtin").live_grep({
    grep_open_files = true,
    prompt_title = "Live Grep in Open Files",
  })
end, { desc = "Search in open buffers" })

keymap.set("n", "<leader>fc", function()
  require("telescope.builtin").grep_string({
    additional_args = function() return {"--hidden", "--follow", "--smart-case"} end,
  })
end, { desc = "Find string under cursor" })

keymap.set("n", "<leader>fp", function()
  require("telescope.builtin").live_grep({
    additional_args = function() return {"--hidden", "--follow", "--type", "py"} end,
    prompt_title = "Live Grep Python Files",
  })
end, { desc = "Search Python files" })

keymap.set("n", "<leader>fj", function()
  require("telescope.builtin").live_grep({
    additional_args = function() return {"--hidden", "--follow", "--type", "js", "--type", "ts", "--type", "jsx", "--type", "tsx"} end,
    prompt_title = "Live Grep JS/TS Files",
  })
end, { desc = "Search JS/TS files" })

keymap.set("n", "<leader>fB", "<cmd>Telescope buffers<cr>", { desc = "Find buffers" })
keymap.set("n", "<leader>ft", "<cmd>TodoTelescope<cr>", { desc = "Find todos" })
keymap.set("n", "<leader>fT", "<cmd>Telescope themes<cr>", { desc = "Switch themes" })
keymap.set("n", "<leader>fh", "<cmd>Telescope help_tags<cr>", { desc = "Find help" })

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
keymap.set("n", "<leader>db", function() require('dap').toggle_breakpoint() end, { desc = "Toggle breakpoint" })
keymap.set("n", "<leader>dbc", function() require('dap').set_breakpoint(vim.fn.input('Breakpoint condition: ')) end, { desc = "Set conditional breakpoint" })
keymap.set("n", "<leader>dbl", function() require('dap').list_breakpoints() end, { desc = "List breakpoints" })
keymap.set("n", "<leader>dca", function() require('dap').clear_breakpoints() end, { desc = "Clear all breakpoints" })
keymap.set("n", "<leader>dc", function() require('dap').continue() end, { desc = "Continue/Start debugging" })
keymap.set("n", "<leader>dso", function() require('dap').step_over() end, { desc = "Step over" })
keymap.set("n", "<leader>dsi", function() require('dap').step_into() end, { desc = "Step into" })
keymap.set("n", "<leader>dse", function() require('dap').step_out() end, { desc = "Step out" })
keymap.set("n", "<leader>du", function() require('dapui').toggle() end, { desc = "Toggle debug UI" })
keymap.set("n", "<leader>de", function() require('dapui').eval() end, { desc = "Evaluate expression" })
keymap.set("v", "<leader>de", function() require('dapui').eval() end, { desc = "Evaluate selection" })
keymap.set("n", "<leader>dre", function() require('dap').repl.toggle() end, { desc = "Toggle REPL" })
keymap.set("n", "<leader>drl", function() require('dap').run_last() end, { desc = "Run last debug configuration" })

-- Python specific debug
keymap.set("n", "<leader>dpt", function() require('dap-python').test_method() end, { desc = "Debug Python test method" })
keymap.set("n", "<leader>dpc", function() require('dap-python').test_class() end, { desc = "Debug Python test class" })
keymap.set("v", "<leader>dps", function() require('dap-python').debug_selection() end, { desc = "Debug Python selection" })

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

-- ── History & Backups ────────────────────────────────────────────────────────
keymap.set("n", "<leader>hu", "<cmd>UndotreeToggle<cr>", { desc = "Toggle undo tree" })
keymap.set("n", "<leader>hf", "<cmd>GV!<cr>", { desc = "File history (current file)" })
keymap.set("n", "<leader>hF", "<cmd>GV<cr>", { desc = "Full commit history" })
keymap.set("n", "<leader>ho", "<cmd>GV --oneline<cr>", { desc = "History oneline" })
keymap.set("n", "<leader>hs", function()
  if _G.LocalHistory then
    _G.LocalHistory.create_manual_snapshot()
  else
    vim.notify("Local history not available", vim.log.levels.WARN)
  end
end, { desc = "Create manual snapshot" })
keymap.set("n", "<leader>hl", function()
  if _G.LocalHistory then
    _G.LocalHistory.show_local_history()
  else
    vim.notify("Local history not available", vim.log.levels.WARN)
  end
end, { desc = "Show local file history" })
keymap.set("n", "<leader>hL", function()
  if _G.LocalHistory then
    _G.LocalHistory.list_all_tracked_files()
  else
    vim.notify("Local history not available", vim.log.levels.WARN)
  end
end, { desc = "List all tracked files" })
keymap.set("n", "<leader>hr", "<cmd>Telescope oldfiles<cr>", { desc = "Recent files" })
keymap.set("n", "<leader>hR", function()
  require("telescope.builtin").oldfiles({ cwd_only = false })
end, { desc = "All recent files" })
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

-- ── Debug (additional) ─────────────────────────────────────────────────────
keymap.set("n", "<leader>dt", function() require('dap').terminate() end, { desc = "Terminate debug session" })
keymap.set("n", "<leader>dr", function() require('dap').restart() end, { desc = "Restart debug session" })

-- ── Window Splits ──────────────────────────────────────────────────────────
keymap.set("n", "<leader>sv", "<C-w>v", { desc = "Split window vertically" })
keymap.set("n", "<leader>sh", "<C-w>s", { desc = "Split window horizontally" })
keymap.set("n", "<leader>se", "<C-w>=", { desc = "Make splits equal size" })
keymap.set("n", "<leader>sx", function()
  local ok, spectre = pcall(require, 'spectre')
  if ok then
    local state = require('spectre.state')
    if state and state.is_open then
      local target = state.target_winid
      spectre.close()
      if target and vim.api.nvim_win_is_valid(target) then
        vim.api.nvim_set_current_win(target)
      end
      return
    end
  end
  vim.cmd('close')
end, { desc = "Close spectre or current split" })

-- ── LSP Navigation (Global Fallbacks) ──────────────────────────────
keymap.set("n", "gd", function() vim.lsp.buf.definition() end, { desc = "Go to Definition" })
keymap.set("n", "gD", function() vim.lsp.buf.declaration() end, { desc = "Go to Declaration" })
keymap.set("n", "gi", function() vim.lsp.buf.implementation() end, { desc = "Go to Implementation" })
keymap.set("n", "gy", function() vim.lsp.buf.type_definition() end, { desc = "Go to Type Definition" })
keymap.set("n", "gr", function() vim.lsp.buf.references() end, { desc = "Go to References" })

-- ── Goto Preview ────────────────────────────────────────────────
keymap.set("n", "gpd", function() require('goto-preview').goto_preview_definition() end, { desc = "Preview definition" })
keymap.set("n", "gpt", function() require('goto-preview').goto_preview_type_definition() end, { desc = "Preview type definition" })
keymap.set("n", "gpi", function() require('goto-preview').goto_preview_implementation() end, { desc = "Preview implementation" })
keymap.set("n", "gpD", function() require('goto-preview').goto_preview_declaration() end, { desc = "Preview declaration" })
keymap.set("n", "gP", function() require('goto-preview').close_all_win() end, { desc = "Close all preview windows" })
keymap.set("n", "gpr", function() require('goto-preview').goto_preview_references() end, { desc = "Preview references" })

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

-- ── Testing (neotest) ──────────────────────────────────────────────────────
keymap.set("n", "<leader>tr", function()
  pcall(function() require("neotest").run.run() end)
end, { desc = "Run nearest test" })
keymap.set("n", "<leader>tf", function()
  pcall(function() require("neotest").run.run(vim.fn.expand("%")) end)
end, { desc = "Run test file" })
keymap.set("n", "<leader>td", function()
  pcall(function() require("neotest").run.run({ strategy = "dap" }) end)
end, { desc = "Debug nearest test" })
keymap.set("n", "<leader>ts", function()
  pcall(function() require("neotest").summary.toggle() end)
end, { desc = "Toggle test summary" })
keymap.set("n", "<leader>tO", function()
  pcall(function() require("neotest").output.open({ enter = true }) end)
end, { desc = "Show test output" })

-- ── Spectre (Search & Replace) ──────────────────────────────────────────────
keymap.set("n", "<leader>sr", function() require("spectre").open() end, { desc = "Open Spectre (search & replace)" })
keymap.set("n", "<leader>sw", function() require("spectre").open_visual({ select_word = true }) end, { desc = "Search current word" })
keymap.set("v", "<leader>sw", function() require("spectre").open_visual() end, { desc = "Search current selection" })

-- ── Misc ──────────────────────────────────────────────────────────────────
keymap.set("n", "<leader>nh", ":nohl<CR>", { desc = "Clear search highlights" })
keymap.set("n", "dw", 'vb"_d', { desc = " " })
keymap.set("n", "s", "<nop>", { desc = "Disabled substitute" })
