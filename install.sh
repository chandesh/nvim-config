#!/usr/bin/env bash
# Dynamic Neovim vim.pack Plugin Installer
# This script parses lua/config/plugins.lua to maintain a single source of truth.
set -e
PACK="$HOME/.config/nvim/pack"
JOBS=8

echo "=== Dynamically Installing Neovim plugins via vim.pack ==="

PLUGIN_LIST_FILE=$(mktemp)
nvim --headless -c "lua for bundle, categories in pairs(require('config.plugins')) do for type_name, list in pairs(categories) do for _, pl in ipairs(list) do vim.api.nvim_out_write(string.format('%s|%s|%s|%s\n', bundle, type_name, pl.source, pl.name)) end end end" -c "qall!" > "$PLUGIN_LIST_FILE" 2>&1 || true
PLUGIN_LIST=$(grep '|' "$PLUGIN_LIST_FILE" || true)
rm "$PLUGIN_LIST_FILE"

if [ -z "$PLUGIN_LIST" ]; then
    echo "Error: Could not retrieve plugin list from lua/config/plugins.lua"
    exit 1
fi

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

while IFS='|' read -r bundle type repo name; do
    clone "$bundle" "$type" "$repo" "$name"
done <<< "$PLUGIN_LIST"

wait

echo ""
echo "=== Plugin installation complete ==="

echo "--- Building native extensions ---"
if command -v make &>/dev/null; then
  (cd "$PACK/nav/start/telescope-fzf-native.nvim" && \
    make 2>/dev/null && echo "  [built] telescope-fzf-native") || \
    echo "  [warn] fzf-native build failed"
fi

echo ""
echo "Next: nvim → :TSUpdate → :MasonInstall → :checkhealth"
