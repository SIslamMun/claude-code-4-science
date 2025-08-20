#!/bin/bash
# ========================================================================
# WARPIO ONE-CLICK INSTALLER FOR CLAUDE CODE
# Transform Claude Code into a Scientific Computing Orchestrator
# Powered by IOWarp.ai
# ========================================================================

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Configuration
REPO_URL="https://github.com/iowarp/claude-code-4-science"
IOWARP_MCPS_URL="https://iowarp.github.io/iowarp-mcps"
VERSION="1.0.0"

# Installation mode
INTERACTIVE_MODE=false
TARGET_DIR=""

# Default selections for interactive mode
SELECTED_EXPERTS=("data-expert" "hpc-expert" "analysis-expert" "research-expert" "workflow-expert")
SELECTED_CORE_MCPS=("filesystem" "git" "zen" "numpy" "pandas")
SELECTED_SCIENTIFIC_MCPS=()
CONFIGURE_LOCAL_AI=true
ORCHESTRATION_MODE="parallel" # parallel or sequential

# ========================================================================
# HELPER FUNCTIONS
# ========================================================================

print_banner() {
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║          🚀 WARPIO FOR CLAUDE CODE INSTALLER v${VERSION}        ║${NC}"
    echo -e "${CYAN}║              Powered by IOWarp.ai                            ║${NC}"
    echo -e "${CYAN}║                                                              ║${NC}"
    echo -e "${CYAN}║  Transforming Claude Code into a Scientific Computing        ║${NC}"
    echo -e "${CYAN}║  Orchestrator with HPC, Data I/O, and AI capabilities       ║${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

show_usage() {
    echo "Usage: $0 [OPTIONS] [TARGET_DIRECTORY]"
    echo ""
    echo "Options:"
    echo "  --interactive, -i    Run in interactive mode for advanced configuration"
    echo "  --help, -h          Show this help message"
    echo "  --version, -v       Show version information"
    echo ""
    echo "Examples:"
    echo "  $0 /path/to/project              # One-click installation"
    echo "  $0 --interactive /path/to/project # Interactive configuration"
    echo ""
}

# ========================================================================
# PARSE ARGUMENTS
# ========================================================================

while [[ $# -gt 0 ]]; do
    case $1 in
        --interactive|-i)
            INTERACTIVE_MODE=true
            shift
            ;;
        --help|-h)
            print_banner
            show_usage
            exit 0
            ;;
        --version|-v)
            echo "Warpio Installer v${VERSION}"
            exit 0
            ;;
        *)
            TARGET_DIR="$1"
            shift
            ;;
    esac
done

print_banner

# ========================================================================
# INTERACTIVE MODE FUNCTIONS
# ========================================================================

select_experts() {
    echo -e "${BOLD}Select Expert Personas to Install:${NC}"
    echo -e "${YELLOW}Use arrow keys to navigate, space to select/deselect, enter to confirm${NC}"
    echo ""
    
    local experts=("data-expert" "hpc-expert" "analysis-expert" "research-expert" "workflow-expert")
    local descriptions=(
        "Data I/O optimization, HDF5, NetCDF, Zarr"
        "HPC job scheduling, MPI, performance profiling"
        "Statistical analysis, visualization, ML"
        "Paper writing, citations, reproducibility"
        "Pipeline orchestration, workflow automation"
    )
    
    SELECTED_EXPERTS=()
    
    for i in "${!experts[@]}"; do
        echo -e "${CYAN}[?]${NC} Install ${BOLD}${experts[$i]}${NC}?"
        echo -e "    ${descriptions[$i]}"
        read -p "    (Y/n): " choice
        case "$choice" in
            n|N) ;;
            *) SELECTED_EXPERTS+=("${experts[$i]}") ;;
        esac
        echo ""
    done
    
    if [ ${#SELECTED_EXPERTS[@]} -eq 0 ]; then
        echo -e "${YELLOW}⚠️  No experts selected. Using default set.${NC}"
        SELECTED_EXPERTS=("data-expert" "hpc-expert" "analysis-expert")
    fi
    
    echo -e "${GREEN}✓${NC} Selected experts: ${SELECTED_EXPERTS[*]}"
    echo ""
}

select_mcps() {
    echo -e "${BOLD}Configure MCP Tools:${NC}"
    echo ""
    
    # Core MCPs (main agent)
    echo -e "${CYAN}Core MCPs for Main Agent (recommended):${NC}"
    echo "  • filesystem - File operations"
    echo "  • git - Version control"
    echo "  • zen - AI orchestration"
    echo "  • numpy - Numerical computing"
    echo "  • pandas - Data manipulation"
    read -p "Install core MCPs? (Y/n): " choice
    case "$choice" in
        n|N) SELECTED_CORE_MCPS=() ;;
        *) SELECTED_CORE_MCPS=("filesystem" "git" "zen" "numpy" "pandas") ;;
    esac
    echo ""
    
    # Scientific MCPs based on selected experts
    echo -e "${CYAN}Scientific MCPs based on selected experts:${NC}"
    SELECTED_SCIENTIFIC_MCPS=()
    
    if [[ " ${SELECTED_EXPERTS[@]} " =~ " data-expert " ]]; then
        echo -e "${BOLD}Data Format MCPs:${NC}"
        local data_mcps=("hdf5" "netcdf" "adios" "zarr" "parquet")
        for mcp in "${data_mcps[@]}"; do
            read -p "  Install $mcp-mcp? (Y/n): " choice
            case "$choice" in
                n|N) ;;
                *) SELECTED_SCIENTIFIC_MCPS+=("$mcp") ;;
            esac
        done
    fi
    
    if [[ " ${SELECTED_EXPERTS[@]} " =~ " hpc-expert " ]]; then
        echo -e "${BOLD}HPC MCPs:${NC}"
        local hpc_mcps=("slurm" "mpi" "darshan")
        for mcp in "${hpc_mcps[@]}"; do
            read -p "  Install $mcp-mcp? (Y/n): " choice
            case "$choice" in
                n|N) ;;
                *) SELECTED_SCIENTIFIC_MCPS+=("$mcp") ;;
            esac
        done
    fi
    
    if [[ " ${SELECTED_EXPERTS[@]} " =~ " analysis-expert " ]]; then
        echo -e "${BOLD}Analysis MCPs:${NC}"
        read -p "  Install scipy-mcp? (Y/n): " choice
        case "$choice" in
            n|N) ;;
            *) SELECTED_SCIENTIFIC_MCPS+=("scipy") ;;
        esac
    fi
    
    if [[ " ${SELECTED_EXPERTS[@]} " =~ " research-expert " ]]; then
        echo -e "${BOLD}Research MCPs:${NC}"
        local research_mcps=("arxiv" "context7")
        for mcp in "${research_mcps[@]}"; do
            read -p "  Install $mcp-mcp? (Y/n): " choice
            case "$choice" in
                n|N) ;;
                *) SELECTED_SCIENTIFIC_MCPS+=("$mcp") ;;
            esac
        done
    fi
    
    echo ""
    echo -e "${GREEN}✓${NC} Core MCPs: ${SELECTED_CORE_MCPS[*]}"
    echo -e "${GREEN}✓${NC} Scientific MCPs: ${SELECTED_SCIENTIFIC_MCPS[*]}"
    echo ""
}

configure_orchestration() {
    echo -e "${BOLD}Configure Orchestration:${NC}"
    echo ""
    echo "How should multiple experts work together?"
    echo "  1) Parallel - Run independent experts simultaneously (faster)"
    echo "  2) Sequential - Chain experts for dependent tasks (safer)"
    echo "  3) Auto - Let Warpio decide based on task (recommended)"
    read -p "Select mode (1-3) [3]: " choice
    
    case "$choice" in
        1) ORCHESTRATION_MODE="parallel" ;;
        2) ORCHESTRATION_MODE="sequential" ;;
        *) ORCHESTRATION_MODE="auto" ;;
    esac
    
    echo -e "${GREEN}✓${NC} Orchestration mode: $ORCHESTRATION_MODE"
    echo ""
}

configure_local_ai() {
    echo -e "${BOLD}Configure Local AI:${NC}"
    echo ""
    read -p "Do you want to configure local AI integration? (Y/n): " choice
    case "$choice" in
        n|N) 
            CONFIGURE_LOCAL_AI=false
            ;;
        *)
            CONFIGURE_LOCAL_AI=true
            echo "Checking for local AI providers..."
            if lsof -i:1234 &> /dev/null; then
                echo -e "${GREEN}✓${NC} LM Studio detected on port 1234"
            elif command -v ollama &> /dev/null; then
                echo -e "${GREEN}✓${NC} Ollama detected"
            else
                echo -e "${YELLOW}⚠️${NC} No local AI detected. You can configure it later in .env"
            fi
            ;;
    esac
    echo ""
}

run_interactive_setup() {
    echo -e "${BOLD}🎮 Interactive Configuration Mode${NC}"
    echo -e "${YELLOW}Let's customize your Warpio installation!${NC}"
    echo ""
    
    select_experts
    select_mcps
    configure_orchestration
    configure_local_ai
    
    echo -e "${BOLD}Configuration Summary:${NC}"
    echo -e "  Experts: ${CYAN}${SELECTED_EXPERTS[*]}${NC}"
    echo -e "  Core MCPs: ${CYAN}${SELECTED_CORE_MCPS[*]}${NC}"
    echo -e "  Scientific MCPs: ${CYAN}${SELECTED_SCIENTIFIC_MCPS[*]}${NC}"
    echo -e "  Orchestration: ${CYAN}$ORCHESTRATION_MODE${NC}"
    echo -e "  Local AI: ${CYAN}$([[ $CONFIGURE_LOCAL_AI == true ]] && echo "Yes" || echo "No")${NC}"
    echo ""
    read -p "Proceed with installation? (Y/n): " confirm
    if [[ "$confirm" == "n" || "$confirm" == "N" ]]; then
        echo "Installation cancelled."
        exit 0
    fi
}

# ========================================================================
# STEP 1: Validate Environment
# ========================================================================

validate_environment() {
    echo -e "${BLUE}[1/9]${NC} Validating environment..."
    
    # Check if running from repo directory
    if [ ! -d ".warpio" ]; then
        echo -e "${RED}❌ Error: .warpio directory not found!${NC}"
        echo -e "   Please run this script from the claude-code-4-science repository:"
        echo -e "   ${YELLOW}git clone $REPO_URL${NC}"
        echo -e "   ${YELLOW}cd claude-code-4-science${NC}"
        echo -e "   ${YELLOW}./install-warpio.sh /path/to/your/project${NC}"
        exit 1
    fi
    
    # Get target directory
    if [ -z "$TARGET_DIR" ]; then
        read -p "Enter target directory path: " TARGET_DIR
    fi
    
    TARGET_DIR="${TARGET_DIR:-$(pwd)}"
    
    # Prevent installation in repo directory
    if [ "$TARGET_DIR" = "$(pwd)" ] && [ -d ".warpio" ]; then
        echo -e "${RED}❌ Error: Cannot install in the repository directory!${NC}"
        echo -e "   Please specify a target project directory:"
        echo -e "   ${YELLOW}./install-warpio.sh /path/to/your/project${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}✓${NC} Environment validated"
    echo -e "   Target: ${CYAN}$TARGET_DIR${NC}"
}

# ========================================================================
# STEP 2: Check Prerequisites
# ========================================================================

check_prerequisites() {
    echo -e "${BLUE}[2/9]${NC} Checking prerequisites..."
    
    local missing_deps=()
    
    # Check UV
    if ! command -v uv &> /dev/null; then
        echo -e "${YELLOW}⚠️  UV not found. Installing...${NC}"
        curl -LsSf https://astral.sh/uv/install.sh | sh
        export PATH="$HOME/.local/bin:$PATH"
        echo -e "${GREEN}✓${NC} UV installed"
    else
        echo -e "${GREEN}✓${NC} UV detected: $(which uv)"
    fi
    
    # Check Claude CLI
    if ! command -v claude &> /dev/null; then
        echo -e "${YELLOW}⚠️  Claude CLI not found${NC}"
        echo -e "   Install with: ${CYAN}npm install -g @anthropic-ai/claude-cli${NC}"
        missing_deps+=("claude-cli")
    else
        echo -e "${GREEN}✓${NC} Claude CLI detected: $(which claude)"
    fi
    
    # Check jq for JSON processing
    if ! command -v jq &> /dev/null; then
        echo -e "${YELLOW}⚠️  jq not found. Installing...${NC}"
        if [[ "$OSTYPE" == "linux-gnu"* ]]; then
            sudo apt-get update && sudo apt-get install -y jq
        elif [[ "$OSTYPE" == "darwin"* ]]; then
            brew install jq
        fi
        echo -e "${GREEN}✓${NC} jq installed"
    else
        echo -e "${GREEN}✓${NC} jq detected"
    fi
    
    if [ ${#missing_deps[@]} -gt 0 ]; then
        echo -e "${YELLOW}⚠️  Some dependencies are missing: ${missing_deps[*]}${NC}"
        echo -e "   Installation will continue, but some features may not work."
        read -p "   Continue anyway? (y/N): " continue_anyway
        if [[ "$continue_anyway" != "y" && "$continue_anyway" != "Y" ]]; then
            exit 1
        fi
    fi
}

# ========================================================================
# STEP 3: Create Target Directory Structure
# ========================================================================

setup_directory_structure() {
    echo -e "${BLUE}[3/9]${NC} Setting up Warpio in: ${CYAN}$TARGET_DIR${NC}"
    
    mkdir -p "$TARGET_DIR"
    
    # Check for existing .claude directory
    if [ -d "$TARGET_DIR/.claude" ]; then
        echo -e "${YELLOW}⚠️  .claude directory exists. Backup? (y/N): ${NC}"
        read -r BACKUP
        if [[ "$BACKUP" =~ ^[Yy]$ ]]; then
            BACKUP_DIR="$TARGET_DIR/.claude.backup.$(date +%Y%m%d%H%M%S)"
            mv "$TARGET_DIR/.claude" "$BACKUP_DIR"
            echo -e "${GREEN}✓${NC} Backed up to $BACKUP_DIR"
        else
            echo -e "${RED}❌ Installation cancelled${NC}"
            exit 1
        fi
    fi
    
    # Copy .warpio to .claude, excluding CLAUDE.md if it exists
    rsync -av --exclude='CLAUDE.md' .warpio/ "$TARGET_DIR/.claude/"
    echo -e "${GREEN}✓${NC} Warpio configuration installed"
}

# ========================================================================
# STEP 4: Handle CLAUDE.md Integration
# ========================================================================

configure_claude_md() {
    echo -e "${BLUE}[4/9]${NC} Configuring CLAUDE.md..."
    
    WARPIO_PROMPT="$TARGET_DIR/.claude/WARPIO.md"
    USER_CLAUDE_MD="$TARGET_DIR/CLAUDE.md"
    
    # Check if user has existing CLAUDE.md
    if [ -f "$USER_CLAUDE_MD" ]; then
        echo -e "${YELLOW}⚠️  Existing CLAUDE.md found. Merging with Warpio...${NC}"
        
        # Create backup
        cp "$USER_CLAUDE_MD" "$USER_CLAUDE_MD.backup.$(date +%Y%m%d%H%M%S)"
        
        # Prepend Warpio prompt to existing CLAUDE.md
        {
            cat "$WARPIO_PROMPT"
            echo ""
            echo "# === USER'S ORIGINAL CLAUDE.MD CONTENT BELOW ==="
            echo ""
            cat "$USER_CLAUDE_MD"
        } > "$USER_CLAUDE_MD.new"
        
        mv "$USER_CLAUDE_MD.new" "$USER_CLAUDE_MD"
        echo -e "${GREEN}✓${NC} Warpio identity prepended to existing CLAUDE.md"
    else
        # No existing CLAUDE.md, copy Warpio as CLAUDE.md
        cp "$WARPIO_PROMPT" "$USER_CLAUDE_MD"
        echo -e "${GREEN}✓${NC} Created CLAUDE.md with Warpio identity"
    fi
}

# ========================================================================
# STEP 5: Configure Environment
# ========================================================================

configure_environment() {
    echo -e "${BLUE}[5/9]${NC} Configuring environment..."
    
    # Copy .env.example to .env
    if [ -f "$TARGET_DIR/.env" ]; then
        echo -e "${YELLOW}⚠️  .env exists. Overwrite? (y/N): ${NC}"
        read -r OVERWRITE
        if [[ "$OVERWRITE" =~ ^[Yy]$ ]]; then
            cp ".warpio/.env.example" "$TARGET_DIR/.env"
        fi
    else
        cp ".warpio/.env.example" "$TARGET_DIR/.env"
    fi
    
    # Configure orchestration mode
    sed -i.bak "s/ORCHESTRATION_MODE=.*/ORCHESTRATION_MODE=$ORCHESTRATION_MODE/" "$TARGET_DIR/.env"
    
    # Detect and configure local AI if requested
    if [[ $CONFIGURE_LOCAL_AI == true ]]; then
        echo -e "   Detecting local AI..."
        
        if lsof -i:1234 &> /dev/null || timeout 2 curl -s "http://192.168.86.20:1234/v1/models" &> /dev/null; then
            echo -e "${GREEN}✓${NC} LM Studio detected"
            sed -i.bak 's/LOCAL_AI_PROVIDER=.*/LOCAL_AI_PROVIDER=lmstudio/' "$TARGET_DIR/.env"
            
            if timeout 2 curl -s "http://192.168.86.20:1234/v1/models" &> /dev/null; then
                sed -i.bak 's|LMSTUDIO_API_URL=.*|LMSTUDIO_API_URL=http://192.168.86.20:1234/v1|' "$TARGET_DIR/.env"
            else
                sed -i.bak 's|LMSTUDIO_API_URL=.*|LMSTUDIO_API_URL=http://localhost:1234/v1|' "$TARGET_DIR/.env"
            fi
        elif command -v ollama &> /dev/null; then
            echo -e "${GREEN}✓${NC} Ollama detected"
            sed -i.bak 's/LOCAL_AI_PROVIDER=.*/LOCAL_AI_PROVIDER=ollama/' "$TARGET_DIR/.env"
        else
            echo -e "${YELLOW}⚠️${NC} No local AI detected (cloud fallback will be used)"
        fi
    fi
    
    rm -f "$TARGET_DIR/.env.bak"
}

# ========================================================================
# STEP 6: Configure Expert Agents
# ========================================================================

configure_experts() {
    echo -e "${BLUE}[6/9]${NC} Configuring expert agents..."
    
    # Remove unselected experts
    for expert_file in "$TARGET_DIR"/.claude/agents/*.md; do
        expert_name=$(basename "$expert_file" .md)
        if [[ ! " ${SELECTED_EXPERTS[@]} " =~ " ${expert_name} " ]]; then
            rm "$expert_file"
            echo -e "   Removed $expert_name (not selected)"
        fi
    done
    
    echo -e "${GREEN}✓${NC} Configured ${#SELECTED_EXPERTS[@]} expert agents"
}

# ========================================================================
# STEP 7: Install MCPs
# ========================================================================

create_mcp_configs() {
    echo -e "${BLUE}[7/9]${NC} Creating MCP configurations..."
    
    # Create MCP wrapper scripts for env loading
    mkdir -p "$TARGET_DIR/.claude/scripts/mcp-wrappers"
    
    # Create zen-mcp wrapper
    cat > "$TARGET_DIR/.claude/scripts/mcp-wrappers/zen-wrapper.sh" << 'EOF'
#!/bin/bash
# Load environment variables
[ -f .env ] && export $(grep -v '^#' .env | xargs) 2>/dev/null

# Set zen-mcp environment
export CUSTOM_PROVIDER="${LOCAL_AI_PROVIDER:-lmstudio}"
export CUSTOM_API_URL="${LMSTUDIO_API_URL:-http://localhost:1234/v1}"
export CUSTOM_MODEL_NAME="${LMSTUDIO_MODEL:-qwen3-4b-instruct-2507}"

# Launch zen-mcp
exec uvx --from git+https://github.com/BeehiveInnovations/zen-mcp-server.git zen-mcp-server
EOF
    chmod +x "$TARGET_DIR/.claude/scripts/mcp-wrappers/zen-wrapper.sh"
    
    # Generate MCP configuration based on selections
    cat > "$TARGET_DIR/.claude/mcp-configs/warpio-mcps.json" << EOF
{
  "mcps": {
EOF
    
    # Add core MCPs
    local first=true
    for mcp in "${SELECTED_CORE_MCPS[@]}"; do
        if [ "$first" = false ]; then
            echo "," >> "$TARGET_DIR/.claude/mcp-configs/warpio-mcps.json"
        fi
        first=false
        
        if [ "$mcp" = "zen" ]; then
            cat >> "$TARGET_DIR/.claude/mcp-configs/warpio-mcps.json" << EOF
    "zen": {
      "command": "$TARGET_DIR/.claude/scripts/mcp-wrappers/zen-wrapper.sh",
      "args": []
    }
EOF
        else
            cat >> "$TARGET_DIR/.claude/mcp-configs/warpio-mcps.json" << EOF
    "$mcp": {
      "command": "uvx",
      "args": ["--from", "git+https://github.com/iowarp/$mcp-mcp.git", "$mcp-mcp"]
    }
EOF
        fi
    done
    
    # Add scientific MCPs
    for mcp in "${SELECTED_SCIENTIFIC_MCPS[@]}"; do
        echo "," >> "$TARGET_DIR/.claude/mcp-configs/warpio-mcps.json"
        
        if [ "$mcp" = "context7" ]; then
            cat >> "$TARGET_DIR/.claude/mcp-configs/warpio-mcps.json" << EOF
    "context7": {
      "command": "uvx",
      "args": ["--from", "git+https://github.com/context7/context7-mcp.git", "context7-mcp"]
    }
EOF
        else
            cat >> "$TARGET_DIR/.claude/mcp-configs/warpio-mcps.json" << EOF
    "$mcp": {
      "command": "uvx",
      "args": ["--from", "git+https://github.com/iowarp/$mcp-mcp.git", "$mcp-mcp"]
    }
EOF
        fi
    done
    
    cat >> "$TARGET_DIR/.claude/mcp-configs/warpio-mcps.json" << EOF
  }
}
EOF
    
    echo -e "${GREEN}✓${NC} MCP configurations created"
    echo -e "   Core MCPs: ${#SELECTED_CORE_MCPS[@]}"
    echo -e "   Scientific MCPs: ${#SELECTED_SCIENTIFIC_MCPS[@]}"
    
    # Create MCP installation script
    cat > "$TARGET_DIR/.claude/scripts/install-mcps.sh" << 'EOF'
#!/bin/bash
echo "Installing configured MCPs..."

# Parse warpio-mcps.json and attempt to install each MCP
MCPs=$(jq -r '.mcps | keys[]' .claude/mcp-configs/warpio-mcps.json 2>/dev/null)

for MCP in $MCPs; do
    echo "  Checking $MCP..."
    if [ "$MCP" = "zen" ]; then
        uvx --from git+https://github.com/BeehiveInnovations/zen-mcp-server.git zen-mcp-server --version 2>/dev/null || echo "    [Check zen-mcp-server repository]"
    elif [ "$MCP" = "context7" ]; then
        uvx --from git+https://github.com/context7/context7-mcp.git context7-mcp --version 2>/dev/null || echo "    [Check context7 repository]"
    else
        uvx --from "git+https://github.com/iowarp/$MCP-mcp.git" $MCP-mcp --version 2>/dev/null || echo "    [Will be available when published]"
    fi
done

echo "MCP installation check complete!"
EOF
    chmod +x "$TARGET_DIR/.claude/scripts/install-mcps.sh"
}

# ========================================================================
# STEP 8: Make Scripts Executable and Create Utilities
# ========================================================================

finalize_installation() {
    echo -e "${BLUE}[8/9]${NC} Finalizing installation..."
    
    # Make all scripts executable
    find "$TARGET_DIR/.claude" -type f \( -name "*.sh" -o -name "*.py" \) -exec chmod +x {} \;
    echo -e "${GREEN}✓${NC} Scripts made executable"
    
    # Create validation script
    cat > "$TARGET_DIR/validate-warpio.sh" << 'EOF'
#!/bin/bash
echo "=== Warpio Installation Validator ==="
echo ""

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Check .claude directory
[ -d ".claude" ] && echo -e "${GREEN}✅ .claude directory exists${NC}" || echo -e "${RED}❌ .claude directory missing${NC}"

# Check CLAUDE.md
if [ -f "CLAUDE.md" ]; then
    echo -e "${GREEN}✅ CLAUDE.md exists${NC}"
    grep -q "WARPIO" CLAUDE.md && echo -e "${GREEN}✅ Warpio identity found${NC}" || echo -e "${RED}❌ Warpio identity missing${NC}"
else
    echo -e "${RED}❌ CLAUDE.md missing${NC}"
fi

# Check .env
[ -f ".env" ] && echo -e "${GREEN}✅ .env file exists${NC}" || echo -e "${YELLOW}⚠️  .env file missing${NC}"

# Check hooks
HOOKS=$(find .claude/hooks -name "*.sh" -o -name "*.py" 2>/dev/null | wc -l)
echo -e "${GREEN}✅ Found $HOOKS hook scripts${NC}"

# Check agents
AGENTS=$(ls .claude/agents/*.md 2>/dev/null | wc -l)
echo -e "${GREEN}✅ Found $AGENTS expert agents${NC}"

# Check MCPs
MCP_COUNT=$(jq '.mcps | length' .claude/mcp-configs/warpio-mcps.json 2>/dev/null || echo 0)
echo -e "${GREEN}✅ $MCP_COUNT MCPs configured${NC}"

# Test local AI if configured
if [ -f ".env" ]; then
    source .env
    if [ "$LOCAL_AI_PROVIDER" = "lmstudio" ]; then
        echo -n "Testing LM Studio connection... "
        if timeout 2 curl -s "$LMSTUDIO_API_URL/models" > /dev/null 2>&1; then
            echo -e "${GREEN}✅ Connected${NC}"
        else
            echo -e "${YELLOW}⚠️  Not available${NC}"
        fi
    elif [ "$LOCAL_AI_PROVIDER" = "ollama" ]; then
        echo -n "Testing Ollama... "
        if command -v ollama > /dev/null 2>&1; then
            echo -e "${GREEN}✅ Available${NC}"
        else
            echo -e "${YELLOW}⚠️  Not found${NC}"
        fi
    fi
fi

echo ""
echo "=== Validation Complete ==="
echo ""
echo "To start using Warpio:"
echo "  1. cd $(pwd)"
echo "  2. claude"
echo ""
echo "Or use the 'warpio' alias if configured"
EOF
    chmod +x "$TARGET_DIR/validate-warpio.sh"
    
    # Create quick start guide
    cat > "$TARGET_DIR/WARPIO-QUICKSTART.md" << EOF
# 🚀 Warpio Quick Start Guide

## Your Configuration
- **Experts**: ${SELECTED_EXPERTS[*]}
- **Core MCPs**: ${SELECTED_CORE_MCPS[*]}
- **Scientific MCPs**: ${SELECTED_SCIENTIFIC_MCPS[*]}
- **Orchestration**: $ORCHESTRATION_MODE
- **Local AI**: $([[ $CONFIGURE_LOCAL_AI == true ]] && echo "Configured" || echo "Not configured")

## Starting Warpio
\`\`\`bash
cd $TARGET_DIR
claude
\`\`\`

## Test Your Installation

### 1. Identity Test
\`\`\`
You: Who are you?
\`\`\`
Expected: Should identify as Warpio with scientific computing capabilities

### 2. Expert Army Test
\`\`\`
You: Analyze my data and create publication figures
\`\`\`
Expected: Multiple experts working in $ORCHESTRATION_MODE mode

### 3. Local AI Test (if configured)
\`\`\`
You: Use zen to analyze this code: print("hello")
\`\`\`
Expected: Delegates to local AI for analysis

## Available Commands
- \`/warpio-status\` - Check system status
- \`/orchestrate-experts <task>\` - Multi-expert collaboration
- \`/output-style scientific-computing\` - Switch output mode

## Expert Activation Keywords
EOF
    
    for expert in "${SELECTED_EXPERTS[@]}"; do
        case "$expert" in
            data-expert)
                echo "- **Data Expert**: HDF5, NetCDF, Zarr, data format, I/O optimization" >> "$TARGET_DIR/WARPIO-QUICKSTART.md"
                ;;
            hpc-expert)
                echo "- **HPC Expert**: MPI, SLURM, parallel, cluster, performance" >> "$TARGET_DIR/WARPIO-QUICKSTART.md"
                ;;
            analysis-expert)
                echo "- **Analysis Expert**: plot, statistics, analyze, visualize" >> "$TARGET_DIR/WARPIO-QUICKSTART.md"
                ;;
            research-expert)
                echo "- **Research Expert**: paper, citation, reproducible, documentation" >> "$TARGET_DIR/WARPIO-QUICKSTART.md"
                ;;
            workflow-expert)
                echo "- **Workflow Expert**: pipeline, workflow, automation, orchestrate" >> "$TARGET_DIR/WARPIO-QUICKSTART.md"
                ;;
        esac
    done
    
    cat >> "$TARGET_DIR/WARPIO-QUICKSTART.md" << 'EOF'

## Troubleshooting
- Run validation: `./validate-warpio.sh`
- Check logs: `/tmp/warpio-workflows/`
- Update MCPs: `.claude/scripts/install-mcps.sh`
- Edit config: `.env`

## Support
- GitHub: https://github.com/iowarp/claude-code-4-science
- Docs: https://iowarp.github.io
EOF
}

# ========================================================================
# STEP 9: Create Shell Alias
# ========================================================================

create_shell_alias() {
    echo -e "${BLUE}[9/9]${NC} Creating 'warpio' command..."
    
    # Detect shell and create alias
    SHELL_RC=""
    DETECTED_SHELL=""
    
    if [ -n "$SHELL" ]; then
        case "$SHELL" in
            */bash) 
                SHELL_RC="$HOME/.bashrc"
                DETECTED_SHELL="bash"
                ;;
            */zsh)
                SHELL_RC="$HOME/.zshrc"
                DETECTED_SHELL="zsh"
                ;;
            */fish)
                SHELL_RC="$HOME/.config/fish/config.fish"
                DETECTED_SHELL="fish"
                ;;
        esac
    fi
    
    # Fallback: check for existing RC files
    if [ -z "$SHELL_RC" ]; then
        if [ -f "$HOME/.zshrc" ]; then
            SHELL_RC="$HOME/.zshrc"
            DETECTED_SHELL="zsh"
        elif [ -f "$HOME/.bashrc" ]; then
            SHELL_RC="$HOME/.bashrc"
            DETECTED_SHELL="bash"
        fi
    fi
    
    if [ -n "$SHELL_RC" ]; then
        echo -e "   Detected shell: ${CYAN}$DETECTED_SHELL${NC}"
        
        if [ "$DETECTED_SHELL" = "fish" ]; then
            mkdir -p "$HOME/.config/fish/functions"
            cat > "$HOME/.config/fish/functions/warpio.fish" << EOF
function warpio
    cd $TARGET_DIR && claude \$argv
end
EOF
            echo -e "${GREEN}✓${NC} Created 'warpio' function for fish"
        else
            # Remove old alias if exists
            sed -i.bak '/alias warpio=/d' "$SHELL_RC" 2>/dev/null || true
            
            # Add new alias
            echo "" >> "$SHELL_RC"
            echo "# Warpio - Scientific Computing Orchestrator for Claude Code" >> "$SHELL_RC"
            echo "alias warpio='cd $TARGET_DIR && claude'" >> "$SHELL_RC"
            
            echo -e "${GREEN}✓${NC} Created 'warpio' alias in $SHELL_RC"
        fi
        
        echo -e "   ${YELLOW}Run: source $SHELL_RC${NC}"
    else
        echo -e "${YELLOW}⚠️  Could not detect shell${NC}"
        echo -e "   Add this alias manually:"
        echo -e "   ${CYAN}alias warpio='cd $TARGET_DIR && claude'${NC}"
    fi
}

# ========================================================================
# MAIN INSTALLATION FLOW
# ========================================================================

# Run interactive setup if requested
if [ "$INTERACTIVE_MODE" = true ]; then
    run_interactive_setup
fi

# Execute installation steps
validate_environment
check_prerequisites
setup_directory_structure
configure_claude_md
configure_environment
configure_experts
create_mcp_configs
finalize_installation
create_shell_alias

# ========================================================================
# FINAL OUTPUT
# ========================================================================

echo ""
echo -e "${GREEN}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║              🎉 WARPIO INSTALLATION COMPLETE! 🎉              ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${BOLD}Installation Summary:${NC}"
echo -e "${CYAN}📍 Location:${NC} $TARGET_DIR"
echo -e "${CYAN}📋 Configuration:${NC} $TARGET_DIR/.env"
echo -e "${CYAN}🧬 Identity:${NC} $TARGET_DIR/CLAUDE.md"
echo -e "${CYAN}👥 Experts:${NC} ${#SELECTED_EXPERTS[@]} installed"
echo -e "${CYAN}🔧 MCPs:${NC} $((${#SELECTED_CORE_MCPS[@]} + ${#SELECTED_SCIENTIFIC_MCPS[@]})) configured"
echo -e "${CYAN}🎯 Mode:${NC} $ORCHESTRATION_MODE orchestration"
echo ""
echo -e "${MAGENTA}🚀 To start using Warpio:${NC}"
echo -e "   1. ${YELLOW}source $SHELL_RC${NC} (reload shell)"
echo -e "   2. ${YELLOW}warpio${NC} (launches Claude in Warpio mode)"
echo -e "   OR"
echo -e "   ${YELLOW}cd $TARGET_DIR && claude${NC}"
echo ""
echo -e "${MAGENTA}📚 Next Steps:${NC}"
echo -e "   • Review: ${CYAN}$TARGET_DIR/WARPIO-QUICKSTART.md${NC}"
echo -e "   • Validate: ${CYAN}$TARGET_DIR/validate-warpio.sh${NC}"
echo -e "   • Configure: ${CYAN}$TARGET_DIR/.env${NC}"
echo -e "   • Test MCPs: ${CYAN}$TARGET_DIR/.claude/scripts/install-mcps.sh${NC}"
echo ""
echo -e "${BOLD}🔬 Warpio is ready to orchestrate your scientific computing army!${NC}"
echo -e "${BLUE}   Experience the power of coordinated AI experts working in harmony${NC}"
echo -e "${BLUE}   Powered by IOWarp.ai | Transforming Science Through Intelligent Computing${NC}"
echo ""