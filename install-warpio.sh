#!/bin/bash
# ========================================================================
# WARPIO INSTALLER v2.0 - SIMPLIFIED & CLEAN
# Core installation without redundancies
# ========================================================================

set -e

# Source utilities
INSTALLER_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WARPIO_SOURCE="$INSTALLER_DIR/.warpio"

# Try to source utilities if available
if [ -f "$WARPIO_SOURCE/scripts/utils/warpio-utils.sh" ]; then
    source "$WARPIO_SOURCE/scripts/utils/warpio-utils.sh"
else
    # Fallback to basic colors if utils not available
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    BLUE='\033[0;34m'
    CYAN='\033[0;36m'
    BOLD='\033[1m'
    NC='\033[0m'
    
    log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
    log_success() { echo -e "${GREEN}✓${NC} $1"; }
    log_error() { echo -e "${RED}✗${NC} $1"; }
    log_warning() { echo -e "${YELLOW}⚠${NC} $1"; }
fi

# Configuration
VERSION="2.0.0"
TARGET_DIR=""
RUN_PRE_INSTALL=false
RUN_POST_INSTALL=true

# ========================================================================
# CORE FUNCTIONS
# ========================================================================

show_usage() {
    echo "Usage: $0 [OPTIONS] TARGET_DIRECTORY"
    echo ""
    echo "Simplified Warpio installer that focuses on core installation."
    echo ""
    echo "Options:"
    echo "  --pre-install     Run pre-installation checks first"
    echo "  --skip-post       Skip post-installation configuration"
    echo "  --help, -h        Show this help message"
    echo "  --version, -v     Show version information"
    echo ""
    echo "Examples:"
    echo "  $0 myproject                    # Basic installation"
    echo "  $0 --pre-install myproject       # With environment check"
    echo "  $0 --skip-post /path/to/project  # Install only, no config"
    echo ""
}

validate_source() {
    log_info "Validating source directory..."
    
    if [ ! -d "$WARPIO_SOURCE" ]; then
        log_error ".warpio directory not found!"
        echo "   Please run from the claude-code-4-science repository"
        exit 1
    fi
    
    # Check for essential files
    local required_files=(
        "WARPIO.md"
        ".env.example"
        "mcp-configs/warpio-mcps.json"
    )
    
    for file in "${required_files[@]}"; do
        if [ ! -f "$WARPIO_SOURCE/$file" ]; then
            log_error "Missing required file: $file"
            exit 1
        fi
    done
    
    log_success "Source directory validated"
}

prepare_target() {
    log_info "Preparing target directory: $TARGET_DIR"
    
    # Create target directory
    mkdir -p "$TARGET_DIR"
    
    # Handle existing .claude directory
    if [ -d "$TARGET_DIR/.claude" ]; then
        log_warning "Existing .claude directory found"
        echo -n "Backup and continue? (y/N): "
        read -r response
        if [[ "$response" =~ ^[Yy]$ ]]; then
            local backup="$TARGET_DIR/.claude.backup.$(date +%Y%m%d%H%M%S)"
            mv "$TARGET_DIR/.claude" "$backup"
            log_success "Backed up to: $backup"
        else
            log_error "Installation cancelled"
            exit 1
        fi
    fi
}

copy_core_files() {
    log_info "Copying core Warpio files..."
    
    # Copy .warpio to .claude (excluding WARPIO.md)
    rsync -a --exclude='WARPIO.md' "$WARPIO_SOURCE/" "$TARGET_DIR/.claude/"
    
    # Copy .env.example to .env if not exists
    if [ ! -f "$TARGET_DIR/.env" ]; then
        cp "$WARPIO_SOURCE/.env.example" "$TARGET_DIR/.env"
        log_success "Created .env from template"
    else
        log_info ".env already exists, skipping"
    fi
    
    log_success "Core files installed"
}

setup_claude_md() {
    log_info "Setting up CLAUDE.md..."
    
    local warpio_md="$WARPIO_SOURCE/WARPIO.md"
    local target_md="$TARGET_DIR/CLAUDE.md"
    
    if [ -f "$target_md" ]; then
        log_info "Existing CLAUDE.md found, creating merged version"
        
        # Backup existing
        cp "$target_md" "$target_md.backup.$(date +%Y%m%d%H%M%S)"
        
        # Create merged version
        {
            cat "$warpio_md"
            echo ""
            echo "# === USER'S ORIGINAL INSTRUCTIONS BELOW ==="
            echo ""
            cat "$target_md.backup."*
        } > "$target_md"
    else
        cp "$warpio_md" "$target_md"
    fi
    
    log_success "CLAUDE.md configured"
}

fix_permissions() {
    log_info "Setting file permissions..."
    
    # Make all scripts executable
    find "$TARGET_DIR/.claude" -type f -name "*.sh" -exec chmod +x {} \;
    find "$TARGET_DIR/.claude" -type f -name "*.py" -exec chmod +x {} \;
    
    # Ensure Python scripts have proper shebang
    for script in $(find "$TARGET_DIR/.claude" -name "*.py" 2>/dev/null); do
        if ! head -1 "$script" | grep -q "^#!"; then
            sed -i '1i#!/usr/bin/env python3' "$script"
        fi
    done
    
    log_success "Permissions configured"
}

create_quickstart() {
    log_info "Creating quickstart guide..."
    
    cat > "$TARGET_DIR/WARPIO-QUICKSTART.md" << 'EOF'
# 🚀 Warpio Quick Start

## Installation Complete!

Warpio has been installed to enhance your Claude Code experience.

## Next Steps

1. **Run Post-Installation** (if skipped):
   ```bash
   ./.claude/scripts/post-install.sh
   ```

2. **Test Installation**:
   ```bash
   ./.claude/scripts/test-warpio.sh
   ```

3. **Configure Local AI** (optional):
   ```bash
   ./.claude/scripts/configure-local-ai.sh
   ```

4. **Start Claude Code**:
   ```bash
   claude
   ```

## Quick Test

Ask Claude: "Who are you?" - Should identify with Warpio enhancements.

## Configuration Files

- `.env` - Environment configuration
- `.claude/settings.json` - Claude settings
- `.claude/mcp-configs/` - MCP configurations

## Support

- GitHub: https://github.com/iowarp/claude-code-4-science
- Documentation: https://iowarp.github.io

---
Powered by IOWarp.ai
EOF
    
    log_success "Quickstart guide created"
}

# ========================================================================
# MAIN EXECUTION
# ========================================================================

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --pre-install)
            RUN_PRE_INSTALL=true
            shift
            ;;
        --skip-post)
            RUN_POST_INSTALL=false
            shift
            ;;
        --help|-h)
            show_usage
            exit 0
            ;;
        --version|-v)
            echo "Warpio Installer v$VERSION"
            exit 0
            ;;
        *)
            TARGET_DIR="$1"
            shift
            ;;
    esac
done

# Validate target directory
if [ -z "$TARGET_DIR" ]; then
    log_error "Target directory required"
    show_usage
    exit 1
fi

# Convert to absolute path
if [[ "$TARGET_DIR" != /* ]]; then
    TARGET_DIR="$(pwd)/$TARGET_DIR"
fi
TARGET_DIR="$(realpath -m "$TARGET_DIR")"

# Prevent installation in repo directory
if [ "$TARGET_DIR" = "$INSTALLER_DIR" ]; then
    log_error "Cannot install in repository directory"
    echo "   Please specify a different target directory"
    exit 1
fi

# Print banner
echo -e "${CYAN}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║           WARPIO INSTALLER v$VERSION - SIMPLIFIED            ║${NC}"
echo -e "${CYAN}║                   Powered by IOWarp.ai                      ║${NC}"
echo -e "${CYAN}╚══════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Run pre-installation if requested
if [ "$RUN_PRE_INSTALL" = true ]; then
    if [ -x "$WARPIO_SOURCE/scripts/pre-install.sh" ]; then
        log_info "Running pre-installation checks..."
        "$WARPIO_SOURCE/scripts/pre-install.sh"
        echo ""
    else
        log_warning "Pre-install script not found"
    fi
fi

# Main installation
log_info "Starting Warpio installation..."
echo ""

validate_source
prepare_target
copy_core_files
setup_claude_md
fix_permissions
create_quickstart

echo ""
log_success "Core installation complete!"

# Run post-installation if not skipped
if [ "$RUN_POST_INSTALL" = true ]; then
    echo ""
    if [ -x "$TARGET_DIR/.claude/scripts/post-install.sh" ]; then
        log_info "Running post-installation configuration..."
        cd "$TARGET_DIR"
        ./.claude/scripts/post-install.sh
    else
        log_warning "Post-install script not found, skipping configuration"
    fi
fi

# Final message
echo ""
echo -e "${GREEN}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║              🎉 WARPIO INSTALLATION COMPLETE!                ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${CYAN}Installation location:${NC} $TARGET_DIR"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo -e "  1. cd $TARGET_DIR"
echo -e "  2. Review WARPIO-QUICKSTART.md"
echo -e "  3. Run: ./.claude/scripts/test-warpio.sh"
echo -e "  4. Start: claude"
echo ""
echo -e "${BLUE}Warpio is ready to enhance your Claude Code experience!${NC}"