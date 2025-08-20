---
description: Design and implement scientific workflow pipeline
argument-hint: <pipeline-name> [workflow-engine]
allowed-tools: Task, Write, Read
---

## 🔗 Pipeline Creation

Pipeline: $ARGUMENTS

I'll delegate to the workflow-expert for comprehensive pipeline design.

### Pipeline Architecture
- **DAG construction** - Task dependencies and parallelization
- **Resource allocation** - CPU, memory, storage per stage
- **Error handling** - Retry logic, checkpointing, recovery
- **Data flow** - Input/output specifications between stages
- **Monitoring** - Progress tracking, logging, alerts

### Workflow Engines
- Nextflow (DSL2 with containers)
- Snakemake (Python-based rules)
- CWL (Common Workflow Language)
- Custom Python/Bash orchestration

### Deliverables
1. Pipeline definition file
2. Configuration templates
3. Test data and validation
4. Documentation and usage guide
5. Deployment instructions

The workflow-expert will design optimal pipeline architecture using their orchestration expertise...