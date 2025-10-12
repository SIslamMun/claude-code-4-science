# Warpio Full Installation Design

## Context

Plugin system provides components but NOT personality/branding. Testing showed Claude hallucinating because WARPIO.md (core intelligence) not loaded. Need creative solution to transform Claude Code into full Warpio experience during installation.

## Goals

- ✅ One-command full Warpio setup (`/warpio-install`)
- ✅ Automatic personality loading (WARPIO.md → CLAUDE.md)
- ✅ Branding and statusLine auto-configured
- ✅ Seamless user experience (install → restart → Warpio active)
- ✅ Clean uninstall capability

## Non-Goals

- ❌ Modify Claude Code internals
- ❌ Require manual file editing by users
- ❌ Break existing projects
- ❌ Override user's existing settings destructively

---

## Architecture: Three-Layer Installation

### Layer 1: Plugin Installation (Standard)
```bash
/plugin marketplace add akougkas/claude-code-4-science
/plugin install warpio@iowarp-scientific-computing
```

**Provides**:
- 13 agents (auto-discovered)
- 19 commands (auto-discovered)
- 4 hooks (loaded from hooks.json)
- 17 MCPs (loaded from .mcp.json)

**Missing**:
- Warpio personality (WARPIO.md not loaded as CLAUDE.md)
- Branding/statusLine
- Permissions/env vars

### Layer 2: Warpio Transformation (`/warpio-install`)
```bash
/warpio-install
```

**Auto-configures**:
1. Copy `WARPIO.md` → `.claude/CLAUDE.md` (personality)
2. Create Warpio output style in `~/.claude/output-styles/warpio.md`
3. Add statusLine to `.claude/settings.local.json`
4. Add suggested permissions to `.claude/settings.local.json`
5. Create `.claude/.warpio-installed` marker
6. Display next steps (restart Claude Code)

### Layer 3: Auto-Activation (SessionStart Hook)
```bash
# On next Claude Code startup
# SessionStart hook detects .warpio-installed marker
# Displays welcome message
# Validates configuration
# Warpio fully operational!
```

---

## Technical Decisions

### Decision 1: Installation Command Structure

**Chosen**: Bash script invoked by slash command

**`/warpio-install` command**:
```markdown
---
description: Complete Warpio installation and configuration (run once after plugin install)
allowed-tools: Bash, Write, Read
---

# Warpio Full Installation

Run the comprehensive installation script:

\`\`\`bash
${CLAUDE_PLUGIN_ROOT}/scripts/warpio-full-install.sh
\`\`\`

This transforms your Claude Code into the complete Warpio scientific computing platform.
```

**`scripts/warpio-full-install.sh`**:
- Detects if already installed
- Creates `.claude/` directory if needed
- Copies WARPIO.md → .claude/CLAUDE.md
- Creates Warpio output style
- Configures statusLine
- Adds permission suggestions
- Creates installation marker
- Displays success message with next steps

**Why bash script vs inline**:
- More maintainable (separate file)
- Can be reused/tested independently
- Easier error handling
- Can use `${CLAUDE_PLUGIN_ROOT}` properly

### Decision 2: Configuration Strategy

**Chosen**: Write to `.claude/settings.local.json` (not committed)

**Reasoning**:
- `settings.local.json` is gitignored by Claude Code
- Won't pollute team's shared settings.json
- User-specific configuration
- Can be overridden by user

**Configuration structure**:
```json
{
  "statusLine": {
    "type": "command",
    "command": "${CLAUDE_PLUGIN_ROOT}/scripts/warpio-status.sh"
  },
  "permissions": {
    "allow": [
      "Task",
      "Bash(sbatch:*)",
      "Bash(srun:*)",
      "Bash(uvx:*)",
      "mcp__*"
    ],
    "defaultMode": "acceptEdits"
  },
  "env": {
    "WARPIO_VERSION": "0.1.0",
    "WARPIO_ENABLED": "true"
  }
}
```

**Edge case handling**:
- If settings.local.json exists, merge (don't overwrite)
- Use `jq` for JSON manipulation
- Fallback if jq not available: append suggestion comments

### Decision 3: CLAUDE.md vs Output Style

**Chosen**: Use BOTH strategically

**CLAUDE.md** (`.claude/CLAUDE.md`):
- Contains Warpio's core orchestration logic
- Expert routing, decision framework
- MCP partitioning rules
- Always loaded by Claude Code in project

**Output Style** (`~/.claude/output-styles/warpio.md`):
- User-level Warpio mode
- Available across ALL projects
- User can activate with `/output-style warpio`
- Lighter-weight Warpio mode

**Why both**:
- CLAUDE.md = project-level (full power)
- Output style = user-level (portable Warpio)
- Users can choose: full Warpio in specific projects, or warpio output style globally

### Decision 4: First-Run Detection

**Chosen**: Marker file + SessionStart hook

**Mechanism**:
```bash
# In SessionStart hook (warpio-init.sh)
if [ ! -f ".claude/.warpio-installed" ]; then
    # First run - display welcome message
    echo "🚀 Warpio detected! Run /warpio-install to complete setup."
    exit 0
fi

# Already installed - normal init
echo "✅ Warpio active | 13 experts | 17 MCP tools | iowarp.ai"
# Run MCP health checks
# Display status
```

**Marker file** (`.claude/.warpio-installed`):
```json
{
  "installed_at": "2025-10-12T13:00:00Z",
  "version": "0.1.0",
  "components": {
    "personality": true,
    "output_style": true,
    "statusline": true,
    "permissions": true
  }
}
```

---

## Implementation Plan

### Component 1: Installation Script

**`warpio/scripts/warpio-full-install.sh`**:

```bash
#!/bin/bash
set -euo pipefail

PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT}"
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${CYAN}╔════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║   WARPIO FULL INSTALLATION WIZARD         ║${NC}"
echo -e "${CYAN}║   Scientific Computing for Claude Code     ║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════════╝${NC}"
echo

# Check if already installed
if [ -f ".claude/.warpio-installed" ]; then
    echo -e "${YELLOW}⚠️  Warpio already installed in this project${NC}"
    echo "   To reinstall, run: /warpio-uninstall first"
    exit 0
fi

echo "📦 Installing Warpio components..."
echo

# Step 1: Create .claude directory
echo -n "1/6 Creating .claude directory... "
mkdir -p .claude
echo -e "${GREEN}✓${NC}"

# Step 2: Copy WARPIO.md → CLAUDE.md
echo -n "2/6 Installing Warpio personality... "
cp "${PLUGIN_ROOT}/WARPIO.md" .claude/CLAUDE.md
echo -e "${GREEN}✓${NC}"

# Step 3: Create Warpio output style (user-level)
echo -n "3/6 Creating Warpio output style... "
mkdir -p ~/.claude/output-styles
cp "${PLUGIN_ROOT}/WARPIO.md" ~/.claude/output-styles/warpio.md
# Add proper frontmatter
sed -i '1i---\nname: Warpio\ndescription: Scientific Computing Orchestration Mode\n---\n' ~/.claude/output-styles/warpio.md
echo -e "${GREEN}✓${NC}"

# Step 4: Configure statusLine
echo -n "4/6 Configuring Warpio statusLine... "
if command -v jq &>/dev/null; then
    # Use jq to merge JSON properly
    if [ -f ".claude/settings.local.json" ]; then
        jq '. + {"statusLine": {"type": "command", "command": "'"${PLUGIN_ROOT}"'/scripts/warpio-status.sh"}}' \
            .claude/settings.local.json > .claude/settings.local.json.tmp
        mv .claude/settings.local.json.tmp .claude/settings.local.json
    else
        cat > .claude/settings.local.json << EOF
{
  "statusLine": {
    "type": "command",
    "command": "${PLUGIN_ROOT}/scripts/warpio-status.sh"
  }
}
EOF
    fi
    echo -e "${GREEN}✓${NC}"
else
    echo -e "${YELLOW}⚠${NC}"
    echo "   jq not found - statusLine not configured"
    echo "   Install jq or configure manually"
fi

# Step 5: Add permission suggestions
echo -n "5/6 Adding suggested permissions... "
cat > .claude/WARPIO-PERMISSIONS.md << 'EOF'
# Warpio Recommended Permissions

Add these to your `.claude/settings.json` or `.claude/settings.local.json`:

\`\`\`json
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
      "mcp__*"
    ],
    "defaultMode": "acceptEdits"
  },
  "env": {
    "WARPIO_VERSION": "0.1.0",
    "WARPIO_ENABLED": "true"
  }
}
\`\`\`
EOF
echo -e "${GREEN}✓${NC}"

# Step 6: Create installation marker
echo -n "6/6 Finalizing installation... "
cat > .claude/.warpio-installed << EOF
{
  "installed_at": "$(date -Iseconds)",
  "version": "0.1.0",
  "plugin_root": "${PLUGIN_ROOT}",
  "components": {
    "personality": true,
    "output_style": true,
    "statusline": true,
    "permissions_guide": true
  }
}
EOF
echo -e "${GREEN}✓${NC}"

echo
echo -e "${GREEN}╔════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║   ✅ WARPIO INSTALLATION COMPLETE!        ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════╝${NC}"
echo
echo "🎉 Warpio has been installed with:"
echo "   ✓ 13 AI expert agents"
echo "   ✓ 19 specialized commands"
echo "   ✓ 17 scientific MCP tools"
echo "   ✓ 4 lifecycle hooks"
echo "   ✓ Warpio personality loaded"
echo "   ✓ Custom statusLine configured"
echo
echo "🔄 NEXT STEP: Restart Claude Code"
echo "   1. Exit: /exit"
echo "   2. Restart: claude"
echo "   3. Warpio will be fully operational!"
echo
echo "📚 After restart, try:"
echo "   - /warpio-help"
echo "   - /warpio-expert-list"
echo "   - /warpio-status"
echo
echo "🚀 Powered by IOWarp.ai"
```

### Component 2: Enhanced SessionStart Hook

**Update `warpio/hooks/SessionStart/warpio-init.sh`**:

```bash
#!/bin/bash

# Warpio SessionStart Hook - Smart Initialization

# Check if Warpio personality is installed
if [ ! -f ".claude/.warpio-installed" ]; then
    # First detection - guide user to full install
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "🚀 Warpio Plugin Detected!"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo
    echo "Warpio is installed but not yet configured for this project."
    echo
    echo "Run this command to complete setup:"
    echo "  /warpio-install"
    echo
    echo "This will activate:"
    echo "  • Warpio AI personality and expert routing"
    echo "  • 13 specialized scientific computing experts"
    echo "  • Custom statusLine and branding"
    echo "  • Intelligent task orchestration"
    echo
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    exit 0
fi

# Already installed - display welcome
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🚀 Warpio Scientific Computing Platform"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ 13 Expert Agents | 19 Commands | 17 MCP Tools"
echo "🔬 Powered by IOWarp.ai"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo

# Quick MCP health check (don't block on failures)
MCP_COUNT=0
if command -v uvx &>/dev/null; then
    for mcp in hdf5 slurm plot arxiv; do
        if timeout 2 uvx iowarp-mcps "$mcp" --help &>/dev/null 2>&1; then
            ((MCP_COUNT++))
        fi
    done

    if [ $MCP_COUNT -gt 0 ]; then
        echo "✅ MCP Tools: $MCP_COUNT/4 core tools responding"
    else
        echo "⚠️  MCP Tools: Install iowarp-mcps (pip install iowarp-mcps)"
    fi
fi

echo "📖 Quick start: /warpio-help | /warpio-expert-list | /warpio-status"
echo
```

### Component 3: Uninstall Command

**`/warpio-uninstall` command**:
```markdown
---
description: Remove Warpio configuration from current project
allowed-tools: Bash, Read
---

# Warpio Uninstall

Remove Warpio configuration while keeping the plugin installed:

\`\`\`bash
${CLAUDE_PLUGIN_ROOT}/scripts/warpio-uninstall.sh
\`\`\`

This removes:
- .claude/CLAUDE.md (Warpio personality)
- .claude/.warpio-installed marker
- StatusLine from settings.local.json
- Warpio-added permissions

The plugin remains installed and can be reinstalled with `/warpio-install`.

To completely remove Warpio:
1. Run `/warpio-uninstall`
2. Run `/plugin uninstall warpio@iowarp-scientific-computing`
```

---

## Installation Flow Diagram

```
User Journey:
┌─────────────────────────────────────────┐
│ 1. Install Plugin                       │
│    /plugin install warpio@iowarp        │
└─────────────┬───────────────────────────┘
              │
              ▼
┌─────────────────────────────────────────┐
│ 2. First Startup (SessionStart Hook)   │
│    → Detects no .warpio-installed       │
│    → Shows: "Run /warpio-install"       │
└─────────────┬───────────────────────────┘
              │
              ▼
┌─────────────────────────────────────────┐
│ 3. User Runs /warpio-install            │
│    → Copies WARPIO.md → CLAUDE.md       │
│    → Creates output style               │
│    → Configures statusLine              │
│    → Adds permissions                   │
│    → Creates .warpio-installed marker   │
│    → Shows: "Restart Claude Code"       │
└─────────────┬───────────────────────────┘
              │
              ▼
┌─────────────────────────────────────────┐
│ 4. User Restarts Claude Code            │
│    → CLAUDE.md loads (Warpio active!)   │
│    → StatusLine shows Warpio branding   │
│    → SessionStart shows welcome         │
└─────────────┬───────────────────────────┘
              │
              ▼
┌─────────────────────────────────────────┐
│ 5. Warpio Fully Operational             │
│    ✅ Personality loaded                │
│    ✅ Experts auto-invoke correctly     │
│    ✅ MCP tools partitioned             │
│    ✅ StatusLine branded                │
│    ✅ Commands functional               │
└─────────────────────────────────────────┘
```

---

## User Experience Comparison

### Before (Current State)
```
/plugin install warpio@iowarp-scientific-computing
[restart]
/warpio-help
→ Claude hallucinates responses
→ No personality loaded
→ Agents don't work properly
→ Commands just prompts, no intelligence
```

### After (With Full Installation)
```
/plugin install warpio@iowarp-scientific-computing
[restart]
→ "Run /warpio-install to complete setup"

/warpio-install
→ "Installation complete! Restart Claude Code"

[restart]
→ "🚀 Warpio Scientific Computing Platform"
→ CLAUDE.md loaded - full Warpio intelligence
→ StatusLine shows Warpio branding
→ Experts route correctly
→ Commands work with real logic
```

---

## Risks & Mitigations

### Risk 1: CLAUDE_PLUGIN_ROOT Not Available
**Scenario**: Variable empty during script execution
**Mitigation**: Fallback to hardcoded relative paths, detect plugin location
**Test**: Verify in multiple environments

### Risk 2: Overwriting User's CLAUDE.md
**Scenario**: User already has project CLAUDE.md
**Mitigation**:
- Check if CLAUDE.md exists
- Ask user to confirm overwrite
- Offer to merge/append instead

### Risk 3: JSON Merge Failures
**Scenario**: settings.local.json malformed or jq not available
**Mitigation**:
- Validate JSON before merge
- Fallback: Create WARPIO-SETTINGS.md with manual instructions
- Never fail silently

### Risk 4: Permission Conflicts
**Scenario**: User has restrictive permissions
**Mitigation**:
- Add to settings.local.json (user-specific)
- Don't modify shared settings.json
- Document why each permission needed

---

## Testing Strategy

### Test 1: Fresh Install
```bash
# Clean environment
rm -rf test-fresh && mkdir test-fresh && cd test-fresh
claude

# Install
/plugin marketplace add ../claude-code-4-science
/plugin install warpio@iowarp-scientific-computing
[restart]

# Should see: "Run /warpio-install"

/warpio-install
# Should succeed, create .claude/CLAUDE.md

[restart]
# Should see: "Warpio active" with branding
```

### Test 2: Existing CLAUDE.md
```bash
# Project with existing CLAUDE.md
mkdir -p .claude
echo "# My Project" > .claude/CLAUDE.md

/warpio-install
# Should detect conflict and ask user
```

### Test 3: No jq Available
```bash
# Environment without jq
which jq || echo "jq not found"

/warpio-install
# Should fallback gracefully, provide manual instructions
```

### Test 4: Uninstall/Reinstall
```bash
/warpio-uninstall
# Should clean up files

/warpio-install
# Should reinstall fresh
```

---

## Open Questions

1. **Output style frontmatter**: How to properly format WARPIO.md as output style?
2. **Merge vs replace**: CLAUDE.md conflict - merge or replace strategy?
3. **StatusLine path**: Should we use absolute path or ${CLAUDE_PLUGIN_ROOT}?
4. **Permission prompt**: Interactive y/n for each permission, or all at once?
5. **Version tracking**: Should marker file track which components installed?

---

## Migration from Current State

### Files to Create
- `warpio/scripts/warpio-full-install.sh` (new)
- `warpio/scripts/warpio-uninstall.sh` (new)
- `warpio/commands/warpio-install.md` (new)
- `warpio/commands/warpio-uninstall.md` (new)

### Files to Modify
- `warpio/hooks/SessionStart/warpio-init.sh` (enhance with first-run detection)

### Files to Keep
- Everything else stays as-is
- Archive remains for reference

---

## Success Metrics

**Installation succeeds if**:
- ✅ `/warpio-install` completes without errors
- ✅ `.claude/CLAUDE.md` exists with Warpio content
- ✅ StatusLine configured in settings.local.json
- ✅ Output style created in ~/.claude/output-styles/
- ✅ Installation marker created

**Warpio operational if**:
- ✅ Claude responds with Warpio identity ("I am Claude Code enhanced by Warpio...")
- ✅ Expert routing works (tasks delegated to correct experts)
- ✅ StatusLine shows Warpio branding
- ✅ Commands execute with real logic (not hallucinations)
- ✅ MCP tools accessible to experts
