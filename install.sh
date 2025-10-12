#!/bin/bash
# ========================================================================
# WARPIO UNIFIED INSTALLER
# Complete installation script for Warpio Scientific Computing Enhancement
# 
# Usage: 
#   Local: ./install.sh [target-directory]
#   Remote: curl -LsSf https://raw.githubusercontent.com/akougkas/claude-code-4-science/main/install.sh | bash
# ========================================================================

set -euo pipefail

# Configuration
GITHUB_REPO="akougkas/claude-code-4-science"
BRANCH="${WARPIO_BRANCH:-main}"

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

# Generate default directory name: username_warpio_timestamp
DEFAULT_DIR="${USER}_warpio_$(date +%Y%m%d_%H%M%S)"
TARGET_DIR="${1:-$DEFAULT_DIR}"

print_banner() {
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║                    WARPIO INSTALLER v1.0                    ║${NC}"
    echo -e "${CYAN}║         Scientific Computing Enhancement for Claude Code     ║${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo
}

# ========================================================================
# PRE-INSTALLATION CHECK
# ========================================================================

run_preinstall_if_needed() {
    # Check if critical dependencies are missing
    local need_preinstall=false
    
    if ! command -v git &>/dev/null; then
        need_preinstall=true
    elif ! command -v claude &>/dev/null; then
        need_preinstall=true
    elif ! command -v uvx &>/dev/null; then
        need_preinstall=true
    elif ! command -v npx &>/dev/null; then
        need_preinstall=true
    fi
    
    if [ "$need_preinstall" = true ]; then
        log_warning "Missing critical dependencies. Running pre-installation..."
        echo
        
        # Download and run pre-install script
        local preinstall_url="https://raw.githubusercontent.com/$GITHUB_REPO/$BRANCH/warpio/scripts/pre-install.sh"
        log_info "Downloading pre-installation script..."
        
        if curl -LsSf "$preinstall_url" | bash; then
            log_success "Pre-installation completed"
            echo
            log_info "Please run: source ~/.bashrc (or restart terminal)"
            log_info "Then run this installer again"
            exit 0
        else
            log_error "Pre-installation failed"
            exit 1
        fi
    fi
}

# ========================================================================
# DEPENDENCY CHECKS
# ========================================================================

check_dependencies() {
    log_info "Checking system dependencies..."
    
    local missing_deps=()
    local optional_missing=()
    
    # Required: Git
    if ! command -v git &>/dev/null; then
        missing_deps+=("git")
        log_error "Git not found (required)"
    else
        log_success "Git detected"
    fi
    
    # Required: Claude CLI
    if ! command -v claude &>/dev/null; then
        missing_deps+=("claude")
        log_error "Claude CLI not found (required)"
        echo "   Install with: npm install -g @anthropic-ai/claude-code"
    else
        log_success "Claude CLI detected: $(claude --version 2>/dev/null || echo 'version unknown')"
    fi
    
    # Optional: UV for Python MCPs
    if ! command -v uvx &>/dev/null; then
        optional_missing+=("uv")
        log_warning "UV not found (optional, needed for Python MCPs)"
        echo "   Install with: curl -LsSf https://astral.sh/uv/install.sh | sh"
    else
        log_success "UV detected"

        # Check for iowarp-mcps package if UV is available
        if ! uv pip list 2>/dev/null | grep -q iowarp-mcps; then
            log_warning "iowarp-mcps package not found (needed for scientific MCPs)"
            echo "   Install with: uv pip install iowarp-mcps"
            echo "   Or continue and install later"
        else
            log_success "iowarp-mcps package detected"
        fi
    fi
    
    # Optional: npx for JavaScript MCPs
    if ! command -v npx &>/dev/null; then
        optional_missing+=("npx")
        log_warning "npx not found (optional, needed for JavaScript MCPs)"
    else
        log_success "npx detected"
    fi
    
    # Optional: jq for JSON manipulation
    if ! command -v jq &>/dev/null; then
        optional_missing+=("jq")
        log_warning "jq not found (optional, for MCP configuration merging)"
    else
        log_success "jq detected"
    fi
    
    if [ ${#missing_deps[@]} -gt 0 ]; then
        echo
        log_error "Missing required dependencies: ${missing_deps[*]}"
        echo "Please install the required dependencies and try again."
        exit 1
    fi
    
    if [ ${#optional_missing[@]} -gt 0 ]; then
        echo
        log_info "Optional dependencies missing: ${optional_missing[*]}"
        echo "Some features may be limited without these."
        read -p "Continue anyway? (y/N) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
}

# ========================================================================
# DOWNLOAD OR USE LOCAL
# ========================================================================

get_warpio_source() {
    local temp_dir=""
    
    # Check if we're running from a local clone
    if [ -d "warpio" ] && [ -f "warpio/WARPIO.md" ]; then
        log_info "Using local Warpio source"
        WARPIO_SOURCE="$(pwd)/warpio"
    else
        log_info "Downloading Warpio from GitHub..."
        temp_dir=$(mktemp -d)
        
        # Clone the repository
        if ! git clone --depth 1 --branch "$BRANCH" "https://github.com/$GITHUB_REPO.git" "$temp_dir" 2>/dev/null; then
            log_error "Failed to download Warpio from GitHub"
            rm -rf "$temp_dir"
            exit 1
        fi
        
        WARPIO_SOURCE="$temp_dir/warpio"
        log_success "Warpio downloaded"
    fi
    
    # Verify source structure
    if [ ! -d "$WARPIO_SOURCE" ]; then
        log_error "Invalid Warpio source: warpio directory not found"
        [ -n "$temp_dir" ] && rm -rf "$temp_dir"
        exit 1
    fi
}

# ========================================================================
# MAIN INSTALLATION
# ========================================================================

install_warpio() {
    # Create target directory
    log_info "Creating target directory: $TARGET_DIR"
    mkdir -p "$TARGET_DIR"
    TARGET_DIR="$(cd "$TARGET_DIR" && pwd)"
    
    # Create .claude directory structure
    log_info "Setting up Claude Code directory structure..."
    mkdir -p "$TARGET_DIR/.claude"
    mkdir -p "$TARGET_DIR/.claude/agents"
    mkdir -p "$TARGET_DIR/.claude/commands"
    # Create all hook directories
    for hook_dir in SessionStart PostToolUse PreCompact Stop SubagentStop; do
        mkdir -p "$TARGET_DIR/.claude/hooks/$hook_dir"
    done
    mkdir -p "$TARGET_DIR/.claude/output-styles"
    mkdir -p "$TARGET_DIR/.claude/statusline"
    mkdir -p "$TARGET_DIR/.claude/themes"
    
    # Install expert agents
    if [ -d "$WARPIO_SOURCE/agents" ]; then
        log_info "Installing expert agents..."
        cp -r "$WARPIO_SOURCE/agents/"* "$TARGET_DIR/.claude/agents/" 2>/dev/null || true
        log_success "Expert agents installed"
    fi
    
    # Install commands
    if [ -d "$WARPIO_SOURCE/commands" ]; then
        log_info "Installing Warpio commands..."
        cp -r "$WARPIO_SOURCE/commands/"* "$TARGET_DIR/.claude/commands/" 2>/dev/null || true
        log_success "Commands installed"
    fi
    
    # Install hooks
    if [ -d "$WARPIO_SOURCE/hooks" ]; then
        log_info "Installing hooks..."
        cp -r "$WARPIO_SOURCE/hooks/"* "$TARGET_DIR/.claude/hooks/" 2>/dev/null || true
        # Make all shell and Python scripts executable
        find "$TARGET_DIR/.claude/hooks" -type f \( -name "*.sh" -o -name "*.py" \) -exec chmod +x {} \;
        log_success "Hooks installed"
    fi
    
    # Install output styles
    if [ -d "$WARPIO_SOURCE/output-styles" ]; then
        log_info "Installing output styles..."
        cp -r "$WARPIO_SOURCE/output-styles/"* "$TARGET_DIR/.claude/output-styles/" 2>/dev/null || true
        log_success "Output styles installed"
    fi
    
    # Install statusline
    if [ -d "$WARPIO_SOURCE/statusline" ]; then
        log_info "Installing statusline..."
        cp -r "$WARPIO_SOURCE/statusline/"* "$TARGET_DIR/.claude/statusline/" 2>/dev/null || true
        find "$TARGET_DIR/.claude/statusline" -type f -name "*.sh" -exec chmod +x {} \;
        log_success "Statusline installed"
    fi

    # Install themes
    if [ -d "$WARPIO_SOURCE/themes" ]; then
        log_info "Installing themes..."
        cp -r "$WARPIO_SOURCE/themes/"* "$TARGET_DIR/.claude/themes/" 2>/dev/null || true
        log_success "Themes installed"
    fi
    
    # Install Warpio personality
    if [ -f "$WARPIO_SOURCE/WARPIO.md" ]; then
        log_info "Installing Warpio personality..."
        cp "$WARPIO_SOURCE/WARPIO.md" "$TARGET_DIR/CLAUDE.md"
        log_success "Warpio personality installed"
    fi
    
    # Create .env from template
    if [ ! -f "$TARGET_DIR/.env" ]; then
        if [ -f "$WARPIO_SOURCE/.env.example" ]; then
            log_info "Creating .env from template..."
            cp "$WARPIO_SOURCE/.env.example" "$TARGET_DIR/.env"
            log_success "Environment file created - please edit .env to configure your settings"
        else
            log_warning ".env.example not found in source"
        fi
    else
        log_info ".env already exists, skipping creation"
    fi
}

# ========================================================================
# MCP CONFIGURATION
# ========================================================================

configure_mcps() {
    log_info "Configuring MCP servers..."
    
    local mcp_config="$TARGET_DIR/.mcp.json"
    
    # If we have the full MCP config from warpio-mcps.json, use it
    if [ -f "$WARPIO_SOURCE/mcps/warpio-mcps.json" ]; then
        log_info "Using complete Warpio MCP configuration..."
        cp "$WARPIO_SOURCE/mcps/warpio-mcps.json" "$mcp_config"
        
        # Verify context7 is present
        if command -v jq &>/dev/null; then
            if jq -e '.mcpServers.context7' "$mcp_config" &>/dev/null; then
                log_success "context7 MCP confirmed in configuration"
            else
                log_warning "context7 MCP not found, adding it..."
                local temp_file=$(mktemp)
                jq '.mcpServers.context7 = {
                    "command": "npx",
                    "args": ["-y", "@upstash/context7-mcp"],
                    "env": {},
                    "description": "Documentation retrieval for any library"
                }' "$mcp_config" > "$temp_file" && mv "$temp_file" "$mcp_config"
            fi
        fi
    else
        # Fallback: Create basic MCP configuration
        cat > "$mcp_config" << 'EOF'
{
  "mcpServers": {
    "context7": {
      "command": "npx",
      "args": ["-y", "@upstash/context7-mcp"],
      "env": {},
      "description": "Documentation retrieval for any library"
    },
    "zen": {
      "command": "uvx",
      "args": ["--from", "git+https://github.com/BeehiveInnovations/zen-mcp-server.git", "zen-mcp-server"],
      "env": {
        "CUSTOM_API_URL": "${LMSTUDIO_API_URL:-http://localhost:1234/v1}",
        "CUSTOM_MODEL_NAME": "${LMSTUDIO_MODEL:-qwen-2.5}",
        "CUSTOM_API_KEY": "${LMSTUDIO_API_KEY:-lm-studio}"
      },
      "description": "Local AI integration"
    },
    "filesystem": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem"],
      "env": {
        "FILESYSTEM_ROOT": "${CLAUDE_PROJECT_DIR}"
      },
      "description": "Enhanced filesystem operations"
    }
  }
}
EOF
    fi
    
    log_success "MCP servers configured in .mcp.json"
    
    # Copy project settings
    log_info "Installing project settings..."
    if [ -f "$WARPIO_SOURCE/settings.json" ]; then
        cp "$WARPIO_SOURCE/settings.json" "$TARGET_DIR/.claude/settings.json"
        log_success "Settings configured with auto-approval for MCPs"

        # Verify status line configuration
        if command -v jq &>/dev/null; then
            if jq -e '.statusLine' "$TARGET_DIR/.claude/settings.json" &>/dev/null; then
                log_success "Status line configured"
            else
                log_warning "Status line not configured in settings.json"
            fi
        fi
    else
        log_warning "settings.json not found, creating minimal config"
        cat > "$TARGET_DIR/.claude/settings.json" << 'EOF'
{
  "enableAllProjectMcpServers": true,
  "statusLine": {
    "type": "command",
    "command": "${CLAUDE_PROJECT_DIR}/.claude/statusline/warpio-status.sh"
  },
  "env": {
    "WARPIO_VERSION": "1.0.0",
    "WARPIO_ENABLED": "true"
  }
}
EOF
    fi
}

# ========================================================================
# VALIDATION
# ========================================================================

validate_installation() {
    log_info "Validating installation..."
    
    local errors=0
    
    # Check critical files
    [ -f "$TARGET_DIR/.mcp.json" ] && log_success ".mcp.json present" || { log_error ".mcp.json missing"; ((errors++)); }
    [ -f "$TARGET_DIR/CLAUDE.md" ] && log_success "CLAUDE.md present" || { log_error "CLAUDE.md missing"; ((errors++)); }
    [ -d "$TARGET_DIR/.claude" ] && log_success ".claude directory present" || { log_error ".claude directory missing"; ((errors++)); }
    [ -f "$TARGET_DIR/.env" ] && log_success ".env template present" || { log_error ".env missing"; ((errors++)); }

    # Check component directories
    [ -d "$TARGET_DIR/.claude/agents" ] && log_success "Expert agents directory present" || { log_warning "Agents directory missing"; }
    [ -d "$TARGET_DIR/.claude/commands" ] && log_success "Commands directory present" || { log_warning "Commands directory missing"; }
    [ -d "$TARGET_DIR/.claude/hooks" ] && log_success "Hooks directory present" || { log_warning "Hooks directory missing"; }
    [ -d "$TARGET_DIR/.claude/output-styles" ] && log_success "Output styles directory present" || { log_warning "Output styles directory missing"; }
    [ -d "$TARGET_DIR/.claude/statusline" ] && log_success "Statusline directory present" || { log_warning "Statusline directory missing"; }
    [ -d "$TARGET_DIR/.claude/themes" ] && log_success "Themes directory present" || { log_warning "Themes directory missing"; }
    
    # Check MCP configuration validity
    if [ -f "$TARGET_DIR/.mcp.json" ]; then
        if command -v jq &>/dev/null; then
            if jq -e '.mcpServers' "$TARGET_DIR/.mcp.json" &>/dev/null; then
                local mcp_count=$(jq '.mcpServers | length' "$TARGET_DIR/.mcp.json")
                log_success "$mcp_count MCP servers configured"
                
                # Verify critical MCPs are present
                if jq -e '.mcpServers.context7' "$TARGET_DIR/.mcp.json" &>/dev/null; then
                    log_success "context7 MCP configured"
                else
                    log_warning "context7 MCP not found"
                fi

                if jq -e '.mcpServers.zen_mcp' "$TARGET_DIR/.mcp.json" &>/dev/null; then
                    log_success "zen_mcp configured"
                else
                    log_warning "zen_mcp not found"
                fi

                if jq -e '.mcpServers.filesystem' "$TARGET_DIR/.mcp.json" &>/dev/null; then
                    log_success "filesystem MCP configured"
                else
                    log_warning "filesystem MCP not found"
                fi

    # Check for new critical scientific MCPs
    if jq -e '.mcpServers.hdf5' "$TARGET_DIR/.mcp.json" &>/dev/null; then
        log_success "HDF5 MCP configured"
    else
        log_warning "HDF5 MCP not found (scientific data I/O)"
    fi

    if jq -e '.mcpServers.slurm' "$TARGET_DIR/.mcp.json" &>/dev/null; then
        log_success "SLURM MCP configured"
    else
        log_warning "SLURM MCP not found (HPC job management)"
    fi

    if jq -e '.mcpServers.jarvis' "$TARGET_DIR/.mcp.json" &>/dev/null; then
        log_success "Jarvis MCP configured"
    else
        log_warning "Jarvis MCP not found (pipeline management)"
    fi

    # Check theme installation
    if [ -f "$TARGET_DIR/.claude/themes/warpio-theme.json" ]; then
        log_success "Warpio theme installed"
        if command -v jq &>/dev/null; then
            local theme_name=$(jq -r '.name // "unknown"' "$TARGET_DIR/.claude/themes/warpio-theme.json" 2>/dev/null)
            log_success "Theme: $theme_name"
        fi
    else
        log_warning "Warpio theme not found"
    fi

    # Check status line functionality
    if [ -f "$TARGET_DIR/.claude/statusline/warpio-status.sh" ]; then
        if [ -x "$TARGET_DIR/.claude/statusline/warpio-status.sh" ]; then
            log_success "Main status line script executable"
        else
            log_warning "Main status line script not executable"
        fi
    else
        log_warning "Main status line script not found"
    fi

    # Check hook scripts
    local hook_count=0
    for hook_script in "$TARGET_DIR/.claude/hooks"/*/*; do
        if [ -f "$hook_script" ] && [ -x "$hook_script" ]; then
            ((hook_count++))
        fi
    done
    if [ $hook_count -gt 0 ]; then
        log_success "$hook_count hook scripts installed and executable"
    else
        log_warning "No executable hook scripts found"
    fi
            else
                log_error "Invalid MCP configuration"
                ((errors++))
            fi
        fi
    fi
    
    # Create validation script
    cat > "$TARGET_DIR/validate-warpio.sh" << 'EOF'
#!/bin/bash
echo "Warpio Installation Validation"
echo "=============================="
echo

    # Check files
    echo "File Structure:"
    [ -f ".mcp.json" ] && echo "✓ .mcp.json (MCP config)" || echo "✗ .mcp.json missing"
    [ -f "CLAUDE.md" ] && echo "✓ CLAUDE.md (personality)" || echo "✗ CLAUDE.md missing"
    [ -f ".env" ] && echo "✓ .env configuration" || echo "✗ .env missing"
    [ -d ".claude" ] && echo "✓ .claude directory" || echo "✗ .claude directory missing"
    [ -d ".claude/agents" ] && echo "✓ Expert agents" || echo "✗ Agents missing"
    [ -d ".claude/commands" ] && echo "✓ Commands" || echo "✗ Commands missing"
    [ -d ".claude/hooks" ] && echo "✓ Hooks" || echo "✗ Hooks missing"
    [ -d ".claude/output-styles" ] && echo "✓ Output styles" || echo "✗ Output styles missing"
    [ -d ".claude/statusline" ] && echo "✓ Statusline" || echo "✗ Statusline missing"
    [ -d ".claude/themes" ] && echo "✓ Themes" || echo "✗ Themes missing"
    echo

# Check MCPs if jq available
if command -v jq &>/dev/null && [ -f ".mcp.json" ]; then
    echo "Configured MCPs:"
    jq -r '.mcpServers | to_entries[] | "  - \(.key): \(.value.description // "no description")"' .mcp.json
    echo
    
    # Check for critical MCPs
    echo "Critical MCP Status:"
    jq -e '.mcpServers.context7' .mcp.json &>/dev/null && echo "✓ context7 configured" || echo "✗ context7 missing"
    jq -e '.mcpServers.zen_mcp' .mcp.json &>/dev/null && echo "✓ zen_mcp configured" || echo "✗ zen_mcp missing"
    echo

    # Check theme
    echo "Theme Status:"
    [ -f ".claude/themes/warpio-theme.json" ] && echo "✓ Warpio theme installed" || echo "✗ Warpio theme missing"
    echo
fi

echo "To test with Claude Code:"
echo "  1. Run: claude"
echo "  2. Type: /mcp"
echo "  3. Type: /check-mcps"
echo "  4. Ask: who are you?"
EOF
    chmod +x "$TARGET_DIR/validate-warpio.sh"
    
    if [ $errors -eq 0 ]; then
        log_success "Installation validated successfully"
        return 0
    else
        log_warning "Installation completed with $errors issue(s)"
        return 1
    fi
}

# ========================================================================
# CLEANUP
# ========================================================================

cleanup() {
    if [ -n "${temp_dir:-}" ] && [ -d "$temp_dir" ]; then
        rm -rf "$temp_dir"
    fi
}

# ========================================================================
# MAIN EXECUTION
# ========================================================================

main() {
    # Set up cleanup trap
    trap cleanup EXIT
    
    print_banner
    
    # Run pre-installation if needed
    run_preinstall_if_needed
    
    # Check dependencies
    check_dependencies
    echo
    
    # Get Warpio source
    get_warpio_source
    echo
    
    # Install Warpio
    install_warpio
    echo
    
    # Configure MCPs
    configure_mcps
    echo

    # Install MCP validation script
    if [ -f "$WARPIO_SOURCE/scripts/validate-mcp-setup.sh" ]; then
        log_info "Installing MCP validation script..."
        cp "$WARPIO_SOURCE/scripts/validate-mcp-setup.sh" "$TARGET_DIR/.claude/"
        chmod +x "$TARGET_DIR/.claude/validate-mcp-setup.sh"
        log_success "MCP validation script installed"
    fi

    # Make all scripts executable
    log_info "Setting executable permissions..."
    find "$TARGET_DIR/.claude" -type f \( -name "*.sh" -o -name "*.py" \) -exec chmod +x {} \;
    log_success "All scripts made executable"

    # Validate installation
    if validate_installation; then
        echo
        echo -e "${GREEN}════════════════════════════════════════════════════════════════${NC}"
        echo -e "${GREEN}✓ Warpio installation complete and validated!${NC}"
        echo -e "${GREEN}════════════════════════════════════════════════════════════════${NC}"
        echo
        echo -e "Installation location: ${CYAN}$TARGET_DIR${NC}"
        echo
        echo "Next steps:"
        echo -e "  1. ${CYAN}cd $TARGET_DIR${NC}"
        echo -e "  2. ${CYAN}./validate-warpio.sh${NC}  # Run basic validation"
        echo -e "  3. ${CYAN}.claude/validate-mcp-setup.sh${NC}  # Check scientific MCPs"
        echo -e "  4. ${CYAN}claude${NC}               # Start Claude Code"
        echo -e "  5. Type: ${YELLOW}/mcp${NC}          # Check MCP servers"
        echo -e "  6. Type: ${YELLOW}/check-mcps${NC}   # Detailed MCP status"
        echo -e "  7. Ask: ${YELLOW}who are you?${NC}   # Verify Warpio personality"
        echo
        echo "For local AI integration, configure your .env file:"
        echo -e "  ${CYAN}nano .env${NC}"
        echo
        echo "Theme integration:"
        echo -e "  The Warpio theme is installed in ${CYAN}.claude/themes/${NC}"
        echo -e "  Status line uses the theme colors automatically"
        echo
    else
        echo
        log_warning "Installation completed with issues. Please check the errors above."
        echo "You can run ${CYAN}$TARGET_DIR/validate-warpio.sh${NC} to check the installation."
    fi
    
    cleanup
}

# Run main function
main "$@"