#!/bin/bash
# ========================================================================
# WARPIO PRE-INSTALLATION SCRIPT
# Prepares the environment and installs required dependencies
# ========================================================================

set -e

# Source utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils/warpio-utils.sh"

# Configuration
TOTAL_STEPS=5
INSTALL_UV=false
INSTALL_TOOLS=false

# ========================================================================
# MAIN FUNCTIONS
# ========================================================================

check_os() {
    log_step 1 $TOTAL_STEPS "Checking operating system..."
    
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        OS="linux"
        log_success "Linux detected"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        OS="macos"
        log_success "macOS detected"
    elif [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "cygwin" ]]; then
        OS="windows"
        log_success "Windows detected (WSL recommended)"
    else
        log_error "Unsupported operating system: $OSTYPE"
        exit 1
    fi
}

install_uv() {
    log_info "Installing UV package manager..."
    
    if [[ "$OS" == "windows" ]]; then
        log_warning "Please install UV manually on Windows"
        echo "   Visit: https://github.com/astral-sh/uv#installation"
    else
        curl -LsSf https://astral.sh/uv/install.sh | sh
        export PATH="$HOME/.cargo/bin:$PATH"
        
        if check_uv; then
            log_success "UV installed successfully"
        else
            log_error "UV installation failed"
            exit 1
        fi
    fi
}

check_dependencies() {
    log_step 2 $TOTAL_STEPS "Checking required dependencies..."
    
    local missing_critical=()
    local missing_optional=()
    
    # Check UV
    if ! check_uv; then
        missing_critical+=("uv")
        INSTALL_UV=true
    fi
    
    # Check Claude CLI
    if ! check_claude_cli; then
        missing_critical+=("claude-cli")
    fi
    
    # Check Node.js (for Claude CLI)
    if ! check_command node "Node.js"; then
        missing_critical+=("nodejs")
    fi
    
    # Check optional tools
    if ! check_jq; then
        missing_optional+=("jq")
    fi
    
    if ! check_command python3 "Python 3"; then
        missing_optional+=("python3")
    fi
    
    if ! check_command git "Git"; then
        missing_critical+=("git")
    fi
    
    # Report findings
    if [ ${#missing_critical[@]} -gt 0 ]; then
        log_warning "Missing critical dependencies: ${missing_critical[*]}"
        echo ""
        echo "Would you like to install missing dependencies automatically? (y/N)"
        read -r response
        if [[ "$response" =~ ^[Yy]$ ]]; then
            INSTALL_TOOLS=true
        else
            log_error "Cannot proceed without critical dependencies"
            exit 1
        fi
    fi
    
    if [ ${#missing_optional[@]} -gt 0 ]; then
        log_info "Optional tools missing: ${missing_optional[*]}"
    fi
}

install_dependencies() {
    log_step 3 $TOTAL_STEPS "Installing dependencies..."
    
    if [ "$INSTALL_UV" = true ]; then
        install_uv
    fi
    
    if [ "$INSTALL_TOOLS" = true ]; then
        log_info "Installing additional tools..."
        
        case "$OS" in
            "linux")
                # Check package manager
                if command -v apt-get &> /dev/null; then
                    log_info "Using apt-get..."
                    sudo apt-get update
                    sudo apt-get install -y nodejs npm git python3 python3-pip jq curl
                elif command -v yum &> /dev/null; then
                    log_info "Using yum..."
                    sudo yum install -y nodejs npm git python3 python3-pip jq curl
                else
                    log_warning "Unknown package manager. Please install manually."
                fi
                ;;
            "macos")
                if command -v brew &> /dev/null; then
                    log_info "Using Homebrew..."
                    brew install node git python3 jq
                else
                    log_error "Homebrew not found. Please install from https://brew.sh"
                    exit 1
                fi
                ;;
        esac
        
        # Install Claude CLI globally
        if command -v npm &> /dev/null; then
            log_info "Installing Claude CLI..."
            npm install -g @anthropic-ai/claude-cli
        fi
    fi
}

detect_ai_services() {
    log_step 4 $TOTAL_STEPS "Detecting AI services..."
    
    detect_local_ai
    
    # Check for cloud API keys in environment
    if [ -n "$ANTHROPIC_API_KEY" ]; then
        log_success "Anthropic API key found in environment"
    fi
    
    if [ -n "$OPENAI_API_KEY" ]; then
        log_success "OpenAI API key found in environment"
    fi
}

create_directories() {
    log_step 5 $TOTAL_STEPS "Creating temporary directories..."
    
    # Create cache directories
    mkdir -p /tmp/warpio-cache
    mkdir -p /tmp/warpio-scratch
    mkdir -p /tmp/warpio-workflows
    
    log_success "Temporary directories created"
}

print_summary() {
    print_section_header "Pre-Installation Summary"
    
    echo -e "${GREEN}✓ Environment prepared successfully${NC}"
    echo ""
    echo "System Information:"
    echo "  OS: $OS"
    echo "  UV: $(which uv 2>/dev/null || echo 'Not installed')"
    echo "  Claude CLI: $(which claude 2>/dev/null || echo 'Not installed')"
    echo "  Python: $(which python3 2>/dev/null || echo 'Not installed')"
    echo ""
    
    if detect_lmstudio "http://localhost:1234" 2>/dev/null; then
        echo "Local AI:"
        echo "  LM Studio: Available"
    elif detect_ollama 2>/dev/null; then
        echo "Local AI:"
        echo "  Ollama: Available"
    else
        echo "Local AI: Not detected (optional)"
    fi
    
    echo ""
    echo -e "${CYAN}Ready for Warpio installation!${NC}"
    echo -e "Next step: Run ${YELLOW}./install-warpio.sh [target-directory]${NC}"
}

# ========================================================================
# MAIN EXECUTION
# ========================================================================

main() {
    print_warpio_banner
    echo -e "${BOLD}Pre-Installation Environment Check${NC}"
    echo ""
    
    check_os
    check_dependencies
    
    if [ "$INSTALL_TOOLS" = true ] || [ "$INSTALL_UV" = true ]; then
        install_dependencies
    fi
    
    detect_ai_services
    create_directories
    print_summary
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --auto|-y)
            INSTALL_TOOLS=true
            INSTALL_UV=true
            shift
            ;;
        --help|-h)
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --auto, -y    Automatically install missing dependencies"
            echo "  --help, -h    Show this help message"
            exit 0
            ;;
        *)
            shift
            ;;
    esac
done

main