---
description: Show Warpio system status, active MCP servers, and session diagnostics
allowed-tools: Bash, Read
---

# Warpio Status

Execute comprehensive status check to display:

## MCP Server Status
Check connectivity and health of all 17 MCP servers:
- **Scientific Data**: hdf5, adios, parquet, compression
- **HPC Tools**: slurm, lmod, jarvis, darshan, node_hardware
- **Analysis**: pandas, parallel_sort, plot
- **Research**: arxiv, context7
- **Integration**: zen_mcp (local AI), filesystem

## Expert Availability
Report status of all 13 available agents:
- **Core Experts** (5): data, HPC, analysis, research, workflow
- **Specialized Experts** (8): genomics, materials-science, HPC-data-management, data-analysis, research-writing, scientific-computing, markdown-output, YAML-output

## Session Metrics
- Token usage and costs
- Duration and API response times
- Lines added/removed
- Active workflows

## System Health
- Hook execution status
- Recent errors or warnings
- Working directory
- Current model in use

## Execution

\`\`\`bash
${CLAUDE_PLUGIN_ROOT}/scripts/warpio-status.sh
\`\`\`

This command replaces the automatic statusLine feature (which is user-configured, not plugin-provided) with on-demand status information.

**Note**: Users can optionally configure automatic statusLine in their `.claude/settings.json` by pointing to `${CLAUDE_PLUGIN_ROOT}/scripts/warpio-status.sh`
