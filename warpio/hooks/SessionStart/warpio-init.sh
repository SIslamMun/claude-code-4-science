#!/bin/bash

# Warpio SessionStart Hook - Auto-Installation
# Automatically configures Warpio on first run

PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT}"

# First-run detection and auto-install
if [ ! -f ".claude/CLAUDE.md" ] || ! grep -q "WARPIO" ".claude/CLAUDE.md" 2>/dev/null; then
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "🚀 WARPIO - Scientific Computing for Claude Code"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo
    echo "First-time setup detected. Auto-configuring Warpio..."
    echo

    # Create .claude directory
    mkdir -p .claude

    # Copy Warpio personality
    if [ -n "$PLUGIN_ROOT" ] && [ -f "${PLUGIN_ROOT}/WARPIO.md" ]; then
        cp "${PLUGIN_ROOT}/WARPIO.md" .claude/CLAUDE.md
        echo "✅ Warpio personality installed"
    else
        echo "⚠️  Could not locate WARPIO.md - using fallback"
        # Fallback: try to find it
        WARPIO_FILE=$(find ~/.config/claude-code -name "WARPIO.md" 2>/dev/null | head -1)
        if [ -n "$WARPIO_FILE" ]; then
            cp "$WARPIO_FILE" .claude/CLAUDE.md
            echo "✅ Warpio personality installed (fallback)"
        fi
    fi

    # Configure statusLine if jq available
    if command -v jq &>/dev/null && [ -n "$PLUGIN_ROOT" ]; then
        cat > .claude/settings.local.json << EOF
{
  "statusLine": {
    "type": "command",
    "command": "${PLUGIN_ROOT}/scripts/warpio-status.sh"
  },
  "permissions": {
    "allow": ["Task", "Bash(sbatch:*)", "Bash(srun:*)", "Bash(uvx:*)", "mcp__*"],
    "defaultMode": "acceptEdits"
  },
  "env": {
    "WARPIO_VERSION": "0.1.0",
    "WARPIO_ENABLED": "true"
  }
}
EOF
        echo "✅ StatusLine and permissions configured"
    fi

    echo
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "✨ Setup complete! Please restart Claude Code:"
    echo "   1. Exit: /exit"
    echo "   2. Restart: claude"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo
    exit 0
fi

# Normal startup - Warpio already configured
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🚀 WARPIO Scientific Computing Platform"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ 13 Expert Agents | 19 Commands | 17 MCP Tools"
echo "🔬 Powered by IOWarp.ai"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo

# MCP health check
if command -v uvx &>/dev/null; then
    echo "📡 MCP Status:"
    for mcp in hdf5 slurm plot; do
        if timeout 1 uvx iowarp-mcps "$mcp" --help &>/dev/null 2>&1; then
            echo "   ✅ $mcp"
        fi
    done | head -3
fi

echo
echo "📖 Quick start: /warpio-help | /warpio-expert-list | /warpio-status"
echo
