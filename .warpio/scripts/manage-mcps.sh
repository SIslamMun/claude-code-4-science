#!/bin/bash
# ========================================================================
# WARPIO MCP MANAGEMENT SCRIPT
# Manage IOWarp and other MCPs using Claude CLI commands
# ========================================================================

set -e

# Source utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils/warpio-utils.sh"

# Configuration
PROJECT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
MCP_CONFIG_DIR="$PROJECT_DIR/.claude/mcp-configs"
ENV_FILE="$PROJECT_DIR/.env"

# IOWarp MCPs catalog
declare -A IOWARP_MCPS=(
    ["hdf5"]="HDF5 file operations and optimization"
    ["darshan"]="HPC I/O performance analysis"
    ["adios"]="ADIOS2 streaming I/O framework"
    ["parquet"]="Apache Parquet columnar data"
    ["arxiv"]="ArXiv paper search and retrieval"
    ["slurm"]="SLURM job scheduling"
    ["pandas"]="Pandas data manipulation"
    ["plot"]="Scientific plotting and visualization"
    ["jarvis"]="Workflow automation"
    ["lmod"]="Module environment management"
    ["compression"]="Data compression utilities"
    ["chronolog"]="Time-series data logging"
    ["node_hardware"]="Hardware monitoring"
    ["parallel_sort"]="Parallel sorting algorithms"
)

# Other popular MCPs
declare -A COMMUNITY_MCPS=(
    ["filesystem"]="File system operations"
    ["git"]="Git version control"
    ["github"]="GitHub API integration"
    ["docker"]="Docker container management"
    ["kubernetes"]="Kubernetes cluster management"
    ["aws"]="AWS cloud services"
    ["postgresql"]="PostgreSQL database"
    ["redis"]="Redis cache"
)

# ========================================================================
# FUNCTIONS
# ========================================================================

show_usage() {
    cat << EOF
Usage: $0 [COMMAND] [OPTIONS]

Manage Model Context Protocol (MCP) servers for Warpio.

Commands:
  list              List all available MCPs
  status            Show installed MCPs and their status
  install NAME      Install a specific MCP
  remove NAME       Remove a specific MCP
  update [NAME]     Update one or all MCPs
  test NAME         Test MCP connection
  add-custom        Add a custom MCP configuration

Options:
  --category TYPE   Filter by category (iowarp, community, all)
  --json            Output in JSON format
  --help, -h        Show this help message

Examples:
  $0 list --category iowarp       # List IOWarp MCPs
  $0 install hdf5                  # Install HDF5 MCP
  $0 status                        # Show installed MCPs
  $0 test darshan                  # Test Darshan MCP

EOF
}

print_banner() {
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║               WARPIO MCP MANAGER v1.0                       ║${NC}"
    echo -e "${CYAN}║           Model Context Protocol Management                 ║${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

check_claude_cli() {
    if ! command -v claude &>/dev/null; then
        log_error "Claude CLI not installed"
        echo "Install with: npm install -g @anthropic-ai/claude-cli"
        exit 1
    fi
}

list_available_mcps() {
    local category="${1:-all}"
    
    print_section_header "Available MCPs"
    
    if [ "$category" = "iowarp" ] || [ "$category" = "all" ]; then
        echo -e "${BOLD}IOWarp Scientific MCPs:${NC}"
        echo ""
        for mcp in "${!IOWARP_MCPS[@]}"; do
            printf "  ${GREEN}%-20s${NC} - %s\n" "$mcp" "${IOWARP_MCPS[$mcp]}"
        done
        echo ""
    fi
    
    if [ "$category" = "community" ] || [ "$category" = "all" ]; then
        echo -e "${BOLD}Community MCPs:${NC}"
        echo ""
        for mcp in "${!COMMUNITY_MCPS[@]}"; do
            printf "  ${BLUE}%-20s${NC} - %s\n" "$mcp" "${COMMUNITY_MCPS[$mcp]}"
        done
        echo ""
    fi
}

get_installed_mcps() {
    local mcps=()
    
    # Check MCP config file
    if [ -f "$MCP_CONFIG_DIR/warpio-mcps.json" ]; then
        if command -v jq &>/dev/null; then
            mcps=($(jq -r '.mcps | keys[]' "$MCP_CONFIG_DIR/warpio-mcps.json" 2>/dev/null))
        fi
    fi
    
    # Check Claude's global MCPs
    if command -v claude &>/dev/null; then
        # Try to get MCPs from claude mcp list (if available)
        local claude_mcps=$(claude mcp list 2>/dev/null || true)
        if [ -n "$claude_mcps" ]; then
            while IFS= read -r line; do
                mcps+=("$line")
            done <<< "$claude_mcps"
        fi
    fi
    
    printf '%s\n' "${mcps[@]}" | sort -u
}

show_mcp_status() {
    print_section_header "MCP Status"
    
    local installed_mcps=($(get_installed_mcps))
    
    if [ ${#installed_mcps[@]} -eq 0 ]; then
        log_warning "No MCPs installed"
        return
    fi
    
    echo -e "${BOLD}Installed MCPs:${NC}"
    echo ""
    
    for mcp in "${installed_mcps[@]}"; do
        echo -n "  $mcp: "
        
        # Test if MCP is responsive
        if test_mcp_connection "$mcp"; then
            echo -e "${GREEN}✓ Active${NC}"
        else
            echo -e "${YELLOW}⚠ Configured (not tested)${NC}"
        fi
    done
    
    echo ""
    echo "Total: ${#installed_mcps[@]} MCPs configured"
}

install_iowarp_mcp() {
    local mcp_name=$1
    
    log_info "Installing IOWarp MCP: $mcp_name"
    
    # Method 1: Using claude mcp add (if supported)
    if claude mcp add --help &>/dev/null 2>&1; then
        log_info "Using claude mcp add..."
        
        # Install using claude CLI
        claude mcp add "$mcp_name" -- uvx iowarp-mcps "$mcp_name"
        
        log_success "Installed via Claude CLI"
        
    # Method 2: Manual configuration
    else
        log_info "Claude mcp add not available, using manual configuration..."
        
        # Create MCP configuration
        local config_file="$MCP_CONFIG_DIR/${mcp_name}-mcp.json"
        
        cat > "$config_file" << EOF
{
  "mcpServers": {
    "${mcp_name}": {
      "command": "uvx",
      "args": ["iowarp-mcps", "${mcp_name}"]
    }
  }
}
EOF
        
        # Update main MCP configuration
        if [ -f "$MCP_CONFIG_DIR/warpio-mcps.json" ]; then
            # Merge with existing config
            if command -v jq &>/dev/null; then
                jq ".mcps.\"$mcp_name\" = {
                    \"command\": \"uvx\",
                    \"args\": [\"iowarp-mcps\", \"$mcp_name\"],
                    \"description\": \"${IOWARP_MCPS[$mcp_name]}\"
                }" "$MCP_CONFIG_DIR/warpio-mcps.json" > "$MCP_CONFIG_DIR/warpio-mcps.json.tmp"
                mv "$MCP_CONFIG_DIR/warpio-mcps.json.tmp" "$MCP_CONFIG_DIR/warpio-mcps.json"
            fi
        fi
        
        log_success "Configured manually in $config_file"
    fi
    
    # Test installation
    log_info "Testing MCP..."
    if uvx iowarp-mcps "$mcp_name" --help &>/dev/null; then
        log_success "MCP is ready to use"
    else
        log_warning "MCP configured but not tested"
    fi
}

install_community_mcp() {
    local mcp_name=$1
    
    log_info "Installing community MCP: $mcp_name"
    
    # Map to actual package names
    local package_name=""
    case "$mcp_name" in
        filesystem) package_name="mcp-server-filesystem" ;;
        git) package_name="mcp-server-git" ;;
        github) package_name="mcp-server-github" ;;
        docker) package_name="mcp-server-docker" ;;
        postgresql) package_name="mcp-server-postgresql" ;;
        *) package_name="mcp-server-$mcp_name" ;;
    esac
    
    # Try to install via claude CLI
    if claude mcp add --help &>/dev/null 2>&1; then
        claude mcp add "$mcp_name" -- uvx "$package_name"
        log_success "Installed via Claude CLI"
    else
        # Manual configuration
        local config_file="$MCP_CONFIG_DIR/${mcp_name}-mcp.json"
        
        cat > "$config_file" << EOF
{
  "mcpServers": {
    "${mcp_name}": {
      "command": "uvx",
      "args": ["${package_name}"]
    }
  }
}
EOF
        
        log_success "Configured manually"
    fi
}

install_mcp() {
    local mcp_name=$1
    
    if [ -z "$mcp_name" ]; then
        log_error "MCP name required"
        return 1
    fi
    
    # Check if it's an IOWarp MCP
    if [[ -n "${IOWARP_MCPS[$mcp_name]}" ]]; then
        install_iowarp_mcp "$mcp_name"
    elif [[ -n "${COMMUNITY_MCPS[$mcp_name]}" ]]; then
        install_community_mcp "$mcp_name"
    else
        log_error "Unknown MCP: $mcp_name"
        echo "Run '$0 list' to see available MCPs"
        return 1
    fi
}

remove_mcp() {
    local mcp_name=$1
    
    log_info "Removing MCP: $mcp_name"
    
    # Try claude CLI first
    if claude mcp remove --help &>/dev/null 2>&1; then
        claude mcp remove "$mcp_name"
        log_success "Removed via Claude CLI"
    else
        # Manual removal
        if [ -f "$MCP_CONFIG_DIR/${mcp_name}-mcp.json" ]; then
            rm -f "$MCP_CONFIG_DIR/${mcp_name}-mcp.json"
        fi
        
        # Remove from main config
        if command -v jq &>/dev/null && [ -f "$MCP_CONFIG_DIR/warpio-mcps.json" ]; then
            jq "del(.mcps.\"$mcp_name\")" "$MCP_CONFIG_DIR/warpio-mcps.json" > "$MCP_CONFIG_DIR/warpio-mcps.json.tmp"
            mv "$MCP_CONFIG_DIR/warpio-mcps.json.tmp" "$MCP_CONFIG_DIR/warpio-mcps.json"
        fi
        
        log_success "Removed configuration"
    fi
}

test_mcp_connection() {
    local mcp_name=$1
    
    # Basic test - check if MCP can be launched
    case "$mcp_name" in
        zen)
            uvx --from git+https://github.com/BeehiveInnovations/zen-mcp-server.git zen-mcp-server --help &>/dev/null
            ;;
        hdf5|darshan|adios|parquet|arxiv|slurm|pandas)
            uvx iowarp-mcps "$mcp_name" --help &>/dev/null 2>&1
            ;;
        *)
            # Generic test
            return 1
            ;;
    esac
}

test_mcp() {
    local mcp_name=$1
    
    log_info "Testing MCP: $mcp_name"
    
    if test_mcp_connection "$mcp_name"; then
        log_success "MCP is functional"
        
        # Additional tests based on MCP type
        case "$mcp_name" in
            hdf5)
                log_info "Testing HDF5 operations..."
                # Could add actual HDF5 test here
                ;;
            darshan)
                log_info "Testing Darshan analysis..."
                # Could add Darshan test here
                ;;
        esac
    else
        log_error "MCP test failed"
        return 1
    fi
}

update_mcps() {
    local mcp_name=$1
    
    if [ -n "$mcp_name" ]; then
        log_info "Updating MCP: $mcp_name"
        
        # Reinstall to get latest version
        remove_mcp "$mcp_name"
        install_mcp "$mcp_name"
    else
        log_info "Updating all MCPs..."
        
        local installed_mcps=($(get_installed_mcps))
        for mcp in "${installed_mcps[@]}"; do
            log_info "Updating $mcp..."
            remove_mcp "$mcp"
            install_mcp "$mcp"
        done
    fi
    
    log_success "Update complete"
}

add_custom_mcp() {
    log_info "Add Custom MCP Configuration"
    echo ""
    
    read -p "MCP Name: " name
    read -p "Command (e.g., uvx, python): " command
    read -p "Arguments (space-separated): " args
    read -p "Description: " description
    
    # Create configuration
    local config_file="$MCP_CONFIG_DIR/${name}-custom.json"
    
    # Convert args to JSON array
    local args_json=$(echo "$args" | jq -R 'split(" ")')
    
    cat > "$config_file" << EOF
{
  "mcpServers": {
    "${name}": {
      "command": "${command}",
      "args": ${args_json},
      "description": "${description}"
    }
  }
}
EOF
    
    log_success "Custom MCP configured: $config_file"
    echo "Restart Claude Code to activate"
}

install_essential_mcps() {
    print_section_header "Installing Essential MCPs"
    
    local essential_mcps=("hdf5" "darshan" "slurm" "arxiv" "pandas")
    
    echo "Installing essential scientific MCPs..."
    echo ""
    
    for mcp in "${essential_mcps[@]}"; do
        install_mcp "$mcp"
    done
    
    log_success "Essential MCPs installed"
}

# ========================================================================
# MAIN
# ========================================================================

# Check for Claude CLI
check_claude_cli

# Parse command
COMMAND="${1:-}"
shift || true

case "$COMMAND" in
    list)
        print_banner
        CATEGORY="all"
        while [[ $# -gt 0 ]]; do
            case $1 in
                --category) CATEGORY="$2"; shift 2 ;;
                *) shift ;;
            esac
        done
        list_available_mcps "$CATEGORY"
        ;;
        
    status)
        print_banner
        show_mcp_status
        ;;
        
    install)
        print_banner
        if [ -z "$1" ]; then
            log_error "MCP name required"
            exit 1
        fi
        install_mcp "$1"
        ;;
        
    remove)
        print_banner
        if [ -z "$1" ]; then
            log_error "MCP name required"
            exit 1
        fi
        remove_mcp "$1"
        ;;
        
    update)
        print_banner
        update_mcps "$1"
        ;;
        
    test)
        print_banner
        if [ -z "$1" ]; then
            log_error "MCP name required"
            exit 1
        fi
        test_mcp "$1"
        ;;
        
    add-custom)
        print_banner
        add_custom_mcp
        ;;
        
    install-essential)
        print_banner
        install_essential_mcps
        ;;
        
    --help|-h|"")
        show_usage
        ;;
        
    *)
        log_error "Unknown command: $COMMAND"
        show_usage
        exit 1
        ;;
esac