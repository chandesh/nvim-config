local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable", -- latest stable release
		lazypath,
	})
end

vim.opt.rtp:prepend(lazypath)

-- Let's trigger function to activate current python environment.
local pyenv = require("cm.core.pyenv")
pyenv.activate()

-- To ensure filetype and highlighting work correctly after restoring sessions
vim.o.sessionoptions = "blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions"

require("lazy").setup({
	{ import = "cm.plugins" },
	{ import = "cm.plugins.lsp" },
}, {
	checker = {
		enabled = true,
		notify = false,
	},
	change_detection = {
		notify = false,
	},
	rocks = {
		enabled = false,
		hererocks = false,
	},
})

-- Suppress warnings for unused providers
vim.g.loaded_ruby_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_rust_provider = 0
vim.g.loaded_julia_provider = 0
vim.g.loaded_composer_provider = 0
