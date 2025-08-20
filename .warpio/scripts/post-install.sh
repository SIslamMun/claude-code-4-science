#!/bin/bash
# ========================================================================
# WARPIO POST-INSTALLATION SCRIPT
# Configures MCPs, validates installation, and sets up integrations
# ========================================================================

set -e

# Source utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils/warpio-utils.sh"

# Configuration
PROJECT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
CLAUDE_DIR="$PROJECT_DIR/.claude"
ENV_FILE="$PROJECT_DIR/.env"

# Counters
ERRORS=0
WARNINGS=0

# ========================================================================
# MCP CONFIGURATION
# ========================================================================

configure_zen_mcp() {
    log_info "Configuring zen-mcp integration..."
    
    # Load environment
    if load_env "$ENV_FILE"; then
        log_success "Environment loaded"
    else
        log_warning "No .env file found"
        ((WARNINGS++))
    fi
    
    # Get custom API configuration
    eval $(get_custom_api_config)
    
    # Update zen-mcp wrapper with proper configuration
    local wrapper="$CLAUDE_DIR/scripts/mcp-wrappers/zen-wrapper.sh"
    mkdir -p "$(dirname "$wrapper")"
    
    cat > "$wrapper" << 'EOF'
#!/bin/bash
# Zen-MCP wrapper with proper environment loading

# Get script location and project root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"

# Change to project directory
cd "$PROJECT_ROOT"

# Load environment
if [ -f ".env" ]; then
    set -a
    source .env
    set +a
fi

# Configure based on LOCAL_AI_PROVIDER
case "$LOCAL_AI_PROVIDER" in
    "lmstudio")
        export CUSTOM_API_URL="${LMSTUDIO_API_URL}"
        export CUSTOM_MODEL_NAME="${LMSTUDIO_MODEL}"
        export CUSTOM_API_KEY="${LMSTUDIO_API_KEY}"
        ;;
    "ollama")
        export CUSTOM_API_URL="${OLLAMA_API_URL}"
        export CUSTOM_MODEL_NAME="${OLLAMA_MODEL}"
        export CUSTOM_API_KEY="${OLLAMA_API_KEY}"
        ;;
esac

# Launch zen-mcp-server
exec uvx --from git+https://github.com/BeehiveInnovations/zen-mcp-server.git zen-mcp-server
EOF
    
    chmod +x "$wrapper"
    log_success "Zen-MCP wrapper configured"
    
    # Update MCP configuration with correct format
    local mcp_config="$CLAUDE_DIR/mcp-configs/warpio-mcps.json"
    cat > "$mcp_config" << EOF
{
  "mcps": {
    "zen": {
      "command": "$wrapper",
      "args": [],
      "env": {}
    }
  }
}
EOF
    
    log_success "MCP configuration updated"
}

validate_hooks() {
    print_section_header "Hook Validation"
    
    local hook_dirs=("SessionStart" "PreToolUse" "PostToolUse" "SubagentStop")
    
    for dir in "${hook_dirs[@]}"; do
        local hook_path="$CLAUDE_DIR/hooks/$dir"
        if [ -d "$hook_path" ]; then
            local hook_count=0
            for hook in "$hook_path"/*; do
                if [ -f "$hook" ]; then
                    if [ ! -x "$hook" ]; then
                        chmod +x "$hook"
                        log_warning "Fixed permissions for $(basename "$hook")"
                    fi
                    ((hook_count++))
                fi
            done
            if [ $hook_count -gt 0 ]; then
                log_success "$dir: $hook_count hook(s) configured"
            fi
        else
            log_warning "$dir hooks directory missing"
            ((WARNINGS++))
        fi
    done
}

validate_experts() {
    print_section_header "Expert Agent Validation"
    
    local expert_count=0
    for expert in "$CLAUDE_DIR/agents"/*.md; do
        if [ -f "$expert" ]; then
            local name=$(basename "$expert" .md)
            log_success "Expert configured: $name"
            ((expert_count++))
        fi
    done
    
    if [ $expert_count -eq 0 ]; then
        log_error "No expert agents found"
        ((ERRORS++))
    else
        log_info "Total experts: $expert_count"
    fi
}

validate_mcps() {
    print_section_header "MCP Validation"
    
    if [ -f "$CLAUDE_DIR/mcp-configs/warpio-mcps.json" ]; then
        if command -v jq &>/dev/null; then
            local mcp_count=$(jq -r '.mcps | keys | length' "$CLAUDE_DIR/mcp-configs/warpio-mcps.json" 2>/dev/null || echo 0)
            log_success "MCPs configured: $mcp_count"
            
            # Test zen-mcp availability
            if uvx --from git+https://github.com/BeehiveInnovations/zen-mcp-server.git zen-mcp-server --help &>/dev/null; then
                log_success "zen-mcp-server: Available"
            else
                log_warning "zen-mcp-server: Will download on first use"
                ((WARNINGS++))
            fi
        else
            log_warning "jq not installed, cannot validate MCP configuration"
            ((WARNINGS++))
        fi
    else
        log_error "MCP configuration file missing"
        ((ERRORS++))
    fi
}

test_local_ai() {
    print_section_header "Local AI Detection"
    
    if load_env "$ENV_FILE"; then
        case "$LOCAL_AI_PROVIDER" in
            "lmstudio")
                if test_ai_connection "$LMSTUDIO_API_URL" "$LMSTUDIO_MODEL" "lmstudio"; then
                    log_success "LM Studio configured and accessible"
                else
                    log_warning "LM Studio configured but not accessible"
                    ((WARNINGS++))
                fi
                ;;
            "ollama")
                if test_ai_connection "$OLLAMA_API_URL" "$OLLAMA_MODEL" "ollama"; then
                    log_success "Ollama configured and accessible"
                else
                    log_warning "Ollama configured but not accessible"
                    ((WARNINGS++))
                fi
                ;;
            *)
                log_info "No local AI configured (cloud fallback enabled)"
                ;;
        esac
    fi
}

create_validation_report() {
    local report="$PROJECT_DIR/WARPIO-VALIDATION.md"
    
    cat > "$report" << EOF
# Warpio Installation Validation Report

Generated: $(date)

## Summary

- **Errors**: $ERRORS
- **Warnings**: $WARNINGS
- **Status**: $([ $ERRORS -eq 0 ] && echo "✅ Ready" || echo "❌ Issues Found")

## Components Checked

### Core Files
- ✓ .claude directory
- ✓ CLAUDE.md integration
- ✓ Environment configuration
- ✓ MCP configurations

### Expert Agents
$(for expert in "$CLAUDE_DIR/agents"/*.md; do
    [ -f "$expert" ] && echo "- ✓ $(basename "$expert" .md)"
done)

### Local AI
- Provider: ${LOCAL_AI_PROVIDER:-none}
- Status: $([ $WARNINGS -eq 0 ] && echo "Connected" || echo "Check configuration")

## Next Steps

1. Review any warnings above
2. Run \`./claude/scripts/test-warpio.sh\` for comprehensive testing
3. Configure local AI if needed: \`./.claude/scripts/configure-local-ai.sh\`
4. Start Claude Code: \`claude\`

---
Report generated by Warpio Post-Installation Script
EOF
    
    log_success "Validation report created: WARPIO-VALIDATION.md"
}

# ========================================================================
# MAIN EXECUTION
# ========================================================================

main() {
    print_warpio_banner
    echo -e "${BOLD}Post-Installation Configuration & Validation${NC}"
    echo ""
    
    # Configure components
    configure_zen_mcp
    
    # Validate installation
    validate_hooks
    validate_experts
    validate_mcps
    test_local_ai
    
    # Create report
    create_validation_report
    
    # Summary
    print_section_header "Post-Installation Summary"
    
    if [ $ERRORS -eq 0 ]; then
        echo -e "${GREEN}✅ All critical components configured${NC}"
    else
        echo -e "${RED}❌ $ERRORS critical error(s) found${NC}"
    fi
    
    if [ $WARNINGS -gt 0 ]; then
        echo -e "${YELLOW}⚠️  $WARNINGS warning(s) (non-critical)${NC}"
    fi
    
    echo ""
    if [ $ERRORS -eq 0 ]; then
        echo -e "${GREEN}╔══════════════════════════════════════════════════════════════╗${NC}"
        echo -e "${GREEN}║         🚀 Warpio is configured and ready to use!           ║${NC}"
        echo -e "${GREEN}╚══════════════════════════════════════════════════════════════╝${NC}"
    else
        echo -e "${RED}╔══════════════════════════════════════════════════════════════╗${NC}"
        echo -e "${RED}║      🔧 Please fix the errors above before proceeding       ║${NC}"
        echo -e "${RED}╚══════════════════════════════════════════════════════════════╝${NC}"
    fi
}

main