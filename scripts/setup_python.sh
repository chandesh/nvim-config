#!/usr/bin/env bash
# PixelForge Neovim Python Environment Setup
# Ensures pynvim and required packages are installed for all Python environments
# Run once: bash ~/.config/nvim/scripts/setup_python.sh

set -e

echo "=== Neovim Python Environment Setup ==="
echo ""

# ── DETECT PYENV ──────────────────────────────────────────────────
PYENV_ROOT="${PYENV_ROOT:-$HOME/.pyenv}"
PYENV_BIN="$PYENV_ROOT/bin/pyenv"

if [ ! -x "$PYENV_BIN" ]; then
  echo "[warn] pyenv not found at $PYENV_ROOT"
  echo "       Install pyenv: https://github.com/pyenv/pyenv#installation"
  PYENV_AVAILABLE=false
else
  echo "[ok] pyenv found at $PYENV_ROOT"
  export PATH="$PYENV_ROOT/bin:$PATH"
  eval "$($PYENV_BIN init -)"
  PYENV_AVAILABLE=true
fi

# ── PACKAGES REQUIRED FOR NEOVIM PYTHON SUPPORT ───────────────────
PACKAGES=(
  pynvim
  neovim
  black
  isort
  flake8
  mypy
  debugpy
  django-stubs
  djangorestframework-stubs
)

install_packages() {
  local pip_bin=$1
  local label=$2
  echo ""
  echo "--- Installing packages for: $label ---"
  if [ ! -x "$pip_bin" ]; then
    echo "  [skip] pip not found at $pip_bin"
    return
  fi
  for pkg in "${PACKAGES[@]}"; do
    echo -n "  $pkg ... "
    if "$pip_bin" show "$pkg" &>/dev/null; then
      echo "[already installed]"
    else
      "$pip_bin" install --quiet "$pkg" && echo "[installed]" || echo "[FAILED]"
    fi
  done
}

# ── INSTALL IN ALL PYENV VERSIONS ────────────────────────────────
if [ "$PYENV_AVAILABLE" = true ]; then
  echo ""
  echo "=== Installing in all pyenv Python versions ==="
  "$PYENV_BIN" versions --bare 2>/dev/null | while read v; do
    PIP="$PYENV_ROOT/versions/$v/bin/pip"
    install_packages "$PIP" "pyenv $v"
  done

  # ── DEDICATED NEOVIM PYENV ENVIRONMENT ───────────────────────────
  echo ""
  echo "=== Creating dedicated neovim pyenv virtualenv ==="
  NVIM_VENV="neovim"
  GLOBAL_PY=$("$PYENV_BIN" global 2>/dev/null | head -1)

  if "$PYENV_BIN" virtualenvs --bare 2>/dev/null | grep -q "^${NVIM_VENV}$"; then
    echo "  [skip] pyenv virtualenv '$NVIM_VENV' already exists"
  else
    if "$PYENV_BIN" virtualenv "$GLOBAL_PY" "$NVIM_VENV" 2>/dev/null; then
      echo "  [created] pyenv virtualenv '$NVIM_VENV' from $GLOBAL_PY"
    else
      echo "  [warn] could not create virtualenv — install pyenv-virtualenv plugin"
    fi
  fi

  NVIM_PY="$PYENV_ROOT/versions/$NVIM_VENV/bin/python"
  if [ -x "$NVIM_PY" ]; then
    PIP="$PYENV_ROOT/versions/$NVIM_VENV/bin/pip"
    install_packages "$PIP" "neovim virtualenv ($NVIM_VENV)"
  fi
fi

# ── SYSTEM PYTHON FALLBACK ────────────────────────────────────────
echo ""
echo "=== System Python fallback ==="
SYS_PYTHON=$(which python3 2>/dev/null || echo "")
if [ -n "$SYS_PYTHON" ]; then
  SYS_PIP=$(which pip3 2>/dev/null || echo "")
  if [ -n "$SYS_PIP" ]; then
    install_packages "$SYS_PIP" "system python3 ($SYS_PYTHON)"
  fi
fi

echo ""
echo "=== Python setup complete ==="
