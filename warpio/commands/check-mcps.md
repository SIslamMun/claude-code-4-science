---
description: Check MCP availability and configuration for Warpio experts
argument-hint: [expert-name]
allowed-tools: Bash
---

## 🔍 MCP Configuration Check

Checking MCP status for: $ARGUMENTS

I'll verify which MCPs are available and properly configured for Warpio's expert system.

### MCP Inventory by Expert

**Data Expert MCPs:**
- `mcp__hdf5__*` - HDF5 file operations
- `mcp__adios__*` - Streaming I/O
- `mcp__parquet__*` - Columnar data
- `mcp__pandas__*` - Dataframes
- `mcp__compression__*` - Data compression
- `mcp__filesystem__*` - File management

**Analysis Expert MCPs:**
- `mcp__pandas__*` - Data analysis
- `mcp__plot__*` - Visualization
- `mcp__zen_mcp__*` - Local analysis

**HPC Expert MCPs:**
- `mcp__darshan__*` - I/O profiling
- `mcp__node_hardware__*` - Hardware monitoring
- `mcp__zen_mcp__*` - Cluster tasks

**Research Expert MCPs:**
- `mcp__arxiv__*` - Paper retrieval
- `mcp__context7__*` - Documentation
- `mcp__zen_mcp__*` - Local research

**Workflow Expert MCPs:**
- `mcp__filesystem__*` - File operations
- `mcp__zen_mcp__*` - Workflow coordination

### Status Report
✅ Available MCPs
⚠️ Missing MCPs (install with: claude mcp add <name>)
❌ Configuration errors

Checking MCP configuration...