# Add Warpio Full Installation Experience

## Why

Current plugin installation only provides components (commands, agents, hooks, MCPs) but NOT the Warpio personality, branding, or full experience. Testing revealed Claude just hallucinating responses because WARPIO.md (the core intelligence) isn't loaded.

Need a **smart installation system** that transforms Claude Code into the complete Warpio experience:
- Warpio personality (WARPIO.md → CLAUDE.md)
- Branding and statusLine
- Automatic configuration
- Seamless one-command setup

## What Changes

- **Create `/warpio-install` super-command** that orchestrates full setup
- **Enhance SessionStart hook** to detect first-time usage and auto-configure
- **Auto-copy WARPIO.md** → `.claude/CLAUDE.md` (loads Warpio personality)
- **Auto-create Warpio output style** in `~/.claude/output-styles/warpio.md`
- **Auto-configure statusLine** in `.claude/settings.local.json`
- **Auto-configure permissions** suggestions in `.claude/settings.local.json`
- **Create installation state tracking** (`.claude/.warpio-installed` marker file)
- **Provide uninstall command** (`/warpio-uninstall`) for clean removal

**Result**: One-command full Warpio transformation with automatic personality loading, branding, and configuration

## Impact

- **Affected specs**: Builds on convert-to-plugin-system change
- **New capabilities**: installation-orchestration, auto-configuration, branding-setup
- **Affected code**:
  - New `/warpio-install` command
  - Enhanced `hooks/SessionStart/warpio-init.sh`
  - New `/warpio-uninstall` command
  - New installation state management
- **User experience**: Plugin install → `/warpio-install` → Restart → Full Warpio active
- **Timeline**: ~1 hour to implement and test
