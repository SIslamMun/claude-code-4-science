#!/bin/bash
# Warpio SessionStart Hook - One-Shot Auto-Configuration

PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT}"

# === FIRST RUN: Auto-configure everything ===
if [ ! -f ".claude/CLAUDE.md" ] || ! grep -q "WARPIO" ".claude/CLAUDE.md" 2>/dev/null; then

    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "🚀 WARPIO Auto-Configuration"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo

    # Create .claude directory
    mkdir -p .claude

    # 1. Install Warpio personality
    if [ -n "$PLUGIN_ROOT" ] && [ -f "${PLUGIN_ROOT}/WARPIO.md" ]; then
        cp "${PLUGIN_ROOT}/WARPIO.md" .claude/CLAUDE.md
        echo "✅ Warpio personality → .claude/CLAUDE.md"
    fi

    # 2. Copy environment template
    if [ -n "$PLUGIN_ROOT" ] && [ -f "${PLUGIN_ROOT}/_archive/.env.example" ]; then
        cp "${PLUGIN_ROOT}/_archive/.env.example" .env.warpio.example
        echo "✅ Environment template → .env.warpio.example"
    fi

    # 3. Configure settings (statusLine + permissions)
    if command -v jq &>/dev/null && [ -n "$PLUGIN_ROOT" ]; then
        cat > .claude/settings.local.json << EOF
{
  "statusLine": {
    "type": "command",
    "command": "${PLUGIN_ROOT}/scripts/warpio-status.sh"
  },
  "permissions": {
    "allow": [
      "Task",
      "Bash(sbatch:*)",
      "Bash(srun:*)",
      "Bash(h5dump:*)",
      "Bash(ncdump:*)",
      "Bash(mpirun:*)",
      "Bash(uvx:*)",
      "Bash(uv:*)",
      "mcp__*"
    ],
    "defaultMode": "acceptEdits"
  },
  "env": {
    "WARPIO_VERSION": "0.1.0",
    "WARPIO_ENABLED": "true"
  }
}
EOF
        echo "✅ Settings configured → .claude/settings.local.json"
    fi

    # 4. Copy theme (optional)
    if [ -n "$PLUGIN_ROOT" ] && [ -f "${PLUGIN_ROOT}/_archive/themes/warpio-theme.json" ]; then
        mkdir -p .claude/themes
        cp "${PLUGIN_ROOT}/_archive/themes/warpio-theme.json" .claude/themes/warpio.json
        echo "✅ Warpio theme → .claude/themes/warpio.json"
    fi

    echo
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "✨ Warpio Configuration Complete!"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo
    echo "📝 OPTIONAL: Configure your environment variables"
    echo "   Edit .env.warpio.example → .env"
    echo "   Set: LMSTUDIO_API_URL, LMSTUDIO_MODEL, etc."
    echo
    echo "🔄 RESTART Claude Code to activate Warpio:"
    echo "   /exit"
    echo "   claude"
    echo
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    exit 0
fi

# === NORMAL STARTUP: Warpio active ===
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🚀 WARPIO Scientific Computing Platform"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ 13 Expert Agents | 19 Commands | 17 MCP Tools"
echo "🔬 Powered by IOWarp.ai"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo
echo "📖 /warpio-help | /warpio-expert-list | /warpio-status"
echo
