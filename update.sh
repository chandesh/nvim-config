#!/usr/bin/env bash
# Neovim Plugin Updater
# Usage: bash ~/.config/nvim/update.sh

set -e
PACK="$HOME/.config/nvim/pack"

echo "=== Updating all vim.pack plugins ==="
find "$PACK" -mindepth 3 -maxdepth 3 -name '.git' -type d | sort | while read g; do
  dir="$(dirname "$g")"
  name="$(basename "$dir")"
  printf "  %-40s " "$name"
  out=$(git -C "$dir" pull --ff-only --quiet 2>&1) && echo "[ok]" || echo "[WARN] $out"
done
echo ""
echo "=== Done. Run :TSUpdate inside Neovim for parser updates. ==="
