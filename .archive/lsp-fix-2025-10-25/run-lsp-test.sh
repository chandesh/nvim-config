#!/bin/bash
# Automated LSP Testing Script
# This script opens Neovim with the test file and runs diagnostics

set -e

echo "=========================================="
echo "  Automated LSP gd/gD Testing"
echo "=========================================="
echo ""

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if test file exists
TEST_FILE="/tmp/test_lsp_python.py"
if [ ! -f "$TEST_FILE" ]; then
  echo -e "${RED}✗ Test file not found: $TEST_FILE${NC}"
  echo "Creating test file..."
  cat > "$TEST_FILE" << 'EOF'
"""
Test file for LSP definition navigation in Python
"""

def hello_world():
    """A simple test function"""
    return "Hello, World!"

def calculate_sum(a, b):
    """Calculate sum of two numbers"""
    return a + b

class TestClass:
    """A simple test class"""
    
    def __init__(self, name):
        self.name = name
    
    def greet(self):
        """Greet method"""
        return f"Hello, {self.name}"

# Test cases - place cursor on these and try gd
result = hello_world()
sum_result = calculate_sum(5, 10)
obj = TestClass("World")
greeting = obj.greet()
EOF
  echo -e "${GREEN}✓ Test file created${NC}"
fi

echo ""
echo "Test file: $TEST_FILE"
echo ""
echo "=========================================="
echo "  Phase 1: Interactive Test"
echo "=========================================="
echo ""
echo "Instructions:"
echo "1. Neovim will open with the test file"
echo "2. Wait 3-5 seconds for LSP to attach"
echo "3. Watch for debug messages:"
echo "   - [LSP] on_attach called"
echo "   - [LSP] Set keymap: gd -> Go to Definition"
echo ""
echo "4. Test gd keymap:"
echo "   - Place cursor on 'hello_world' (line 29)"
echo "   - Press: gd"
echo "   - Expected: Jump to line 7"
echo ""
echo "5. Run diagnostic:"
echo "   :lua require('test-lsp-auto').run_all_tests()"
echo ""
echo "6. After 3 seconds, move cursor to 'hello_world' and run:"
echo "   :lua require('test-lsp-auto').test_definition_programmatic()"
echo ""
echo "Press ENTER to continue..."
read

# Open Neovim with the test file
nvim "+29" \
  "+normal! w" \
  "$TEST_FILE"

echo ""
echo "=========================================="
echo "  Test Results"
echo "=========================================="
echo ""
echo "Did you see the debug messages? (Y/n)"
read saw_debug

echo "Did 'gd' work? (Y/n)"
read gd_works

echo ""
if [[ "$saw_debug" =~ ^[Yy]$ ]] && [[ "$gd_works" =~ ^[Yy]$ ]]; then
  echo -e "${GREEN}=========================================="
  echo -e "  ✓✓✓ SUCCESS! gd/gD IS WORKING! ✓✓✓"
  echo -e "==========================================${NC}"
elif [[ "$saw_debug" =~ ^[Yy]$ ]] && ! [[ "$gd_works" =~ ^[Yy]$ ]]; then
  echo -e "${YELLOW}=========================================="
  echo -e "  Keymaps set but not working"
  echo -e "==========================================${NC}"
  echo ""
  echo "Next steps:"
  echo "1. Check :messages in Neovim for LSP errors"
  echo "2. Check LSP log:"
  echo "   nvim ~/.local/state/nvim/lsp.log"
  echo "3. Run: :checkhealth lsp"
else
  echo -e "${RED}=========================================="
  echo -e "  ✗ on_attach not being called"
  echo -e "==========================================${NC}"
  echo ""
  echo "Root cause: on_attach function not executing"
  echo ""
  echo "Next steps:"
  echo "1. Check :messages for errors"
  echo "2. Verify LSP server is installed:"
  echo "   nvim +Mason"
  echo "3. Check Python environment:"
  echo "   pyenv version"
  echo "   which python"
fi

echo ""
echo "For full diagnostic output, run in Neovim:"
echo "  :lua require('lsp-diagnostic').run_full_diagnostic()"
