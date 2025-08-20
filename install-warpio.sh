#!/bin/bash
# ========================================================================
# WARPIO ONE-CLICK INSTALLER FOR CLAUDE CODE
# Enhances Claude Code with Scientific Computing Superpowers
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
VERSION="1.0.0"

# Installation mode
INTERACTIVE_MODE=false
TARGET_DIR=""

# Default selections for non-interactive mode
SELECTED_EXPERTS=("data-expert" "hpc-expert" "analysis-expert" "research-expert" "workflow-expert")
SELECTED_CORE_MCPS=("filesystem" "git" "zen" "numpy" "pandas")
SELECTED_SCIENTIFIC_MCPS=()
CONFIGURE_LOCAL_AI=true
ORCHESTRATION_MODE="parallel"

# ========================================================================
# HELPER FUNCTIONS
# ========================================================================

print_banner() {
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║          🚀 WARPIO FOR CLAUDE CODE INSTALLER v${VERSION}        ║${NC}"
    echo -e "${CYAN}║              Powered by IOWarp.ai                            ║${NC}"
    echo -e "${CYAN}║                                                              ║${NC}"
    echo -e "${CYAN}║  Enhancing Claude Code with Scientific Computing             ║${NC}"
    echo -e "${CYAN}║  Superpowers: HPC, Data I/O, and AI Orchestration           ║${NC}"
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
    echo "  $0 myproject              # One-click installation to 'myproject' folder"
    echo "  $0 /path/to/project       # Install to specific path"
    echo "  $0 --interactive project  # Interactive configuration"
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
# STEP 1: Validate Environment
# ========================================================================

validate_environment() {
    echo -e "${BLUE}[1/10]${NC} Validating environment..."
    
    # Get absolute path of the installer script and source directory
    INSTALLER_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    WARPIO_SOURCE="$INSTALLER_DIR/.warpio"
    
    # Check if running from repo directory
    if [ ! -d "$WARPIO_SOURCE" ]; then
        echo -e "${RED}❌ Error: .warpio directory not found!${NC}"
        echo -e "   Please run this script from the claude-code-4-science repository:"
        echo -e "   ${YELLOW}git clone $REPO_URL${NC}"
        echo -e "   ${YELLOW}cd claude-code-4-science${NC}"
        echo -e "   ${YELLOW}./install-warpio.sh yourproject${NC}"
        exit 1
    fi
    
    # Get target directory
    if [ -z "$TARGET_DIR" ]; then
        read -p "Enter target directory name: " TARGET_DIR
    fi
    
    # Handle relative or absolute paths
    if [[ "$TARGET_DIR" = /* ]]; then
        # Absolute path provided
        TARGET_DIR="$TARGET_DIR"
    else
        # Relative path - create in current directory
        TARGET_DIR="$(pwd)/$TARGET_DIR"
    fi
    
    # Normalize the path
    TARGET_DIR="$(realpath -m "$TARGET_DIR")"
    
    # Prevent installation in repo directory
    if [ "$TARGET_DIR" = "$INSTALLER_DIR" ]; then
        echo -e "${RED}❌ Error: Cannot install in the repository directory!${NC}"
        echo -e "   Please specify a different target directory:"
        echo -e "   ${YELLOW}./install-warpio.sh myproject${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}✓${NC} Environment validated"
    echo -e "   Source: ${CYAN}$WARPIO_SOURCE${NC}"
    echo -e "   Target: ${CYAN}$TARGET_DIR${NC}"
}

# ========================================================================
# STEP 2: Check Prerequisites
# ========================================================================

check_prerequisites() {
    echo -e "${BLUE}[2/10]${NC} Checking prerequisites..."
    
    local missing_deps=()
    
    # Check UV
    if ! command -v uv &> /dev/null; then
        echo -e "${YELLOW}⚠️  UV not found. Will install if needed...${NC}"
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
        echo -e "${YELLOW}⚠️  jq not found (optional but recommended)${NC}"
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
    echo -e "${BLUE}[3/10]${NC} Setting up Warpio in: ${CYAN}$TARGET_DIR${NC}"
    
    # Create target directory
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
    
    # Copy .warpio to .claude (excluding WARPIO.md as it goes to CLAUDE.md)
    rsync -av --exclude='WARPIO.md' "$WARPIO_SOURCE/" "$TARGET_DIR/.claude/"
    echo -e "${GREEN}✓${NC} Warpio configuration installed to .claude"
}

# ========================================================================
# STEP 4: Handle CLAUDE.md (Warpio Identity)
# ========================================================================

configure_claude_md() {
    echo -e "${BLUE}[4/10]${NC} Configuring CLAUDE.md..."
    
    WARPIO_PROMPT="$WARPIO_SOURCE/WARPIO.md"
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
            echo "### USER'S ORIGINAL CLAUDE.MD FOLLOWS BELOW (IF EXISTS):"
            echo "---"
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
    echo -e "${BLUE}[5/10]${NC} Configuring environment..."
    
    # Copy .env.example to .env
    if [ -f "$TARGET_DIR/.env" ]; then
        echo -e "${YELLOW}⚠️  .env exists. Overwrite? (y/N): ${NC}"
        read -r OVERWRITE
        if [[ "$OVERWRITE" =~ ^[Yy]$ ]]; then
            cp "$WARPIO_SOURCE/.env.example" "$TARGET_DIR/.env"
        fi
    else
        cp "$WARPIO_SOURCE/.env.example" "$TARGET_DIR/.env"
    fi
    
    # Detect and configure local AI
    echo -e "   Detecting local AI..."
    
    if lsof -i:1234 &> /dev/null; then
        echo -e "${GREEN}✓${NC} LM Studio detected on port 1234"
    elif command -v ollama &> /dev/null; then
        echo -e "${GREEN}✓${NC} Ollama detected"
    else
        echo -e "${YELLOW}⚠️${NC} No local AI detected (configure later in .env)"
    fi
    
    echo -e "${GREEN}✓${NC} Environment configuration created"
}

# ========================================================================
# STEP 6: Configure Expert Agents
# ========================================================================

configure_experts() {
    echo -e "${BLUE}[6/10]${NC} Configuring expert agents..."
    
    # In non-interactive mode, keep all experts
    echo -e "${GREEN}✓${NC} Configured ${#SELECTED_EXPERTS[@]} expert agents"
}

# ========================================================================
# STEP 7: Create MCP Configurations
# ========================================================================

create_mcp_configs() {
    echo -e "${BLUE}[7/10]${NC} Creating MCP configurations..."
    
    # Create MCP wrapper scripts directory
    mkdir -p "$TARGET_DIR/.claude/scripts/mcp-wrappers"
    
    # Create zen-mcp wrapper that works from target directory
    cat > "$TARGET_DIR/.claude/scripts/mcp-wrappers/zen-wrapper.sh" << 'EOF'
#!/bin/bash
# Zen-MCP wrapper - works from project root
# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Project root is 3 levels up from mcp-wrappers
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"

# Change to project directory
cd "$PROJECT_ROOT"

# Load environment variables from project root
[ -f .env ] && export $(grep -v '^#' .env | xargs) 2>/dev/null

# Set zen-mcp environment
export CUSTOM_PROVIDER="${LOCAL_AI_PROVIDER:-lmstudio}"
export CUSTOM_API_URL="${LMSTUDIO_API_URL:-http://localhost:1234/v1}"
export CUSTOM_MODEL_NAME="${LMSTUDIO_MODEL:-qwen3-4b-instruct-2507}"

# Launch zen-mcp
exec uvx --from git+https://github.com/BeehiveInnovations/zen-mcp-server.git zen-mcp-server
EOF
    chmod +x "$TARGET_DIR/.claude/scripts/mcp-wrappers/zen-wrapper.sh"
    
    # Create MCP configuration
    cat > "$TARGET_DIR/.claude/mcp-configs/warpio-mcps.json" << EOF
{
  "mcps": {
    "zen": {
      "command": "$TARGET_DIR/.claude/scripts/mcp-wrappers/zen-wrapper.sh",
      "args": []
    }
  }
}
EOF
    
    echo -e "${GREEN}✓${NC} MCP configurations created"
}

# ========================================================================
# STEP 8: Fix Script Paths
# ========================================================================

fix_script_paths() {
    echo -e "${BLUE}[8/10]${NC} Fixing script paths for target directory..."
    
    # Make all scripts executable
    find "$TARGET_DIR/.claude" -type f \( -name "*.sh" -o -name "*.py" \) -exec chmod +x {} \;
    
    # Ensure Python hooks have proper shebang
    for py_hook in $(find "$TARGET_DIR/.claude/hooks" -name "*.py" 2>/dev/null); do
        if ! head -1 "$py_hook" | grep -q "^#!/usr/bin/env python3"; then
            echo '#!/usr/bin/env python3' > "${py_hook}.tmp"
            tail -n +2 "$py_hook" >> "${py_hook}.tmp"
            mv "${py_hook}.tmp" "$py_hook"
            chmod +x "$py_hook"
        fi
    done
    
    echo -e "${GREEN}✓${NC} Scripts configured for target directory"
}

# ========================================================================
# STEP 9: Create Validation Script
# ========================================================================

create_validation_script() {
    echo -e "${BLUE}[9/10]${NC} Creating validation script..."
    
    # Copy the validation script from .warpio/scripts
    if [ -f "$WARPIO_SOURCE/scripts/validate-warpio.sh" ]; then
        cp "$WARPIO_SOURCE/scripts/validate-warpio.sh" "$TARGET_DIR/validate-warpio.sh"
        chmod +x "$TARGET_DIR/validate-warpio.sh"
        echo -e "${GREEN}✓${NC} Validation script created"
    else
        echo -e "${YELLOW}⚠️${NC} Validation script not found in source, skipping"
    fi
}

# ========================================================================
# STEP 10: Create Quick Start Guide
# ========================================================================

create_quickstart() {
    echo -e "${BLUE}[10/10]${NC} Creating quick start guide..."
    
    cat > "$TARGET_DIR/WARPIO-QUICKSTART.md" << EOF
# 🚀 Warpio Quick Start Guide

Welcome to your Warpio-enhanced Claude Code environment!

## What is Warpio?

Warpio is an enhancement layer that adds scientific computing superpowers to Claude Code.
You still have all of Claude Code's capabilities, plus:

- 🧬 Scientific data format expertise (HDF5, NetCDF, Zarr)
- 🖥️ HPC job scheduling and parallel computing
- 📊 Advanced data analysis and visualization
- 🤖 Multi-expert AI orchestration
- 🔬 Research workflow automation

## Getting Started

### Start Claude Code with Warpio
\`\`\`bash
cd $TARGET_DIR
claude
\`\`\`

### Test Your Installation

1. **Identity Test**
   Ask: "Who are you?"
   Expected: Claude Code will identify with Warpio enhancements

2. **Expert Activation**
   Ask: "Help me optimize an HDF5 file"
   Expected: Data expert activates automatically

3. **Multi-Expert Orchestration**
   Ask: "Analyze my simulation data and create publication figures"
   Expected: Multiple experts work together

## Expert Activation Keywords

- **Data Expert**: HDF5, NetCDF, Zarr, data format, I/O
- **HPC Expert**: MPI, SLURM, parallel, cluster, performance
- **Analysis Expert**: plot, statistics, visualize, analyze
- **Research Expert**: paper, citation, reproducible
- **Workflow Expert**: pipeline, automation, orchestrate

## Configuration

- Environment settings: \`.env\`
- Expert configs: \`.claude/agents/\`
- MCP tools: \`.claude/mcp-configs/\`

## Validation

Run the validation script to check your installation:
\`\`\`bash
./validate-warpio.sh
\`\`\`

## Important Notes

- Warpio enhances Claude Code, it doesn't replace it
- All your normal Claude Code features still work
- Scientific features activate automatically based on context
- Local AI integration available (configure in .env)

## Support

- GitHub: https://github.com/iowarp/claude-code-4-science
- Documentation: https://iowarp.github.io

---
Powered by IOWarp.ai | Enhancing Science Through Intelligent Computing
EOF
    
    echo -e "${GREEN}✓${NC} Quick start guide created"
}

# ========================================================================
# MAIN INSTALLATION FLOW
# ========================================================================

# Execute installation steps
validate_environment
check_prerequisites
setup_directory_structure
configure_claude_md
configure_environment
configure_experts
create_mcp_configs
fix_script_paths
create_validation_script
create_quickstart

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
echo -e "${CYAN}🧬 Identity:${NC} $TARGET_DIR/CLAUDE.md"
echo -e "${CYAN}📋 Configuration:${NC} $TARGET_DIR/.env"
echo -e "${CYAN}✅ Validation:${NC} $TARGET_DIR/validate-warpio.sh"
echo -e "${CYAN}📚 Guide:${NC} $TARGET_DIR/WARPIO-QUICKSTART.md"
echo ""
echo -e "${MAGENTA}🚀 To start using Warpio:${NC}"
echo -e "   ${YELLOW}cd $TARGET_DIR${NC}"
echo -e "   ${YELLOW}claude${NC}"
echo ""
echo -e "${MAGENTA}📖 First Steps:${NC}"
echo -e "   1. Review: ${CYAN}WARPIO-QUICKSTART.md${NC}"
echo -e "   2. Validate: ${CYAN}./validate-warpio.sh${NC}"
echo -e "   3. Configure: ${CYAN}.env${NC} (for local AI)"
echo ""
echo -e "${BOLD}🔬 Warpio is ready to enhance your Claude Code experience!${NC}"
echo -e "${BLUE}   Same Claude Code, now with scientific computing superpowers${NC}"
echo -e "${BLUE}   Powered by IOWarp.ai | Enhancing Science Through Intelligent Computing${NC}"
echo ""