#!/bin/bash

# Quick Test Script for Development
# Runs a subset of tests for faster feedback during development

echo "🚀 Running Quick Neovim Configuration Tests"
echo "============================================"

# Test basic functionality without full test suite
nvim --headless -c 'lua print("✅ Neovim starts successfully")' -c 'qall!'

# Test plugin loading
nvim --headless -c 'lua require("cm.test.plugin_test").run_all()' -c 'qall!'

# Test essential keymaps
nvim --headless -c 'lua require("cm.test.keymap_test").run_all()' -c 'qall!'

echo "🎉 Quick tests completed!"
