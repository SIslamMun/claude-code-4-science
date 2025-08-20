#!/bin/bash
# ========================================================================
# WARPIO PRE-INSTALLATION SCRIPT
# Prepares system with all required dependencies for Warpio
# Supports: Linux, macOS, WSL
# ========================================================================

set -euo pipefail

# Configuration
REQUIRED_NODE_VERSION="24"
NVM_VERSION="v0.40.3"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# Helper functions
log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}✓${NC} $1"; }
log_error() { echo -e "${RED}✗${NC} $1" >&2; }
log_warning() { echo -e "${YELLOW}⚠${NC} $1"; }

print_banner() {
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║           WARPIO PRE-INSTALLATION DEPENDENCIES              ║${NC}"
    echo -e "${CYAN}║                    System Preparation                       ║${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo
}

# Detect operating system
detect_os() {
    case "$(uname -s)" in
        Linux*)
            if grep -q Microsoft /proc/version 2>/dev/null; then
                OS="WSL"
            else
                OS="Linux"
            fi
            ;;
        Darwin*)
            OS="macOS"
            ;;
        *)
            log_error "Unsupported operating system: $(uname -s)"
            exit 1
            ;;
    esac
    log_info "Detected OS: $OS"
}

# Check and install system packages
install_system_packages() {
    log_info "Checking system packages..."
    
    case "$OS" in
        Linux|WSL)
            # Check for package manager
            if command -v apt-get &>/dev/null; then
                PKG_MGR="apt-get"
                UPDATE_CMD="sudo apt-get update"
                INSTALL_CMD="sudo apt-get install -y"
            elif command -v yum &>/dev/null; then
                PKG_MGR="yum"
                UPDATE_CMD="sudo yum check-update || true"
                INSTALL_CMD="sudo yum install -y"
            elif command -v dnf &>/dev/null; then
                PKG_MGR="dnf"
                UPDATE_CMD="sudo dnf check-update || true"
                INSTALL_CMD="sudo dnf install -y"
            else
                log_error "No supported package manager found (apt-get, yum, or dnf)"
                exit 1
            fi
            
            log_info "Updating package lists..."
            eval "$UPDATE_CMD"
            
            # Install required packages
            local packages="curl git jq build-essential"
            log_info "Installing system packages: $packages"
            eval "$INSTALL_CMD $packages"
            ;;
            
        macOS)
            # Check for Homebrew
            if ! command -v brew &>/dev/null; then
                log_info "Installing Homebrew..."
                /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
            fi
            
            log_info "Installing system packages with Homebrew..."
            brew install curl git jq
            ;;
    esac
    
    log_success "System packages ready"
}

# Install or update Node.js via NVM
install_nodejs() {
    log_info "Setting up Node.js v${REQUIRED_NODE_VERSION}..."
    
    # Install NVM if not present
    if [ ! -d "$HOME/.nvm" ]; then
        log_info "Installing NVM (Node Version Manager)..."
        curl -o- "https://raw.githubusercontent.com/nvm-sh/nvm/${NVM_VERSION}/install.sh" | bash
    else
        log_info "NVM already installed"
    fi
    
    # Load NVM
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
    
    # Install required Node.js version
    log_info "Installing Node.js v${REQUIRED_NODE_VERSION}..."
    nvm install "$REQUIRED_NODE_VERSION"
    nvm use "$REQUIRED_NODE_VERSION"
    nvm alias default "$REQUIRED_NODE_VERSION"
    
    # Verify installation
    local node_version=$(node -v)
    local npm_version=$(npm -v)
    log_success "Node.js installed: $node_version"
    log_success "npm installed: $npm_version"
}

# Install Claude Code CLI
install_claude_code() {
    log_info "Installing Claude Code CLI..."
    
    # Ensure we're using the right Node version
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    nvm use "$REQUIRED_NODE_VERSION"
    
    # Install Claude Code globally
    if npm install -g @anthropic-ai/claude-code; then
        local claude_version=$(claude --version 2>/dev/null || echo "version check failed")
        log_success "Claude Code installed: $claude_version"
    else
        log_error "Failed to install Claude Code CLI"
        exit 1
    fi
}

# Install Python and UV for Python MCPs
install_python_tools() {
    log_info "Setting up Python tools..."
    
    # Check for Python 3
    if ! command -v python3 &>/dev/null; then
        log_warning "Python 3 not found, installing..."
        case "$OS" in
            Linux|WSL)
                eval "$INSTALL_CMD python3 python3-pip"
                ;;
            macOS)
                brew install python@3
                ;;
        esac
    else
        log_success "Python 3 detected: $(python3 --version)"
    fi
    
    # Install UV package manager
    if ! command -v uv &>/dev/null; then
        log_info "Installing UV package manager..."
        curl -LsSf https://astral.sh/uv/install.sh | sh
        
        # Add UV to PATH for current session
        export PATH="$HOME/.local/bin:$PATH"
    else
        log_success "UV already installed: $(uv --version)"
    fi
    
    # Ensure uvx is available
    if command -v uvx &>/dev/null; then
        log_success "uvx command available"
    else
        log_warning "uvx not found in PATH"
        log_info "Adding $HOME/.local/bin to PATH in shell profile..."
        
        # Add to appropriate shell profile
        local shell_profile=""
        if [ -f "$HOME/.bashrc" ]; then
            shell_profile="$HOME/.bashrc"
        elif [ -f "$HOME/.zshrc" ]; then
            shell_profile="$HOME/.zshrc"
        elif [ -f "$HOME/.profile" ]; then
            shell_profile="$HOME/.profile"
        fi
        
        if [ -n "$shell_profile" ]; then
            echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$shell_profile"
            log_info "Added UV to PATH in $shell_profile"
        fi
    fi
}

# Verify all dependencies
verify_dependencies() {
    log_info "Verifying all dependencies..."
    echo
    
    local all_good=true
    
    # Check critical commands
    local commands=("git" "curl" "jq" "node" "npm" "npx" "claude" "python3" "uv" "uvx")
    for cmd in "${commands[@]}"; do
        if command -v "$cmd" &>/dev/null; then
            log_success "$cmd is available"
        else
            log_error "$cmd is NOT available"
            all_good=false
        fi
    done
    
    echo
    if [ "$all_good" = true ]; then
        log_success "All dependencies installed successfully!"
        return 0
    else
        log_warning "Some dependencies are missing. Please check the errors above."
        return 1
    fi
}

# Main execution
main() {
    print_banner
    
    # Detect OS
    detect_os
    echo
    
    # Install system packages
    install_system_packages
    echo
    
    # Install Node.js
    install_nodejs
    echo
    
    # Install Claude Code
    install_claude_code
    echo
    
    # Install Python tools
    install_python_tools
    echo
    
    # Verify everything
    if verify_dependencies; then
        echo
        echo -e "${GREEN}════════════════════════════════════════════════════════════════${NC}"
        echo -e "${GREEN}✓ System is ready for Warpio installation!${NC}"
        echo -e "${GREEN}════════════════════════════════════════════════════════════════${NC}"
        echo
        echo "Next steps:"
        echo -e "  1. ${CYAN}source ~/.bashrc${NC} (or restart your terminal)"
        echo -e "  2. ${CYAN}./install.sh [target-directory]${NC}"
        echo
        echo "Or install directly from GitHub:"
        echo -e "  ${CYAN}curl -LsSf https://raw.githubusercontent.com/akougkas/claude-code-4-science/main/install.sh | bash${NC}"
        echo
    else
        echo
        echo -e "${RED}════════════════════════════════════════════════════════════════${NC}"
        echo -e "${RED}⚠ Pre-installation incomplete${NC}"
        echo -e "${RED}════════════════════════════════════════════════════════════════${NC}"
        echo
        echo "Please resolve the issues above and run this script again."
        exit 1
    fi
}

# Run main function
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    main "$@"
fi