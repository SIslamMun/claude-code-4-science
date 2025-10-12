<!-- OPENSPEC:START -->
# OpenSpec Instructions

These instructions are for AI assistants working in this project.

Always open `@/openspec/AGENTS.md` when the request:
- Mentions planning or proposals (words like proposal, spec, change, plan)
- Introduces new capabilities, breaking changes, architecture shifts, or big performance/security work
- Sounds ambiguous and you need the authoritative spec before coding

Use `@/openspec/AGENTS.md` to learn:
- How to create and apply change proposals
- Spec format and conventions
- Project structure and guidelines

Keep this managed block so 'openspec update' can refresh the instructions.

<!-- OPENSPEC:END -->

# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Warpio** is a scientific computing enhancement layer for Claude Code that adds specialized AI experts, scientific MCP tools, and HPC capabilities. It transforms Claude Code into a powerful scientific computing platform while maintaining all standard programming capabilities.

### Key Concept
Warpio enhances (not replaces) Claude Code by adding:
- 5 specialized expert agents (data, HPC, analysis, research, workflow)
- 14+ scientific MCP servers (HDF5, SLURM, ADIOS, Parquet, etc.)
- Local AI integration (LM Studio, Ollama) for privacy-preserving processing
- Intelligent task routing based on required MCP tools

## Repository Structure

```
claude-code-4-science/
├── install.sh                    # Main installer (curl-able entry point)
├── warpio/                       # Core Warpio implementation
│   ├── WARPIO.md                # Main identity and orchestration logic
│   ├── agents/                  # 5 expert personas (markdown definitions)
│   ├── commands/                # 18+ slash commands for user interaction
│   ├── hooks/                   # Event-driven automation (SessionStart, Stop, etc.)
│   ├── mcps/                    # MCP server configurations
│   │   └── warpio-mcps.json    # All 14 MCP tool definitions
│   ├── scripts/                 # Installation and validation utilities
│   │   ├── pre-install.sh      # System dependency setup
│   │   └── validate-mcp-setup.sh # MCP validation
│   ├── settings.json            # Claude Code configuration and permissions
│   ├── statusline/              # Status bar components
│   ├── output-styles/           # Scientific output formatting
│   └── themes/                  # UI customization
```

## Installation and Setup

### Installation Commands
```bash
# One-command remote installation
curl -sSL https://raw.githubusercontent.com/akougkas/claude-code-4-science/main/install.sh | bash

# Local installation to specific directory
./install.sh /path/to/project

# Interactive mode (choose specific experts/MCPs)
./install.sh --interactive /path/to/project
```

### Validation Commands
```bash
# Basic installation check
./validate-warpio.sh

# MCP server validation
warpio/scripts/validate-mcp-setup.sh

# Full system validation
claude  # Start Claude Code, then:
> /warpio-config-validate
```

### Development Setup
```bash
# Clone and setup
git clone https://github.com/akougkas/claude-code-4-science.git
cd claude-code-4-science

# Install dependencies
pip install iowarp-mcps
npm install -g @anthropic-ai/claude-cli

# Test installation
./install.sh test-environment
cd test-environment && claude
```

## Architecture Patterns

### Expert Orchestration Model

Warpio uses **MCP-based expert routing**: each expert has exclusive access to specific MCP tools, preventing overlap and ensuring focused expertise.

**Expert → MCP Mapping:**
- `data-expert`: hdf5, adios, parquet, compression
- `analysis-expert`: plot, pandas (visualization/stats focus)
- `hpc-expert`: slurm, darshan, node_hardware, lmod
- `research-expert`: arxiv, context7
- `workflow-expert`: jarvis, filesystem

**Shared MCPs:** zen_mcp (local AI), pandas (data manipulation), slurm (workflow orchestration)

### Decision Framework

```
Task Received
├── Requires scientific MCP tools?
│   ├── YES → Single domain?
│   │   ├── YES → Delegate to appropriate expert
│   │   └── NO → Multi-expert orchestration
│   └── NO → Handle as standard programming task
```

**Key Routing Rules:**
1. Simple questions (e.g., "How to read HDF5?") → Direct answer, no delegation
2. MCP-requiring tasks (e.g., "Optimize my HDF5 file") → Delegate to expert
3. Multi-domain tasks (e.g., "Analyze climate data and create figures") → Parallel experts

### Hook System

Warpio uses Claude Code's native hook system for automation:

- **SessionStart** (`warpio-init.sh`): Initialize Warpio, log session start
- **SubagentStop** (`expert-result-logger.py`): Log expert completion and results
- **Stop** (`session-summary-logger.py`): Generate session summary
- **PreCompact** (`workflow-checkpoint.py`): Save workflow state before compaction

## Working with Warpio Code

### Modifying Expert Definitions

Expert definitions are in `warpio/agents/*.md` with this structure:
```markdown
---
name: expert-name
description: Brief expertise description
tools: Tool1, Tool2, mcp__category__*
---

# Expert Name - Title

## Core Expertise
[Detailed capabilities]

## Response Protocol
[Behavioral instructions]
```

**When modifying experts:**
1. Update MCP tool assignments in frontmatter
2. Ensure MCP partitioning (no overlap in exclusive tools)
3. Test with `/warpio-expert-list` and `/warpio-expert-delegate`
4. Validate with `warpio/scripts/validate-mcp-setup.sh`

### Adding New Slash Commands

Commands live in `warpio/commands/*.md`:
```markdown
---
description: Command purpose
allowed-tools: Tool1, Tool2
---

# Command Name

[Implementation instructions that become the expanded prompt]
```

**Steps to add a command:**
1. Create `warpio/commands/warpio-newcmd.md`
2. Define description and allowed tools in frontmatter
3. Write implementation instructions in markdown
4. Test: `/warpio-newcmd` in Claude Code
5. Update `/warpio-help` if user-facing

### MCP Configuration

All MCP servers are defined in `warpio/mcps/warpio-mcps.json`:
```json
{
  "mcpServers": {
    "tool-name": {
      "command": "uvx",
      "args": ["iowarp-mcps", "tool-name"],
      "env": {},
      "description": "Tool description"
    }
  }
}
```

**Adding a new MCP:**
1. Add server definition to `warpio-mcps.json`
2. Update expert assignments in `warpio/agents/*.md`
3. Test availability: `uvx iowarp-mcps tool-name --help`
4. Validate: `warpio/scripts/validate-mcp-setup.sh`

### Settings and Permissions

`warpio/settings.json` configures Claude Code behavior:
- **hooks**: Event-driven automation scripts
- **statusLine**: Custom status bar command
- **permissions**: Allowed tools/commands (Task, Bash patterns, MCP tools)
- **env**: Environment variables (WARPIO_VERSION, WARPIO_ENABLED)

**Permission patterns:**
- `"Task"`: Allow Task tool for expert delegation
- `"Bash(sbatch:*)"`: Allow SLURM job submission
- `"mcp__*"`: Allow all MCP tools
- `"defaultMode": "acceptEdits"`: Auto-accept file edits

## Testing and Validation

### Test Commands
```bash
# Identity test
claude
> Who are you?
> Expected: "Claude Code enhanced with Warpio..."

# Expert routing
> I need to optimize an HDF5 file
> Expected: Activates data-expert

# Multi-expert orchestration
> Analyze simulation data and create publication figures
> Expected: Orchestrates data-expert + analysis-expert

# Local AI (if configured)
> Use zen to analyze this code
> Expected: Routes to local AI via zen_mcp
```

### Validation Checklist
1. **Installation**: All files copied to `.claude/`
2. **Dependencies**: `uvx`, `claude`, `git`, `python3` available
3. **MCPs**: At least 5 core MCPs responding (`hdf5`, `slurm`, `plot`, `arxiv`, `jarvis`)
4. **Experts**: All 5 experts defined and accessible
5. **Commands**: `/warpio-help` and core commands work
6. **Hooks**: Session hooks execute without errors

### Debug Commands
```bash
# View configuration
cat .claude/settings.json
cat .claude/mcps/warpio-mcps.json

# Check logs
tail -f .claude/hooks/logs/expert-activity.log
tail -f .claude/hooks/logs/session-summary.log

# Test MCP connectivity
uvx iowarp-mcps hdf5 --help
uvx iowarp-mcps slurm --help

# Interactive testing
claude
> /warpio-expert-list       # List all experts
> /warpio-expert-status     # Current expert state
> /warpio-config-validate   # Full system check
```

## Common Development Tasks

### Running the Installer Locally
```bash
# Standard installation
./install.sh target-directory

# With debugging
bash -x ./install.sh target-directory 2>&1 | tee install.log

# Interactive mode
./install.sh --interactive target-directory
```

### Modifying Installation Logic
Key sections in `install.sh`:
1. **Pre-installation** (lines 48-81): Dependency checking, pre-install trigger
2. **Dependency checks** (lines 87-150): Git, Claude CLI, UV, Node.js validation
3. **File copying** (lines ~300-400): Warpio file installation
4. **MCP setup** (lines ~450-550): iowarp-mcps installation
5. **Post-install** (lines ~600-700): Validation and next steps

### Adding a New Expert

1. **Create expert definition:**
```bash
# warpio/agents/new-expert.md
---
name: new-expert
description: Expert in [domain]
tools: Bash, Read, Write, mcp__tool1__*, mcp__tool2__*
---

# New Expert - [Title]

## Core Expertise
- Capability 1
- Capability 2

## Response Protocol
1. Use TodoWrite to plan
2. Actually use MCP tools
3. Aggregate findings
```

2. **Update WARPIO.md routing:**
```markdown
### Expert Routing
| Task Type | Expert | MCP Required |
|-----------|--------|--------------|
| [new domain] | new-expert | tool1, tool2 |
```

3. **Test integration:**
```bash
claude
> /warpio-expert-list  # Should show new expert
> /warpio-expert-delegate new-expert "test query"
```

### Updating MCP Tools

When `iowarp-mcps` package updates:
1. Update version in `install.sh` if version-pinned
2. Test new MCP tools: `uvx iowarp-mcps --list`
3. Add new MCPs to `warpio/mcps/warpio-mcps.json`
4. Update expert assignments in `warpio/agents/*.md`
5. Update documentation in `README.md`

## Key Implementation Details

### Main Orchestrator (warpio/WARPIO.md)
- **Line 23-64**: Priority decision matrix (MCP requirements → Expert routing → Context analysis → Sensitivity check)
- **Line 100-133**: Exclusive MCP assignments table (prevents tool overlap)
- **Line 136-184**: Orchestration patterns (single, parallel, sequential, iterative)
- **Line 186-211**: Local AI delegation logic
- **Line 214-264**: Error handling and graceful degradation

### Installation Script (install.sh)
- **Line 48-81**: Pre-installation dependency check and bootstrap
- **Line 87-150**: System dependency validation (git, claude, uvx, node)
- **Line 200-300**: GitHub download or local copy logic
- **Line 450-550**: iowarp-mcps installation with UV
- **Line 600+**: Post-install validation and user guidance

### Settings Configuration (warpio/settings.json)
- **Line 4-32**: Hook definitions (SessionStart, SubagentStop, Stop, PreCompact)
- **Line 34-36**: Custom status line configuration
- **Line 38-51**: Permission matrix for Task tool, Bash commands, MCPs
- **Line 53-57**: Environment variables for Warpio version tracking

## Scientific Computing Best Practices

When working with scientific code in Warpio:

### Data I/O Optimization
- Files >1GB: Use chunking (100,100,100) or auto-detect based on access patterns
- Compression: GZIP-6 (balanced), LZF (speed), SZIP (ratio)
- Parallel I/O: Collective operations for datasets >100MB

### HPC Integration
- SLURM scripts: Include array jobs, dependency chains, appropriate QoS
- MPI optimization: Non-blocking communication, collective operations
- Performance: Memory hierarchy awareness, NUMA considerations

### Error Handling
- Always provide fallback when MCPs unavailable
- Graceful degradation to base Python/Bash tools
- Clear user messaging for missing dependencies

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for detailed contribution guidelines.

**Quick contribution checklist:**
1. Fork and create feature branch
2. Make changes following existing patterns
3. Test with `./validate-warpio.sh`
4. Ensure all expert routing still works
5. Update documentation if adding features
6. Submit PR with clear description

## Troubleshooting

**Installation fails with missing dependencies:**
```bash
# Run pre-install script manually
bash warpio/scripts/pre-install.sh
source ~/.bashrc
./install.sh
```

**MCPs not responding:**
```bash
# Test MCP connectivity
uvx iowarp-mcps hdf5 --help

# Reinstall iowarp-mcps
pip uninstall iowarp-mcps
pip install iowarp-mcps
```

**Experts not activating:**
```bash
# Check expert definitions exist
ls -la .claude/agents/

# Validate routing in WARPIO.md
cat .claude/WARPIO.md | grep -A 10 "Expert Routing"
```

**Hooks not executing:**
```bash
# Check hook permissions
chmod +x .claude/hooks/SessionStart/*.sh
chmod +x .claude/hooks/Stop/*.py

# Check logs for errors
tail -f .claude/hooks/logs/*.log
```

## Additional Resources

- **Main Documentation**: [README.md](README.md)
- **Contributing Guide**: [CONTRIBUTING.md](CONTRIBUTING.md)
- **Warpio Identity**: [warpio/WARPIO.md](warpio/WARPIO.md)
- **MCP Documentation**: https://iowarp.github.io/iowarp-mcps
- **Claude Code Docs**: https://docs.anthropic.com/claude-code
