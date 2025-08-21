# 🚀 Warpio for Claude Code

<div align="center">

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Version](https://img.shields.io/badge/version-1.0.0-green.svg)](https://github.com/iowarp/claude-code-4-science)
[![Claude Code](https://img.shields.io/badge/Claude%20Code-Compatible-purple.svg)](https://claude.ai/code)
[![IOWarp](https://img.shields.io/badge/Powered%20by-IOWarp.ai-orange.svg)](https://iowarp.ai)

**Enhance Claude Code with Scientific Computing Superpowers**

[Quick Start](#-quick-start) • [Features](#-features) • [Architecture](#-architecture) • [Documentation](#-documentation) • [Contributing](#-contributing)

</div>

---

## 🌟 What is Warpio?

Warpio is a powerful enhancement layer that adds scientific computing superpowers to Claude Code. You get the same Claude Code you know and love, now with the ability to orchestrate specialized AI experts, scientific tools, and HPC capabilities to tackle complex computational challenges.

### 🎯 Enhancement Philosophy

Warpio **enhances** Claude Code rather than replacing it. Think of it as Claude Code with scientific superpowers:

| Claude Code | Claude Code + Warpio |
|------------|---------------------|
| General software development | **Enhanced with scientific computing** |
| Single agent capabilities | **Multi-expert orchestration** |
| Standard file operations | **HDF5, NetCDF, ADIOS, Zarr expertise** |
| Basic Python/JavaScript | **MPI, OpenMP, CUDA optimization** |
| Simple scripts | **SLURM job orchestration** |
| Sequential processing | **Parallel expert execution** |

### What Stays the Same
- All your familiar Claude Code capabilities
- Same interface and user experience  
- All standard tools and features
- Your existing workflows

### What Gets Enhanced

Warpio transforms Claude Code into a powerful scientific computing platform by adding:

- **🧠 Scientific Intelligence**: Deep expertise in HPC, data formats, and research workflows that goes beyond general programming knowledge
- **👥 Multi-Expert Orchestration**: 5 specialized AI agents that work independently or collaborate on complex multi-domain tasks
- **🔧 Specialized Scientific Tools**: 14+ purpose-built MCP tools for data formats (HDF5, ADIOS, Parquet), HPC (SLURM, Darshan), and analysis
- **🏠 Local AI Integration**: Privacy-preserving delegation to your local models (LM Studio, Ollama) for sensitive data processing
- **🎯 Intelligent Task Detection**: Automatic activation of relevant expertise based on your queries - no need to manually specify which expert to use
- **📊 Advanced Workflows**: End-to-end scientific computing pipeline support with automated orchestration
- **⚡ Performance Optimization**: Built-in knowledge of HPC best practices, data formats, and computational patterns
- **🔒 Research Privacy**: Secure handling of sensitive research data with local AI processing when needed

## ⚡ Quick Start

### One-Command Installation

```bash
# Install Warpio with a single command
curl -sSL https://raw.githubusercontent.com/akougkas/claude-code-4-science/main/install.sh | bash

# Or install to a specific directory
curl -sSL https://raw.githubusercontent.com/akougkas/claude-code-4-science/main/install.sh | bash -s -- --dir myproject
```

The installer automatically:
- ✅ Checks your environment and dependencies
- ✅ Installs missing system dependencies (with permission)
- ✅ Installs iowarp-mcps package for scientific computing
- ✅ Sets up Warpio enhancement layer with all expert personas
- ✅ Configures local AI integration (LM Studio/Ollama)
- ✅ Validates MCP server availability
- ✅ Provides clear next steps and troubleshooting guidance

### Start Using Warpio

After installation, Warpio is ready to use! Here are your options:

#### Option 1: Direct Launch (Recommended)
```bash
# Navigate to your project directory and start Claude Code
cd /path/to/your/project
claude
```

Warpio will automatically activate when you start Claude Code in a directory with Warpio installed.


#### First Steps After Launching

1. **Verify Installation**: Type `Who are you?` to confirm Warpio is active
2. **Explore Experts**: Type `/expert-list` to see available AI experts
3. **Test Configuration**: Type `/config-validate` to check your setup
4. **Try Scientific Tasks**: Ask questions like:
   - "How do I optimize my HDF5 file?"
   - "Generate a SLURM script for my MPI application"
   - "Help me analyze this climate data"

#### Understanding the Interface

- **Expert Activation**: Warpio automatically detects when you need scientific expertise
- **Command System**: Use `/help` to see all available slash commands
- **Status Line**: Check the bottom of your screen for Warpio status information
- **Multi-Expert Tasks**: Complex tasks automatically engage multiple experts working together

Warpio's intelligent routing will automatically activate the appropriate experts based on your requests!

## 🔬 Features

### 👥 Expert Personas

Warpio enhances Claude Code with specialized AI experts that work together:

- **🗄️ Data Expert**: HDF5, NetCDF, Zarr optimization, parallel I/O
- **🖥️ HPC Expert**: MPI programming, SLURM scripts, performance tuning
- **📊 Analysis Expert**: Statistical computing, visualization, ML
- **📚 Research Expert**: Papers, citations, reproducibility
- **⚙️ Workflow Expert**: Pipeline orchestration, automation

### 🛠️ Scientific MCP Tools

14+ specialized Model Context Protocol tools:

**Data Formats:**
- `hdf5` - Hierarchical data format operations and optimization
- `adios` - ADIOS2 framework for scientific simulation data access
- `parquet` - Apache Parquet columnar storage format operations
- `compression` - Data compression and decompression utilities

**HPC Tools:**
- `slurm` - HPC job scheduling and resource management
- `lmod` - Environment module management for scientific computing
- `jarvis` - Data-centric pipeline lifecycle management
- `darshan` - HPC application I/O profiling and performance analysis
- `node_hardware` - System hardware information and monitoring

**Computing & Analysis:**
- `pandas` - Data manipulation and analysis
- `parallel_sort` - Parallel sorting algorithms for large datasets
- `plot` - Scientific plotting and visualization

**AI & Research:**
- `zen_mcp` - Multi-model AI orchestration with local/cloud providers
- `arxiv` - ArXiv paper search and retrieval for research
- `context7` - Documentation retrieval for any library

**Utilities:**
- `filesystem` - Enhanced filesystem operations for data management

### 🤖 AI Orchestration

- **Local AI Integration**: LM Studio, Ollama support
- **Multi-Model Routing**: Intelligent task delegation
- **Parallel Execution**: Multiple experts working simultaneously
- **Result Aggregation**: Unified responses from expert collaboration

### 🎨 Orchestration Modes

1. **Parallel Mode**: Independent experts run simultaneously
2. **Sequential Mode**: Chained execution for dependent tasks
3. **Auto Mode**: Warpio decides based on task requirements

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────┐
│                    User Query                        │
└────────────────────┬────────────────────────────────┘
                     │
        ┌────────────▼────────────┐
        │   Warpio Main Agent     │
        │  (Intent Detection)     │
        └────────────┬────────────┘
                     │
     ┌───────────────┼───────────────┐
     │               │               │
┌────▼────┐    ┌────▼────┐    ┌────▼────┐
│  Data   │    │  HPC    │    │Analysis │
│ Expert  │    │ Expert  │    │ Expert  │
└────┬────┘    └────┬────┘    └────┬────┘
     │               │               │
     └───────────────┼───────────────┘
                     │
        ┌────────────▼────────────┐
        │   Result Aggregation    │
        └────────────┬────────────┘
                     │
        ┌────────────▼────────────┐
        │    Unified Response     │
        └─────────────────────────┘
```

## 📁 Project Structure

```
claude-code-4-science/
├── install.sh                 # One-command installer (curl entry point)
├── warpio/                    # Core Warpio implementation
│   ├── WARPIO.md             # Main identity prompt and behavior
│   ├── agents/               # Expert personas (5 total)
│   │   ├── data-expert.md    # Scientific data formats & I/O
│   │   ├── hpc-expert.md     # HPC, SLURM, MPI optimization
│   │   ├── analysis-expert.md # Visualization & statistics
│   │   ├── research-expert.md # Papers, citations, reproducibility
│   │   └── workflow-expert.md # Pipeline orchestration
│   ├── commands/             # 18+ slash commands
│   │   ├── warpio-config-*   # Configuration management
│   │   ├── warpio-expert-*   # Expert control commands
│   │   ├── warpio-help-*     # Help and documentation
│   │   └── warpio-workflow-* # Workflow management
│   ├── hooks/                # Event-driven automation
│   │   ├── SessionStart/     # Session initialization
│   │   ├── SubagentStop/     # Expert completion logging
│   │   ├── Stop/             # Session cleanup
│   │   └── PreCompact/       # Workflow checkpointing
│   ├── mcps/                # MCP server configurations
│   │   └── warpio-mcps.json  # Complete MCP tool definitions
│   ├── scripts/             # Installation and utility scripts
│   │   ├── pre-install.sh    # System dependency setup
│   │   └── validate-mcp-setup.sh # MCP validation
│   ├── output-styles/       # Custom output formatting
│   ├── statusline/          # Status line components
│   ├── themes/              # Custom themes and styling
│   └── settings.json        # Claude Code configuration
└── README.md                 # This file
```

## 🎮 Interactive Installation

The installer supports two modes:

### Default Mode (One-Click)
- Installs all 5 expert personas
- Configures core MCPs
- Auto-detects local AI
- Sets up parallel orchestration

### Interactive Mode (`--interactive`)
- Choose specific experts
- Select individual MCPs
- Configure orchestration mode
- Customize local AI settings

```bash
./install-warpio.sh --interactive /your/project
```

## 🧪 Testing Your Installation

### Quick Validation

```bash
cd /your/project
./validate-warpio.sh                    # Basic installation check
.claude/validate-mcp-setup.sh          # Scientific MCP validation
```

### Test Commands

```bash
# Identity test
You: Who are you?

# Expert activation
You: I need to optimize an HDF5 file

# Multi-expert orchestration
You: Analyze my simulation data and create publication figures

# Local AI delegation
You: Use zen to analyze this code

# Expert management commands
You: /expert-list     # List all available experts
You: /expert-status   # Show current expert status
You: /expert-delegate data-expert "Optimize my HDF5 file"

# Configuration management
You: /config-setup    # Setup Warpio configuration
You: /config-validate # Validate current configuration
You: /config-reset    # Reset to default configuration

# Workflow management
You: /workflow-create my-data-pipeline
You: /workflow-status
You: /workflow-edit my-data-pipeline

# Help and documentation
You: /help            # General help
You: /help-experts    # Expert-specific help
You: /help-config     # Configuration help
You: /help-local      # Local AI setup help

# HPC job management
You: Submit this job to SLURM

# Pipeline orchestration
You: Create a workflow for my data processing pipeline
```

## 🔧 Configuration

### Environment Variables (.env)

```bash
# AI Configuration
LOCAL_AI_PROVIDER=lmstudio
LMSTUDIO_API_URL=http://localhost:1234/v1
LMSTUDIO_MODEL=qwen3-4b-instruct

# Orchestration
ORCHESTRATION_MODE=parallel

# Warpio Settings
WARPIO_VERSION=1.0.0
WARPIO_ENABLED=true
WARPIO_SUBAGENT_MCP_ACCESS=true

# Data directories
DATA_INPUT_DIR=./data/input
DATA_OUTPUT_DIR=./data/output
```

### Expert Activation Keywords

| Expert | Trigger Keywords |
|--------|-----------------|
| Data | HDF5, NetCDF, Zarr, data format, I/O |
| HPC | MPI, SLURM, parallel, cluster |
| Analysis | plot, statistics, visualize |
| Research | paper, citation, reproducible |
| Workflow | pipeline, automation, orchestrate |

## 📚 Documentation

### Guides
- [Quick Start Guide](WARPIO-QUICKSTART.md)
- [MCP Documentation](https://iowarp.github.io/iowarp-mcps)

### Examples

#### Optimize HDF5 File
```
You: I have a large HDF5 file that's slow to read
Warpio: [Activates data-expert, analyzes structure, optimizes chunking]
```

#### Create SLURM Script
```
You: Generate a SLURM script for my MPI application
Warpio: [Activates hpc-expert, creates optimized job script]
```

#### Multi-Expert Collaboration
```
You: Analyze climate data and prepare publication figures
Warpio: [Orchestrates data-expert + analysis-expert in parallel]
```

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guide](CONTRIBUTING.md) for details.

### Adding New Experts
1. Create expert definition in `.warpio/agents/`
2. Define MCP tools in `mcp-configs/`
3. Add activation keywords to WARPIO.md
4. Test with validation suite

### Adding New MCPs
1. Implement MCP following protocol
2. Add to installer configuration
3. Document in README
4. Submit PR with examples

## 🛠️ Troubleshooting

### Common Issues

| Issue | Solution |
|-------|----------|
| Claude CLI not found | Install with `npm install -g @anthropic-ai/claude-cli` |
| Local AI not detected | Check LM Studio/Ollama is running |
| Experts not activating | Verify keywords in query |

### Debug Commands

```bash
# Installation validation
./validate-warpio.sh                    # Basic installation check
.claude/validate-mcp-setup.sh          # Scientific MCP validation

# View configuration files
cat .env                               # Environment variables
cat .mcp.json                          # MCP server configuration
cat .claude/settings.json              # Claude Code settings

# Interactive testing
claude
> Who are you?                        # Identity test
> /expert-list                         # List available experts
> /expert-status                       # Current expert status
> /config-validate                     # Configuration validation
> I need help with HDF5 files          # Should activate data-expert
> Submit job to SLURM                  # Should activate hpc-expert
> /help                                # Show all available commands

# Log inspection
tail -f .claude/hooks/logs/expert-activity.log
tail -f .claude/hooks/logs/session-summary.log
```

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- [Anthropic](https://anthropic.com) for Claude and Claude Code
- [IOWarp.ai](https://iowarp.ai) for scientific computing expertise
- The open-source scientific computing community

## 🔗 Links

- [GitHub Repository](https://github.com/iowarp/claude-code-4-science)
- [IOWarp Website](https://iowarp.ai)
- [IOWarp MCPs Documentation](https://iowarp.github.io/iowarp-mcps)
- [Claude Code Documentation](https://docs.anthropic.com/claude-code)

---

<div align="center">

**🔬 Warpio - Orchestrating Scientific Computing Excellence**

*Powered by IOWarp.ai | Transforming Science Through Intelligent Computing*

</div>
