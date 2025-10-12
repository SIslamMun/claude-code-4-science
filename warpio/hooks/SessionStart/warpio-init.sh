#!/bin/bash
# Warpio SessionStart Hook - Just update statusLine path

PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT}"

# Update statusLine path if needed (for installed-via-curl users)
if [ -f ".claude/settings.local.json" ] && [ -n "$PLUGIN_ROOT" ]; then
    if command -v jq &>/dev/null; then
        if ! grep -q "${PLUGIN_ROOT}" ".claude/settings.local.json" 2>/dev/null; then
            jq --arg path "${PLUGIN_ROOT}/scripts/warpio-status.sh" \
               '.statusLine.command = $path' \
               .claude/settings.local.json > .claude/settings.local.json.tmp
            mv .claude/settings.local.json.tmp .claude/settings.local.json
        fi
    fi
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
