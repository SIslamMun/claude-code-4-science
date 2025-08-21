---
description: Reset Warpio configuration to defaults
allowed-tools: Write, Bash
---

# Warpio Configuration Reset

## Reset Options

### 1. Reset to Factory Defaults
This will restore Warpio to its initial installation state:

**What gets reset:**
- Environment variables in `.env`
- MCP server configurations
- Expert agent settings
- Custom command configurations

**What stays unchanged:**
- Installed packages and dependencies
- Data files and user content
- Git history and repository settings

### 2. Reset Specific Components
You can reset individual components:

- **Local AI Only:** Reset local AI configuration
- **Experts Only:** Reset expert agent settings
- **MCPs Only:** Reset MCP server configurations

### 3. Clean Reinstall
For a complete fresh start:

```bash
# Backup your data first!
cp -r data data.backup

# Remove and reinstall
cd ..
rm -rf test
./install.sh test
cd test
```

## Current Configuration Backup

Before resetting, I'll create a backup of your current configuration:

- `.env.backup` - Environment variables
- `.mcp.json.backup` - MCP configurations
- `settings.json.backup` - Expert settings

## Reset Process

1. **Backup Creation** - Save current configuration
2. **Reset Selection** - Choose what to reset
3. **Configuration Reset** - Apply default settings
4. **Validation** - Test the reset configuration

## Default Configuration

After reset, you'll have:
- Basic local AI configuration (LM Studio)
- Standard MCP server setup
- Default expert permissions
- Clean command structure

## Warning

⚠️ **This action cannot be undone without backups!**

Resetting will remove:
- Custom environment variables
- Modified MCP configurations
- Personalized expert settings
- Any custom commands

Would you like me to proceed with the reset? If so, specify what to reset:
- `full` - Complete reset to factory defaults
- `local-ai` - Reset only local AI configuration
- `experts` - Reset only expert configurations
- `mcps` - Reset only MCP server configurations