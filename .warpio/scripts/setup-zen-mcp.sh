#!/bin/bash
# Setup script for Zen-MCP Server with Warpio

echo "🚀 Warpio Zen-MCP Setup"
echo "========================"

# Check for UV installation
if ! command -v uv &> /dev/null; then
    echo "⚠️  UV not found. Installing UV..."
    curl -LsSf https://astral.sh/uv/install.sh | sh
    export PATH="$HOME/.cargo/bin:$PATH"
fi

# Check for local AI services
echo ""
echo "🔍 Checking for local AI services..."

# Check Ollama
if command -v ollama &> /dev/null; then
    echo "✅ Ollama found at $(which ollama)"
    if ! pgrep -f "ollama" > /dev/null; then
        echo "   Starting Ollama service..."
        ollama serve &> /dev/null &
        sleep 2
    fi
    # List available models
    echo "   Available Ollama models:"
    ollama list 2>/dev/null | head -5 || echo "   No models installed. Run: ollama pull llama3.2"
else
    echo "❌ Ollama not found"
    echo "   Install with: curl -fsSL https://ollama.com/install.sh | sh"
fi

# Check LM Studio
if lsof -i:1234 &> /dev/null 2>&1; then
    echo "✅ LM Studio API detected on port 1234"
else
    echo "⚠️  LM Studio not detected on port 1234"
    echo "   Start LM Studio and enable the local server on port 1234"
fi

# Test zen-mcp-server installation
echo ""
echo "🧪 Testing zen-mcp-server..."
if uvx --from git+https://github.com/BeehiveInnovations/zen-mcp-server.git zen-mcp-server --help &> /dev/null; then
    echo "✅ zen-mcp-server is ready"
else
    echo "⚠️  zen-mcp-server test failed. Will be installed on first use."
fi

# Configure environment
echo ""
echo "🔧 Configuring environment..."

# Source the zen-mcp.env file
if [ -f "$HOME/claude-code-4-science/.warpio/zen-mcp.env" ]; then
    source "$HOME/claude-code-4-science/.warpio/zen-mcp.env"
    echo "✅ Environment configured from .warpio/zen-mcp.env"
else
    echo "⚠️  .warpio/zen-mcp.env not found"
fi

# Show current configuration
echo ""
echo "📋 Current Configuration:"
echo "   CUSTOM_API_URL: ${CUSTOM_API_URL:-http://localhost:11434/v1}"
echo "   CUSTOM_MODEL_NAME: ${CUSTOM_MODEL_NAME:-llama3.2}"
echo "   ZEN_MODEL_STRATEGY: ${ZEN_MODEL_STRATEGY:-local-first}"

echo ""
echo "✨ Setup complete! Zen-MCP is ready for use with Warpio."
echo ""
echo "To use zen-mcp in Claude Code:"
echo "  - The MCP server will auto-start when Claude Code launches"
echo "  - Use tools like mcp__zen__chat, mcp__zen__analyze, etc."
echo "  - Subagents can delegate tasks to local AI automatically"
echo ""
echo "To manually test zen-mcp:"
echo "  uvx --from git+https://github.com/BeehiveInnovations/zen-mcp-server.git zen-mcp-server"