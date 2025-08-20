---
description: Chain multiple expert tasks in sequence with data flow
argument-hint: <task1> -> <task2> -> <task3>
allowed-tools: Task, Write, Read
---

## ⛓️ Task Chaining

Task chain: $ARGUMENTS

I'll orchestrate multiple experts in sequence, passing results between them.

### Chaining Pattern
```
Data Loading (data-expert)
    ↓
Analysis (analysis-expert)
    ↓
Visualization (analysis-expert)
    ↓
Documentation (research-expert)
```

### Features
- **Automatic handoff** between experts
- **Data transformation** between stages
- **Error propagation** and recovery
- **Progress tracking** across chain
- **Result aggregation** from all stages

### Example Chains
- `load-hdf5 -> statistical-analysis -> plot-results`
- `profile-code -> optimize-parallel -> benchmark`
- `literature-review -> experimental-design -> write-methods`

The workflow-expert will coordinate the expert chain with proper data flow...