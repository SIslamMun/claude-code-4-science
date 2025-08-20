---
description: Show status and capabilities of Warpio expert agents
argument-hint: [expert-name | all]
allowed-tools: Read, Glob
---

## 👥 Expert Status Report

Query: $ARGUMENTS

### Warpio Expert System

**🗂️ Data Expert** (data-expert)
- Status: Ready
- MCPs: HDF5, ADIOS, Parquet, Pandas, Compression
- Specialties: Format conversion, I/O optimization, chunking strategies

**📊 Analysis Expert** (analysis-expert)
- Status: Ready  
- MCPs: Pandas, Plot, Zen_mcp
- Specialties: Statistical testing, visualization, publication figures

**🖥️ HPC Expert** (hpc-expert)
- Status: Ready
- MCPs: Darshan, Node_hardware, Zen_mcp
- Specialties: SLURM scripts, performance profiling, parallel optimization

**📚 Research Expert** (research-expert)
- Status: Ready
- MCPs: Arxiv, Context7, Zen_mcp
- Specialties: Literature review, citations, reproducibility

**🔗 Workflow Expert** (workflow-expert)
- Status: Ready
- MCPs: Filesystem, Zen_mcp
- Specialties: Pipeline design, DAG construction, orchestration

### MCP Partitioning Philosophy
Each expert has **exclusive access** to their domain-specific MCPs. This intelligent partitioning is Warpio's key differentiator, ensuring focused expertise without tool overlap.

### Usage
- Single expert: `/orchestrate-experts data optimization task`
- Multiple experts: `/chain-tasks load-data -> analyze -> visualize`
- Parallel experts: `/launch-workflow comprehensive-analysis`