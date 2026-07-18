#!/usr/bin/env bash
# Neovim vim.pack Plugin Installer
# Usage: bash ~/.config/nvim/install.sh
# Re-running is safe — skips installed plugins

set -e
PACK="$HOME/.config/nvim/pack"
JOBS=8

clone() {
  local bundle=$1 type=$2 repo=$3 name=$4
  local dest="$PACK/$bundle/$type/$name"
  if [ -d "$dest/.git" ]; then
    echo "  [skip]    $name"
    return
  fi
  echo "  [install] $name"
  git clone --depth=1 --quiet "https://github.com/$repo" "$dest" &
  while [ "$(jobs -r | wc -l)" -ge "$JOBS" ]; do sleep 0.1; done
}

echo "=== Installing Neovim plugins via vim.pack ==="

# ── THEME (start — MUST load first, installed first) ──────────────
echo "--- Theme ---"
clone theme start "craftzdog/solarized-osaka.nvim" solarized-osaka.nvim
clone theme start "folke/tokyonight.nvim"           tokyonight.nvim
clone theme start "catppuccin/nvim"                 catppuccin

# ── CORE (start) ──────────
echo "--- Core ---"
clone core start "nvim-lua/plenary.nvim"        plenary.nvim
clone core start "nvim-tree/nvim-web-devicons"  nvim-web-devicons

# ── LSP ───────────────────────────────────────────────────────────
echo "--- LSP ---"
clone lsp start "neovim/nvim-lspconfig"             nvim-lspconfig
clone lsp start "rmagatti/goto-preview"                 goto-preview
clone lsp start "williamboman/mason.nvim"            mason.nvim
clone lsp start "williamboman/mason-lspconfig.nvim"  mason-lspconfig.nvim
clone lsp start "nvimtools/none-ls.nvim"             none-ls.nvim
clone lsp start "j-hui/fidget.nvim"                 fidget.nvim
clone lsp opt   "b0o/SchemaStore.nvim"              SchemaStore.nvim

# ── COMPLETION ────────────────────────────────────────────────────
echo "--- Completion ---"
clone completion start "saghen/blink.cmp"             blink.cmp
clone completion start "fang2hou/blink-copilot"       blink-copilot
clone completion start "L3MON4D3/LuaSnip"             LuaSnip
clone completion start "rafamadriz/friendly-snippets"  friendly-snippets

# ── TREESITTER ────────────────────────────────────────────────────
echo "--- Treesitter ---"
clone treesitter start "nvim-treesitter/nvim-treesitter"             nvim-treesitter
clone treesitter start "nvim-treesitter/nvim-treesitter-textobjects" nvim-treesitter-textobjects
clone treesitter opt   "windwp/nvim-ts-autotag"                      nvim-ts-autotag

# ── DEBUG (all opt) ─────────────────────────────────────────
echo "--- Debug ---"
clone debug opt "mfussenegger/nvim-dap"            nvim-dap
clone debug opt "mfussenegger/nvim-dap-python"     nvim-dap-python
clone debug opt "leoluz/nvim-dap-go"               nvim-dap-go
clone debug opt "rcarriga/nvim-dap-ui"             nvim-dap-ui
clone debug opt "nvim-neotest/nvim-nio"             nvim-nio
clone debug opt "theHamsta/nvim-dap-virtual-text"  nvim-dap-virtual-text

# ── GIT ───────────────────────────────────────────────────────────
echo "--- Git ---"
clone git start "lewis6991/gitsigns.nvim"  gitsigns.nvim
clone git start "tpope/vim-fugitive"       vim-fugitive
clone git opt   "sindrets/diffview.nvim"   diffview.nvim
clone git opt   "junegunn/gv.vim"          gv.vim

# ── NAVIGATION ────────────────────────────────────────────────────
echo "--- Navigation ---"
clone nav start "nvim-telescope/telescope.nvim"            telescope.nvim
clone nav start "nvim-telescope/telescope-fzf-native.nvim" telescope-fzf-native.nvim
clone nav start "nvim-tree/nvim-tree.lua"                  nvim-tree.lua
clone nav start "stevearc/aerial.nvim"                     aerial.nvim
clone nav opt   "ThePrimeagen/harpoon"                     harpoon
clone nav opt   "rmagatti/goto-preview"                    goto-preview
clone nav opt   "andrew-george/telescope-themes"           telescope-themes

# ── SESSION ──────────────────────────────────────────────────────
echo "--- Session ---"
clone core opt "rmagatti/auto-session" auto-session

# ── UI ────────────────────────────────────────────────────────────
echo "--- UI ---"
clone ui start "nvim-lualine/lualine.nvim"           lualine.nvim
clone ui start "akinsho/bufferline.nvim"             bufferline.nvim
clone ui start "lukas-reineke/indent-blankline.nvim" indent-blankline.nvim
clone ui start "folke/which-key.nvim"                which-key.nvim
clone ui start "folke/trouble.nvim"                  trouble.nvim
clone ui start "folke/todo-comments.nvim"            todo-comments.nvim
clone ui start "MunifTanjim/nui.nvim"     nui.nvim
clone ui start "folke/noice.nvim"          noice.nvim
clone ui start "rcarriga/nvim-notify"       nvim-notify
clone ui start "goolord/alpha-nvim"                  alpha-nvim
clone ui start "norcalli/nvim-colorizer.lua"         nvim-colorizer.lua
clone ui start "stevearc/dressing.nvim"              dressing.nvim
clone ui start "smiteshp/nvim-navic"                 nvim-navic
clone ui opt   "folke/zen-mode.nvim"                 zen-mode.nvim
clone ui opt   "MeanderingProgrammer/render-markdown.nvim" render-markdown.nvim
clone ui opt   "folke/twilight.nvim"                 twilight.nvim

# ── EDITING ───────────────────────────────────────────────────────
echo "--- Editing ---"
clone editing start "stevearc/conform.nvim"     conform.nvim
clone editing start "windwp/nvim-autopairs"    nvim-autopairs
clone editing start "kylechui/nvim-surround"   nvim-surround
clone editing start "numToStr/Comment.nvim"    Comment.nvim
clone editing start "mg979/vim-visual-multi"   vim-visual-multi
clone editing start "kevinhwang91/nvim-ufo"    nvim-ufo
clone editing start "kevinhwang91/promise-async" promise-async
clone editing start "nvim-pack/nvim-spectre"   nvim-spectre
clone editing start "mbbill/undotree"          undotree
clone editing start "karb94/neoscroll.nvim"    neoscroll.nvim
clone editing opt   "folke/flash.nvim"         flash.nvim

# ── LANGUAGE SPECIFIC (opt) ───────────────────────────────────────
echo "--- Language ---"
clone lang opt "linux-cultist/venv-selector.nvim"  venv-selector.nvim
clone lang opt "mfussenegger/nvim-lint"             nvim-lint
clone lang opt "pmizio/typescript-tools.nvim"       typescript-tools.nvim
clone lang opt "dmmulroy/tsc.nvim"                  tsc.nvim
clone lang opt "olexsmir/gopher.nvim"               gopher.nvim

wait
echo ""
echo "=== Plugin installation complete ==="

# Build native extensions
echo "--- Building native extensions ---"
if command -v make &>/dev/null; then
  (cd "$PACK/nav/start/telescope-fzf-native.nvim" && \
    make 2>/dev/null && echo "  [built] telescope-fzf-native") || \
    echo "  [warn] fzf-native build failed — install cmake or make"
fi
echo ""
echo "Next: nvim → :TSUpdate → :MasonInstall → :checkhealth"
