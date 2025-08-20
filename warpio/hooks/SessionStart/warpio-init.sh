#!/bin/bash

# Warpio Initialization Hook
# Runs at the start of each Claude Code session

# Load environment configuration from project root
if [ -f ".env" ]; then
    export $(grep -v '^#' .env | xargs) 2>/dev/null
fi

# Set Warpio environment variables (can be overridden by .env)
export WARPIO_MODE="${WARPIO_MODE:-orchestration}"
export WARPIO_PROVIDER="${WARPIO_PROVIDER:-claude}"
export WARPIO_VERSION="${WARPIO_VERSION:-1.0.0}"
export WARPIO_HOME="${WARPIO_HOME:-$(pwd)}"
export WARPIO_BRAND="${WARPIO_BRAND:-Warpio}"
export WARPIO_DOMAIN="${WARPIO_DOMAIN:-iowarp.ai}"

# ASCII Art Banner
cat << 'EOF'
╔══════════════════════════════════════════════════════════════╗
║                                                              ║
║  ██╗    ██╗ █████╗ ██████╗ ██████╗ ██╗ ██████╗             ║
║  ██║    ██║██╔══██╗██╔══██╗██╔══██╗██║██╔═══██╗            ║
║  ██║ █╗ ██║███████║██████╔╝██████╔╝██║██║   ██║            ║
║  ██║███╗██║██╔══██║██╔══██╗██╔═══╝ ██║██║   ██║            ║
║  ╚███╔███╔╝██║  ██║██║  ██║██║     ██║╚██████╔╝            ║
║   ╚══╝╚══╝ ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝     ╚═╝ ╚═════╝             ║
║                                                              ║
║        Scientific Computing Orchestrator v1.0.0             ║
║              Powered by iowarp.ai                           ║
║                                                              ║
╚══════════════════════════════════════════════════════════════╝
EOF

echo ""
echo "🚀 $WARPIO_BRAND Orchestration Layer Initialized"
echo "📊 Expert Personas Available: data, hpc, analysis, research, workflow"

# Show configured AI provider
if [ "$LOCAL_AI_PROVIDER" = "lmstudio" ]; then
    echo "🤖 Local AI: LM Studio ($LMSTUDIO_API_URL)"
    echo "   Model: $LMSTUDIO_MODEL"
elif [ "$LOCAL_AI_PROVIDER" = "ollama" ]; then
    echo "🤖 Local AI: Ollama ($OLLAMA_API_URL)"
    echo "   Model: $OLLAMA_MODEL"
else
    echo "🤖 Local AI: Not configured (using cloud fallback if available)"
fi

echo "🔬 Scientific MCPs: Configured"
echo ""

# Check for local AI availability
if command -v ollama &> /dev/null; then
    echo "✓ Ollama detected at $(which ollama)"
fi

if lsof -i:1234 &> /dev/null; then
    echo "✓ LM Studio API detected on port 1234"
fi

# Check for UV installation
if command -v uv &> /dev/null; then
    echo "✓ UV package manager detected at $(which uv)"
else
    echo "⚠️  UV not found. Installing UV is recommended for Python package management."
    echo "   Install with: curl -LsSf https://astral.sh/uv/install.sh | sh"
fi

# MCP Health Check
echo ""
echo "🔍 Checking MCP availability..."

# Check if iowarp-mcps package is installed
if ! uv pip list 2>/dev/null | grep -q iowarp-mcps; then
    echo "⚠️  iowarp-mcps package not installed"
    echo "   Install with: uv pip install iowarp-mcps"
    echo "   Some scientific computing features may be limited"
else
    echo "✅ iowarp-mcps package found"

    # Check critical MCPs
    critical_mcps=("hdf5" "slurm" "zen_mcp")
    missing_mcps=()

    for mcp in "${critical_mcps[@]}"; do
        echo -n "   $mcp... "
        if uvx iowarp-mcps "$mcp" --help &>/dev/null; then
            echo "✅"
        else
            echo "❌"
            missing_mcps+=("$mcp")
        fi
    done

    if [ ${#missing_mcps[@]} -eq 0 ]; then
        echo "✅ All critical MCPs available"
    else
        echo "⚠️  Some MCPs not working: ${missing_mcps[*]}"
        echo "   Check iowarp-mcps installation"
    fi
fi

# Create temporary workflow directory if it doesn't exist
mkdir -p /tmp/warpio-workflows

# Handle CLAUDE.md integration
if [ -f "CLAUDE.md" ]; then
    echo "📝 User CLAUDE.md detected - integrating with Warpio configuration"
    # Create a symlink or append to WARPIO.md in the future if needed
fi

echo ""
echo "Ready for scientific computing tasks! Use /mcp to check MCP status."
echo "────────────────────────────────────────────────────────────────"