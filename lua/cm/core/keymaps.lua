-- set leader key to space
vim.g.mapleader = " "

local keymap = vim.keymap -- for conciseness

---------------------
-- General Keymaps -------------------

-- -- use jk to exit insert mode
-- keymap.set("i", "jk", "<ESC>", { desc = "Exit insert mode with jk" })

-- clear search highlights
keymap.set("n", "<leader>nh", ":nohl<CR>", { desc = "Clear search highlights" })

-- delete single character without copying into register
-- keymap.set("n", "x", '"_x')

-- -- increment/decrement numbers
-- keymap.set("n", "<leader>+", "<C-a>", { desc = "Increment number" }) -- increment
-- keymap.set("n", "<leader>-", "<C-x>", { desc = "Decrement number" }) -- decrement

-- Delete a word backwards
keymap.set("n", "dw", 'vb"_d')

-- Telescope keymaps
keymap.set("n", "<leader>ff", function()
  require("telescope.builtin").find_files({ hidden = true, no_ignore = true })
end, { desc = "Fuzzy find files in cwd (including hidden)" })
keymap.set("n", "<leader>fr", "<cmd>Telescope oldfiles<cr>", { desc = "Fuzzy find recent files" })
keymap.set("n", "<leader>fs", "<cmd>Telescope live_grep<cr>", { desc = "Find string in cwd" })
keymap.set("n", "<leader>fc", "<cmd>Telescope grep_string<cr>", { desc = "Find string under cursor in cwd" })
keymap.set("n", "<leader>ft", "<cmd>TodoTelescope<cr>", { desc = "Find todos" })

-- Gitsigns keymaps
keymap.set("n", "<leader>gp", ":Gitsigns preview_hunk<CR>", { desc = "Preview git hunk" })
keymap.set("n", "<leader>gt", ":Gitsigns toggle_current_line_blame<CR>", { desc = "Toggle git blame" })

-- NvimTree keymaps
keymap.set("n", "<leader>ee", "<cmd>NvimTreeToggle<CR>", { desc = "Toggle file explorer" })
keymap.set("n", "<leader>ef", "<cmd>NvimTreeFindFileToggle<CR>", { desc = "Toggle file explorer on current file" })
keymap.set("n", "<leader>ec", "<cmd>NvimTreeCollapse<CR>", { desc = "Collapse file explorer" })
keymap.set("n", "<leader>er", "<cmd>NvimTreeRefresh<CR>", { desc = "Refresh file explorer" })

-- Spectre keymaps
keymap.set("n", "<leader>sr", function() require("spectre").open() end, { desc = "Open Spectre for search and replace" })

-- Copilot keymaps handled in plugin config

-- Comment keymaps handled by Comment.nvim

-- Trouble keymaps
keymap.set("n", "<leader>xw", "<cmd>Trouble diagnostics toggle<CR>", { desc = "Open trouble workspace diagnostics" })
keymap.set("n", "<leader>xd", "<cmd>Trouble diagnostics toggle filter.buf=0<CR>", { desc = "Open trouble document diagnostics" })
keymap.set("n", "<leader>xq", "<cmd>Trouble quickfix toggle<CR>", { desc = "Open trouble quickfix list" })
keymap.set("n", "<leader>xl", "<cmd>Trouble loclist toggle<CR>", { desc = "Open trouble location list" })
keymap.set("n", "<leader>xt", "<cmd>Trouble todo toggle<CR>", { desc = "Open todos in trouble" })

-- Maximizer keymaps
keymap.set("n", "<leader>sm", "<cmd>MaximizerToggle<CR>", { desc = "Maximize/minimize a split" })

-- SQL Database keymaps
keymap.set("n", "<leader>dbu", ":DBUI<CR>", { desc = "Open Database UI" })
keymap.set("n", "<leader>dbt", ":DBUIToggle<CR>", { desc = "Toggle Database UI" })
keymap.set("n", "<leader>dbf", ":DBUIFindBuffer<CR>", { desc = "Find Database Buffer" })
keymap.set("n", "<leader>dbr", ":DBUIRenameBuffer<CR>", { desc = "Rename Database Buffer" })
keymap.set("n", "<leader>dbl", ":DBUILastQueryInfo<CR>", { desc = "Last Query Info" })

-- Lint and Format
keymap.set("n", "<leader>ll", function() require("lint").try_lint() end, { desc = "Trigger linting for current file" })
keymap.set({ "n", "v" }, "<leader>mp", function() 
  require("conform").format({ lsp_fallback = true, async = false, timeout_ms = 2000 }) 
end, { desc = "Format file or range" })

-- Folding keymaps
keymap.set("n", "zR", function() require("ufo").openAllFolds() end, { desc = "Open all folds" })
keymap.set("n", "zM", function() require("ufo").closeAllFolds() end, { desc = "Close all folds" })
keymap.set("n", "zr", function() require("ufo").openFoldsExceptKinds() end, { desc = "Open folds except kinds" })
keymap.set("n", "zm", function() require("ufo").closeFoldsWith() end, { desc = "Close folds with" })
keymap.set("n", "<C-=>", "za", { desc = "Toggle fold" })
keymap.set("n", "<C-->", "za", { desc = "Toggle fold" })

-- window management
keymap.set("n", "<leader>sv", "<C-w>v", { desc = "Split window vertically" }) -- split window vertically
keymap.set("n", "<leader>sh", "<C-w>s", { desc = "Split window horizontally" }) -- split window horizontally
keymap.set("n", "<leader>se", "<C-w>=", { desc = "Make splits equal size" }) -- make split windows equal width & height
keymap.set("n", "<leader>sx", "<cmd>close<CR>", { desc = "Close current split" }) -- close current split window

keymap.set("n", "<leader>to", "<cmd>tabnew<CR>", { desc = "Open new tab" }) -- open new tab
keymap.set("n", "<leader>tx", "<cmd>tabclose<CR>", { desc = "Close current tab" }) -- close current tab
keymap.set("n", "<leader>tn", "<cmd>tabn<CR>", { desc = "Go to next tab" }) --  go to next tab
keymap.set("n", "<leader>tp", "<cmd>tabp<CR>", { desc = "Go to previous tab" }) --  go to previous tab

-- Tech stack specific keymaps

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
keymap.set("n", "<leader>er", ":e requirements.txt<CR>", { desc = "Edit requirements.txt" })
keymap.set("n", "<leader>ej", ":e package.json<CR>", { desc = "Edit package.json" })
keymap.set("n", "<leader>ed", ":e docker-compose.yml<CR>", { desc = "Edit docker-compose.yml" })
keymap.set("n", "<leader>ef", ":e Dockerfile<CR>", { desc = "Edit Dockerfile" })

-- Database and SQL keymaps
keymap.set("n", "<leader>sq", ":split | terminal sqlite3<CR>", { desc = "Open SQLite" })
keymap.set("n", "<leader>sp", ":split | terminal psql<CR>", { desc = "Open PostgreSQL" })

-- Quick terminal for development
keymap.set("n", "<leader>tt", ":split | terminal<CR>", { desc = "Open terminal" })
keymap.set("n", "<leader>tv", ":vsplit | terminal<CR>", { desc = "Open vertical terminal" })

-- DAP (Debug Adapter Protocol) keymaps for Python/Django debugging
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

-- Python environment and tools
keymap.set("n", "<leader>pi", "<cmd>PyenvInfo<cr>", { desc = "Show pyenv info" })
keymap.set("n", "<leader>pr", "<cmd>PyenvReactivate<cr>", { desc = "Reactivate pyenv environment" })
keymap.set("n", "<leader>pl", "<cmd>PyenvInstallLSP<cr>", { desc = "Install LSP packages" })
keymap.set("n", "<leader>pv", function() require("swenv").pick_venv() end, { desc = "Pick Python virtual environment" })
keymap.set("n", "<leader>ds", "<Plug>(pydocstring)", { desc = "Generate docstring" })

-- Python testing (neotest)
keymap.set("n", "<leader>tr", function() require("neotest").run.run() end, { desc = "Run nearest test" })
keymap.set("n", "<leader>tf", function() require("neotest").run.run(vim.fn.expand("%")) end, { desc = "Run test file" })
keymap.set("n", "<leader>td", function() require("neotest").run.run({strategy = "dap"}) end, { desc = "Debug nearest test" })
keymap.set("n", "<leader>ts", function() require("neotest").summary.toggle() end, { desc = "Toggle test summary" })
keymap.set("n", "<leader>to", function() require("neotest").output.open({ enter = true }) end, { desc = "Show test output" })
