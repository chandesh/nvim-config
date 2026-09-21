-- ~/.config/nvim/lua/config/lang/flutter.lua
-- =============================================================================
-- Flutter/Dart Language Logic
-- flutter-tools.nvim owns dartls (bundled with the Flutter SDK) and the Dart
-- debug adapter. Lazy-loaded on the `dart` filetype to preserve startup speed.
-- =============================================================================

local setup_done = false

vim.api.nvim_create_autocmd('FileType', {
  group = vim.api.nvim_create_augroup('FlutterSetup', { clear = true }),
  pattern = { 'dart' },
  callback = function()
    vim.cmd('packadd flutter-tools.nvim')
    vim.cmd('packadd dressing.nvim')

    if not setup_done then
      setup_done = true
      require('flutter-tools').setup({
        ui = { border = 'rounded' },
        -- fvm = true, -- enable if you manage the SDK with FVM
        debugger = { enabled = true },
        lsp = {
          capabilities = require('blink.cmp').get_lsp_capabilities(),
          settings = {
            showTodos = true,
            completeFunctionCalls = true,
            renameFilesWithClasses = 'prompt',
            updateImportsOnRename = true,
            enableSnippets = true,
          },
        },
      })
    end

    -- Flutter lifecycle + outline commands.
    -- All Flutter keys live under `<leader>fl` (buffer-local to dart files) so
    -- they don't shadow the global `<leader>f*` Snacks pickers (`<leader>fr`
    -- recent files, `<leader>fh` help, …) or the global DAP keys in keymaps.lua.
    local km = vim.keymap.set
    km('n', '<leader>flr', '<Cmd>FlutterRun<CR>',        { buffer = 0, desc = 'Flutter run' })
    km('n', '<leader>fld', '<Cmd>FlutterDevices<CR>',    { buffer = 0, desc = 'Flutter select device' })
    km('n', '<leader>fle', '<Cmd>FlutterEmulators<CR>',  { buffer = 0, desc = 'Flutter select emulator' })
    km('n', '<leader>flh', '<Cmd>FlutterReload<CR>',     { buffer = 0, desc = 'Flutter hot reload' })
    km('n', '<leader>flR', '<Cmd>FlutterRestart<CR>',    { buffer = 0, desc = 'Flutter hot restart' })
    km('n', '<leader>flq', '<Cmd>FlutterQuit<CR>',       { buffer = 0, desc = 'Flutter quit session' })
    km('n', '<leader>flo', '<Cmd>FlutterOutlineToggle<CR>', { buffer = 0, desc = 'Flutter widget outline' })
    km('n', '<leader>flv', '<Cmd>FlutterVisualDebug<CR>',   { buffer = 0, desc = 'Flutter visual debug' })

    -- nvim-dap keys (buffer-local to dart files). F5/F10/F11/F12 are free in
    -- this config. Breakpoint toggling uses the global `<leader>db` already
    -- defined in keymaps.lua — no redefinition here.
    km('n', '<F5>',   function() require('dap').continue() end,        { buffer = 0, desc = 'DAP continue' })
    km('n', '<F10>',  function() require('dap').step_over() end,       { buffer = 0, desc = 'DAP step over' })
    km('n', '<F11>',  function() require('dap').step_into() end,       { buffer = 0, desc = 'DAP step into' })
    km('n', '<F12>',  function() require('dap').step_out() end,        { buffer = 0, desc = 'DAP step out' })
  end,
})