require("cm.core.options")
require("cm.core.keymaps")

-- Load the pyenv activation script
local pyenv = require("cm.core.pyenv")

-- Call the activation function
pyenv.activate()

-- Optional: Re-run pyenv.activate() on BufEnter for Python files
vim.cmd([[autocmd BufEnter *.py lua require("cm.core.pyenv").activate()]])
