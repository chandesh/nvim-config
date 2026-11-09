-- ~/.config/nvim/lua/config/copilot_chat.lua
-- =============================================================================
-- CopilotChat — chat UI on the free <leader>a namespace.
-- The plugin is an opt plugin; setup() only registers keys and the plugin is
-- packadded on first use. Bare `a` and `i` are never touched.
-- =============================================================================

local M = {}

local loaded = false

local function ensure()
  if loaded then
    return require('CopilotChat')
  end

  vim.cmd('packadd CopilotChat.nvim')
  local ok, CopilotChat = pcall(require, 'CopilotChat')
  if not ok then
    vim.notify('CopilotChat.nvim not found. Run install.sh / :PI', vim.log.levels.WARN)
    return nil
  end

  CopilotChat.setup({
    window = { border = 'rounded' },
  })

  loaded = true
  return CopilotChat
end

M.ensure = ensure

local function explain_line(chat)
  local line = vim.api.nvim_win_get_cursor(0)[1]
  vim.api.nvim_buf_set_mark(0, '<', line, 0, {})
  vim.api.nvim_buf_set_mark(0, '>', line, 0, {})
  chat.ask('/Explain')
end

function M.setup()
  -- Prefix first, so the children are discovered after it. <Nop> keeps `a`
  -- and `i` free; the prefix never starts insert mode.
  vim.keymap.set({ 'n', 'x' }, '<leader>a', '<Nop>', { desc = 'AI' })

  local ok_wk, wk = pcall(require, 'which-key')
  if ok_wk then
    wk.add({ { '<leader>a', group = 'AI', mode = { 'n', 'x' } } })
  end

  vim.keymap.set('n', '<leader>aa', function()
    local chat = ensure()
    if chat then
      chat.toggle()
    end
  end, { desc = 'Copilot chat' })

  vim.keymap.set('n', '<leader>ae', function()
    local chat = ensure()
    if chat then
      explain_line(chat)
    end
  end, { desc = 'Explain selection' })

  vim.keymap.set('x', '<leader>ae', function()
    local chat = ensure()
    if chat then
      chat.ask('/Explain')
    end
  end, { desc = 'Explain selection' })

  vim.keymap.set('n', '<leader>aq', function()
    local chat = ensure()
    if not chat then
      return
    end
    vim.ui.input({ prompt = 'Copilot: ' }, function(input)
      if input and vim.trim(input) ~= '' then
        chat.ask(input)
      end
    end)
  end, { desc = 'Quick chat' })
end

return M
