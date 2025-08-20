# 🚀 Warpio for Claude Code

<div align="center">

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Version](https://img.shields.io/badge/version-1.0.0-green.svg)](https://github.com/iowarp/claude-code-4-science)
[![Claude Code](https://img.shields.io/badge/Claude%20Code-Compatible-purple.svg)](https://claude.ai/code)
[![IOWarp](https://img.shields.io/badge/Powered%20by-IOWarp.ai-orange.svg)](https://iowarp.ai)

**Transform Claude Code into a Scientific Computing Orchestrator**

[Quick Start](#-quick-start) • [Features](#-features) • [Architecture](#-architecture) • [Documentation](#-documentation) • [Contributing](#-contributing)

</div>

---

## 🌟 What is Warpio?

Warpio is a powerful transformation layer that enhances Claude Code with scientific computing superpowers. It orchestrates an "army" of specialized AI experts, scientific tools, and HPC capabilities to tackle complex computational challenges with minimal user intervention.

### 🎯 Key Differentiators

| Claude Code | Warpio |
|------------|--------|
| General software development | **Scientific computing focus** |
| Single agent | **Multi-expert orchestration** |
| Standard file operations | **HDF5, NetCDF, ADIOS, Zarr expertise** |
| Basic Python/JavaScript | **MPI, OpenMP, CUDA optimization** |
| Simple scripts | **SLURM job orchestration** |
| Sequential processing | **Parallel expert execution** |

## ⚡ Quick Start

### One-Click Installation

```bash
# Clone the repository
git clone https://github.com/iowarp/claude-code-4-science
cd claude-code-4-science

# Install to your project (one-click mode)
./install-warpio.sh /path/to/your/project

# Or use interactive mode for customization
./install-warpio.sh --interactive /path/to/your/project
```

### Start Using Warpio

```bash
# Option 1: Use the warpio alias
warpio

# Option 2: Navigate and launch
cd /path/to/your/project
claude
```

## 🔬 Features

### 👥 Expert Personas

Warpio orchestrates specialized AI experts that work together:

- **🗄️ Data Expert**: HDF5, NetCDF, Zarr optimization, parallel I/O
- **🖥️ HPC Expert**: MPI programming, SLURM scripts, performance tuning
- **📊 Analysis Expert**: Statistical computing, visualization, ML
- **📚 Research Expert**: Papers, citations, reproducibility
- **⚙️ Workflow Expert**: Pipeline orchestration, automation

### 🛠️ Scientific MCP Tools

14+ specialized Model Context Protocol tools:

**Data Formats:**
- `hdf5-mcp` - Hierarchical data operations
- `netcdf-mcp` - Climate data handling
- `adios-mcp` - Streaming I/O for simulations
- `zarr-mcp` - Cloud-optimized arrays
- `parquet-mcp` - Columnar analytics

**HPC Tools:**
- `slurm-mcp` - Job scheduling
- `mpi-mcp` - Message passing
- `darshan-mcp` - I/O profiling

**Computing:**
- `numpy-mcp` - Numerical operations
- `pandas-mcp` - Data manipulation
- `scipy-mcp` - Scientific algorithms

**Utilities:**
- `arxiv-mcp` - Paper retrieval
- `git-mcp` - Version control
- `filesystem-mcp` - Advanced file ops

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
├── .warpio/                    # Core Warpio configuration
│   ├── WARPIO.md              # Main identity prompt
│   ├── agents/                # Expert personas
│   │   ├── data-expert.md
│   │   ├── hpc-expert.md
│   │   └── ...
│   ├── commands/              # Custom slash commands
│   ├── hooks/                 # Event hooks
│   ├── mcp-configs/           # MCP configurations
│   └── scripts/               # Utility scripts
├── install-warpio.sh          # Main installer
├── TEST-WARPIO.md            # Comprehensive test suite
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
./validate-warpio.sh
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
WARPIO_DOMAIN=iowarp.ai
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
- [Testing Guide](TEST-WARPIO.md)
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
| MCPs not loading | Run `.claude/scripts/install-mcps.sh` |
| Local AI not detected | Check LM Studio/Ollama is running |
| Experts not activating | Verify keywords in query |

### Debug Commands

```bash
# Check installation
./validate-warpio.sh

# View configuration
cat .env
cat .claude/mcp-configs/warpio-mcps.json

# Test specific expert
claude
> I need help with HDF5 files  # Should activate data-expert
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