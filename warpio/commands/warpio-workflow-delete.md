---
description: Safely delete scientific workflows and clean up resources
argument-hint: <workflow-name> [--force] [--keep-data]
allowed-tools: Task, Bash, mcp__filesystem__*
---

# Delete Scientific Workflow

**Workflow:** $ARGUMENTS

I'll help you safely delete a scientific workflow and clean up associated resources.

## Deletion Process

### 1. Safety Checks
- **Confirm ownership** - Verify you have permission to delete
- **Check dependencies** - Identify other workflows or processes using this one
- **Backup verification** - Ensure important data is backed up
- **Resource status** - Check if workflow is currently running

### 2. Resource Inventory
- **Code and scripts** - Workflow definition files
- **Configuration files** - Parameter and settings files
- **Data files** - Input/output data (optional preservation)
- **Log files** - Execution logs and monitoring data
- **Temporary files** - Cache and intermediate results
- **Compute resources** - Any active jobs or reservations

### 3. Cleanup Options

#### Standard Deletion (Default)
- Remove workflow definition and scripts
- Clean up temporary and cache files
- Stop any running processes
- Remove configuration files
- Preserve important data files (with confirmation)

#### Complete Deletion (--force)
- Remove ALL associated files including data
- Force stop any running processes
- Remove from workflow registry
- Clean up all dependencies

#### Data Preservation (--keep-data)
- Remove workflow code and configs
- Preserve all data files
- Keep logs for future reference
- Maintain data lineage information

### 4. Confirmation Process
- **Summary display** - Show what will be deleted
- **Impact analysis** - Explain consequences of deletion
- **Backup reminder** - Suggest creating backups if needed
- **Final confirmation** - Require explicit approval

## Interactive Deletion

### Available Options:
1. **Preview deletion** - See what would be removed
2. **Selective deletion** - Choose specific components to remove
3. **Archive instead** - Move to archive instead of deleting
4. **Cancel operation** - Abort the deletion process

### Safety Features:
- **Cannot delete running workflows** (must stop first)
- **Preserves data by default** (opt-in to delete data)
- **Creates deletion manifest** (record of what was removed)
- **30-second cooldown** (prevents accidental deletion)

## Usage Examples

```bash
# Standard deletion (preserves data)
/warpio-workflow-delete my-analysis-workflow

# Force complete deletion
/warpio-workflow-delete my-workflow --force

# Delete but keep all data
/warpio-workflow-delete my-workflow --keep-data

# Preview what would be deleted
/warpio-workflow-delete my-workflow --preview
```

## Recovery Options

If you need to recover a deleted workflow:
1. **Check archives** - Recently deleted workflows may be in archive
2. **Restore from backup** - Use backup files if available
3. **Recreate from template** - Use similar templates to recreate
4. **Contact support** - For critical workflow recovery

The workflow will be safely deleted with proper cleanup and resource deallocation.