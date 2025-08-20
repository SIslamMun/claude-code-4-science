#!/bin/bash
# ========================================================================
# WARPIO UNINSTALLER - CONFIGURABLE REMOVAL
# Safe and selective removal of Warpio components
# ========================================================================

set -e

# Get script location
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# Configuration
UNINSTALL_MODE="interactive"
TARGET_DIR=""
BACKUP_DIR=""
DRY_RUN=false
PRESERVE_CONFIGS=false
PRESERVE_DATA=true
REMOVE_TEMP=true
COMPONENTS_TO_REMOVE=()

# ========================================================================
# FUNCTIONS
# ========================================================================

show_usage() {
    cat << EOF
Usage: $0 [OPTIONS] [TARGET_DIRECTORY]

Safely uninstall Warpio from your project.

Options:
  --complete        Complete removal of all Warpio components
  --disable         Disable Warpio without removing files
  --partial         Remove Warpio but keep configurations
  --component NAME  Remove specific component (can be repeated)
  --dry-run         Show what would be removed without doing it
  --no-backup       Skip backup creation (not recommended)
  --help, -h        Show this help message

Uninstall Modes:
  complete   - Remove all Warpio files and configurations
  disable    - Keep files but disable hooks and MCPs
  partial    - Remove core files but preserve .env and user data
  component  - Remove specific components only

Components:
  experts    - Remove expert agents
  mcps       - Remove MCP configurations
  hooks      - Remove hook scripts
  configs    - Remove configuration files
  temp       - Remove temporary files only

Examples:
  $0 myproject                    # Interactive uninstall
  $0 --complete myproject          # Complete removal
  $0 --disable myproject           # Disable without removing
  $0 --component mcps myproject    # Remove MCPs only
  $0 --dry-run myproject          # Preview changes

EOF
}

print_banner() {
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║              WARPIO UNINSTALLER v1.0                        ║${NC}"
    echo -e "${CYAN}║                 Safe Removal Utility                        ║${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}✓${NC} $1"; }
log_error() { echo -e "${RED}✗${NC} $1"; }
log_warning() { echo -e "${YELLOW}⚠${NC} $1"; }
log_action() { 
    if [ "$DRY_RUN" = true ]; then
        echo -e "${YELLOW}[DRY-RUN]${NC} Would: $1"
    else
        echo -e "${BLUE}[ACTION]${NC} $1"
    fi
}

detect_warpio() {
    log_info "Detecting Warpio installation..."
    
    if [ ! -d "$TARGET_DIR/.claude" ]; then
        log_error "No Warpio installation found at: $TARGET_DIR"
        return 1
    fi
    
    # Check for Warpio signature
    if [ -f "$TARGET_DIR/CLAUDE.md" ] && grep -q "WARPIO" "$TARGET_DIR/CLAUDE.md"; then
        log_success "Warpio installation detected"
        return 0
    else
        log_warning ".claude directory exists but may not be Warpio"
        echo -n "Continue anyway? (y/N): "
        read -r response
        [[ "$response" =~ ^[Yy]$ ]] && return 0 || return 1
    fi
}

create_backup() {
    if [ "$BACKUP_DIR" = "skip" ]; then
        log_warning "Skipping backup (not recommended)"
        return
    fi
    
    BACKUP_DIR="$TARGET_DIR/.warpio-uninstall-backup.$(date +%Y%m%d%H%M%S)"
    
    log_info "Creating backup at: $BACKUP_DIR"
    
    if [ "$DRY_RUN" = false ]; then
        mkdir -p "$BACKUP_DIR"
        
        # Backup .claude directory
        if [ -d "$TARGET_DIR/.claude" ]; then
            cp -r "$TARGET_DIR/.claude" "$BACKUP_DIR/"
        fi
        
        # Backup CLAUDE.md
        if [ -f "$TARGET_DIR/CLAUDE.md" ]; then
            cp "$TARGET_DIR/CLAUDE.md" "$BACKUP_DIR/"
        fi
        
        # Backup .env
        if [ -f "$TARGET_DIR/.env" ]; then
            cp "$TARGET_DIR/.env" "$BACKUP_DIR/"
        fi
        
        log_success "Backup created"
    else
        log_action "Create backup at $BACKUP_DIR"
    fi
}

extract_original_claude_md() {
    local claude_md="$TARGET_DIR/CLAUDE.md"
    local original_md="$TARGET_DIR/CLAUDE.md.original"
    
    if [ -f "$claude_md" ]; then
        # Check if there's a section marker for original content
        if grep -q "USER'S ORIGINAL" "$claude_md"; then
            log_info "Extracting original CLAUDE.md content..."
            
            if [ "$DRY_RUN" = false ]; then
                # Extract content after the marker
                sed -n '/USER.S ORIGINAL/,$p' "$claude_md" | tail -n +3 > "$original_md"
                
                if [ -s "$original_md" ]; then
                    mv "$original_md" "$claude_md"
                    log_success "Restored original CLAUDE.md"
                else
                    rm -f "$original_md"
                    rm -f "$claude_md"
                    log_info "No original content found, removed CLAUDE.md"
                fi
            else
                log_action "Extract and restore original CLAUDE.md"
            fi
        else
            # No Warpio content, might be original or corrupted
            log_warning "CLAUDE.md doesn't appear to have Warpio content"
        fi
    fi
}

remove_complete() {
    log_info "Performing complete removal..."
    
    # Remove .claude directory
    if [ -d "$TARGET_DIR/.claude" ]; then
        log_action "Remove .claude directory"
        [ "$DRY_RUN" = false ] && rm -rf "$TARGET_DIR/.claude"
    fi
    
    # Handle CLAUDE.md
    extract_original_claude_md
    
    # Remove .env if it's Warpio's
    if [ -f "$TARGET_DIR/.env" ] && grep -q "WARPIO" "$TARGET_DIR/.env"; then
        log_action "Remove .env file"
        [ "$DRY_RUN" = false ] && rm -f "$TARGET_DIR/.env"
    fi
    
    # Remove Warpio documentation
    for doc in WARPIO-QUICKSTART.md WARPIO-VALIDATION.md WARPIO-TEST-REPORT.md; do
        if [ -f "$TARGET_DIR/$doc" ]; then
            log_action "Remove $doc"
            [ "$DRY_RUN" = false ] && rm -f "$TARGET_DIR/$doc"
        fi
    done
    
    # Remove temp files
    remove_temp_files
}

remove_partial() {
    log_info "Performing partial removal (preserving configs)..."
    
    PRESERVE_CONFIGS=true
    
    # Remove .claude but keep configs
    if [ -d "$TARGET_DIR/.claude" ]; then
        # Save configs first
        if [ "$DRY_RUN" = false ]; then
            [ -f "$TARGET_DIR/.env" ] && cp "$TARGET_DIR/.env" "$TARGET_DIR/.env.preserved"
            [ -d "$TARGET_DIR/.claude/mcp-configs" ] && cp -r "$TARGET_DIR/.claude/mcp-configs" "$TARGET_DIR/.mcp-configs.preserved"
        fi
        
        log_action "Remove .claude directory (configs preserved)"
        [ "$DRY_RUN" = false ] && rm -rf "$TARGET_DIR/.claude"
        
        # Restore configs
        if [ "$DRY_RUN" = false ]; then
            [ -f "$TARGET_DIR/.env.preserved" ] && mv "$TARGET_DIR/.env.preserved" "$TARGET_DIR/.env"
            [ -d "$TARGET_DIR/.mcp-configs.preserved" ] && {
                mkdir -p "$TARGET_DIR/.claude"
                mv "$TARGET_DIR/.mcp-configs.preserved" "$TARGET_DIR/.claude/mcp-configs"
            }
        fi
    fi
    
    # Handle CLAUDE.md
    extract_original_claude_md
    
    # Keep documentation for reference
    log_info "Keeping documentation files for reference"
}

disable_warpio() {
    log_info "Disabling Warpio (files preserved)..."
    
    # Rename .claude to .claude.disabled
    if [ -d "$TARGET_DIR/.claude" ]; then
        log_action "Disable .claude directory"
        [ "$DRY_RUN" = false ] && mv "$TARGET_DIR/.claude" "$TARGET_DIR/.claude.disabled"
    fi
    
    # Comment out Warpio content in CLAUDE.md
    if [ -f "$TARGET_DIR/CLAUDE.md" ] && grep -q "WARPIO" "$TARGET_DIR/CLAUDE.md"; then
        log_action "Disable Warpio in CLAUDE.md"
        if [ "$DRY_RUN" = false ]; then
            # Create disabled version
            sed 's/^/# DISABLED: /' "$TARGET_DIR/CLAUDE.md" > "$TARGET_DIR/CLAUDE.md.disabled"
            extract_original_claude_md
        fi
    fi
    
    # Disable in .env
    if [ -f "$TARGET_DIR/.env" ]; then
        log_action "Disable Warpio environment variables"
        if [ "$DRY_RUN" = false ]; then
            sed -i 's/^WARPIO_/#DISABLED_WARPIO_/' "$TARGET_DIR/.env"
        fi
    fi
    
    log_success "Warpio disabled (run 'enable-warpio.sh' to re-enable)"
}

remove_component() {
    local component=$1
    
    case "$component" in
        experts)
            log_info "Removing expert agents..."
            log_action "Remove .claude/agents directory"
            [ "$DRY_RUN" = false ] && rm -rf "$TARGET_DIR/.claude/agents"
            ;;
            
        mcps)
            log_info "Removing MCP configurations..."
            log_action "Remove .claude/mcp-configs directory"
            [ "$DRY_RUN" = false ] && rm -rf "$TARGET_DIR/.claude/mcp-configs"
            
            # Remove from settings.json
            if [ -f "$TARGET_DIR/.claude/settings.json" ]; then
                log_action "Remove MCP reference from settings.json"
                if [ "$DRY_RUN" = false ]; then
                    jq 'del(.mcpConfig)' "$TARGET_DIR/.claude/settings.json" > "$TARGET_DIR/.claude/settings.json.tmp"
                    mv "$TARGET_DIR/.claude/settings.json.tmp" "$TARGET_DIR/.claude/settings.json"
                fi
            fi
            ;;
            
        hooks)
            log_info "Removing hooks..."
            log_action "Remove .claude/hooks directory"
            [ "$DRY_RUN" = false ] && rm -rf "$TARGET_DIR/.claude/hooks"
            
            # Remove from settings.json
            if [ -f "$TARGET_DIR/.claude/settings.json" ]; then
                log_action "Remove hooks from settings.json"
                if [ "$DRY_RUN" = false ]; then
                    jq 'del(.hooks)' "$TARGET_DIR/.claude/settings.json" > "$TARGET_DIR/.claude/settings.json.tmp"
                    mv "$TARGET_DIR/.claude/settings.json.tmp" "$TARGET_DIR/.claude/settings.json"
                fi
            fi
            ;;
            
        configs)
            log_info "Removing configuration files..."
            log_action "Remove .env file"
            [ "$DRY_RUN" = false ] && rm -f "$TARGET_DIR/.env"
            log_action "Remove settings files"
            [ "$DRY_RUN" = false ] && rm -f "$TARGET_DIR/.claude/settings.json"
            [ "$DRY_RUN" = false ] && rm -f "$TARGET_DIR/.claude/settings.local.json"
            ;;
            
        temp)
            remove_temp_files
            ;;
            
        *)
            log_error "Unknown component: $component"
            ;;
    esac
}

remove_temp_files() {
    log_info "Removing temporary files..."
    
    # Remove temp directories
    for dir in /tmp/warpio-*; do
        if [ -d "$dir" ]; then
            log_action "Remove $dir"
            [ "$DRY_RUN" = false ] && rm -rf "$dir"
        fi
    done
    
    # Remove backup files
    for backup in "$TARGET_DIR"/.claude.backup.* "$TARGET_DIR"/CLAUDE.md.backup.*; do
        if [ -e "$backup" ]; then
            log_action "Remove backup: $(basename "$backup")"
            [ "$DRY_RUN" = false ] && rm -rf "$backup"
        fi
    done
}

interactive_mode() {
    print_banner
    
    echo "Select uninstall mode:"
    echo ""
    echo "  1) Complete - Remove all Warpio components"
    echo "  2) Partial  - Remove Warpio but keep configurations"
    echo "  3) Disable  - Disable Warpio without removing files"
    echo "  4) Component - Remove specific components"
    echo "  5) Temp Only - Remove temporary files only"
    echo "  0) Cancel"
    echo ""
    
    read -p "Select option [0-5]: " choice
    
    case "$choice" in
        1)
            log_warning "This will completely remove Warpio!"
            echo -n "Are you sure? (type 'yes' to confirm): "
            read -r confirm
            if [ "$confirm" = "yes" ]; then
                create_backup
                remove_complete
            else
                log_info "Cancelled"
                exit 0
            fi
            ;;
        2)
            create_backup
            remove_partial
            ;;
        3)
            create_backup
            disable_warpio
            ;;
        4)
            echo ""
            echo "Select components to remove:"
            echo "  1) Expert agents"
            echo "  2) MCP configurations"
            echo "  3) Hooks"
            echo "  4) Configuration files"
            echo "  5) Temporary files"
            echo ""
            read -p "Enter component numbers (space-separated): " components
            
            create_backup
            for comp in $components; do
                case "$comp" in
                    1) remove_component "experts" ;;
                    2) remove_component "mcps" ;;
                    3) remove_component "hooks" ;;
                    4) remove_component "configs" ;;
                    5) remove_component "temp" ;;
                esac
            done
            ;;
        5)
            remove_temp_files
            ;;
        0)
            log_info "Uninstall cancelled"
            exit 0
            ;;
        *)
            log_error "Invalid option"
            exit 1
            ;;
    esac
}

# ========================================================================
# MAIN
# ========================================================================

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --complete)
            UNINSTALL_MODE="complete"
            shift
            ;;
        --partial)
            UNINSTALL_MODE="partial"
            shift
            ;;
        --disable)
            UNINSTALL_MODE="disable"
            shift
            ;;
        --component)
            UNINSTALL_MODE="component"
            COMPONENTS_TO_REMOVE+=("$2")
            shift 2
            ;;
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --no-backup)
            BACKUP_DIR="skip"
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

# Validate target directory
if [ -z "$TARGET_DIR" ]; then
    if [ -d ".claude" ]; then
        TARGET_DIR="."
    else
        log_error "Target directory required"
        show_usage
        exit 1
    fi
fi

# Convert to absolute path
TARGET_DIR="$(cd "$TARGET_DIR" && pwd)"

# Detect Warpio installation
if ! detect_warpio; then
    exit 1
fi

# Execute based on mode
case "$UNINSTALL_MODE" in
    complete)
        print_banner
        log_warning "Complete removal selected"
        create_backup
        remove_complete
        ;;
    partial)
        print_banner
        log_info "Partial removal selected"
        create_backup
        remove_partial
        ;;
    disable)
        print_banner
        log_info "Disable mode selected"
        create_backup
        disable_warpio
        ;;
    component)
        print_banner
        log_info "Component removal selected"
        create_backup
        for comp in "${COMPONENTS_TO_REMOVE[@]}"; do
            remove_component "$comp"
        done
        ;;
    interactive)
        interactive_mode
        ;;
esac

# Summary
echo ""
if [ "$DRY_RUN" = true ]; then
    echo -e "${YELLOW}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${YELLOW}║           DRY RUN COMPLETE - No changes made                ║${NC}"
    echo -e "${YELLOW}╚══════════════════════════════════════════════════════════════╝${NC}"
else
    echo -e "${GREEN}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║              Warpio uninstall complete                      ║${NC}"
    echo -e "${GREEN}╚══════════════════════════════════════════════════════════════╝${NC}"
    
    if [ -n "$BACKUP_DIR" ] && [ "$BACKUP_DIR" != "skip" ]; then
        echo ""
        echo -e "${CYAN}Backup saved at:${NC} $BACKUP_DIR"
        echo -e "${CYAN}To restore:${NC} cp -r $BACKUP_DIR/* $TARGET_DIR/"
    fi
fi

echo ""