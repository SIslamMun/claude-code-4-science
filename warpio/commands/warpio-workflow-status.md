---
description: Check the status and health of scientific workflows
argument-hint: <workflow-name> [detailed]
allowed-tools: Task, Read, Bash, mcp__filesystem__*
---

# Workflow Status Check

**Workflow:** $ARGUMENTS

I'll provide a comprehensive status report for your scientific workflow, including execution status, performance metrics, and health indicators.

## Current Status Overview

### Execution Status
- **State**: Running/Completed/Failed/Paused
- **Progress**: 75% (Stage 3 of 4)
- **Runtime**: 2h 15m elapsed
- **Estimated completion**: 45 minutes remaining

### Resource Utilization
- **CPU Usage**: 85% (12/16 cores)
- **Memory Usage**: 24GB / 32GB
- **Storage I/O**: 125 MB/s read, 89 MB/s write
- **Network**: 45 MB/s (if applicable)

### Stage-by-Stage Progress

#### ✅ Stage 1: Data Preparation (Data Expert)
- **Status**: Completed
- **Duration**: 25 minutes
- **Output**: 2.1GB processed dataset
- **Quality**: All validation checks passed

#### ✅ Stage 2: Initial Analysis (Analysis Expert)
- **Status**: Completed
- **Duration**: 45 minutes
- **Output**: Statistical summary report
- **Quality**: All metrics within expected ranges

#### 🔄 Stage 3: Advanced Processing (HPC Expert)
- **Status**: Running
- **Duration**: 1h 5m (so far)
- **Progress**: 75% complete
- **Current Task**: Parallel computation on 8 nodes

#### ⏳ Stage 4: Final Validation (Research Expert)
- **Status**: Pending
- **Estimated Duration**: 30 minutes
- **Dependencies**: Stage 3 completion

## Expert Coordination Status

### Active Experts
- **Data Expert**: Monitoring data quality
- **HPC Expert**: Managing compute resources
- **Analysis Expert**: Available for consultation
- **Research Expert**: Preparing validation procedures
- **Workflow Expert**: Coordinating overall execution

### Communication Status
- **Inter-expert messaging**: Active
- **Data transfer**: Optimized
- **Error reporting**: Real-time
- **Progress updates**: Every 5 minutes

## Performance Metrics

### Efficiency Indicators
- **Resource efficiency**: 92% (CPU utilization vs. requirements)
- **Data processing rate**: 45.2 MB/s
- **Parallel efficiency**: 88% (8-node scaling)
- **I/O efficiency**: 78% (storage bandwidth utilization)

### Quality Metrics
- **Data integrity**: 100% (no corruption detected)
- **Result accuracy**: 99.7% (validation checks)
- **Error rate**: 0.02% (minimal errors handled)
- **Recovery success**: 100% (all errors recovered)

## Alerts & Issues

### ⚠️ Minor Issues
- **Storage I/O**: Running at 78% of optimal bandwidth
- **Memory usage**: Approaching 75% limit
- **Network latency**: 15ms (acceptable)

### ✅ Resolved Issues
- **Node connectivity**: Previously intermittent, now stable
- **Data transfer bottleneck**: Optimized with compression
- **Memory fragmentation**: Resolved with restart

## Recommendations

### Immediate Actions
1. **Monitor memory usage** - Close to limit
2. **Consider I/O optimization** - Storage performance could be improved
3. **Prepare for Stage 4** - Validation procedures ready

### Future Improvements
1. **Resource allocation**: Consider increasing memory for similar workflows
2. **Data staging**: Implement data staging to improve I/O performance
3. **Checkpoint frequency**: Optimize checkpoint intervals for this workload type

## Quick Actions

- **Pause workflow**: Temporarily stop execution
- **Resume workflow**: Continue from current state
- **View logs**: Detailed execution logs
- **Get expert help**: Consult specific experts
- **Modify parameters**: Update workflow settings

The workflow is executing normally with good performance and should complete successfully within the estimated time.