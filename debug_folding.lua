-- Debug script to identify what's causing folding on save
-- Run this in Neovim: :luafile ~/.config/nvim/debug_folding.lua

local function debug_autocmds()
  print("=== Debugging folding on save ===")
  
  -- Create a debug group
  local debug_group = vim.api.nvim_create_augroup("FoldingDebug", { clear = true })
  
  -- Monitor all events that might affect folding
  local events_to_monitor = {
    "BufWritePre", "BufWritePost", "BufWrite",
    "FileType", "BufReadPost", "BufEnter",
    "TextChanged", "TextChangedI",
    "LspAttach", "User"
  }
  
  for _, event in ipairs(events_to_monitor) do
    vim.api.nvim_create_autocmd(event, {
      group = debug_group,
      pattern = "*.sh",
      callback = function(args)
        local foldlevel = vim.fn.foldlevel(vim.fn.line('.'))
        local foldlevelstart = vim.o.foldlevelstart
        print(string.format("[%s] Event: %s, FoldLevel: %d, FoldLevelStart: %d, Buffer: %s", 
          os.date("%H:%M:%S"), event, foldlevel, foldlevelstart, vim.fn.expand('%:t')))
      end
    })
  end
  
  -- Monitor fold-related commands
  vim.api.nvim_create_autocmd("CmdlineLeave", {
    group = debug_group,
    callback = function()
      local cmd = vim.fn.getcmdline()
      if cmd:match("fold") or cmd:match("^z[MmRr]") then
        print(string.format("[%s] Fold command executed: %s", os.date("%H:%M:%S"), cmd))
      end
    end
  })
  
  -- Check for nvim-ufo events
  vim.api.nvim_create_autocmd("User", {
    group = debug_group,
    pattern = "UfoFoldingRange",
    callback = function()
      print(string.format("[%s] nvim-ufo folding range event triggered", os.date("%H:%M:%S")))
    end
  })
  
  print("Debug monitoring enabled. Save a shell file to see what events are triggered.")
  print("To stop debugging, run: :autocmd! FoldingDebug")
end

-- Run the debug function
debug_autocmds()
