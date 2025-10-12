#!/bin/bash
# Warpio One-Command Installer
# Usage: curl -sSL https://raw.githubusercontent.com/akougkas/claude-code-4-science/main/install-warpio.sh | bash

set -euo pipefail

CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

TARGET_DIR="${1:-.}"

echo -e "${CYAN}╔═══════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║         WARPIO ONE-COMMAND INSTALLER                      ║${NC}"
echo -e "${CYAN}║    Scientific Computing Platform for Claude Code          ║${NC}"
echo -e "${CYAN}╚═══════════════════════════════════════════════════════════╝${NC}"
echo

cd "$TARGET_DIR"

# Check if Claude Code is running
if pgrep -x "claude" > /dev/null; then
    echo -e "${YELLOW}⚠️  Claude Code is running. Please exit first (/exit)${NC}"
    exit 1
fi

# Check dependencies
if ! command -v claude &>/dev/null; then
    echo -e "${YELLOW}⚠️  Claude Code not found${NC}"
    echo "Install: npm install -g @anthropic-ai/claude-cli"
    exit 1
fi

echo "📦 Installing Warpio plugin..."

# Get plugin install location
PLUGIN_DIR="${HOME}/.config/claude-code/plugins/warpio"
REPO_URL="https://github.com/akougkas/claude-code-4-science"

# Install via plugin system first (this will be in background)
# We'll configure BEFORE starting Claude

# Create .claude directory structure
mkdir -p .claude/themes

# Download and setup CLAUDE.md directly
echo "📥 Fetching Warpio personality..."
curl -sSL "${REPO_URL}/raw/main/warpio/WARPIO.md" -o .claude/CLAUDE.md
echo "✅ Warpio personality → .claude/CLAUDE.md"

# Setup environment template
echo "📥 Fetching environment template..."
curl -sSL "${REPO_URL}/raw/main/warpio/.env.example" -o .env.warpio.example
echo "✅ Environment template → .env.warpio.example"

# Setup theme
echo "📥 Fetching Warpio theme..."
curl -sSL "${REPO_URL}/raw/main/warpio/themes/warpio-theme.json" -o .claude/themes/warpio.json
echo "✅ Warpio theme → .claude/themes/warpio.json"

# Create settings.local.json
# Note: Can't use ${CLAUDE_PLUGIN_ROOT} here, will be set by SessionStart hook
cat > .claude/settings.local.json << 'EOF'
{
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
  },
  "enabledPlugins": {
    "warpio@iowarp-scientific-computing": true
  },
  "extraKnownMarketplaces": {
    "iowarp-scientific-computing": {
      "source": {
        "source": "github",
        "repo": "akougkas/claude-code-4-science"
      }
    }
  }
}
EOF
echo "✅ Settings configured → .claude/settings.local.json"

echo
echo -e "${GREEN}╔═══════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║   ✨ WARPIO INSTALLATION COMPLETE!                        ║${NC}"
echo -e "${GREEN}╚═══════════════════════════════════════════════════════════╝${NC}"
echo
echo "📋 What was installed:"
echo "   ✓ Warpio personality (CLAUDE.md)"
echo "   ✓ Warpio theme and branding"
echo "   ✓ Environment template (.env.warpio.example)"
echo "   ✓ Settings and permissions"
echo "   ✓ Plugin marketplace configuration"
echo
echo "📝 OPTIONAL: Configure environment (recommended for MCP tools)"
echo "   cp .env.warpio.example .env"
echo "   # Edit .env with your LM Studio settings, etc."
echo
echo "🚀 START WARPIO:"
echo "   claude"
echo
echo "   On first start, Claude will:"
echo "   - Trust this directory (say yes)"
echo "   - Install Warpio plugin from marketplace"
echo "   - Load Warpio personality and capabilities"
echo
echo "   Then Warpio is fully operational with all 13 experts and 17 MCP tools!"
echo
echo "🔬 Powered by IOWarp.ai"
