---
description: Analyze I/O patterns and bottlenecks in scientific data pipelines
argument-hint: <data-directory> [file-pattern]
allowed-tools: Task, Read, Bash, Grep, Glob
---

## 📊 I/O Pattern Analysis

Analyzing: $ARGUMENTS

I'll coordinate the data-expert and hpc-expert to analyze I/O patterns comprehensively.

### Analysis Components

**Data-Expert (using data format MCPs):**
- File structure analysis with mcp__hdf5__info
- Compression effectiveness with mcp__compression__*
- Access pattern detection
- Chunk size optimization

**HPC-Expert (using performance MCPs):**
- I/O profiling with mcp__darshan__*
- Hardware bottleneck analysis with mcp__node_hardware__*
- Parallel I/O efficiency

### Deliverables
- I/O performance metrics (bandwidth, latency)
- Bottleneck identification (CPU, memory, disk)
- Optimization recommendations
- Implementation scripts

Initiating dual-expert I/O analysis...