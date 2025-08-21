---
description: Delegate a specific task to the appropriate Warpio expert
argument-hint: <expert-name> "<task description>"
allowed-tools: Task, mcp__hdf5__*, mcp__slurm__*, mcp__pandas__*, mcp__plot__*, mcp__arxiv__*, mcp__filesystem__*
---

# Expert Task Delegation

**Expert:** $ARGUMENTS

I'll analyze your request and delegate it to the most appropriate Warpio expert. The expert will use their specialized tools and knowledge to complete the task efficiently.

## Delegation Process

1. **Task Analysis** - Understanding the requirements and constraints
2. **Expert Selection** - Choosing the best expert for the job
3. **Tool Selection** - Selecting appropriate MCP tools and capabilities
4. **Execution** - Running the task with expert oversight
5. **Quality Check** - Validating results and ensuring completeness

## Available Experts

- **data** - Scientific data formats, I/O optimization, format conversion
- **analysis** - Statistical analysis, visualization, data exploration
- **hpc** - High-performance computing, parallel processing, job scheduling
- **research** - Literature review, citations, documentation
- **workflow** - Pipeline orchestration, automation, resource management

## Example Usage

```
/warpio-expert-delegate data "Convert my HDF5 dataset to Parquet with gzip compression"
/warpio-expert-delegate analysis "Generate statistical summary of my CSV data"
/warpio-expert-delegate hpc "Submit this MPI job to the cluster and monitor progress"
/warpio-expert-delegate research "Find recent papers on machine learning optimization"
/warpio-expert-delegate workflow "Create a data processing pipeline for my experiment"
```

The selected expert will now handle your task using their specialized capabilities and tools.