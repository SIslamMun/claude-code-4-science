# Warpio Scripts Documentation

## Script Organization (v1.0)

### Core Installation Scripts

1. **pre-install.sh**
   - Purpose: Environment preparation and dependency checks
   - When to run: Before main installation
   - Functions:
     - Checks OS compatibility
     - Installs UV if missing
     - Detects local AI services
     - Creates temp directories

2. **install-warpio.sh** (main, in repo root)
   - Purpose: Core installation
   - Functions:
     - Validates source files
     - Copies files to target
     - Sets up CLAUDE.md
     - Configures permissions

3. **post-install.sh**
   - Purpose: Configuration and validation
   - When to run: After main installation
   - Functions:
     - Configures zen-mcp
     - Validates hooks
     - Validates experts
     - Tests MCPs

### Utility Scripts

4. **utils/warpio-utils.sh**
   - Purpose: Shared functions library
   - Usage: Sourced by other scripts
   - Functions:
     - Logging functions
     - Environment loading
     - Local AI detection
     - Connection testing
     - File operations

5. **test-warpio.sh**
   - Purpose: Comprehensive testing
   - Functions:
     - Tests all components
     - Validates installation
     - Generates test report
     - Checks integrations

6. **configure-local-ai.sh**
   - Purpose: Local AI setup
   - Functions:
     - Auto-detects services
     - Configures providers
     - Tests connections
     - Updates .env

## Installation Workflow

```bash
# 1. Prepare environment (optional)
./.warpio/scripts/pre-install.sh

# 2. Install Warpio
./install-warpio.sh myproject

# 3. Post-installation (automatic unless --skip-post)
# Runs automatically, or manually:
cd myproject
./.claude/scripts/post-install.sh

# 4. Test installation
./.claude/scripts/test-warpio.sh

# 5. Configure local AI (optional)
./.claude/scripts/configure-local-ai.sh
```

## Script Dependencies

```
install-warpio.sh
├── utils/warpio-utils.sh (if available)
├── pre-install.sh (optional)
└── post-install.sh (automatic)

post-install.sh
└── utils/warpio-utils.sh

test-warpio.sh
└── utils/warpio-utils.sh

configure-local-ai.sh
└── utils/warpio-utils.sh
```

## Environment Variables

All scripts use `.env` for configuration. Key variables:

- `LOCAL_AI_PROVIDER`: lmstudio, ollama, or custom
- `LMSTUDIO_API_URL`: LM Studio endpoint
- `OLLAMA_API_URL`: Ollama endpoint
- `WARPIO_VERSION`: Installation version
- `ZEN_*`: Zen-MCP configuration

## Error Handling

All scripts:
- Use `set -e` for error stopping
- Provide colored output for clarity
- Generate logs/reports where applicable
- Return appropriate exit codes

## Maintenance

To add new functionality:
1. Add shared functions to `utils/warpio-utils.sh`
2. Keep scripts focused on single responsibility
3. Use consistent logging and error handling
4. Update this documentation

---
*Warpio Scripts v1.0 - Simplified & Clean*