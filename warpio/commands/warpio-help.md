---
description: Warpio help system and command overview
allowed-tools: Read
---

# Warpio Help System

## Welcome to Warpio! 🚀

Warpio is your intelligent scientific computing orchestrator, combining expert AI agents with local AI capabilities for enhanced research workflows.

## Command Categories

### 👥 Expert Management (`/warpio-expert-*`)
Manage and delegate tasks to specialized AI experts

- `/warpio-expert-list` - View all available experts and capabilities
- `/warpio-expert-status` - Check current expert status and resource usage
- `/warpio-expert-delegate` - Delegate specific tasks to appropriate experts

**Quick Start:** `/warpio-expert-list`

### 🤖 Local AI (`/warpio-local-*`)
Configure and manage local AI providers

- `/warpio-local-status` - Check local AI connection and performance
- `/warpio-local-config` - Configure local AI providers (LM Studio, Ollama)
- `/warpio-local-test` - Test local AI connectivity and functionality

**Quick Start:** `/warpio-local-status`

### ⚙️ Configuration (`/warpio-config-*`)
Setup and manage Warpio configuration

- `/warpio-config-setup` - Initial Warpio setup and configuration
- `/warpio-config-validate` - Validate installation and check system status
- `/warpio-config-reset` - Reset configuration to defaults

**Quick Start:** `/warpio-config-validate`

## Getting Started

1. **First Time Setup:** `/warpio-config-setup`
2. **Check Everything Works:** `/warpio-config-validate`
3. **See Available Experts:** `/warpio-expert-list`
4. **Test Local AI:** `/warpio-local-test`

## Key Features

### Intelligent Delegation
- **Local AI** for quick tasks, analysis, and real-time responses
- **Expert Agents** for specialized scientific computing tasks
- **Automatic Fallback** between local and cloud AI

### Scientific Computing Focus
- **16 MCP Servers** for data formats, HPC, analysis
- **5 Expert Agents** covering data, analysis, HPC, research, workflow
- **Native Support** for HDF5, SLURM, Parquet, and more

### Smart Resource Management
- **Cost Optimization** - Use local AI for simple tasks
- **Performance Optimization** - Leverage local AI for low-latency tasks
- **Intelligent Caching** - Reuse results across sessions

## Detailed Help

For detailed help on each category:
- `/warpio-help-experts` - Expert management details
- `/warpio-help-local` - Local AI configuration help
- `/warpio-help-config` - Configuration and setup help

## Quick Examples

```bash
# Get started
/warpio-config-validate
/warpio-expert-list

# Use experts
/warpio-expert-delegate data "Convert HDF5 to Parquet"
/warpio-expert-delegate analysis "Generate statistical summary"

# Manage local AI
/warpio-local-status
/warpio-local-config
```

## Need More Help?

- **Documentation:** Check the Warpio README and guides
- **Issues:** Report bugs or request features
- **Updates:** Check for Warpio updates regularly

**Happy computing with Warpio! 🔬✨**