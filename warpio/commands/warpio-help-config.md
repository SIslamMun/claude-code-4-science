---
description: Detailed help for Warpio configuration and setup
allowed-tools: Read
---

# Warpio Configuration Help

## Configuration Overview

Warpio configuration is managed through several files and commands. This guide covers all configuration options and best practices.

## Configuration Files

### 1. .env (Environment Variables)
**Location:** `./.env`
**Purpose:** User-specific configuration and secrets

**Key Variables:**
```bash
# Local AI Configuration
LOCAL_AI_PROVIDER=lmstudio
LMSTUDIO_API_URL=http://192.168.86.20:1234/v1
LMSTUDIO_MODEL=qwen3-4b-instruct-2507
LMSTUDIO_API_KEY=lm-studio

# Data Directories
DATA_INPUT_DIR=./data/input
DATA_OUTPUT_DIR=./data/output

# HPC Configuration
SLURM_CLUSTER=your-cluster-name
SLURM_PARTITION=gpu
SLURM_ACCOUNT=your-account
SLURM_TIME=01:00:00
SLURM_NODES=1
SLURM_TASKS_PER_NODE=16
```

### 2. .mcp.json (MCP Servers)
**Location:** `./.mcp.json`
**Purpose:** Configure Model Context Protocol servers

**Managed by:** Installation script (don't edit manually)
**Contains:** 16 scientific computing MCP servers
- HDF5, ADIOS, Parquet (Data formats)
- SLURM, Darshan (HPC)
- Pandas, Plot (Analysis)
- ArXiv, Context7 (Research)

### 3. settings.json (Claude Settings)
**Location:** `./.claude/settings.json`
**Purpose:** Configure Claude Code behavior

**Key Settings:**
- Expert agent permissions
- Auto-approval for scientific tools
- Hook configurations
- Status line settings

## Configuration Commands

### Initial Setup
```bash
/warpio-config-setup
```
- Creates basic `.env` file
- Sets up recommended directory structure
- Configures default local AI provider

### Validation
```bash
/warpio-config-validate
```
- Checks all configuration files
- Validates MCP server connections
- Tests local AI connectivity
- Reports system status

### Reset
```bash
/warpio-config-reset
```
- Resets to factory defaults
- Options: full, local-ai, experts, mcps
- Creates backups before reset

## Directory Structure

### Recommended Layout
```
project/
├── .claude/              # Claude Code configuration
│   ├── commands/         # Custom slash commands
│   ├── agents/          # Expert agent definitions
│   ├── hooks/           # Session hooks
│   └── statusline/      # Status line configuration
├── .env                  # Environment variables
├── .mcp.json            # MCP server configuration
├── data/                # Data directories
│   ├── input/          # Raw data files
│   └── output/         # Processed results
├── scripts/             # Analysis scripts
├── notebooks/           # Jupyter notebooks
└── docs/               # Documentation
```

### Creating Directory Structure
```bash
# Create data directories
mkdir -p data/input data/output

# Create analysis directories
mkdir -p scripts notebooks docs

# Set permissions
chmod 755 data/input data/output
```

## Local AI Configuration

### LM Studio Setup
1. **Install LM Studio** from https://lmstudio.ai
2. **Download Models:**
   - qwen3-4b-instruct-2507 (recommended)
   - llama3.2-8b-instruct (alternative)
3. **Start Server:** Click "Start Server" button
4. **Configure Warpio:**
   ```bash
   /warpio-local-config
   ```

### Ollama Setup
1. **Install Ollama** from https://ollama.ai
2. **Pull Models:**
   ```bash
   ollama pull llama3.2
   ollama pull qwen2.5:7b
   ```
3. **Start Service:**
   ```bash
   ollama serve
   ```
4. **Configure Warpio:**
   ```bash
   LOCAL_AI_PROVIDER=ollama
   OLLAMA_API_URL=http://localhost:11434/v1
   OLLAMA_MODEL=llama3.2
   ```

## HPC Configuration

### SLURM Setup
```bash
# .env file
SLURM_CLUSTER=your-cluster-name
SLURM_PARTITION=gpu
SLURM_ACCOUNT=your-account
SLURM_TIME=01:00:00
SLURM_NODES=1
SLURM_TASKS_PER_NODE=16
```

### Cluster-Specific Settings
- **Check available partitions:** `sinfo`
- **Check account limits:** `sacctmgr show user $USER`
- **Test job submission:** `sbatch --test-only your-script.sh`

## Research Configuration

### ArXiv Setup
```bash
# Get API key from arxiv.org
ARXIV_API_KEY=your-arxiv-key
ARXIV_MAX_RESULTS=50
```

### Context7 Setup
```bash
# Get API key from context7.ai
CONTEXT7_API_KEY=your-context7-key
CONTEXT7_BASE_URL=https://api.context7.ai
```

## Advanced Configuration

### Custom MCP Servers
Add custom MCP servers to `.mcp.json`:
```json
{
  "mcpServers": {
    "custom-server": {
      "command": "custom-command",
      "args": ["arg1", "arg2"],
      "env": {"ENV_VAR": "value"}
    }
  }
}
```

### Expert Permissions
Modify `.claude/settings.json` to add custom permissions:
```json
{
  "permissions": {
    "allow": [
      "Bash(custom-command:*)",
      "mcp__custom-server__*"
    ]
  }
}
```

### Hook Configuration
Customize session hooks in `.claude/hooks/`:
- **SessionStart:** Runs when Claude starts
- **Stop:** Runs when Claude stops
- **PreCompact:** Runs before conversation compaction

## Troubleshooting Configuration

### Common Issues

**Problem:** "Environment variable not found"
- Check `.env` file exists and is readable
- Verify variable names are correct
- Restart Claude Code after changes

**Problem:** "MCP server not connecting"
- Check server is running
- Verify API URLs and keys
- Test connection manually with curl

**Problem:** "Permission denied"
- Check file permissions
- Verify user has access to directories
- Check expert permissions in settings.json

### Debug Commands
```bash
# Check environment variables
env | grep -i warpio

# Test MCP connections
curl http://localhost:1234/v1/models

# Check file permissions
ls -la .env .mcp.json

# Validate JSON syntax
jq . .mcp.json
```

## Best Practices

1. **Backup Configuration:** Keep copies of working configurations
2. **Test Changes:** Use `/warpio-config-validate` after changes
3. **Version Control:** Consider tracking `.env.example` instead of `.env`
4. **Security:** Don't commit API keys to version control
5. **Documentation:** Document custom configurations for team members

## Getting Help

- **Command Help:** `/warpio-help`
- **Category Help:** `/warpio-help-config`
- **Validation:** `/warpio-config-validate`
- **Reset:** `/warpio-config-reset` (if needed)