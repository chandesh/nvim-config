return {
  "kevinhwang91/nvim-ufo",
  dependencies = {
    "kevinhwang91/promise-async",
    "nvim-treesitter/nvim-treesitter",
  },
  event = "BufReadPost",
  opts = {
    -- Using treesitter as the main provider with LSP fallback
    provider_selector = function(bufnr, filetype, buftype)
      return { "treesitter", "indent" }
    end,
    -- Preview configuration
    preview = {
      win_config = {
        border = { "", "─", "", "", "", "─", "", "" },
        winhighlight = "Normal:Folded",
        winblend = 0,
      },
      mappings = {
        scrollU = "<C-u>",
        scrollD = "<C-d>",
        jumpTop = "[",
        jumpBot = "]",
      },
    },
    -- Fold column configuration
    fold_virt_text_handler = function(virtText, lnum, endLnum, width, truncate)
      local newVirtText = {}
      local suffix = (" 󰁂 %d lines"):format(endLnum - lnum)
      local sufWidth = vim.fn.strdisplaywidth(suffix)
      local targetWidth = width - sufWidth
      local curWidth = 0
      
      for _, chunk in ipairs(virtText) do
        local chunkText = chunk[1]
        local chunkWidth = vim.fn.strdisplaywidth(chunkText)
        if targetWidth > curWidth + chunkWidth then
          table.insert(newVirtText, chunk)
        else
          chunkText = truncate(chunkText, targetWidth - curWidth)
          local hlGroup = chunk[2]
          table.insert(newVirtText, { chunkText, hlGroup })
          chunkWidth = vim.fn.strdisplaywidth(chunkText)
          if curWidth + chunkWidth < targetWidth then
            suffix = suffix .. (" "):rep(targetWidth - curWidth - chunkWidth)
          end
          break
        end
        curWidth = curWidth + chunkWidth
      end
      
      table.insert(newVirtText, { suffix, "MoreMsg" })
      return newVirtText
    end,
  },
  config = function(_, opts)
    -- Setup ufo
    require("ufo").setup(opts)
    
    -- Set folding options
    vim.o.foldcolumn = "1" -- Show fold column
    vim.o.foldlevel = 99 -- Using ufo provider need a large value
    vim.o.foldlevelstart = 1 -- Start with some folds closed (PyCharm-like)
    vim.o.foldenable = true
    
    -- Set fold method to manual (ufo will handle the folding)
    vim.o.foldmethod = "manual"
    
    -- Key mappings for folding (PyCharm-like)
    vim.keymap.set("n", "zR", require("ufo").openAllFolds, { desc = "Open all folds" })
    vim.keymap.set("n", "zM", require("ufo").closeAllFolds, { desc = "Close all folds" })
    vim.keymap.set("n", "zr", require("ufo").openFoldsExceptKinds, { desc = "Open folds except kinds" })
    vim.keymap.set("n", "zm", require("ufo").closeFoldsWith, { desc = "Close folds with" })
    
    -- PyCharm-like fold toggle (Ctrl+NumPad+/- or Ctrl+Plus/Minus)
    vim.keymap.set("n", "<C-=>", "za", { desc = "Toggle fold" })
    vim.keymap.set("n", "<C-->", "za", { desc = "Toggle fold" })
    vim.keymap.set("n", "<C-kPlus>", "za", { desc = "Toggle fold" })
    vim.keymap.set("n", "<C-kMinus>", "za", { desc = "Toggle fold" })
    
    -- Additional useful fold mappings
    vim.keymap.set("n", "zK", function()
      local winid = require("ufo").peekFoldedLinesUnderCursor()
      if not winid then
        vim.lsp.buf.hover()
      end
    end, { desc = "Peek fold or hover" })
    
    -- Enhanced fold navigation
    vim.keymap.set("n", "]z", "zj", { desc = "Next fold" })
    vim.keymap.set("n", "[z", "zk", { desc = "Previous fold" })
  end,
}
