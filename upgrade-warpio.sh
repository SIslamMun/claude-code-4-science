#!/bin/bash
# ========================================================================
# WARPIO UPGRADE SCRIPT
# Safe upgrade of existing Warpio installations
# ========================================================================

set -e

# Script location
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WARPIO_SOURCE="$SCRIPT_DIR/.warpio"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# Configuration
TARGET_DIR=""
BACKUP_FIRST=true
PRESERVE_CUSTOMIZATIONS=true
CHECK_ONLY=false
FORCE_UPGRADE=false

# Version detection
CURRENT_VERSION=""
NEW_VERSION="2.0.0"

# ========================================================================
# FUNCTIONS
# ========================================================================

show_usage() {
    cat << EOF
Usage: $0 [OPTIONS] TARGET_DIRECTORY

Upgrade existing Warpio installation to the latest version.

Options:
  --check           Check for updates without upgrading
  --force           Force upgrade even if versions match
  --no-backup       Skip backup (not recommended)
  --help, -h        Show this help message

Examples:
  $0 myproject              # Upgrade project
  $0 --check myproject      # Check if upgrade available
  $0 --force myproject      # Force reinstall

EOF
}

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}✓${NC} $1"; }
log_error() { echo -e "${RED}✗${NC} $1"; }
log_warning() { echo -e "${YELLOW}⚠${NC} $1"; }

print_banner() {
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║              WARPIO UPGRADE UTILITY v2.0                    ║${NC}"
    echo -e "${CYAN}║                 Safe Version Upgrade                        ║${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

detect_current_version() {
    log_info "Detecting current Warpio version..."
    
    # Try to get version from .env
    if [ -f "$TARGET_DIR/.env" ]; then
        CURRENT_VERSION=$(grep "^WARPIO_VERSION=" "$TARGET_DIR/.env" | cut -d= -f2)
    fi
    
    # Fallback to checking WARPIO.md signature
    if [ -z "$CURRENT_VERSION" ]; then
        if [ -f "$TARGET_DIR/CLAUDE.md" ] && grep -q "WARPIO" "$TARGET_DIR/CLAUDE.md"; then
            CURRENT_VERSION="1.0.0"  # Assume old version if no version found
        fi
    fi
    
    if [ -n "$CURRENT_VERSION" ]; then
        log_success "Current version: $CURRENT_VERSION"
    else
        log_error "Could not detect Warpio version"
        return 1
    fi
}

check_for_updates() {
    log_info "Checking for updates..."
    
    # Compare versions
    if [ "$CURRENT_VERSION" = "$NEW_VERSION" ]; then
        log_success "Already running latest version ($NEW_VERSION)"
        return 1
    elif [ "$CURRENT_VERSION" \< "$NEW_VERSION" ]; then
        log_success "Update available: $CURRENT_VERSION → $NEW_VERSION"
        return 0
    else
        log_warning "Current version ($CURRENT_VERSION) is newer than available ($NEW_VERSION)"
        return 1
    fi
}

backup_current_installation() {
    if [ "$BACKUP_FIRST" = false ]; then
        log_warning "Skipping backup"
        return
    fi
    
    local backup_dir="$TARGET_DIR/.warpio-upgrade-backup.$(date +%Y%m%d%H%M%S)"
    
    log_info "Creating backup at: $backup_dir"
    
    mkdir -p "$backup_dir"
    
    # Backup critical directories and files
    [ -d "$TARGET_DIR/.claude" ] && cp -r "$TARGET_DIR/.claude" "$backup_dir/"
    [ -f "$TARGET_DIR/CLAUDE.md" ] && cp "$TARGET_DIR/CLAUDE.md" "$backup_dir/"
    [ -f "$TARGET_DIR/.env" ] && cp "$TARGET_DIR/.env" "$backup_dir/"
    
    log_success "Backup created: $backup_dir"
    echo "$backup_dir" > "$TARGET_DIR/.last-warpio-backup"
}

preserve_customizations() {
    log_info "Preserving user customizations..."
    
    # Save custom configurations
    local temp_dir="/tmp/warpio-upgrade-$$"
    mkdir -p "$temp_dir"
    
    # Save .env customizations
    if [ -f "$TARGET_DIR/.env" ]; then
        cp "$TARGET_DIR/.env" "$temp_dir/user.env"
    fi
    
    # Save custom MCPs
    if [ -d "$TARGET_DIR/.claude/mcp-configs" ]; then
        cp -r "$TARGET_DIR/.claude/mcp-configs" "$temp_dir/"
    fi
    
    # Save custom hooks
    if [ -d "$TARGET_DIR/.claude/hooks" ]; then
        # Find user-added hooks (not standard Warpio ones)
        for hook in "$TARGET_DIR/.claude/hooks"/*/*; do
            if [ -f "$hook" ] && ! grep -q "WARPIO STANDARD HOOK" "$hook"; then
                local rel_path="${hook#$TARGET_DIR/.claude/}"
                mkdir -p "$temp_dir/$(dirname "$rel_path")"
                cp "$hook" "$temp_dir/$rel_path"
            fi
        done
    fi
    
    echo "$temp_dir"
}

upgrade_core_files() {
    log_info "Upgrading core Warpio files..."
    
    # Update scripts
    rsync -a --exclude='WARPIO.md' "$WARPIO_SOURCE/" "$TARGET_DIR/.claude/"
    
    # Update version in .env
    if [ -f "$TARGET_DIR/.env" ]; then
        sed -i "s/^WARPIO_VERSION=.*/WARPIO_VERSION=$NEW_VERSION/" "$TARGET_DIR/.env"
    fi
    
    log_success "Core files upgraded"
}

update_claude_md() {
    log_info "Updating CLAUDE.md..."
    
    local claude_md="$TARGET_DIR/CLAUDE.md"
    local new_warpio="$WARPIO_SOURCE/WARPIO.md"
    
    if [ -f "$claude_md" ]; then
        # Extract user's original content
        local user_content="/tmp/user-claude-md-$$"
        if grep -q "USER'S ORIGINAL" "$claude_md"; then
            sed -n '/USER.S ORIGINAL/,$p' "$claude_md" | tail -n +3 > "$user_content"
        else
            # Whole file might be user content
            cp "$claude_md" "$user_content"
        fi
        
        # Create new merged version
        {
            cat "$new_warpio"
            if [ -s "$user_content" ]; then
                echo ""
                echo "### USER'S ORIGINAL CLAUDE.MD FOLLOWS BELOW (IF EXISTS):"
                echo "---"
                echo ""
                cat "$user_content"
            fi
        } > "$claude_md"
        
        rm -f "$user_content"
        log_success "CLAUDE.md updated"
    else
        cp "$new_warpio" "$claude_md"
        log_success "CLAUDE.md created"
    fi
}

restore_customizations() {
    local temp_dir=$1
    
    if [ ! -d "$temp_dir" ]; then
        return
    fi
    
    log_info "Restoring customizations..."
    
    # Merge .env customizations
    if [ -f "$temp_dir/user.env" ]; then
        log_info "Merging environment customizations..."
        # Keep user's custom variables
        grep -v "^WARPIO_VERSION=" "$temp_dir/user.env" | while read -r line; do
            if [[ "$line" =~ ^[A-Z_]+= ]]; then
                local key=$(echo "$line" | cut -d= -f1)
                if ! grep -q "^$key=" "$TARGET_DIR/.env"; then
                    echo "$line" >> "$TARGET_DIR/.env"
                fi
            fi
        done
    fi
    
    # Restore custom hooks
    if [ -d "$temp_dir/hooks" ]; then
        log_info "Restoring custom hooks..."
        cp -r "$temp_dir/hooks"/* "$TARGET_DIR/.claude/hooks/" 2>/dev/null || true
    fi
    
    # Restore custom MCPs
    if [ -d "$temp_dir/mcp-configs" ]; then
        log_info "Restoring custom MCP configurations..."
        for config in "$temp_dir/mcp-configs"/*.json; do
            if [ -f "$config" ]; then
                local basename=$(basename "$config")
                if [ "$basename" != "warpio-mcps.json" ]; then
                    cp "$config" "$TARGET_DIR/.claude/mcp-configs/"
                fi
            fi
        done
    fi
    
    rm -rf "$temp_dir"
    log_success "Customizations restored"
}

run_post_upgrade() {
    log_info "Running post-upgrade tasks..."
    
    # Fix permissions
    find "$TARGET_DIR/.claude" -type f -name "*.sh" -exec chmod +x {} \;
    find "$TARGET_DIR/.claude" -type f -name "*.py" -exec chmod +x {} \;
    
    # Run validation
    if [ -x "$TARGET_DIR/.claude/scripts/test-warpio.sh" ]; then
        log_info "Running validation tests..."
        cd "$TARGET_DIR"
        ./.claude/scripts/test-warpio.sh || log_warning "Some tests failed"
    fi
    
    log_success "Post-upgrade tasks complete"
}

show_changelog() {
    cat << EOF

${BOLD}What's New in v$NEW_VERSION:${NC}

${GREEN}✨ New Features:${NC}
  • Simplified installation process
  • Configurable uninstall options
  • Improved zen-mcp integration
  • Better local AI detection

${YELLOW}🔧 Improvements:${NC}
  • Cleaner script organization
  • Reduced redundancy
  • Better error handling
  • Comprehensive testing

${BLUE}🐛 Fixes:${NC}
  • Fixed zen-mcp environment loading
  • Corrected MCP configurations
  • Improved hook execution

EOF
}

# ========================================================================
# MAIN
# ========================================================================

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --check)
            CHECK_ONLY=true
            shift
            ;;
        --force)
            FORCE_UPGRADE=true
            shift
            ;;
        --no-backup)
            BACKUP_FIRST=false
            shift
            ;;
        --help|-h)
            show_usage
            exit 0
            ;;
        *)
            TARGET_DIR="$1"
            shift
            ;;
    esac
done

# Validate target
if [ -z "$TARGET_DIR" ]; then
    if [ -d ".claude" ]; then
        TARGET_DIR="."
    else
        log_error "Target directory required"
        show_usage
        exit 1
    fi
fi

TARGET_DIR="$(cd "$TARGET_DIR" && pwd)"

# Check for Warpio installation
if [ ! -d "$TARGET_DIR/.claude" ]; then
    log_error "No Warpio installation found at: $TARGET_DIR"
    echo "Run install-warpio.sh first"
    exit 1
fi

print_banner

# Detect current version
detect_current_version

# Check for updates
if [ "$CHECK_ONLY" = true ]; then
    if check_for_updates; then
        show_changelog
        echo ""
        echo "Run without --check to perform upgrade"
    fi
    exit 0
fi

# Check if upgrade needed
if ! check_for_updates && [ "$FORCE_UPGRADE" = false ]; then
    echo "No upgrade needed. Use --force to reinstall."
    exit 0
fi

# Confirm upgrade
if [ "$FORCE_UPGRADE" = false ]; then
    show_changelog
    echo ""
    echo -n "Proceed with upgrade? (y/N): "
    read -r response
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        log_info "Upgrade cancelled"
        exit 0
    fi
fi

# Perform upgrade
log_info "Starting upgrade process..."
echo ""

# 1. Backup
backup_current_installation

# 2. Preserve customizations
CUSTOM_DIR=$(preserve_customizations)

# 3. Upgrade core files
upgrade_core_files

# 4. Update CLAUDE.md
update_claude_md

# 5. Restore customizations
restore_customizations "$CUSTOM_DIR"

# 6. Post-upgrade tasks
run_post_upgrade

# Summary
echo ""
echo -e "${GREEN}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║          ✅ Warpio upgraded to v$NEW_VERSION successfully!        ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo "Changes:"
echo "  • Previous version: $CURRENT_VERSION"
echo "  • New version: $NEW_VERSION"
echo ""
echo "Next steps:"
echo "  1. Review changes: cat WARPIO-QUICKSTART.md"
echo "  2. Test installation: ./.claude/scripts/test-warpio.sh"
echo "  3. Start Claude Code: claude"
echo ""

if [ -f "$TARGET_DIR/.last-warpio-backup" ]; then
    echo -e "${CYAN}Backup location:${NC} $(cat "$TARGET_DIR/.last-warpio-backup")"
fi