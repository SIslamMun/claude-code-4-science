#!/bin/bash
# ========================================================================
# WARPIO ONE-COMMAND INSTALLER
# The easiest way to enhance Claude Code with scientific computing powers
# 
# Usage:
#   curl -sSL https://raw.githubusercontent.com/akougkas/claude-code-4-science/main/install.sh | bash
#   curl -sSL https://raw.githubusercontent.com/akougkas/claude-code-4-science/main/install.sh | bash -s -- --help
# ========================================================================

set -e

# Configuration
REPO_URL="https://github.com/akougkas/claude-code-4-science.git"
REPO_RAW="https://raw.githubusercontent.com/akougkas/claude-code-4-science/main"
BRANCH="main"
VERSION="2.0.0"
INSTALL_DIR=""
VERBOSE=false
DRY_RUN=false
AUTO_YES=false
UNINSTALL=false
UPDATE_CHECK=false

# Colors
if [ -t 1 ]; then
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    BLUE='\033[0;34m'
    MAGENTA='\033[0;35m'
    CYAN='\033[0;36m'
    BOLD='\033[1m'
    NC='\033[0m'
else
    RED=''
    GREEN=''
    YELLOW=''
    BLUE=''
    MAGENTA=''
    CYAN=''
    BOLD=''
    NC=''
fi

# Spinner for long operations
spinner() {
    local pid=$1
    local delay=0.1
    local spinstr='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
    while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    printf "    \b\b\b\b"
}

# ========================================================================
# FUNCTIONS
# ========================================================================

show_banner() {
    echo ""
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║                                                              ║${NC}"
    echo -e "${CYAN}║${NC}  ${BOLD}🚀 WARPIO${NC} - Scientific Computing for Claude Code          ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}     Powered by IOWarp.ai | Version $VERSION                    ${CYAN}║${NC}"
    echo -e "${CYAN}║                                                              ║${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

show_usage() {
    cat << EOF
Usage: curl -sSL $REPO_RAW/install.sh | bash [OPTIONS]

Options:
    --dir PATH      Installation directory (default: warpio-enhanced)
    --branch NAME   Git branch to install from (default: main)
    --yes, -y       Automatic yes to prompts
    --dry-run       Show what would be done without doing it
    --verbose, -v   Verbose output
    --uninstall     Uninstall Warpio
    --update        Check for updates
    --help, -h      Show this help message

Examples:
    # Basic installation
    curl -sSL $REPO_RAW/install.sh | bash

    # Install to specific directory
    curl -sSL $REPO_RAW/install.sh | bash -s -- --dir myproject

    # Uninstall
    curl -sSL $REPO_RAW/install.sh | bash -s -- --uninstall

EOF
}

log_info() {
    echo -e "${BLUE}→${NC} $1"
}

log_success() {
    echo -e "${GREEN}✓${NC} $1"
}

log_error() {
    echo -e "${RED}✗${NC} $1" >&2
}

log_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

detect_os() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        echo "linux"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos"
    elif [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "cygwin" ]]; then
        echo "windows"
    else
        echo "unknown"
    fi
}

check_command() {
    command -v "$1" &> /dev/null
}

install_dependency() {
    local cmd=$1
    local package=$2
    local install_cmd=$3
    
    if ! check_command "$cmd"; then
        log_warning "$cmd not found"
        
        if [ "$AUTO_YES" = true ]; then
            response="y"
        else
            echo -n "Install $package? (y/N): "
            read -r response
        fi
        
        if [[ "$response" =~ ^[Yy]$ ]]; then
            log_info "Installing $package..."
            eval "$install_cmd"
            
            if check_command "$cmd"; then
                log_success "$package installed"
            else
                log_error "Failed to install $package"
                return 1
            fi
        else
            log_warning "Skipping $package installation"
            return 1
        fi
    fi
    return 0
}

check_dependencies() {
    local os=$(detect_os)
    local missing_critical=false
    
    log_info "Checking dependencies..."
    
    # Git (critical)
    if ! check_command git; then
        case "$os" in
            linux)
                if check_command apt-get; then
                    install_dependency git git "sudo apt-get update && sudo apt-get install -y git"
                elif check_command yum; then
                    install_dependency git git "sudo yum install -y git"
                fi
                ;;
            macos)
                install_dependency git git "xcode-select --install"
                ;;
        esac
        
        if ! check_command git; then
            log_error "Git is required but not installed"
            missing_critical=true
        fi
    else
        log_success "Git detected"
    fi
    
    # UV (recommended)
    if ! check_command uv; then
        log_info "Installing UV package manager..."
        curl -LsSf https://astral.sh/uv/install.sh | sh &>/dev/null
        export PATH="$HOME/.cargo/bin:$PATH"
        
        if check_command uv; then
            log_success "UV installed"
        else
            log_warning "UV installation failed (optional)"
        fi
    else
        log_success "UV detected"
    fi
    
    # Claude CLI (recommended)
    if ! check_command claude; then
        if check_command npm; then
            install_dependency claude "@anthropic-ai/claude-cli" "npm install -g @anthropic-ai/claude-cli"
        else
            log_warning "Claude CLI not installed (npm required)"
        fi
    else
        log_success "Claude CLI detected"
    fi
    
    # Python (optional)
    if ! check_command python3; then
        log_warning "Python 3 not detected (optional)"
    else
        log_success "Python 3 detected"
    fi
    
    if [ "$missing_critical" = true ]; then
        log_error "Critical dependencies missing. Please install manually."
        exit 1
    fi
}

detect_local_ai() {
    log_info "Detecting local AI services..."
    
    local ai_found=false
    
    # Check LM Studio
    if timeout 1 curl -s http://localhost:1234/v1/models &>/dev/null; then
        log_success "LM Studio detected on port 1234"
        ai_found=true
    fi
    
    # Check Ollama
    if check_command ollama && ollama list &>/dev/null; then
        log_success "Ollama detected"
        ai_found=true
    fi
    
    if [ "$ai_found" = false ]; then
        log_info "No local AI detected (optional - can configure later)"
    fi
}

clone_repository() {
    log_info "Downloading Warpio..."
    
    local temp_dir="/tmp/warpio-install-$$"
    
    # Clone repository
    if [ "$VERBOSE" = true ]; then
        git clone -b "$BRANCH" "$REPO_URL" "$temp_dir"
    else
        git clone -q -b "$BRANCH" "$REPO_URL" "$temp_dir" &
        spinner $!
    fi
    
    if [ -d "$temp_dir" ]; then
        log_success "Warpio downloaded"
        echo "$temp_dir"
    else
        log_error "Failed to download Warpio"
        exit 1
    fi
}

run_installer() {
    local repo_dir=$1
    local target_dir=$2
    
    log_info "Installing Warpio to $target_dir..."
    
    # Run the main installer
    if [ -x "$repo_dir/.warpio/scripts/install-warpio.sh" ]; then
        cd "$repo_dir"
        
        # The installer handles everything internally
        if [ "$VERBOSE" = true ]; then
            ./.warpio/scripts/install-warpio.sh "$target_dir"
        else
            ./.warpio/scripts/install-warpio.sh "$target_dir" &>/dev/null &
            spinner $!
        
        if [ -d "$target_dir/.claude" ]; then
            log_success "Warpio installed successfully"
        else
            log_error "Installation failed"
            exit 1
        fi
    else
        log_error "Installer not found in repository"
        exit 1
    fi
}

run_validation() {
    local target_dir=$1
    
    log_info "Validating installation..."
    
    if [ -x "$target_dir/.claude/scripts/test-warpio.sh" ]; then
        cd "$target_dir"
        
        if [ "$VERBOSE" = true ]; then
            ./.claude/scripts/test-warpio.sh
        else
            ./.claude/scripts/test-warpio.sh &>/dev/null
            local exit_code=$?
            
            if [ $exit_code -eq 0 ]; then
                log_success "All tests passed"
            else
                log_warning "Some tests failed (non-critical)"
            fi
        fi
    else
        log_warning "Test script not found"
    fi
}

show_next_steps() {
    local target_dir=$1
    
    echo ""
    echo -e "${GREEN}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║         🎉 Warpio Installation Complete! 🎉                 ║${NC}"
    echo -e "${GREEN}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${BOLD}Installation location:${NC} $(cd "$target_dir" && pwd)"
    echo ""
    echo -e "${BOLD}Next steps:${NC}"
    echo ""
    echo "  1. Navigate to your project:"
    echo -e "     ${CYAN}cd $target_dir${NC}"
    echo ""
    echo "  2. Configure local AI (optional):"
    echo -e "     ${CYAN}./.claude/scripts/configure-local-ai.sh${NC}"
    echo ""
    echo "  3. Install scientific MCPs (recommended):"
    echo -e "     ${CYAN}./.claude/scripts/manage-mcps.sh install-essential${NC}"
    echo ""
    echo "  4. Start Claude Code:"
    echo -e "     ${CYAN}claude${NC}"
    echo ""
    echo "  5. Test Warpio:"
    echo -e "     Ask Claude: ${YELLOW}\"Who are you?\"${NC}"
    echo ""
    echo -e "${BLUE}Documentation:${NC} https://github.com/akougkas/claude-code-4-science"
    echo -e "${BLUE}Quick Start:${NC} cat WARPIO-QUICKSTART.md"
    echo ""
}

uninstall_warpio() {
    log_info "Uninstalling Warpio..."
    
    # Try to find existing installation
    local locations=("." "warpio-enhanced" "$HOME/warpio-enhanced")
    local found=false
    
    for loc in "${locations[@]}"; do
        if [ -f "$loc/.claude/scripts/uninstall-warpio.sh" ]; then
            log_info "Found Warpio at $loc"
            cd "$loc"
            ./.claude/scripts/uninstall-warpio.sh --complete
            found=true
            break
        elif [ -d "$loc/.claude" ] && grep -q "WARPIO" "$loc/CLAUDE.md" 2>/dev/null; then
            log_info "Found Warpio at $loc"
            # Manual uninstall
            rm -rf "$loc/.claude"
            rm -f "$loc/CLAUDE.md"
            rm -f "$loc/.env"
            rm -f "$loc/WARPIO-"*.md
            log_success "Warpio uninstalled"
            found=true
            break
        fi
    done
    
    if [ "$found" = false ]; then
        log_error "No Warpio installation found"
        exit 1
    fi
}

check_for_updates() {
    log_info "Checking for updates..."
    
    # Get latest version from repository
    local latest=$(curl -s "$REPO_RAW/install.sh" | grep "^VERSION=" | cut -d'"' -f2)
    
    if [ "$latest" = "$VERSION" ]; then
        log_success "You have the latest version ($VERSION)"
    else
        log_warning "Update available: $VERSION → $latest"
        echo "Run installer again to update"
    fi
}

# ========================================================================
# MAIN EXECUTION
# ========================================================================

main() {
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --dir)
                INSTALL_DIR="$2"
                shift 2
                ;;
            --branch)
                BRANCH="$2"
                shift 2
                ;;
            --yes|-y)
                AUTO_YES=true
                shift
                ;;
            --dry-run)
                DRY_RUN=true
                shift
                ;;
            --verbose|-v)
                VERBOSE=true
                shift
                ;;
            --uninstall)
                UNINSTALL=true
                shift
                ;;
            --update)
                UPDATE_CHECK=true
                shift
                ;;
            --help|-h)
                show_usage
                exit 0
                ;;
            *)
                shift
                ;;
        esac
    done
    
    # Show banner
    show_banner
    
    # Handle special modes
    if [ "$UNINSTALL" = true ]; then
        uninstall_warpio
        exit 0
    fi
    
    if [ "$UPDATE_CHECK" = true ]; then
        check_for_updates
        exit 0
    fi
    
    # Set default install directory
    if [ -z "$INSTALL_DIR" ]; then
        INSTALL_DIR="warpio-enhanced"
    fi
    
    # Check if already installed
    if [ -d "$INSTALL_DIR/.claude" ]; then
        log_warning "Warpio already installed at $INSTALL_DIR"
        echo -n "Reinstall/upgrade? (y/N): "
        read -r response
        if [[ ! "$response" =~ ^[Yy]$ ]]; then
            log_info "Installation cancelled"
            exit 0
        fi
    fi
    
    # Main installation flow
    log_info "Starting Warpio installation..."
    echo ""
    
    # Step 1: Check dependencies
    check_dependencies
    echo ""
    
    # Step 2: Detect local AI
    detect_local_ai
    echo ""
    
    # Step 3: Clone repository
    REPO_DIR=$(clone_repository)
    echo ""
    
    # Step 4: Run installer
    run_installer "$REPO_DIR" "$INSTALL_DIR"
    echo ""
    
    # Step 5: Validate
    run_validation "$INSTALL_DIR"
    echo ""
    
    # Step 6: Cleanup
    rm -rf "$REPO_DIR"
    
    # Step 7: Show next steps
    show_next_steps "$INSTALL_DIR"
}

# Run main function
main "$@"