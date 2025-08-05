#!/bin/bash
# ------------------------------------------------------------------
# Contify Media Apps Setup Script
# ------------------------------------------------------------------
# This script is designed to run inside the webapp container via make commands.
# It sets up frontend/media applications with their Node.js dependencies,
# handling different build systems (Grunt, Bower, Angular CLI, npm scripts).
# The script automatically uses local npm installs and npx when running
# in container mode to avoid permission issues.
# ------------------------------------------------------------------

set -e          # Exit immediately if a command exits with a non-zero status.
set -o pipefail # Exit if a command in a pipeline fails.

# --- Colors for output ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# --- Logging functions (must be defined early) ---
log_info() { echo -e "${BLUE}ℹ️  $1${NC}" | tee -a "${LOG_FILE:-/tmp/media-apps-setup.log}"; }
log_success() { echo -e "${GREEN}✅ $1${NC}" | tee -a "${LOG_FILE:-/tmp/media-apps-setup.log}"; }
log_warning() { echo -e "${YELLOW}⚠️  $1${NC}" | tee -a "${LOG_FILE:-/tmp/media-apps-setup.log}"; }
log_error() {
    echo -e "${RED}❌ $1${NC}" | tee -a "${LOG_FILE:-/tmp/media-apps-setup.log}"
    exit 1
} # Exit on critical error

# Non-fatal error logging for app-specific failures
log_app_error() {
    echo -e "${RED}❌ $1${NC}" | tee -a "${LOG_FILE:-/tmp/media-apps-setup.log}"
    # Don't exit - let the calling function handle the error
}
log_step() { echo -e "${CYAN}  → $1${NC}" | tee -a "${LOG_FILE:-/tmp/media-apps-setup.log}"; }
log_header() { echo -e "${MAGENTA}🎨 $1${NC}" | tee -a "${LOG_FILE:-/tmp/media-apps-setup.log}"; }
log_section_separator() { echo -e "${MAGENTA}================================================================${NC}" | tee -a "${LOG_FILE:-/tmp/media-apps-setup.log}"; }

# --- System Detection and Cross-Platform Compatibility ---
# Detect operating system and architecture for container compatibility
detect_system_info() {
    # Detect OS
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        DETECTED_OS="linux"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        DETECTED_OS="macos"
    else
        DETECTED_OS="unknown"
    fi

    # Detect architecture
    DETECTED_ARCH=$(uname -m 2>/dev/null || echo "unknown")
    case "$DETECTED_ARCH" in
    x86_64 | amd64)
        DETECTED_ARCH="x86_64"
        ;;
    aarch64 | arm64)
        DETECTED_ARCH="arm64"
        ;;
    armv7l | armv6l)
        DETECTED_ARCH="arm"
        ;;
    i686 | i386)
        DETECTED_ARCH="i386"
        ;;
    *)
        DETECTED_ARCH="unknown"
        ;;
    esac

    # Set platform-specific configurations
    case "$DETECTED_OS" in
    "linux")
        SHELL_PROFILE="/etc/profile"
        TEMP_DIR="/tmp"
        ;;
    "macos")
        SHELL_PROFILE="/etc/profile"
        TEMP_DIR="/tmp"
        ;;
    "windows")
        SHELL_PROFILE="/etc/profile"
        TEMP_DIR="/tmp"
        ;;
    *)
        SHELL_PROFILE="/etc/profile"
        TEMP_DIR="/tmp"
        ;;
    esac
}

# Call system detection
detect_system_info

# --- Environment Setup for Linux Container ---
# Suppress Node.js deprecation warnings globally
setup_environment() {
    log_info "Setting up environment for $DETECTED_OS ($DETECTED_ARCH)"

    # Suppress Node.js punycode and other deprecation warnings
    export NODE_NO_WARNINGS=1
    export NODE_OPTIONS="--no-deprecation ${NODE_OPTIONS:-}"

    # Configure npm to suppress warnings during installs
    if command -v npm >/dev/null 2>&1; then
        npm config set fund false --silent 2>/dev/null || true
        npm config set audit false --silent 2>/dev/null || true
    fi

    # Check Sass availability (should be pre-installed in container)
    setup_sass_environment
}

# Check Sass availability (expect it to be pre-installed in container)
setup_sass_environment() {
    # Check if sass command is available
    if ! command -v sass >/dev/null 2>&1; then
        log_warning "Sass command not found. Expected to be pre-installed in container image."
        log_info "Some build processes may require sass. Install it globally: npm install -g sass OR gem install sass"

        # Create a stub function to prevent hard failures
        sass() {
            log_warning "sass command called but not installed: sass $*"
            log_info "Install sass in Dockerfile: RUN npm install -g sass OR RUN gem install sass"
            return 0
        }
        export -f sass
    else
        log_success "Sass command found: $(sass --version 2>/dev/null || echo 'version unknown')"
    fi
}

# Function to install Ruby Sass for css/style app
install_ruby_sass_for_css_style() {
    local app_name="$1"

    # Only install for css/style app
    if [ "$app_name" != "css/style" ]; then
        return 0
    fi

    log_step "Checking Ruby Sass availability for css/style app..."

    # Check if Ruby is available
    if ! command -v ruby >/dev/null 2>&1; then
        log_warning "Ruby not found - css/style app requires Ruby Sass"
        log_info "Ruby Sass is needed for the grunt sass:dev task in css/style app"
        log_info "Consider installing Ruby or switching to Dart Sass (npm install -g sass)"
        return 1
    fi

    # Check if gem command is available
    if ! command -v gem >/dev/null 2>&1; then
        log_warning "Ruby gem command not found - cannot install Ruby Sass"
        return 1
    fi

    # Check if sass gem is already installed
    if gem list sass | grep -q "^sass "; then
        local sass_version=$(gem list sass | grep "^sass " | sed 's/sass (\([^)]*\)).*/\1/')
        log_success "Ruby Sass gem already installed: version $sass_version"
        return 0
    fi

    log_step "Installing Ruby Sass gem for css/style app..."
    if [ "$DRY_RUN" = true ]; then
        log_info "DRY RUN: gem install sass --no-document --user-install"
    else
        # Try multiple installation methods for Ruby Sass gem
        local sass_installed=false

        # Method 1: Try user installation first (avoids permission issues)
        log_step "Attempting user installation of Ruby Sass gem..."
        if gem install sass --no-document --user-install 2>/dev/null; then
            log_success "Ruby Sass gem installed successfully (user installation)"
            sass_installed=true
        else
            log_info "User installation failed, trying system installation..."

            # Method 2: Try system installation with sudo if available
            if command -v sudo >/dev/null 2>&1; then
                log_step "Attempting system installation with sudo..."
                if sudo gem install sass --no-document 2>/dev/null; then
                    log_success "Ruby Sass gem installed successfully (system installation with sudo)"
                    sass_installed=true
                else
                    log_info "System installation with sudo failed"
                fi
            fi

            # Method 3: Try bundler if available and Gemfile exists
            if [ "$sass_installed" = false ] && command -v bundle >/dev/null 2>&1 && [ -f "Gemfile" ]; then
                log_step "Attempting installation via bundler..."
                if bundle install 2>/dev/null; then
                    log_success "Dependencies installed via bundler"
                    sass_installed=true
                fi
            fi

            # Method 4: Fall back to Dart Sass via npm as alternative
            if [ "$sass_installed" = false ]; then
                log_step "Installing Dart Sass via npm as fallback..."
                if npm install -g sass 2>/dev/null; then
                    log_success "Dart Sass installed via npm as fallback"
                    sass_installed=true
                elif npm install sass 2>/dev/null; then
                    log_success "Dart Sass installed locally via npm as fallback"
                    sass_installed=true
                fi
            fi
        fi

        if [ "$sass_installed" = true ]; then
            # Verify installation and fix PATH if needed
            if command -v sass >/dev/null 2>&1; then
                local installed_version=$(sass --version 2>/dev/null || echo "version unknown")
                log_success "Sass command available: $installed_version"
            else
                log_warning "Sass gem installed but sass command not in PATH"
                # Try to add gem bin directories to PATH
                local gem_paths=(
                    "$(gem environment gemdir 2>/dev/null)/bin"
                    "$(ruby -e 'puts Gem.user_dir' 2>/dev/null)/bin"
                    "$HOME/.gem/ruby/$(ruby -e 'puts RUBY_VERSION' 2>/dev/null)/bin"
                    "./node_modules/.bin"
                )

                for gem_path in "${gem_paths[@]}"; do
                    if [ -d "$gem_path" ] && [ -x "$gem_path/sass" ]; then
                        export PATH="$gem_path:$PATH"
                        log_info "Added gem bin directory to PATH: $gem_path"
                        if command -v sass >/dev/null 2>&1; then
                            local found_version=$(sass --version 2>/dev/null || echo 'version unknown')
                            log_success "Sass command now available: $found_version"
                            break
                        fi
                    fi
                done

                # If still not found, create a wrapper that uses npx sass
                if ! command -v sass >/dev/null 2>&1; then
                    log_info "Creating sass wrapper to use npm-installed Dart Sass..."
                    local sass_wrapper="/tmp/sass-wrapper-$$.sh"
                    cat >"$sass_wrapper" <<'EOF'
#!/bin/bash
# Sass wrapper script
if command -v npx >/dev/null 2>&1 && npx sass --version >/dev/null 2>&1; then
    npx sass "$@"
elif [ -x "./node_modules/.bin/sass" ]; then
    ./node_modules/.bin/sass "$@"
else
    echo "Error: sass command not found" >&2
    exit 1
fi
EOF
                    chmod +x "$sass_wrapper"
                    # Add wrapper directory to PATH
                    export PATH="$(dirname "$sass_wrapper"):$PATH"
                    # Create a symlink named 'sass' to the wrapper
                    ln -sf "$sass_wrapper" "$(dirname "$sass_wrapper")/sass"
                    log_info "Created sass wrapper script for npm-based Sass"
                fi
            fi
        else
            log_warning "Failed to install Ruby Sass gem or Dart Sass fallback"
            log_info "The css/style app may fail during grunt sass:dev task"
            log_info "Manual installation options:"
            log_info "  - Ruby Sass: gem install sass --user-install"
            log_info "  - Dart Sass: npm install -g sass"
            return 1
        fi
    fi

    return 0
}

# Enhanced Node.js version switching function for individual apps
setup_nodejs_version_for_app() {
    local app_name="$1"
    local node_version="$2"

    if [ "$DRY_RUN" = true ]; then
        log_info "DRY RUN: setup Node.js ${node_version} for ${app_name}"
        return 0
    fi

    # Store current NVM state for verification
    local pre_nvm_node_version=$(command -v node >/dev/null 2>&1 && node --version 2>/dev/null || echo "none")
    log_info "Pre-switch Node.js version: $pre_nvm_node_version (target: $node_version)"

    # Force clean NVM environment reload - this is critical for multi-app setups
    log_step "Reloading NVM environment for clean state..."

    # Clear any existing node/npm from PATH temporarily
    local CLEAN_PATH=$(echo "$PATH" | tr ':' '\n' | grep -v node | grep -v nvm | tr '\n' ':' | sed 's/:$//')

    # Reload NVM environment completely
    unset NVM_DIR
    unset NVM_BIN
    unset NVM_PATH

    # Re-detect and setup NVM environment
    if [ "$CONTAINER_MODE" = true ]; then
        export NVM_DIR="/app/.nvm"
        if [ -s "/etc/profile.d/nvm_env.sh" ]; then
            source /etc/profile.d/nvm_env.sh
        fi
    fi

    # Ensure NVM script is sourced
    if [ -s "$NVM_DIR/nvm.sh" ]; then
        source "$NVM_DIR/nvm.sh"
    else
        log_app_error "NVM script not found at $NVM_DIR/nvm.sh"
        return 1
    fi

    # Verify NVM is available
    if ! command -v nvm >/dev/null 2>&1; then
        log_app_error "NVM command not available after sourcing environment"
        log_info "NVM_DIR: ${NVM_DIR:-not set}"
        log_info "PATH: ${PATH:0:200}..."
        return 1
    fi

    log_step "Installing Node.js ${node_version} if not present..."
    if ! nvm install "${node_version}" 2>/dev/null; then
        log_app_error "Failed to install Node.js ${node_version} for app $app_name"
        return 1
    fi

    log_step "Switching to Node.js ${node_version}..."
    local nvm_use_output
    nvm_use_output=$(nvm use "${node_version}" 2>&1)
    local nvm_use_result=$?

    if [ $nvm_use_result -ne 0 ]; then
        log_app_error "Failed to switch to Node.js ${node_version} for app $app_name"
        log_info "NVM use output: $nvm_use_output"
        log_info "Available versions: $(nvm list 2>/dev/null | head -5 | tr '\n' ' ')"
        return 1
    fi

    log_info "NVM use output: $nvm_use_output"

    # Force environment refresh
    hash -r

    # Re-source NVM to ensure environment is updated
    source "$NVM_DIR/nvm.sh" 2>/dev/null || true

    # Explicitly update PATH with the new Node.js version
    local node_bin_path="$NVM_DIR/versions/node/${node_version}/bin"
    if [ -d "$node_bin_path" ]; then
        # Remove any existing node paths from PATH and add the new one at the beginning
        local cleaned_path=$(echo "$PATH" | tr ':' '\n' | grep -v "/node/v" | tr '\n' ':' | sed 's/:$//')
        export PATH="$node_bin_path:$cleaned_path"
        log_info "Updated PATH with Node.js bin directory: $node_bin_path"
    else
        log_warning "Node.js bin directory not found: $node_bin_path"
    fi

    # Verify the version switch with multiple approaches
    local actual_version="none"
    local node_binary_path="$node_bin_path/node"

    # Method 1: Direct binary execution
    if [ -x "$node_binary_path" ]; then
        actual_version=$("$node_binary_path" --version 2>/dev/null || echo "none")
        log_info "Direct binary check: $actual_version"
    fi

    # Method 2: Command lookup
    if [ "$actual_version" = "none" ] && command -v node >/dev/null 2>&1; then
        actual_version=$(node --version 2>/dev/null || echo "none")
        log_info "Command lookup check: $actual_version"
        log_info "Node found at: $(which node 2>/dev/null || echo 'not found')"
    fi

    # Method 3: Force NVM current
    if [ "$actual_version" = "none" ]; then
        actual_version=$(nvm current 2>/dev/null || echo "none")
        log_info "NVM current check: $actual_version"
    fi

    log_info "Final Node version verification: $actual_version (expected: $node_version)"

    # Validate version match
    if [[ "$actual_version" == "$node_version" ]] || [[ "$actual_version" == "${node_version}"* ]]; then
        log_success "✅ Successfully switched to Node.js $actual_version for $app_name"

        # Verify npm is also available
        if command -v npm >/dev/null 2>&1; then
            local npm_version=$(npm --version 2>/dev/null || echo "unknown")
            log_info "NPM version: $npm_version"
        else
            log_warning "NPM not found after Node.js switch"
        fi

        return 0
    else
        log_app_error "❌ Node.js version switch failed for $app_name"
        log_info "Expected: $node_version, Got: $actual_version"
        log_info "Debug info:"
        log_info "  - NVM_DIR: ${NVM_DIR:-not set}"
        log_info "  - PATH (first 200 chars): ${PATH:0:200}..."
        log_info "  - which node: $(which node 2>/dev/null || echo 'not found')"
        log_info "  - nvm current: $(nvm current 2>/dev/null || echo 'unknown')"
        log_info "  - nvm list (last 3): $(nvm list 2>/dev/null | tail -3 | tr '\n' ' ')"
        return 1
    fi
}

# Call environment setup after system detection
setup_environment

# --- Configuration & Environment Detection ---
if [ -d "/app/contify/contify/media" ]; then
    # Running inside container
    MEDIA_DIR="/app/contify/contify/media"
    CONTAINER_MODE=true
else
    # Running on host (primarily for testing script logic outside container)
    MEDIA_DIR="./contify/contify/media" # Adjust if your host path is different
    CONTAINER_MODE=false
fi
LOG_FILE="/tmp/media-apps-setup.log"

# --- Logging functions already defined above ---

# --- Initialize log file ---
echo "=================================================" >"$LOG_FILE"
echo "Contify Media Apps Setup Log - $(date)" >>"$LOG_FILE"
echo "System: $DETECTED_OS ($DETECTED_ARCH), Container: $CONTAINER_MODE" >>"$LOG_FILE"
echo "Script: $0, Args: $*" >>"$LOG_FILE"
echo "=================================================" >>"$LOG_FILE"

# --- Enhanced Error Handling ---
# Error handler function
error_handler() {
    local exit_code=$?
    local line_number=$1
    log_error "Script failed at line $line_number with exit code $exit_code"
    log_info "Last command: $BASH_COMMAND"
    log_info "Working directory: $(pwd)"
    log_info "Check log file: $LOG_FILE for details"
    exit $exit_code
}

# Set up error trapping
trap 'error_handler $LINENO' ERR

# --- Default values for script arguments ---
MODE="dev"
APPS="all"
INTERACTIVE=false
DRY_RUN=false
PARALLEL=false
FORCE_INSTALL=false

# --- Global counters for tracking results ---
SUCCESS_COUNT=0
FAILURE_COUNT=0
WARNING_COUNT=0
SCRIPT_START_TIME=$(date +%s)

# Arrays to track apps with issues
FAILED_APPS=()
FAILED_APPS_REASONS=()
WARNING_APPS=()
WARNING_APPS_DETAILS=()
SUCCESSFUL_WITH_WARNINGS_APPS=()
SUCCESSFUL_WITH_WARNINGS_DETAILS=()

# Functions to track app failures and warnings
track_app_failure() {
    local app_name="$1"
    local reason="$2"
    FAILED_APPS+=("$app_name")
    FAILED_APPS_REASONS+=("$reason")
}

track_app_warning() {
    local app_name="$1"
    local warning_detail="$2"

    # Check if app is already in warning list
    local app_exists=false
    for i in "${!WARNING_APPS[@]}"; do
        if [[ "${WARNING_APPS[i]}" == "$app_name" ]]; then
            # Append to existing warning details
            WARNING_APPS_DETAILS[i]="${WARNING_APPS_DETAILS[i]}; $warning_detail"
            app_exists=true
            break
        fi
    done

    # If app not in warning list, add it
    if [ "$app_exists" = false ]; then
        WARNING_APPS+=("$app_name")
        WARNING_APPS_DETAILS+=("$warning_detail")
        WARNING_COUNT=$((WARNING_COUNT + 1))
    fi
}

# Function to track apps that completed successfully but with compilation warnings
track_successful_with_warnings() {
    local app_name="$1"
    local warning_detail="$2"

    # Check if app is already in successful with warnings list
    local app_exists=false
    for i in "${!SUCCESSFUL_WITH_WARNINGS_APPS[@]}"; do
        if [[ "${SUCCESSFUL_WITH_WARNINGS_APPS[i]}" == "$app_name" ]]; then
            # Append to existing warning details
            SUCCESSFUL_WITH_WARNINGS_DETAILS[i]="${SUCCESSFUL_WITH_WARNINGS_DETAILS[i]}; $warning_detail"
            app_exists=true
            break
        fi
    done

    # If app not in successful with warnings list, add it
    if [ "$app_exists" = false ]; then
        SUCCESSFUL_WITH_WARNINGS_APPS+=("$app_name")
        SUCCESSFUL_WITH_WARNINGS_DETAILS+=("$warning_detail")
    fi
}

# --- Parse arguments ---
while [[ $# -gt 0 ]]; do
    case $1 in
    --mode=*)
        MODE="${1#*=}"
        shift
        ;;
    --apps=*)
        APPS="${1#*=}"
        shift
        ;;
    --interactive)
        INTERACTIVE=true
        shift
        ;;
    --dry-run)
        DRY_RUN=true
        shift
        ;;
    --parallel)
        PARALLEL=true
        shift
        ;;
    --force)
        FORCE_INSTALL=true
        shift
        ;;
    --help)
        echo "Contify Media Apps Setup Script"
        echo "Usage: $0 [OPTIONS]"
        echo ""
        echo "Options:"
        echo "  --mode=MODE         Build mode: 'dev' or 'prod' (default: dev)"
        echo "  --apps=APPS         Comma-separated list of apps or 'all' (default: all)"
        echo "  --interactive       Interactive mode for app selection"
        echo "  --dry-run           Show what would be done without executing"
        echo "  --parallel          Run compatible apps in parallel (experimental)"
        echo "  --force             Force reinstall packages even if they already exist"
        echo "  --help              Show this help message"
        echo ""
        echo "Examples:"
        echo "  $0                                   # Setup all apps in dev mode (default)"
        echo "  $0 --mode=prod                       # Setup all apps in prod mode"
        echo "  $0 --apps=\"api-webhook,api_tracker\" # Setup specific apps (dev mode)"
        echo "  $0 --interactive                     # Interactive selection"
        exit 0
        ;;
    *)
        log_error "Unknown option: $1"
        echo "Use --help for usage information"
        exit 1
        ;;
    esac
done

log_header "Starting media apps setup (mode: $MODE)"
log_info "System Information: OS=$DETECTED_OS, Architecture=$DETECTED_ARCH, Container=$CONTAINER_MODE"
if [ "$FORCE_INSTALL" = true ]; then
    log_info "Force reinstall mode enabled - will reinstall packages even if already present"
fi

# Check if media directory exists
if [ ! -d "$MEDIA_DIR" ]; then
    log_error "Media directory not found: $MEDIA_DIR"
    log_info "Please ensure the 'contify/contify/media' directory exists and is correctly mounted/available."
    exit 1
fi

# --- Enhanced NVM Setup with Fallbacks ---
# Robust NVM setup that works in container and host environments
setup_nvm() {
    local nvm_loaded=false

    # Container environment (primary)
    if [ "$CONTAINER_MODE" = true ]; then
        export NVM_DIR="/app/.nvm"
        # Try container-specific NVM setup first
        if [ -s "/etc/profile.d/nvm_env.sh" ]; then
            source /etc/profile.d/nvm_env.sh
            nvm_loaded=true
            log_success "NVM loaded from container environment"
        fi
    fi

    # Host environment fallbacks (if container setup failed or not in container)
    if [ "$nvm_loaded" = false ]; then
        local nvm_locations=(
            "$HOME/.nvm/nvm.sh"
            "/usr/local/opt/nvm/nvm.sh"    # Homebrew on macOS Intel
            "/opt/homebrew/opt/nvm/nvm.sh" # Homebrew on Apple Silicon
            "/usr/share/nvm/nvm.sh"        # Some Linux distributions
            "/usr/local/share/nvm/nvm.sh"  # Alternative Linux location
        )

        for nvm_path in "${nvm_locations[@]}"; do
            if [ -s "$nvm_path" ]; then
                export NVM_DIR="$(dirname "$nvm_path")"
                source "$nvm_path"
                # Also source bash_completion if available
                [ -s "$NVM_DIR/bash_completion" ] && source "$NVM_DIR/bash_completion"
                nvm_loaded=true
                log_success "NVM loaded from host environment: $nvm_path"
                break
            fi
        done
    fi

    # Fallback: Try to find NVM in common directories
    if [ "$nvm_loaded" = false ]; then
        local common_nvm_dirs=(
            "/app/.nvm"
            "$HOME/.nvm"
            "/usr/local/nvm"
            "/opt/nvm"
            "/usr/share/nvm"
        )

        for nvm_dir in "${common_nvm_dirs[@]}"; do
            if [ -d "$nvm_dir" ] && [ -s "$nvm_dir/nvm.sh" ]; then
                export NVM_DIR="$nvm_dir"
                source "$nvm_dir/nvm.sh"
                [ -s "$NVM_DIR/bash_completion" ] && source "$NVM_DIR/bash_completion"
                nvm_loaded=true
                log_success "NVM found and loaded from: $nvm_dir"
                break
            fi
        done
    fi

    # Final fallback: Check if Node.js is available without NVM
    if [ "$nvm_loaded" = false ]; then
        if command -v node &>/dev/null && command -v npm &>/dev/null; then
            log_warning "NVM not found, but Node.js is available. Using system Node.js: $(node --version)"
            # Create a dummy nvm function for compatibility
            nvm() {
                case "$1" in
                "install")
                    local requested_version="$2"
                    local current_version=$(node --version)
                    if [ "$requested_version" != "$current_version" ]; then
                        log_warning "Requested Node.js version $requested_version, but system has $current_version"
                        log_info "Continuing with system Node.js version..."
                    fi
                    return 0
                    ;;
                "use")
                    local requested_version="$2"
                    local current_version=$(node --version)
                    if [ "$requested_version" != "$current_version" ]; then
                        log_warning "Cannot switch to Node.js version $requested_version, using system version $current_version"
                    fi
                    return 0
                    ;;
                "--version")
                    echo "system-node-fallback"
                    return 0
                    ;;
                *)
                    log_warning "NVM command '$1' not supported in system Node.js fallback mode"
                    return 0
                    ;;
                esac
            }
            nvm_loaded=true
        else
            log_error "Neither NVM nor Node.js could be found. Please install Node.js or NVM."
            log_info "For macOS with Homebrew: brew install nvm"
            log_info "For Linux: curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash"
            return 1
        fi
    fi

    return 0
}

# Call NVM setup
if ! setup_nvm; then
    exit 1
fi

# Verify NVM or Node.js is available and log version info
if command -v nvm &>/dev/null; then
    nvm_version=$(nvm --version)
    node_version=$(command -v node &>/dev/null && node --version || echo "not installed")
    log_success "NVM loaded successfully. NVM: $nvm_version, Node: $node_version"
elif command -v node &>/dev/null; then
    log_success "Node.js available (system). Version: $(node --version), NPM: $(npm --version)"
else
    log_error "Neither NVM nor Node.js could be found. Cannot proceed."
fi

# --- Check if bower is available (local or global) ---
check_bower_availability() {
    # Check if bower is available locally via npx or globally
    if npx --yes bower --version /dev/null 21 || command -v bower /dev/null; then
        log_step "Bower is available (will use npx bower for local packages)"
        return 0
    else
        log_step "Bower not found - will be installed locally via npm install if needed"
        return 1
    fi
}

# --- Check if grunt-cli is available (local or global) ---
check_grunt_availability() {
    # Check if grunt is available locally via npx or globally
    if npx grunt --version &>/dev/null 2>&1 || command -v grunt &>/dev/null; then
        log_step "Grunt-cli is available (will use npx grunt for local packages)"
        return 0
    else
        log_step "Grunt-cli not found - installing globally for container compatibility"
        if [ "$DRY_RUN" != true ]; then
            # Install grunt-cli globally in container to avoid per-app installation issues
            if npm install -g grunt-cli@1.4.3 2>/dev/null; then
                log_success "Grunt-cli installed globally"
                return 0
            else
                log_warning "Failed to install grunt-cli globally, will try local installations"
                return 1
            fi
        fi
        return 1
    fi
}

# --- Check and install phantomjs-prebuilt if needed ---
check_and_install_phantomjs() {
    # This function will be called after Node version is set for apps that need phantomjs

    # Skip PhantomJS installation on ARM64 architecture due to compatibility issues
    if [[ "$DETECTED_ARCH" == "arm64" ]]; then
        log_warning "Skipping PhantomJS installation on ARM64 architecture due to compatibility issues"
        log_info "PhantomJS does not have prebuilt binaries for ARM64 and compilation often fails"
        log_info "If PhantomJS is required, consider using alternatives like Puppeteer"
        return 0
    fi

    # Check if phantomjs-prebuilt is available in the current Node environment
    if ! npm list phantomjs-prebuilt &>/dev/null; then
        log_step "Installing phantomjs-prebuilt for current Node version..."
        if [ "$DRY_RUN" = true ]; then
            log_info "DRY RUN: npm install phantomjs-prebuilt@2.1.2 --ignore-scripts"
        else
            npm install phantomjs-prebuilt@2.1.2 --ignore-scripts || {
                log_warning "Failed to install phantomjs-prebuilt - this may be due to platform compatibility"
                log_info "Continuing without PhantomJS - some features may not work"
                return 0
            }
            log_success "Phantomjs-prebuilt installed successfully for Node $(node --version)"
        fi
    fi
}

# --- App configurations (embedded) ---
# Format: "node_version:type:setup_commands"
# - 'type' can be 'npm-scripts', 'grunt', 'angular', 'complex', 'bower', 'batch'.
# - 'setup_commands' are comma-separated. Newlines within commands are '\n'.
get_app_config() {
    local app_name="$1"
    case "$app_name" in

    "css/style") echo "v22.6.0:grunt:npm install, grunt css --force" ;;
    "api_tracker") echo "v22.6.0:grunt:npm install,npm install grunt-cli --save-dev,grunt --force" ;;
    "common") echo "v10.16.0:grunt:npm install,echo \"2\" | bower install,grunt --force" ;;
    "company_tracker") echo "v10.16.0:grunt:npm install -g grunt-cli,echo \"2\" | bower install,grunt --force" ;;
    "custom_trigger_management") echo "v10.16.0:grunt:npm install,echo \"2\" | bower install,grunt --force" ;; # Added echo "2" | and --force
    "prompt-management") echo "v10.16.0:npm install,bower install,grunt --force" ;;
    "serp") echo "v10.16.0:grunt:npm install --ignore-scripts,echo \"2\" | bower install,grunt --force" ;;

    "api-webhook") echo "v22.6.0:npm:npm install,npm run devBuild" ;; # devBuild fails, however prodBuild works fine.
    "saved-searches") echo "v12.22.12:npm-scripts:npm install,npm run devBuild" ;;
    "sourcing-manager-new") echo "v10.16.0:grunt:npm install,echo \"2\" | bower install,grunt --force" ;;

    "company-management") echo "v22.6.0:complex:npm run installAll,npm run buildAllDev" ;;
    "company-profile") echo "v22.6.0:complex:npm run installAll,npm run buildAllDev" ;;

    "copilot") echo "v22.6.0:complex:rm -rf node_modules package-lock.json,npm run installAll --legacy-peer-deps,npm run buildAllDev" ;;
    "insights") echo "v22.6.0:complex:npm run installAll,npm run buildAllDev" ;;
    "landing_page") echo "v22.6.0:complex:npm run installAll,npm run buildAllDev" ;;
    "settings/insights") echo "v22.6.0:complex:npm run installAll,npm run buildAllDev" ;;
    "share_point") echo "v22.6.0:complex:npm run installAll,npm run buildAllDev" ;;
    "taxonomy") echo "v22.6.0:complex:npm run installAll,npm run buildAllDev" ;;
    "serp/visualization") echo "v22.6.0:complex:npm run installAll,npm run buildAllDev" ;;

    "ngCfy") echo "v22.6.0:ng:npm install,ng build" ;;
    "prompt-log") echo "v22.6.0:ng:npm install,ng build --configuration development" ;;

    "embed/dashboard") echo "v22.6.0:grunt:npm install,grunt --force" ;;
    "js/dashboard_proto") echo "v22.6.0:grunt:npm install,grunt --force" ;;
    "js/nlc") echo "v22.6.0:grunt:npm install,grunt --force" ;;
    "js/user_management") echo "v22.6.0:grunt:npm install,grunt --force" ;;

    "subscriber_management") echo "v18.16.0:bower:echo \"2\" | bower install" ;;

        # Complex apps with special requirements
    "client_analytics") echo "v22.6.0:complex:npm install -g grunt-cli,echo \"2\" | bower install,grunt --force" ;;

    esac
}

# Transform command to use npx for local binaries when appropriate
transform_command_for_npx() {
    local cmd="$1"

    # List of commands that should be run with npx if they're not globally available
    # and are likely to be available as local dependencies
    local npx_commands=("grunt" "ng" "bower" "webpack" "rollup" "vite" "tsc" "eslint" "prettier" "jest" "mocha" "karma")

    # Handle compound commands with && chains (like in npm scripts)
    if [[ "$cmd" == *" && "* ]]; then
        # Split the command by && and process each part
        local processed_cmd=""
        IFS=' && ' read -ra CMD_PARTS <<<"$cmd"
        for i in "${!CMD_PARTS[@]}"; do
            local part="${CMD_PARTS[i]}"
            # Process each part individually
            local processed_part=$(transform_single_command_for_npx "$part")
            if [ $i -eq 0 ]; then
                processed_cmd="$processed_part"
            else
                processed_cmd="$processed_cmd && $processed_part"
            fi
        done
        echo "$processed_cmd"
        return 0
    fi

    # Handle single commands
    transform_single_command_for_npx "$cmd"
}

# Transform a single command (helper function)
transform_single_command_for_npx() {
    local cmd="$1"

    # List of commands that should be run with npx
    local npx_commands=("grunt" "ng" "bower" "webpack" "rollup" "vite" "tsc" "eslint" "prettier" "jest" "mocha" "karma")

    # Handle piped commands like "echo 2 | bower install"
    if [[ "$cmd" == *" | "* ]]; then
        # Extract the command after the pipe
        local piped_part=$(echo "$cmd" | sed 's/.*| *//')
        local pipe_prefix=$(echo "$cmd" | sed 's/ *|.*//')
        local piped_first_word=$(echo "$piped_part" | awk '{print $1}')

        # Check if the piped command should use npx
        for npx_cmd in "${npx_commands[@]}"; do
            if [[ "$piped_first_word" == "$npx_cmd" ]]; then
                local remaining_args=$(echo "$piped_part" | cut -d' ' -f2-)
                if [[ "$remaining_args" == "$piped_first_word" ]]; then
                    # No additional arguments
                    echo "$pipe_prefix | npx $piped_first_word"
                else
                    # Has additional arguments
                    echo "$pipe_prefix | npx $piped_first_word $remaining_args"
                fi
                return 0
            fi
        done
        # If no npx transformation needed for piped command, return as-is
        echo "$cmd"
        return 0
    fi

    # Extract the first word (command name) from the command
    local first_word=$(echo "$cmd" | awk '{print $1}')

    # Skip cd commands - they don't need npx
    if [[ "$first_word" == "cd" ]]; then
        echo "$cmd"
        return 0
    fi

    # Handle npm run commands specially
    if [[ "$cmd" =~ ^npm[[:space:]]+run[[:space:]]+ ]]; then
        echo "$cmd"
        return 0
    fi

    # Check if this command should use npx
    for npx_cmd in "${npx_commands[@]}"; do
        if [[ "$first_word" == "$npx_cmd" ]]; then
            # Always use npx for consistency, regardless of global availability
            echo "npx $cmd"
            return 0
        fi
    done

    # Return original command if no transformation needed
    echo "$cmd"
}

# Create a wrapper script that ensures npx is used in nested directories
create_npm_wrapper() {
    local wrapper_script="/tmp/npm-wrapper-$$.sh"
    cat >"$wrapper_script" <<'EOF'
#!/bin/bash
# NPM wrapper script to ensure npx is used for local binaries

original_npm="$(which npm)"

# Override npm function to handle npx for local binaries
npm() {
    if [[ "$1" == "run" ]]; then
        # For npm run commands, we need to ensure the script uses npx for local binaries
        # We'll modify the PATH to include local node_modules/.bin
        local original_path="$PATH"
        if [ -d "node_modules/.bin" ]; then
            export PATH="$PWD/node_modules/.bin:$PATH"
        fi
        "$original_npm" "$@"
        local exit_code=$?
        export PATH="$original_path"
        return $exit_code
    else
        "$original_npm" "$@"
    fi
}

# Execute the original command
exec "$@"
EOF
    chmod +x "$wrapper_script"
    echo "$wrapper_script"
}

# Function to handle multi-package apps like ngCfy
handle_multi_package_app() {
    local app_name="$1"
    local app_path="$2"
    local node_version="$3"
    local current_index="$4"
    local total_apps="$5"

    log_info "Handling multi-package app: $app_name"

    # Scan for top-level subdirectories containing package.json, excluding node_modules
    # Use -maxdepth 2 to find package.json files only in immediate subdirectories
    local subprojects=($(find "$app_path" -mindepth 2 -maxdepth 2 -name package.json -not -path "*/node_modules/*" -exec dirname {} \;))

    # Execute commands in each subproject
    for subproject in "${subprojects[@]}"; do
        log_step "Entering subproject directory: $subproject"
        if ! cd "$subproject"; then
            log_error "Failed to change directory to '$subproject'. Skipping this subproject."
            continue
        fi

        # Ensure Node version is correct for subproject
        log_step "Setting up Node.js $node_version for subproject"

        # Ensure NVM environment is loaded in this subshell
        if [ -s "$NVM_DIR/nvm.sh" ]; then
            source "$NVM_DIR/nvm.sh"
        fi

        # Install and switch to required version with suppressed output
        if ! nvm install "$node_version" >/dev/null 2>&1; then
            log_warning "Failed to install Node.js $node_version for subproject"
            continue
        fi

        if ! nvm use "$node_version" >/dev/null 2>&1; then
            log_warning "Failed to switch to Node.js $node_version for subproject"
            continue
        fi

        # Verify version switch
        local current_version=$(node --version 2>/dev/null || echo "none")
        if [[ "$current_version" == "$node_version" ]] || [[ "$current_version" == "${node_version}"* ]]; then
            log_success "Subproject using Node.js $current_version"
        else
            log_warning "Node.js version mismatch in subproject: expected $node_version, got $current_version"
        fi

        # Run npm install
        log_step "Running npm install in $subproject"
        if [ "$DRY_RUN" = true ]; then
            log_info "DRY RUN: npm install"
        else
            npm install || log_warning "Failed npm install in $subproject"
        fi

        # Custom build or other setup commands if needed
        # log_step "Running custom setup in $subproject"
        # Example: you could define custom commands here if needed

        # Return to the main app directory
        cd "$app_path"
    done

    log_success "All subprojects setup completed for multi-package app: $app_name"
    return 0
}

# Get list of all configured apps
get_all_configured_apps() {
    echo "css/style common company_tracker custom_trigger_management prompt-management serp serp/visualization sourcing-manager-new client_analytics ngCfy prompt-log embed/dashboard js/dashboard_proto js/nlc js/user_management subscriber_management company-management copilot insights landing_page settings/insights share_point taxonomy api-webhook saved-searches api_tracker  "
}

# Function to fix Node.js OpenSSL compatibility issues with older webpack versions
fix_nodejs_openssl_compatibility() {
    local app_name="$1"
    local node_version="$2"

    # Extract major version number
    local node_major=$(echo "$node_version" | sed 's/v\([0-9]*\).*/\1/')

    # Check if this is Node.js 17+ (which uses OpenSSL 3.0) with legacy webpack
    if [ "$node_major" -ge 17 ]; then
        # Apps that are known to have older webpack versions that need legacy OpenSSL support
        case "$app_name" in
        "api-webhook" | "saved-searches" | "client_analytics")
            log_warning "Node.js $node_version detected with app '$app_name' - may need OpenSSL legacy provider for older webpack"
            log_info "Setting NODE_OPTIONS to use OpenSSL legacy provider for webpack compatibility"
            if [ "$DRY_RUN" != true ]; then
                # Set the legacy OpenSSL provider flag
                export NODE_OPTIONS="--openssl-legacy-provider ${NODE_OPTIONS:-}"
                log_step "NODE_OPTIONS set to: $NODE_OPTIONS"
            fi
            ;;
        *)
            # For other apps, only warn if we detect specific webpack versions
            if [ -f "package.json" ] && grep -q '"webpack".*"[1-4]\.' "package.json" 2>/dev/null; then
                log_warning "Older webpack detected in '$app_name' with Node.js $node_version - may need OpenSSL legacy provider"
                log_info "If build fails with OpenSSL errors, consider upgrading webpack or Node.js version"
            fi
            ;;
        esac
    fi
}

# Function to handle node-sass compatibility issues
fix_node_sass_compatibility() {
    local app_name="$1"
    local package_json="package.json"

    if [ ! -f "$package_json" ]; then
        return 0
    fi

    # Check if node-sass is present in package.json
    if grep -q '"node-sass"' "$package_json"; then
        local node_sass_version=$(grep -o '"node-sass":[[:space:]]*"[^"]*"' "$package_json" | grep -o '[0-9][^"]*')
        log_warning "Found node-sass version $node_sass_version in $app_name"
        log_info "node-sass can have compatibility issues with newer Node.js versions and ARM64 architecture"

        # Check if we're on ARM64 architecture
        if [[ "$DETECTED_ARCH" == "arm64" ]]; then
            log_warning "ARM64 architecture detected - node-sass may require compilation from source"
            log_info "Node.js v12.22.12 has better ARM64 support for node-sass than v10.16.0"

            # Special handling for saved-searches app on ARM64
            if [ "$app_name" = "saved-searches" ]; then
                log_warning "saved-searches app uses node-sass@4.7.2 on ARM64 - this is problematic"
                log_info "node-sass@4.7.2 does not have prebuilt binaries for ARM64 Linux"
                log_info "ARM64 compilation requires:"
                log_info "  - Python 2.7 (not available in this container)"
                log_info "  - Build tools (make, g++, etc.)"
                log_info "  - Significant compilation time (5-10 minutes)"
                log_info "Recommended solutions for saved-searches:"
                log_info "  1. Upgrade to node-sass ^6.0.0 (supports newer Python and ARM64)"
                log_info "  2. Replace with 'sass' package (Dart Sass - no native compilation needed)"
                log_info "  3. Use precompiled CSS files in the repository"
                if [ "$DRY_RUN" != true ]; then
                    log_step "Configuring npm for extended timeout and verbose logging..."
                    npm config set node-sass-binary-site https://github.com/sass/node-sass/releases/download/ 2>/dev/null || true
                    npm config set timeout 600000 2>/dev/null || true # 10 minutes for potential ARM64 compilation
                    npm config set loglevel info 2>/dev/null || true  # Reduce verbosity but keep important info
                fi
            fi
        fi

        # For very old node-sass versions, warn about Python requirements
        if [[ "$node_sass_version" =~ ^[34]\. ]]; then
            log_warning "Old node-sass version detected ($node_sass_version) - may require Python 2.x for compilation"
            log_info "Node.js v12.22.12 with node-gyp should handle this better than v10.16.0"

            # Check Python availability for node-sass compilation
            if command -v python2 >/dev/null 2>&1; then
                log_info "Python 2.x found - should work with node-sass@4.7.2"
                if [ "$DRY_RUN" != true ]; then
                    npm config set python python2 2>/dev/null || true
                fi
            elif command -v python >/dev/null 2>&1 && python --version 2>&1 | grep -q "Python 2"; then
                log_info "Python 2.x available as 'python' - configuring for node-sass"
                if [ "$DRY_RUN" != true ]; then
                    npm config set python python 2>/dev/null || true
                fi
            else
                log_warning "Python 2.x not found - node-sass@4.7.2 compilation will likely fail"
                log_info "node-sass@4.7.2 requires Python 2.7 for native compilation on ARM64 architecture"
                log_info "Solutions:"
                log_info "  1. Install Python 2.7 in the container (not recommended due to security/maintenance issues)"
                log_info "  2. Upgrade node-sass to a newer version (^6.0.0+ supports newer Python versions)"
                log_info "  3. Replace node-sass with 'sass' (Dart Sass) - the recommended modern alternative"
                log_info "  4. Use prebuilt CSS files instead of compiling SCSS at build time"
                log_warning "Continuing with setup - npm install may show node-sass compilation errors"
            fi
        fi

        # Set npm config to help with node-sass compilation if needed
        if [ "$DRY_RUN" != true ]; then
            log_step "Configuring npm for node-sass compatibility..."
            # Set build timeout to handle slow ARM64 compilation
            npm config set node-sass-binary-site https://github.com/sass/node-sass/releases/download/ 2>/dev/null || true
            npm config set timeout 300000 2>/dev/null || true
        fi
    fi
}

# Function to determine if TypeScript compilation errors should be bypassed
should_bypass_typescript_errors() {
    local app_name="$1"
    local failed_command="$2"
    local exit_code="$3"

    # Only bypass errors for specific nested build commands in certain apps
    # Focus on buildAllDev and buildAllProd which are known to have TypeScript issues
    if [[ "$failed_command" =~ ^npm[[:space:]]+run[[:space:]]+(buildAllDev|buildAllProd) ]]; then
        # Apps where we know TypeScript compilation warnings occur but builds are still usable
        case "$app_name" in
        "company-management" | "company-profile" | "copilot" | "insights" | "landing_page" | "settings/insights" | "share_point" | "taxonomy" | "serp/visualization")
            log_info "Known TypeScript compilation issue in nested builds for '$app_name'"
            log_info "Command: '$failed_command' (exit code: $exit_code)"
            return 0 # Bypass this error
            ;;
        *)
            return 1 # Don't bypass for other apps
            ;;
        esac
    fi

    # Don't bypass other types of errors
    return 1
}

# Function to validate Node.js version compatibility
validate_node_compatibility() {
    local app_name="$1"
    local node_version="$2"

    # Check current Node.js version
    local current_node_version=$(node --version 2>/dev/null || echo "none")

    if [ "$current_node_version" != "none" ]; then
        log_info "Current Node.js version: $current_node_version (requested: $node_version)"

        # Extract major version numbers for comparison
        local current_major=$(echo "$current_node_version" | sed 's/v\([0-9]*\).*/\1/')
        local requested_major=$(echo "$node_version" | sed 's/v\([0-9]*\).*/\1/')

        # Check for native module specifier usage (node:path, etc.)
        if [ "$current_major" -lt 12 ] && (grep -q 'node:' package.json 2>/dev/null || find . -name '*.js' -o -name '*.ts' -o -name '*.jsx' -o -name '*.tsx' | head -10 | xargs grep -l 'node:' 2>/dev/null | head -1 >/dev/null); then
            log_error "Node.js version $current_node_version detected, but app uses 'node:' module specifiers which require Node.js 12+"
            log_info "The app '$app_name' needs Node.js v12 or higher to resolve 'node:path', 'node:fs', etc. imports"
            return 1
        fi

        # Special validation for saved-searches app
        if [ "$app_name" = "saved-searches" ] && [ "$current_major" -lt 12 ]; then
            log_error "The 'saved-searches' app requires Node.js v12+ due to native module imports and node-sass compatibility"
            log_info "Upgrading from v10.16.0 to v12.22.12 to resolve ARM64 binary issues and module resolution"
            return 1
        fi

        if [ "$current_major" -lt 10 ]; then
            log_warning "Very old Node.js version detected ($current_node_version) - many modern packages may not work"
        fi

        # Validate version matches expected for critical apps
        if [ "$current_node_version" != "$node_version" ]; then
            log_info "Version mismatch detected - will use nvm to switch to $node_version"
        fi
    fi

    return 0
}

# Function to execute commands for an app
execute_app_commands() {
    local app_name="$1"
    local current_index="$2"
    local total_apps="$3"
    local config_string=$(get_app_config "$app_name")

    # Record start time for this app
    local app_start_time=$(date +%s)
    # Initialize warning flag for this app
    local APP_HAD_WARNINGS=false

    # Store original npm config to restore later (prevent config pollution between apps)
    local ORIGINAL_NPM_CONFIG_FILE="/tmp/npm-config-backup-$$.json"
    if [ "$DRY_RUN" != true ]; then
        # Backup current npm config
        npm config list --json >"$ORIGINAL_NPM_CONFIG_FILE" 2>/dev/null || echo '{}' >"$ORIGINAL_NPM_CONFIG_FILE"
    fi

    if [ -z "$config_string" ]; then
        log_warning "No configuration found for app '$app_name'. Skipping."
        track_app_failure "$app_name" "No configuration found"
        FAILURE_COUNT=$((FAILURE_COUNT + 1))
        return 1
    fi

    # All the following code should be inside the function
    IFS=':' read -r node_version app_type setup_commands_str <<<"$config_string"

    local APP_PATH="${MEDIA_DIR}/${app_name}"

    log_section_separator
    log_header "⚙️ Setting up App [${current_index}/${total_apps}]: ${app_name} (Node: ${node_version}, Type: ${app_type})"
    log_section_separator

    if [ ! -d "$APP_PATH" ]; then
        log_warning "Application directory '$APP_PATH' not found. Skipping."
        track_app_failure "$app_name" "Directory not found: $APP_PATH"
        FAILURE_COUNT=$((FAILURE_COUNT + 1))
        return 1
    fi

    # Handle multi-package apps (like ngCfy) that have subdirectories with package.json
    if [[ "$app_name" == "ngCfy" ]]; then
        handle_multi_package_app "$app_name" "$APP_PATH" "$node_version" "$current_index" "$total_apps"
        local multi_package_result=$?
        cd "$original_dir" # Ensure we return to original directory
        if [ $multi_package_result -eq 0 ]; then
            SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
            log_success "✅ Finished setup for App [${current_index}/${total_apps}]: ${app_name}!"
        else
            FAILURE_COUNT=$((FAILURE_COUNT + 1))
            track_app_failure "$app_name" "Multi-package app setup failed"
        fi
        return $multi_package_result
    fi

    # Change to the application directory
    local original_dir=$(pwd)
    if ! cd "$APP_PATH"; then
        log_app_error "Failed to change directory to '$APP_PATH'. Aborting setup for this app."
        FAILURE_COUNT=$((FAILURE_COUNT + 1))
        return 1
    fi

    # Check if package.json exists in the root directory before proceeding
    if [ ! -f "package.json" ]; then
        log_warning "No package.json found in '$APP_PATH'. Skipping npm-based commands."
        cd "$original_dir"
        FAILURE_COUNT=$((FAILURE_COUNT + 1))
        return 1
    fi

    # Note: Using npx for local binaries instead of modifying PATH
    log_step "Using npx to execute local binaries when available..."

    # Validate Node.js compatibility before switching versions
    if ! validate_node_compatibility "$app_name" "$node_version"; then
        log_warning "Pre-install compatibility check failed, proceeding with Node.js version switch..."
    fi

    # Enhanced Node.js version switching with robust NVM environment management
    log_step "Setting up Node.js ${node_version} environment for ${app_name}..."
    if ! setup_nodejs_version_for_app "$app_name" "$node_version"; then
        log_app_error "Failed to setup Node.js ${node_version} environment for app $app_name"
        track_app_failure "$app_name" "Failed to setup Node.js ${node_version} environment"
        cd "$original_dir"
        FAILURE_COUNT=$((FAILURE_COUNT + 1))
        return 1
    fi

    # Final compatibility validation after switching versions
    if ! validate_node_compatibility "$app_name" "$node_version"; then
        log_app_error "Post-install Node.js compatibility validation failed for $app_name"
        cd "$original_dir"
        FAILURE_COUNT=$((FAILURE_COUNT + 1))
        return 1
    fi

    # Fix Node.js OpenSSL compatibility issues with older webpack versions
    fix_nodejs_openssl_compatibility "$app_name" "$node_version"

    # Handle node-sass compatibility issues
    fix_node_sass_compatibility "$app_name"

    # Install Ruby Sass for css/style app specifically
    if [[ "$app_name" == "css/style" ]]; then
        if ! install_ruby_sass_for_css_style "$app_name"; then
            log_warning "Ruby Sass installation failed for css/style app - grunt sass:dev task may fail"
            track_app_warning "$app_name" "Ruby Sass gem installation failed"
        fi
    fi

    # Set Angular CLI analytics to false globally to prevent prompts in nested builds and Angular apps
    if [[ "$app_type" == "complex" ]] || [[ "$app_type" == "ng" ]] || [[ "$app_name" == "landing_page" ]] || [[ "$app_name" == "taxonomy" ]] || [[ "$app_name" == "prompt-log" ]] || [[ "$app_name" == "ngCfy" ]]; then
        log_step "Disabling Angular CLI analytics to prevent prompts..."
        if [ "$DRY_RUN" != true ]; then
            export NG_CLI_ANALYTICS=false
            # Also set it globally in npm config to avoid modifying project files
            npm config set '@angular/cli:analytics' false 2>/dev/null || true
            # Note: Avoiding 'npx ng analytics off' as it modifies angular.json files
            log_info "Angular CLI analytics disabled via environment variables and npm config"
        fi
    fi

    # Check if this app needs bower (just log availability, don't install globally)
    if [[ "$setup_commands_str" =~ bower\ install ]]; then
        check_bower_availability
    fi

    # Check if this app needs grunt (just log availability, don't install globally)
    if [[ "$setup_commands_str" =~ grunt ]] || [[ "$app_type" == "grunt" ]]; then
        check_grunt_availability
    fi

    # Check if this app might need phantomjs-prebuilt (for older grunt-based apps)
    # Install phantomjs-prebuilt for grunt-based apps using older Node versions that commonly need it
    # Skip for client_analytics and other apps on ARM64 as PhantomJS doesn't support ARM64
    if [[ "$app_type" == "grunt" ]] && [[ "$node_version" == v4.* || "$node_version" == v6.* || "$node_version" == v8.* || "$node_version" == v10.* ]] && [[ "$app_name" != "client_analytics" ]]; then
        check_and_install_phantomjs
    fi

    # Special handling for client_analytics PhantomJS dependency on ARM64
    if [[ "$app_name" == "client_analytics" ]] && [[ "$DETECTED_ARCH" == "arm64" ]]; then
        log_warning "Detected client_analytics app on ARM64 - PhantomJS installation will be skipped"
        log_info "PhantomJS will fail to install on ARM64. Skipping PhantomJS installation..."
        log_step "PhantomJS dependencies not removed; consider using Puppeteer as an alternative"
        # Consider informing developers to handle PhantomJS dependencies manually or switch to a different library
        track_app_warning "$app_name" "PhantomJS skipped on ARM64 architecture due to compatibility issues"
    fi

    # For complex apps, warn about --watch flags in build scripts that might hang
    local MODIFIED_SCRIPTS=false
    if [[ "$app_type" == "complex" ]] && [[ "$setup_commands_str" =~ buildAllDev ]]; then
        if grep -q '"buildAllDev".*--watch' "package.json" 2>/dev/null; then
            log_warning "Detected --watch flags in buildAllDev script for $app_name"
            log_info "Setup may take longer or appear to hang due to watch mode"
            log_info "Consider running builds manually without --watch for setup purposes"
        fi
    fi

    log_step "Running setup commands for '$app_name' in ${MODE} mode..."

    # Split setup commands string by comma
    IFS=',' read -r -a commands_array <<<"$setup_commands_str"

    for cmd_raw in "${commands_array[@]}"; do
        # Trim leading/trailing whitespace
        local cmd_line=$(echo "$cmd_raw" | xargs)

        # Expand '\n' into actual newlines for multi-line commands within a single config string
        local commands_to_run=$(echo -e "$cmd_line")

        # Process each sub-command line (if 'commands_to_run' itself contains newlines)
        # Use process substitution instead of pipe to avoid subshell issues
        while IFS= read -r sub_cmd_line; do
            sub_cmd_line=$(echo "$sub_cmd_line" | xargs) # Trim again

            # Skip empty lines or lines that are comments (starting with #)
            if [[ -z "$sub_cmd_line" || "$sub_cmd_line" =~ ^\# ]]; then
                continue
            fi

            # Remove markdown list prefixes (*, -) and extra whitespace
            local cmd_to_exec=$(echo "$sub_cmd_line" | sed -e 's/^[[:space:]]*[*-\s]*//')

            # Transform command to use npx for local binaries when appropriate
            cmd_to_exec=$(transform_command_for_npx "$cmd_to_exec")

            # --- Conditional Execution based on MODE ---
            # This logic attempts to pick dev/prod specific builds
            local should_execute=false
            if [[ "$cmd_to_exec" =~ ^npm[[:space:]]+run[[:space:]]+(devBuild|buildAllDev) ]]; then
                if [ "$MODE" = "dev" ]; then should_execute=true; fi
            elif [[ "$cmd_to_exec" =~ ^npm[[:space:]]+run[[:space:]]+(prodBuild|buildAll) ]]; then
                if [ "$MODE" = "prod" ]; then should_execute=true; fi
            elif [[ "$cmd_to_exec" =~ ^(npx[[:space:]]+)?ng[[:space:]]+build ]]; then
                # Handle ng build (with or without npx): if --prod is in cmd_to_exec, run only in prod mode.
                # If --dev is in cmd_to_exec, run only in dev mode.
                # If neither, run in dev mode by default.
                if [[ "$cmd_to_exec" =~ --prod ]] && [ "$MODE" = "prod" ]; then
                    should_execute=true
                elif [[ "$cmd_to_exec" =~ --dev ]] && [ "$MODE" = "dev" ]; then
                    should_execute=true
                elif ! [[ "$cmd_to_exec" =~ --prod|--dev ]] && [ "$MODE" = "dev" ]; then
                    # Generic ng build without explicit mode flags runs in dev
                    should_execute=true
                fi
            else
                # For generic commands like npm install, bower install, grunt, gem, etc.
                should_execute=true
            fi

            if [ "$should_execute" = true ]; then
                log_step "Executing: $cmd_to_exec"
                if [ "$DRY_RUN" = true ]; then
                    log_info "DRY RUN: $cmd_to_exec"
                else
                    # For npm run commands, ensure local binaries are available in nested scripts
                    if [[ "$cmd_to_exec" =~ ^npm[[:space:]]+run[[:space:]]+ ]]; then
                        # Create a custom environment for npm run that includes local binaries in PATH
                        local original_path="$PATH"
                        # Add current directory node_modules/.bin to PATH
                        if [ -d "node_modules/.bin" ]; then
                            export PATH="$PWD/node_modules/.bin:$PATH"
                        fi

                        # Execute the command
                        if ! bash -c "$cmd_to_exec"; then
                            export PATH="$original_path" # Restore PATH before error exit

                            # Special handling for TypeScript compilation errors in specific apps
                            if should_bypass_typescript_errors "$app_name" "$cmd_to_exec" "$?"; then
                                log_warning "Build command failed with TypeScript errors, but continuing as configured: '$cmd_to_exec'"
                                log_info "⚠️  TypeScript compilation warnings detected in '$app_name'"
                                log_info "   This is a known issue that should be addressed by developers."
                                log_info "   The build artifacts may still be usable for development/testing."
                                track_successful_with_warnings "$app_name" "TypeScript compilation errors in nested build command: $cmd_to_exec"
                                # Set a flag to indicate this app had warnings
                                APP_HAD_WARNINGS=true
                                # Continue with setup - don't treat this as a failure
                            else
                                log_app_error "Command failed for '$app_name': '$cmd_to_exec'"
                                track_app_failure "$app_name" "Command failed: $cmd_to_exec"
                                cd "$original_dir" # Return to original dir before continuing
                                FAILURE_COUNT=$((FAILURE_COUNT + 1))
                                return 1
                            fi
                        fi

                        # Restore original PATH
                        export PATH="$original_path"
                    else
                        # Execute the command
                        # Temporarily disable error trap to allow custom error handling
                        trap - ERR
                        bash -c "$cmd_to_exec"
                        local cmd_exit_code=$?
                        # Re-enable error trap
                        trap 'error_handler $LINENO' ERR

                        if [ $cmd_exit_code -ne 0 ]; then
                            # Special handling for PhantomJS failure in apps with grunt-contrib-qunit
                            if [[ "$cmd_to_exec" == "npm install" ]] && [[ "$DETECTED_ARCH" == "arm64" ]] && [[ "$app_name" =~ ^(company_tracker|sourcing-manager-new|custom_trigger_management)$ ]]; then
                                case "$app_name" in
                                "company_tracker")
                                    local qunit_version="~1.0.1"
                                    local phantomjs_info="grunt-contrib-qunit@1.0.1 requires phantomjs-prebuilt@2.1.16"
                                    ;;
                                "sourcing-manager-new")
                                    local qunit_version="~0.5.2"
                                    local phantomjs_info="grunt-contrib-qunit@0.5.2 requires phantomjs@1.9.20"
                                    ;;
                                "custom_trigger_management")
                                    local qunit_version="~0.5.2"
                                    local phantomjs_info="grunt-contrib-qunit@0.5.2 requires phantomjs@1.9.20"
                                    ;;
                                esac

                                log_app_error "$app_name setup failed due to PhantomJS dependency incompatibility with ARM64 architecture"
                                log_info "🔧 SOLUTION: Remove grunt-contrib-qunit from package.json to fix this issue"
                                log_info "   $phantomjs_info which doesn't support ARM64"
                                log_info "   PhantomJS error: 'Unexpected platform or architecture: linux/arm64'"
                                log_info "   Note: grunt-contrib-qunit is used for testing but may not be essential for build process"
                                log_info ""
                                log_info "To fix this:"
                                log_info "   1. Edit contify/contify/media/$app_name/package.json"
                                log_info "   2. Remove the line: \"grunt-contrib-qunit\": \"$qunit_version\","
                                log_info "   3. Re-run the setup: make setup-media-apps APPS=\"$app_name\""
                                log_info ""
                                log_info "Alternative solutions:"
                                log_info "   - Use Puppeteer or Playwright for testing instead of PhantomJS"
                                log_info "   - Run setup on x86_64 architecture instead of ARM64"
                                log_info "   - Update grunt-contrib-qunit to a newer version that doesn't require PhantomJS"
                                track_app_failure "$app_name" "PhantomJS dependency failure - remove grunt-contrib-qunit from package.json"
                                cd "$original_dir"
                                FAILURE_COUNT=$((FAILURE_COUNT + 1))
                                return 1
                            # Special handling for TypeScript compilation errors in specific apps
                            elif should_bypass_typescript_errors "$app_name" "$cmd_to_exec" "$cmd_exit_code"; then
                                log_warning "Build command failed with TypeScript errors, but continuing as configured: '$cmd_to_exec'"
                                log_info "⚠️  TypeScript compilation warnings detected in '$app_name'"
                                log_info "   This is a known issue that should be addressed by developers."
                                log_info "   The build artifacts may still be usable for development/testing."
                                track_successful_with_warnings "$app_name" "TypeScript compilation errors in nested build command: $cmd_to_exec"
                                # Set a flag to indicate this app had warnings
                                APP_HAD_WARNINGS=true
                            else
                                log_app_error "Command failed for '$app_name': '$cmd_to_exec'"
                                track_app_failure "$app_name" "Command failed: $cmd_to_exec"
                                cd "$original_dir" # Return to original dir before continuing
                                FAILURE_COUNT=$((FAILURE_COUNT + 1))
                                return 1
                            fi
                        fi
                    fi
                fi
            else
                log_step "Skipping (mode: ${MODE}): $cmd_to_exec"
            fi
        done < <(echo "$commands_to_run")
    done

    # Return to the original directory
    cd "$original_dir"

    # No need to restore scripts since we're not modifying package.json files

    # Calculate elapsed time for this app
    local app_end_time=$(date +%s)
    local app_elapsed=$((app_end_time - app_start_time))
    local app_elapsed_formatted=$(printf "%02d:%02d:%02d" $((app_elapsed / 3600)) $(((app_elapsed % 3600) / 60)) $((app_elapsed % 60)))

    # Count this app appropriately based on whether it had warnings
    if [ "$APP_HAD_WARNINGS" = true ]; then
        # Don't increment SUCCESS_COUNT for apps with warnings - they're tracked separately
        log_success "✅ Finished setup for App [${current_index}/${total_apps}]: ${app_name} (with warnings)! (Elapsed: ${app_elapsed_formatted})"
    else
        SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
        log_success "✅ Finished setup for App [${current_index}/${total_apps}]: ${app_name}! (Elapsed: ${app_elapsed_formatted})"
    fi
    echo # Add a newline for better separation after each app
    return 0
}

# --- Main execution logic ---
selected_apps=()
if [ "$APPS" = "all" ]; then
    selected_apps=($(get_all_configured_apps))
else
    IFS=',' read -r -a selected_apps <<<"$APPS"
fi

# Interactive mode for app selection
if [ "$INTERACTIVE" = true ]; then
    log_info "Entering interactive app selection mode."
    local temp_selected_apps=()
    for app in $(get_all_configured_apps); do
        read -p "Include '$app' in setup? [y/N]: " include_app
        if [[ "$include_app" =~ ^[Yy]$ ]]; then
            temp_selected_apps+=("$app")
        fi
    done
    selected_apps=("${temp_selected_apps[@]}")
    if [ ${#selected_apps[@]} -eq 0 ]; then
        log_warning "No applications selected. Exiting."
        exit 0
    fi
fi

if [ ${#selected_apps[@]} -eq 0 ]; then
    log_error "No applications to set up. Please check your --apps parameter or configured apps."
fi

APP_COUNTER=0
TOTAL_APPS=${#selected_apps[@]}

if [ "$PARALLEL" = true ]; then
    log_warning "Parallel execution is experimental and may lead to conflicting Node/NPM states."
    # Basic parallel execution (can be expanded)
    for app in "${selected_apps[@]}"; do
        APP_COUNTER=$((APP_COUNTER + 1))
        log_info "Starting '$app' in background (App ${APP_COUNTER}/${TOTAL_APPS})..."
        execute_app_commands "$app" "$APP_COUNTER" "$TOTAL_APPS" & # Run in background
    done
    wait # Wait for all background jobs to finish
else
    for app in "${selected_apps[@]}"; do
        APP_COUNTER=$((APP_COUNTER + 1))
        # Continue with next app even if current one fails
        if ! execute_app_commands "$app" "$APP_COUNTER" "$TOTAL_APPS"; then
            log_warning "App '$app' setup failed, continuing with next app..."
        fi
    done
fi

# Calculate total elapsed time
SCRIPT_END_TIME=$(date +%s)
TOTAL_ELAPSED=$((SCRIPT_END_TIME - SCRIPT_START_TIME))
TOTAL_ELAPSED_FORMATTED=$(printf "%02d:%02d:%02d" $((TOTAL_ELAPSED / 3600)) $(((TOTAL_ELAPSED % 3600) / 60)) $((TOTAL_ELAPSED % 60)))

# Print summary report
log_section_separator
log_header "📊 SETUP SUMMARY REPORT"
log_section_separator
log_info "Total Apps Processed: $((SUCCESS_COUNT + FAILURE_COUNT + ${#SUCCESSFUL_WITH_WARNINGS_APPS[@]} + ${#WARNING_APPS[@]}))"
log_success "✅ Successful Setups (Clean): $SUCCESS_COUNT"

# Create comma-separated lists for cleaner reporting

# Show successful apps with compilation warnings (TypeScript errors in nested builds)
if [ ${#SUCCESSFUL_WITH_WARNINGS_APPS[@]} -gt 0 ]; then
    successful_with_warnings_list=$(
        IFS=', '
        echo "${SUCCESSFUL_WITH_WARNINGS_APPS[*]}"
    )
    log_warning "🔶 Successful with Compilation Warnings (${#SUCCESSFUL_WITH_WARNINGS_APPS[@]}): $successful_with_warnings_list"
    log_info "   ⚠️  These apps have TypeScript/compilation issues in nested builds that developers should address."
fi

# Show apps with other warnings (not compilation failures)
if [ $WARNING_COUNT -gt 0 ]; then
    warning_apps_list=$(
        IFS=', '
        echo "${WARNING_APPS[*]}"
    )
    log_warning "⚠️  Apps with Other Warnings (${#WARNING_APPS[@]}): $warning_apps_list"
    log_info "   ℹ️  These apps have non-critical warnings (e.g., dependency issues, architecture compatibility)."
fi

# Show failed apps
if [ $FAILURE_COUNT -gt 0 ]; then
    failed_apps_list=$(
        IFS=', '
        echo "${FAILED_APPS[*]}"
    )
    log_warning "❌ Failed Setups (${FAILURE_COUNT}): $failed_apps_list"
    log_info "   🔧 These apps require manual intervention. Check the log for detailed error reasons."
else
    log_info "✅ No failed setups."
fi

log_info "⏱️  Total Elapsed Time: $TOTAL_ELAPSED_FORMATTED"
log_info "🖥️  System: $DETECTED_OS ($DETECTED_ARCH), Container: $CONTAINER_MODE"
log_info "📄 Full log available at: $LOG_FILE"

# Determine overall success based on different criteria
CRITICAL_FAILURES=0
SUCCESSFUL_APPS=$((SUCCESS_COUNT + ${#SUCCESSFUL_WITH_WARNINGS_APPS[@]}))
TOTAL_PROCESSED_APPS=$((SUCCESS_COUNT + FAILURE_COUNT + ${#SUCCESSFUL_WITH_WARNINGS_APPS[@]} + ${#WARNING_APPS[@]}))

# Count only critical failures (not configuration issues or minor problems)
for i in "${!FAILED_APPS[@]}"; do
    reason="${FAILED_APPS_REASONS[i]}"
    # Don't count configuration or directory issues as critical failures
    if [[ "$reason" != "No configuration found" ]] && [[ "$reason" != "Directory not found:"* ]]; then
        CRITICAL_FAILURES=$((CRITICAL_FAILURES + 1))
    fi
done

# Calculate success rate
if [ $TOTAL_PROCESSED_APPS -gt 0 ]; then
    SUCCESS_RATE=$(((SUCCESSFUL_APPS * 100) / TOTAL_PROCESSED_APPS))
else
    SUCCESS_RATE=0
fi

log_section_separator
if [ $CRITICAL_FAILURES -eq 0 ] && [ $SUCCESSFUL_APPS -gt 0 ]; then
    log_success "🎉 Media applications setup completed successfully!"
    if [ $FAILURE_COUNT -gt 0 ]; then
        log_info "Note: $FAILURE_COUNT apps were skipped due to configuration or directory issues."
    fi
    if [ ${#SUCCESSFUL_WITH_WARNINGS_APPS[@]} -gt 0 ]; then
        log_info "Note: ${#SUCCESSFUL_WITH_WARNINGS_APPS[@]} apps completed with compilation warnings that developers should address."
    fi
elif [ $SUCCESS_RATE -ge 80 ] && [ $SUCCESSFUL_APPS -gt 0 ]; then
    log_success "🎯 Media applications setup mostly successful! ($SUCCESS_RATE% success rate)"
    if [ $CRITICAL_FAILURES -gt 0 ]; then
        log_warning "$CRITICAL_FAILURES apps had critical failures that may need attention."
    fi
else
    log_warning "⚠️ Media applications setup had significant issues."
    if [ $CRITICAL_FAILURES -gt 0 ]; then
        log_warning "$CRITICAL_FAILURES apps had critical failures requiring intervention."
    fi
fi
log_section_separator

# Disable error trap before exit to prevent interference with normal exit
trap - ERR

# Exit with appropriate code - only fail on critical issues or very low success rate
if [ $CRITICAL_FAILURES -gt 0 ] && [ $SUCCESS_RATE -lt 50 ]; then
    log_info "Exiting with error code due to critical failures and low success rate."
    exit 1
elif [ $SUCCESSFUL_APPS -eq 0 ] && [ $TOTAL_PROCESSED_APPS -gt 0 ]; then
    log_info "Exiting with error code - no apps were successfully set up."
    exit 1
else
    # Success case - at least some apps worked, or only minor issues
    log_info "Setup completed. Most apps are ready for use."
    exit 0
fi
