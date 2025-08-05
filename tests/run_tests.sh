#!/bin/bash

# Neovim Configuration Test Runner
# This script tests the Neovim configuration to ensure everything works as expected

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test configuration
NVIM_CONFIG_DIR="$HOME/.config/nvim"
TEST_DIR="$NVIM_CONFIG_DIR/tests"
LOG_FILE="$TEST_DIR/test_results.log"

echo -e "${BLUE}🧪 Starting Neovim Configuration Tests${NC}"
echo "=================================="

# Clear previous log
> "$LOG_FILE"

# Function to log messages
log_message() {
    echo "$1" | tee -a "$LOG_FILE"
}

# Function to run a test
run_test() {
    local test_name="$1"
    local test_command="$2"
    
    echo -e "${YELLOW}Running: $test_name${NC}"
    log_message "$(date): Running $test_name"
    
    if eval "$test_command" >> "$LOG_FILE" 2>&1; then
        echo -e "${GREEN}✅ PASS: $test_name${NC}"
        log_message "PASS: $test_name"
        return 0
    else
        echo -e "${RED}❌ FAIL: $test_name${NC}"
        log_message "FAIL: $test_name"
        return 1
    fi
}

# Test 1: Neovim version check
echo -e "\n${BLUE}📋 Basic Configuration Tests${NC}"
run_test "Neovim Version Check" "nvim --version | head -1"

# Test 2: Configuration syntax check
run_test "Configuration Syntax Check" "nvim --headless -c 'lua vim.health.check()' -c 'qall!' 2>/dev/null"

# Test 3: Plugin loading test
run_test "Plugin Loading Test" "nvim --headless -c 'lua require(\"cm.test.plugin_test\").run_all()' -c 'qall!'"

# Test 4: LSP configuration test
run_test "LSP Configuration Test" "nvim --headless -c 'lua require(\"cm.test.lsp_test\").run_all()' -c 'qall!'"

# Test 5: Keymap test
run_test "Keymap Configuration Test" "nvim --headless -c 'lua require(\"cm.test.keymap_test\").run_all()' -c 'qall!'"

# Test 6: Mason tools test
run_test "Mason Tools Test" "nvim --headless -c 'lua require(\"cm.test.mason_test\").run_all()' -c 'qall!'"

# Test 7: Pyenv integration test
run_test "Pyenv Integration Test" "nvim --headless -c 'lua require(\"cm.test.pyenv_test\").run_all()' -c 'qall!'"

# Test 8: File type detection test
run_test "File Type Detection Test" "nvim --headless -c 'lua require(\"cm.test.filetype_test\").run_all()' -c 'qall!'"

echo -e "\n${BLUE}📊 Test Summary${NC}"
echo "=================================="

# Count results - only count actual test runs, not plugin installation tasks
total_tests=0
passed_tests=0
failed_tests=0

# Count total tests
total_tests=$(grep ": Running" "$LOG_FILE" | wc -l | tr -d ' ')

# Count passed tests
passed_tests=$(grep "PASS:" "$LOG_FILE" | wc -l | tr -d ' ')

# Count failed tests
failed_tests=$(grep "FAIL:" "$LOG_FILE" | wc -l | tr -d ' ')

echo "Total Tests: $total_tests"
echo -e "${GREEN}Passed: $passed_tests${NC}"
echo -e "${RED}Failed: $failed_tests${NC}"

if [ "$failed_tests" = "0" ]; then
    echo -e "\n${GREEN}🎉 All tests passed! Your Neovim configuration is working correctly.${NC}"
    exit 0
else
    echo -e "\n${RED}⚠️  Some tests failed. Check the log file: $LOG_FILE${NC}"
    echo -e "${YELLOW}Failed tests details:${NC}"
    grep "FAIL:" "$LOG_FILE" || echo "No failed tests found in log"
    exit 1
fi
