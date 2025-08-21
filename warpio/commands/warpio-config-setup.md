---
description: Initial Warpio configuration and setup
allowed-tools: Write, Read, Bash
---

# Warpio Initial Setup

## Welcome to Warpio!

I'll help you configure Warpio for optimal scientific computing performance.

### Current Configuration Status

**System Check:**
- ✅ Git detected
- ✅ Claude CLI detected
- ✅ UV package manager detected
- ✅ Python environment ready
- ✅ MCP servers configured

**Warpio Components:**
- ✅ Expert agents installed
- ✅ Scientific MCPs configured
- ✅ Local AI integration ready
- ✅ Status line configured

### Essential Configuration

#### 1. Environment Variables (.env file)

I'll create a basic `.env` configuration:

```bash
# Local AI Configuration
LOCAL_AI_PROVIDER=lmstudio
LMSTUDIO_API_URL=http://192.168.86.20:1234/v1
LMSTUDIO_MODEL=qwen3-4b-instruct-2507
LMSTUDIO_API_KEY=lm-studio

# Data Directories
DATA_INPUT_DIR=./data/input
DATA_OUTPUT_DIR=./data/output

# HPC Configuration (if applicable)
SLURM_CLUSTER=your-cluster-name
SLURM_PARTITION=your-partition
```

#### 2. Directory Structure

Creating recommended directory structure:
```
project/
├── data/
│   ├── input/     # Raw data files
│   └── output/    # Processed results
├── scripts/       # Analysis scripts
├── notebooks/     # Jupyter notebooks
└── docs/         # Documentation
```

### Quick Start Guide

1. **Test Local AI:** `/warpio-local-test`
2. **Check Experts:** `/warpio-expert-list`
3. **View Status:** `/warpio-expert-status`
4. **Get Help:** `/warpio-help`

### Next Steps

After setup, you can:
- Delegate tasks to experts with `/warpio-expert-delegate`
- Use local AI for quick tasks
- Access 16 scientific MCPs for data operations
- Submit HPC jobs through the HPC expert

Would you like me to proceed with creating the basic configuration?