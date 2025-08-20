#!/bin/bash
# =======================================================================
# WARPIO INSTALLATION VALIDATOR v2.0
# Comprehensive validation of Warpio installation
# =======================================================================

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

ERRORS=0
WARNINGS=0

# Banner
echo -e "${CYAN}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║           Warpio Installation Validator v2.0                ║${NC}"
echo -e "${CYAN}║              Powered by IOWarp.ai                           ║${NC}"
echo -e "${CYAN}╚══════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Helper functions
check_component() {
    local component="$1"
    local check_cmd="$2"
    local error_msg="$3"
    local fix_msg="$4"
    
    echo -n "Checking $component... "
    if eval "$check_cmd" >/dev/null 2>&1; then
        echo -e "${GREEN}✅ OK${NC}"
    else
        echo -e "${RED}❌ FAILED${NC}"
        echo -e "   ${RED}Error:${NC} $error_msg"
        echo -e "   ${BLUE}Fix:${NC} $fix_msg"
        ((ERRORS++))
        echo ""
    fi
}

check_warning() {
    local component="$1"
    local check_cmd="$2"
    local warning_msg="$3"
    local fix_msg="$4"
    
    echo -n "Checking $component... "
    if eval "$check_cmd" >/dev/null 2>&1; then
        echo -e "${GREEN}✅ OK${NC}"
    else
        echo -e "${YELLOW}⚠️ WARNING${NC}"
        echo -e "   ${YELLOW}Warning:${NC} $warning_msg"
        echo -e "   ${BLUE}Suggestion:${NC} $fix_msg"
        ((WARNINGS++))
        echo ""
    fi
}

# ========================================================================
# CORE COMPONENT CHECKS
# ========================================================================

echo -e "${BLUE}${BOLD}Core Components:${NC}"
echo ""

check_component ".claude directory" "[ -d '.claude' ]" \
    ".claude directory missing" \
    "Re-run install-warpio.sh from the claude-code-4-science repository"

check_component "CLAUDE.md with Warpio" "[ -f 'CLAUDE.md' ] && grep -q 'WARPIO' CLAUDE.md" \
    "CLAUDE.md missing or no Warpio identity" \
    "Re-run install-warpio.sh or check CLAUDE.md integration"

check_component "Environment config" "[ -f '.env' ]" \
    ".env file missing" \
    "Copy .claude/.env.example to .env and configure"

check_component "Warpio settings" "[ -f '.claude/settings.json' ] || [ -f '.claude/settings.local.json' ]" \
    "Settings file missing" \
    "Re-run install-warpio.sh to create settings configuration"

# ========================================================================
# HOOK VALIDATION
# ========================================================================

echo ""
echo -e "${BLUE}${BOLD}Hook Validation:${NC}"
echo ""

for hook_dir in SessionStart PreToolUse PostToolUse SubagentStop; do
    hook_path=".claude/hooks/$hook_dir"
    if [ -d "$hook_path" ]; then
        for hook_file in "$hook_path"/*; do
            if [ -f "$hook_file" ]; then
                hook_name=$(basename "$hook_file")
                
                # Check if executable
                check_component "Hook $hook_name" "[ -x '$hook_file' ]" \
                    "Hook not executable" \
                    "chmod +x '$hook_file'"
                
                # Check Python shebang
                if [[ "$hook_file" == *.py ]]; then
                    check_component "Hook $hook_name shebang" "head -1 '$hook_file' | grep -q 'python'" \
                        "Python hook missing proper shebang" \
                        "Add #!/usr/bin/env python3 to first line of $hook_file"
                fi
            fi
        done
    else
        check_warning "Hook directory $hook_dir" "false" \
            "Hook directory missing" \
            "Re-run install-warpio.sh to restore hooks"
    fi
done

# ========================================================================
# EXPERT VALIDATION
# ========================================================================

echo ""
echo -e "${BLUE}${BOLD}Expert Agents:${NC}"
echo ""

EXPERT_COUNT=0
for expert_file in .claude/agents/*.md; do
    if [ -f "$expert_file" ]; then
        expert_name=$(basename "$expert_file" .md)
        echo -e "  ${GREEN}✓${NC} $expert_name configured"
        ((EXPERT_COUNT++))
    fi
done

if [ $EXPERT_COUNT -eq 0 ]; then
    echo -e "${RED}❌ No expert agents found${NC}"
    echo -e "   ${BLUE}Fix:${NC} Re-run install-warpio.sh and select experts"
    ((ERRORS++))
else
    echo -e "${GREEN}✅ $EXPERT_COUNT expert agents available${NC}"
fi

# ========================================================================
# MCP VALIDATION
# ========================================================================

echo ""
echo -e "${BLUE}${BOLD}MCP Validation:${NC}"
echo ""

if [ -f ".claude/mcp-configs/warpio-mcps.json" ]; then
    if command -v jq >/dev/null 2>&1; then
        mcps=$(jq -r '.mcps | keys[]' .claude/mcp-configs/warpio-mcps.json 2>/dev/null || echo "")
        MCP_COUNT=0
        
        if [ -n "$mcps" ]; then
            for mcp in $mcps; do
                echo -n "  MCP $mcp... "
                if [ "$mcp" = "zen" ]; then
                    if uvx --from git+https://github.com/BeehiveInnovations/zen-mcp-server.git zen-mcp-server --version &>/dev/null; then
                        echo -e "${GREEN}✅ Available${NC}"
                    else
                        echo -e "${YELLOW}⚠️ Not installed (will download on first use)${NC}"
                        ((WARNINGS++))
                    fi
                else
                    echo -e "${CYAN}📦 Will be downloaded on first use${NC}"
                fi
                ((MCP_COUNT++))
            done
            echo -e "${GREEN}✅ $MCP_COUNT MCPs configured${NC}"
        else
            echo -e "${YELLOW}⚠️ No MCPs configured${NC}"
            ((WARNINGS++))
        fi
    else
        check_component "jq for MCP parsing" "command -v jq" \
            "jq not available for MCP validation" \
            "Install jq: sudo apt-get install jq (Linux) or brew install jq (Mac)"
    fi
else
    check_component "MCP configuration" "false" \
        "MCP configuration file missing" \
        "Re-run install-warpio.sh to configure MCPs"
fi

# ========================================================================
# LOCAL AI VALIDATION
# ========================================================================

echo ""
echo -e "${BLUE}${BOLD}Local AI Validation:${NC}"
echo ""

if [ -f ".env" ]; then
    # Source environment variables
    export $(grep -v '^#' .env | xargs) 2>/dev/null
    
    if [ "$LOCAL_AI_PROVIDER" = "lmstudio" ]; then
        echo -n "LM Studio connection... "
        if timeout 2 curl -s "$LMSTUDIO_API_URL/models" >/dev/null 2>&1; then
            echo -e "${GREEN}✅ Connected${NC}"
            echo -e "  API URL: ${CYAN}$LMSTUDIO_API_URL${NC}"
            echo -e "  Model: ${CYAN}$LMSTUDIO_MODEL${NC}"
        else
            echo -e "${YELLOW}⚠️ Not responding${NC}"
            echo -e "   ${BLUE}Suggestion:${NC} Start LM Studio and ensure it's running on $LMSTUDIO_API_URL"
            ((WARNINGS++))
        fi
    elif [ "$LOCAL_AI_PROVIDER" = "ollama" ]; then
        echo -n "Ollama availability... "
        if command -v ollama >/dev/null 2>&1; then
            echo -e "${GREEN}✅ Installed${NC}"
            if ollama list >/dev/null 2>&1; then
                echo -e "  Models available: $(ollama list | wc -l)"
            else
                echo -e "  ${YELLOW}⚠️ No models found${NC}"
                echo -e "   ${BLUE}Suggestion:${NC} ollama pull $OLLAMA_MODEL"
                ((WARNINGS++))
            fi
        else
            echo -e "${YELLOW}⚠️ Not installed${NC}"
            echo -e "   ${BLUE}Suggestion:${NC} Install Ollama from https://ollama.ai"
            ((WARNINGS++))
        fi
    else
        echo -e "${CYAN}ℹ️ Local AI not configured (cloud fallback will be used)${NC}"
    fi
else
    echo -e "${YELLOW}⚠️ Cannot check - .env file missing${NC}"
    ((WARNINGS++))
fi

# ========================================================================
# DEPENDENCY CHECKS
# ========================================================================

echo ""
echo -e "${BLUE}${BOLD}Dependencies:${NC}"
echo ""

check_warning "UV package manager" "command -v uv" \
    "UV not installed" \
    "Install UV: curl -LsSf https://astral.sh/uv/install.sh | sh"

check_warning "Claude CLI" "command -v claude" \
    "Claude CLI not installed" \
    "Install: npm install -g @anthropic-ai/claude-cli"

check_warning "Python 3" "command -v python3" \
    "Python 3 not installed" \
    "Install Python 3 from your package manager"

# ========================================================================
# VALIDATION SUMMARY
# ========================================================================

echo ""
echo -e "${BLUE}════════════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}${BOLD}Validation Summary${NC}"
echo -e "${BLUE}════════════════════════════════════════════════════════════════${NC}"
echo ""

if [ $ERRORS -eq 0 ]; then
    echo -e "${GREEN}✅ All critical components working${NC}"
else
    echo -e "${RED}❌ $ERRORS critical error(s) found${NC}"
fi

if [ $WARNINGS -gt 0 ]; then
    echo -e "${YELLOW}⚠️  $WARNINGS warning(s) (non-critical)${NC}"
fi

# Quick tests section
echo ""
echo -e "${BLUE}${BOLD}Quick Tests You Can Run:${NC}"
echo ""
echo "1. Test identity:"
echo -e "   ${CYAN}claude${NC}"
echo -e "   ${CYAN}> Who are you?${NC}"
echo ""
echo "2. Test expert activation:"
echo -e "   ${CYAN}> I need to optimize an HDF5 file${NC}"
echo ""
echo "3. Test multi-expert orchestration:"
echo -e "   ${CYAN}> Analyze my data and create publication figures${NC}"
echo ""

# Final status
if [ $ERRORS -eq 0 ]; then
    echo -e "${GREEN}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║    🚀 Warpio is ready! Start with: claude                   ║${NC}"
    echo -e "${GREEN}╚══════════════════════════════════════════════════════════════╝${NC}"
else
    echo -e "${RED}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${RED}║    🔧 Please fix errors above before using Warpio           ║${NC}"
    echo -e "${RED}╚══════════════════════════════════════════════════════════════╝${NC}"
fi

echo ""
echo -e "${CYAN}Powered by IOWarp.ai | Transforming Science Through Intelligent Computing${NC}"