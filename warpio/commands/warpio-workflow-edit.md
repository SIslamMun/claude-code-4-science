---
description: Edit and modify existing scientific workflows
argument-hint: <workflow-name> [component]
allowed-tools: Task, Write, Read, Edit, mcp__filesystem__*
---

# Edit Scientific Workflow

**Workflow:** $ARGUMENTS

I'll help you modify and improve your existing scientific workflow using Warpio's expert system.

## Editing Capabilities

### 1. Workflow Structure
- **Add/remove stages** in the processing pipeline
- **Modify data flow** between components
- **Change execution order** and dependencies
- **Update resource requirements** and allocations

### 2. Component Modification
- **Update processing logic** for individual stages
- **Modify parameters** and configuration settings
- **Change expert assignments** for specific tasks
- **Update error handling** and recovery procedures

### 3. Optimization Features
- **Performance tuning** for better execution speed
- **Resource optimization** to reduce costs
- **Parallelization improvements** for scalability
- **Memory usage optimization** for large datasets

### 4. Validation & Testing
- **Syntax checking** for workflow configuration
- **Dependency validation** between components
- **Test data generation** for validation
- **Performance benchmarking** before/after changes

## Interactive Editing

### Available Operations:
1. **Add Component**: Insert new processing stages
2. **Remove Component**: Delete unnecessary stages
3. **Modify Parameters**: Update configuration settings
4. **Reorder Steps**: Change execution sequence
5. **Update Resources**: Modify compute requirements
6. **Test Changes**: Validate modifications
7. **Preview Impact**: See how changes affect workflow

### Expert Integration:
- **Data Expert**: Data format and processing changes
- **HPC Expert**: Compute resource and parallelization updates
- **Analysis Expert**: Statistical and visualization modifications
- **Research Expert**: Documentation and validation updates
- **Workflow Expert**: Overall orchestration and dependency management

## Safety Features

### Backup & Recovery:
- **Automatic backups** before major changes
- **Change history** tracking
- **Rollback capability** to previous versions
- **Impact analysis** before applying changes

### Validation Checks:
- **Syntax validation** for configuration files
- **Dependency checking** between components
- **Resource requirement verification**
- **Test execution** with sample data

## Usage Examples

```bash
# Edit specific workflow
/warpio-workflow-edit my-analysis-workflow

# Edit specific component
/warpio-workflow-edit my-analysis-workflow data-processing-stage

# Interactive editing mode
/warpio-workflow-edit my-workflow --interactive
```

The workflow will be updated with your changes while maintaining proper expert coordination and error handling.