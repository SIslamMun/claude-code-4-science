---
description: Detailed help for Warpio expert management
allowed-tools: Read
---

# Warpio Expert Management Help

## Expert System Overview

Warpio's expert system consists of 5 specialized AI agents, each with domain-specific knowledge and tools.

## Available Experts

### 🗂️ Data Expert
**Purpose:** Scientific data format handling and I/O optimization

**Capabilities:**
- Format conversion (HDF5 ↔ Parquet, NetCDF ↔ Zarr)
- Data compression and optimization
- Chunking strategy optimization
- Memory-mapped I/O operations
- Streaming data processing

**Tools:** HDF5, ADIOS, Parquet, Zarr, Compression, Filesystem

**Example Tasks:**
- "Convert my HDF5 dataset to Parquet with gzip compression"
- "Optimize chunking strategy for 10GB dataset"
- "Validate data integrity after format conversion"

### 📊 Analysis Expert
**Purpose:** Statistical analysis and data visualization

**Capabilities:**
- Statistical testing and modeling
- Data exploration and summary statistics
- Publication-ready visualizations
- Time series analysis
- Correlation and regression analysis

**Tools:** Pandas, Plot, Statistics, Zen MCP

**Example Tasks:**
- "Generate statistical summary of my dataset"
- "Create publication-ready plots for my results"
- "Perform correlation analysis on multiple variables"

### 🖥️ HPC Expert
**Purpose:** High-performance computing and cluster management

**Capabilities:**
- SLURM job submission and monitoring
- Performance profiling and optimization
- Parallel algorithm implementation
- Resource allocation and scaling
- Cluster utilization analysis

**Tools:** SLURM, Darshan, Node Hardware, Zen MCP

**Example Tasks:**
- "Submit this MPI job to the cluster"
- "Profile my application's performance"
- "Optimize memory usage for large-scale simulation"

### 📚 Research Expert
**Purpose:** Scientific research workflows and documentation

**Capabilities:**
- Literature review and paper analysis
- Citation management and formatting
- Method documentation
- Reproducible environment setup
- Research workflow automation

**Tools:** ArXiv, Context7, Zen MCP

**Example Tasks:**
- "Find recent papers on machine learning optimization"
- "Generate citations for my research paper"
- "Document my experimental methodology"

### 🔗 Workflow Expert
**Purpose:** Pipeline orchestration and automation

**Capabilities:**
- Complex workflow design and execution
- Data pipeline optimization
- Resource management and scheduling
- Dependency tracking and resolution
- Workflow monitoring and debugging

**Tools:** Filesystem, Jarvis, SLURM, Zen MCP

**Example Tasks:**
- "Create a data processing pipeline for my experiment"
- "Automate my analysis workflow with error handling"
- "Set up a reproducible research environment"

## How to Use Experts

### 1. List Available Experts
```bash
/warpio-expert-list
```

### 2. Check Expert Status
```bash
/warpio-expert-status
```

### 3. Delegate Tasks
```bash
/warpio-expert-delegate <expert> "<task description>"
```

### 4. Examples
```bash
# Data operations
/warpio-expert-delegate data "Convert HDF5 to Parquet format"
/warpio-expert-delegate data "Optimize dataset chunking for better I/O"

# Analysis tasks
/warpio-expert-delegate analysis "Generate statistical summary"
/warpio-expert-delegate analysis "Create correlation plots"

# HPC operations
/warpio-expert-delegate hpc "Submit SLURM job for simulation"
/warpio-expert-delegate hpc "Profile MPI application performance"

# Research tasks
/warpio-expert-delegate research "Find papers on optimization algorithms"
/warpio-expert-delegate research "Generate method documentation"

# Workflow tasks
/warpio-expert-delegate workflow "Create data processing pipeline"
/warpio-expert-delegate workflow "Automate analysis workflow"
```

## Best Practices

### Task Delegation
- **Be Specific:** Provide clear, detailed task descriptions
- **Include Context:** Mention file formats, data sizes, requirements
- **Specify Output:** Indicate desired output format or location

### Expert Selection
- **Data Expert:** For any data format or I/O operations
- **Analysis Expert:** For statistics, visualization, data exploration
- **HPC Expert:** For cluster computing, performance optimization
- **Research Expert:** For literature, citations, documentation
- **Workflow Expert:** For automation, pipelines, complex multi-step tasks

### Performance Tips
- **Local AI Tasks:** Use for quick analysis, format validation, documentation
- **Complex Tasks:** Use appropriate experts for domain-specific complex work
- **Resource Management:** Experts manage their own resources and tools

## Troubleshooting

### Expert Not Responding
- Check expert status with `/warpio-expert-status`
- Verify required tools are available
- Ensure task description is clear and complete

### Task Failed
- Check error messages for specific issues
- Verify input data and file paths
- Ensure required dependencies are installed

### Performance Issues
- Monitor resource usage with `/warpio-expert-status`
- Consider breaking large tasks into smaller ones
- Use appropriate expert for the task type