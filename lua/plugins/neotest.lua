-- Neotest is a testing framework for Neovim that provides a unified interface for 
-- running tests across different languages and testing frameworks. 
-- It allows you to run tests directly from your editor, view test results, and 
-- navigate between test files and test cases.
--
return {
  "nvim-neotest/neotest",
  dependencies = {
    "nvim-neotest/nvim-nio",
    "nvim-lua/plenary.nvim",
    "antoinemadec/FixCursorHold.nvim",
    "nvim-treesitter/nvim-treesitter"
  }
}

