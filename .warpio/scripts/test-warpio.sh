#!/bin/bash
# ========================================================================
# WARPIO COMPREHENSIVE TEST SUITE
# Tests all components of Warpio installation
# ========================================================================

set -e

# Source utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils/warpio-utils.sh"

# Configuration
PROJECT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
CLAUDE_DIR="$PROJECT_DIR/.claude"
ENV_FILE="$PROJECT_DIR/.env"
TEST_RESULTS=()
FAILED_TESTS=0
PASSED_TESTS=0

# ========================================================================
# TEST FUNCTIONS
# ========================================================================

run_test() {
    local test_name=$1
    local test_cmd=$2
    local expected_result=${3:-0}
    
    echo -n "Testing $test_name... "
    
    if eval "$test_cmd" &>/dev/null; then
        if [ $expected_result -eq 0 ]; then
            echo -e "${GREEN}✓ PASSED${NC}"
            TEST_RESULTS+=("✓ $test_name")
            ((PASSED_TESTS++))
            return 0
        else
            echo -e "${RED}✗ FAILED${NC} (expected failure but passed)"
            TEST_RESULTS+=("✗ $test_name - unexpected pass")
            ((FAILED_TESTS++))
            return 1
        fi
    else
        if [ $expected_result -ne 0 ]; then
            echo -e "${GREEN}✓ PASSED${NC} (expected failure)"
            TEST_RESULTS+=("✓ $test_name (expected failure)")
            ((PASSED_TESTS++))
            return 0
        else
            echo -e "${RED}✗ FAILED${NC}"
            TEST_RESULTS+=("✗ $test_name")
            ((FAILED_TESTS++))
            return 1
        fi
    fi
}

test_core_files() {
    print_section_header "Core Files Test"
    
    run_test ".claude directory" "[ -d '$CLAUDE_DIR' ]"
    run_test "CLAUDE.md exists" "[ -f '$PROJECT_DIR/CLAUDE.md' ]"
    run_test "CLAUDE.md has Warpio" "grep -q 'WARPIO' '$PROJECT_DIR/CLAUDE.md'"
    run_test ".env file exists" "[ -f '$ENV_FILE' ]"
    run_test "Settings exist" "[ -f '$CLAUDE_DIR/settings.json' ] || [ -f '$CLAUDE_DIR/settings.local.json' ]"
}

test_scripts() {
    print_section_header "Script Permissions Test"
    
    local scripts=(
        "scripts/utils/warpio-utils.sh"
        "scripts/pre-install.sh"
        "scripts/post-install.sh"
        "scripts/test-warpio.sh"
        "scripts/configure-local-ai.sh"
    )
    
    for script in "${scripts[@]}"; do
        if [ -f "$CLAUDE_DIR/$script" ]; then
            run_test "$(basename $script) executable" "[ -x '$CLAUDE_DIR/$script' ]"
        fi
    done
}

test_hooks() {
    print_section_header "Hooks Test"
    
    local hook_dirs=("SessionStart" "PreToolUse" "PostToolUse" "SubagentStop")
    
    for dir in "${hook_dirs[@]}"; do
        if [ -d "$CLAUDE_DIR/hooks/$dir" ]; then
            run_test "$dir hook directory" "[ -d '$CLAUDE_DIR/hooks/$dir' ]"
            
            # Test individual hooks
            for hook in "$CLAUDE_DIR/hooks/$dir"/*; do
                if [ -f "$hook" ]; then
                    local hook_name=$(basename "$hook")
                    run_test "$hook_name executable" "[ -x '$hook' ]"
                    
                    # Test Python shebang if .py file
                    if [[ "$hook" == *.py ]]; then
                        run_test "$hook_name shebang" "head -1 '$hook' | grep -q 'python'"
                    fi
                fi
            done
        fi
    done
}

test_experts() {
    print_section_header "Expert Agents Test"
    
    local expert_count=0
    for expert in "$CLAUDE_DIR/agents"/*.md; do
        if [ -f "$expert" ]; then
            local name=$(basename "$expert" .md)
            run_test "Expert $name" "[ -f '$expert' ]"
            ((expert_count++))
        fi
    done
    
    run_test "At least one expert" "[ $expert_count -gt 0 ]"
}

test_mcp_config() {
    print_section_header "MCP Configuration Test"
    
    local mcp_config="$CLAUDE_DIR/mcp-configs/warpio-mcps.json"
    
    run_test "MCP config exists" "[ -f '$mcp_config' ]"
    
    if command -v jq &>/dev/null; then
        run_test "Valid JSON" "jq . '$mcp_config' >/dev/null"
        run_test "Has zen MCP" "jq -e '.mcps.zen' '$mcp_config' >/dev/null"
        
        # Test wrapper script
        local wrapper_path=$(jq -r '.mcps.zen.command' "$mcp_config" 2>/dev/null || echo "")
        if [ -n "$wrapper_path" ] && [ -f "$wrapper_path" ]; then
            run_test "Zen wrapper exists" "[ -f '$wrapper_path' ]"
            run_test "Zen wrapper executable" "[ -x '$wrapper_path' ]"
        fi
    else
        log_warning "jq not installed, skipping JSON validation"
    fi
}

test_zen_mcp() {
    print_section_header "Zen-MCP Test"
    
    # Test zen-mcp-server availability
    run_test "zen-mcp-server accessible" \
        "uvx --from git+https://github.com/BeehiveInnovations/zen-mcp-server.git zen-mcp-server --help"
}

test_local_ai() {
    print_section_header "Local AI Test"
    
    if load_env "$ENV_FILE"; then
        case "$LOCAL_AI_PROVIDER" in
            "lmstudio")
                log_info "Testing LM Studio connection..."
                run_test "LM Studio API" "timeout 2 curl -s '$LMSTUDIO_API_URL/v1/models'"
                
                # Test inference if connected
                if timeout 2 curl -s "$LMSTUDIO_API_URL/v1/models" &>/dev/null; then
                    local test_prompt='{"model":"'$LMSTUDIO_MODEL'","messages":[{"role":"user","content":"Say OK"}],"max_tokens":10}'
                    run_test "LM Studio inference" \
                        "curl -s -X POST '$LMSTUDIO_API_URL/v1/chat/completions' -H 'Content-Type: application/json' -d '$test_prompt'"
                fi
                ;;
            
            "ollama")
                log_info "Testing Ollama connection..."
                run_test "Ollama command" "command -v ollama"
                run_test "Ollama API" "curl -s '$OLLAMA_API_URL/api/tags'"
                
                # Test model availability
                if command -v ollama &>/dev/null; then
                    run_test "Ollama model" "ollama list | grep -q '$OLLAMA_MODEL'"
                fi
                ;;
            
            *)
                log_info "No local AI configured"
                ;;
        esac
    else
        log_warning "No .env file, skipping local AI tests"
    fi
}

test_environment() {
    print_section_header "Environment Variables Test"
    
    if load_env "$ENV_FILE"; then
        run_test "WARPIO_VERSION set" "[ -n '$WARPIO_VERSION' ]"
        run_test "LOCAL_AI_PROVIDER set" "[ -n '$LOCAL_AI_PROVIDER' ]"
        
        # Test critical variables based on provider
        case "$LOCAL_AI_PROVIDER" in
            "lmstudio")
                run_test "LMSTUDIO_API_URL set" "[ -n '$LMSTUDIO_API_URL' ]"
                run_test "LMSTUDIO_MODEL set" "[ -n '$LMSTUDIO_MODEL' ]"
                ;;
            "ollama")
                run_test "OLLAMA_API_URL set" "[ -n '$OLLAMA_API_URL' ]"
                run_test "OLLAMA_MODEL set" "[ -n '$OLLAMA_MODEL' ]"
                ;;
        esac
    fi
}

test_integration() {
    print_section_header "Integration Test"
    
    # Test that all components work together
    run_test "Utils sourcing" "source '$CLAUDE_DIR/scripts/utils/warpio-utils.sh'"
    
    # Test environment loading through utils
    if [ -f "$CLAUDE_DIR/scripts/utils/warpio-utils.sh" ]; then
        source "$CLAUDE_DIR/scripts/utils/warpio-utils.sh"
        run_test "Environment loading" "load_env '$ENV_FILE'"
    fi
}

generate_report() {
    local report="$PROJECT_DIR/WARPIO-TEST-REPORT.md"
    
    cat > "$report" << EOF
# Warpio Test Report

Generated: $(date)

## Test Summary

- **Total Tests**: $((PASSED_TESTS + FAILED_TESTS))
- **Passed**: $PASSED_TESTS
- **Failed**: $FAILED_TESTS
- **Success Rate**: $(echo "scale=1; $PASSED_TESTS * 100 / ($PASSED_TESTS + $FAILED_TESTS)" | bc)%

## Test Results

$(for result in "${TEST_RESULTS[@]}"; do
    echo "- $result"
done)

## Status

$(if [ $FAILED_TESTS -eq 0 ]; then
    echo "✅ **All tests passed!** Warpio is fully functional."
else
    echo "❌ **Some tests failed.** Please review the failures above."
fi)

## Recommendations

$(if [ $FAILED_TESTS -gt 0 ]; then
    echo "1. Review failed tests above"
    echo "2. Run post-installation script: \`./.claude/scripts/post-install.sh\`"
    echo "3. Check configuration in \`.env\`"
else
    echo "1. Your Warpio installation is ready to use"
    echo "2. Start Claude Code: \`claude\`"
    echo "3. Test with: \"Who are you?\""
fi)

---
Report generated by Warpio Test Suite
EOF
    
    log_success "Test report saved to: WARPIO-TEST-REPORT.md"
}

# ========================================================================
# MAIN EXECUTION
# ========================================================================

main() {
    if [ "$QUIET_MODE" = false ]; then
        print_warpio_banner
        echo -e "${BOLD}Warpio Comprehensive Test Suite${NC}"
        echo ""
    fi
    
    # Run all tests
    test_core_files
    test_scripts
    test_hooks
    test_experts
    test_mcp_config
    test_zen_mcp
    test_local_ai
    test_environment
    test_integration
    
    # Generate report
    generate_report
    
    # Print summary
    if [ "$QUIET_MODE" = false ]; then
        print_section_header "Test Summary"
        
        echo "Total Tests: $((PASSED_TESTS + FAILED_TESTS))"
        echo -e "${GREEN}Passed: $PASSED_TESTS${NC}"
        echo -e "${RED}Failed: $FAILED_TESTS${NC}"
        
        echo ""
        if [ $FAILED_TESTS -eq 0 ]; then
            echo -e "${GREEN}╔══════════════════════════════════════════════════════════════╗${NC}"
            echo -e "${GREEN}║           ✅ All tests passed! Warpio is ready!             ║${NC}"
            echo -e "${GREEN}╚══════════════════════════════════════════════════════════════╝${NC}"
        else
            echo -e "${YELLOW}╔══════════════════════════════════════════════════════════════╗${NC}"
            echo -e "${YELLOW}║         ⚠️  Some tests failed. Review report above.          ║${NC}"
            echo -e "${YELLOW}╚══════════════════════════════════════════════════════════════╝${NC}"
        fi
    fi
    
    # Always exit with appropriate code
    if [ $FAILED_TESTS -eq 0 ]; then
        exit 0
    else
        exit 1
    fi
}

# Parse arguments
QUIET_MODE=false
case "${1:-}" in
    --help|-h)
        echo "Usage: $0 [OPTIONS]"
        echo ""
        echo "Run comprehensive tests on Warpio installation"
        echo ""
        echo "Options:"
        echo "  --verbose, -v    Show detailed test output"
        echo "  --quiet, -q      Minimal output (exit code only)"
        echo "  --help, -h       Show this help message"
        exit 0
        ;;
    --verbose|-v)
        set -x
        ;;
    --quiet|-q)
        QUIET_MODE=true
        ;;
esac

main