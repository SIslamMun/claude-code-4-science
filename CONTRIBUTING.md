# Contributing to Warpio

Thank you for your interest in contributing to Warpio! We welcome contributions from researchers, HPC professionals, and developers who share our vision of making scientific computing more accessible and efficient.

## 🚀 Ways to Contribute

### Types of Contributions
- **🐛 Bug Reports**: Help us identify and fix issues
- **✨ Feature Requests**: Suggest new capabilities or improvements
- **💻 Code Contributions**: Implement new features, fix bugs, or improve documentation
- **📚 Documentation**: Improve guides, tutorials, or API documentation
- **🧪 Testing**: Add test cases or improve testing infrastructure
- **🎨 UI/UX**: Enhance the user experience and interface

## 📋 Prerequisites

Before contributing, ensure you have:
- **Git** for version control
- **Node.js** and **npm** for Claude Code
- **Python 3.8+** for scientific computing tools
- **UV** package manager (`curl -LsSf https://astral.sh/uv/install.sh | sh`)
- **Claude CLI** (`npm install -g @anthropic-ai/claude-cli`)

## 🛠️ Development Setup

### 1. Fork and Clone
```bash
# Fork the repository on GitHub
# Then clone your fork
git clone https://github.com/your-username/claude-code-4-science.git
cd claude-code-4-science
```

### 2. Create Development Environment
```bash
# Install Warpio for development
./install.sh dev-environment

# Or manually install dependencies
pip install iowarp-mcps
npm install -g @anthropic-ai/claude-cli
```

### 3. Set Up Local Development
```bash
# Create development configuration
cp .env.example .env
# Edit .env with your settings

# Test installation
./validate-warpio.sh
```

### 4. Verify Setup
```bash
# Start Claude Code with Warpio
claude

# Test basic functionality
> Who are you?
> /expert-list
> /config-validate
```

## 🔧 Development Workflow

### 1. Create a Feature Branch
```bash
# Create branch for your feature
git checkout -b feature/your-feature-name

# Or for bug fixes
git checkout -b fix/bug-description
```

### 2. Make Your Changes
- Follow the existing code style and conventions
- Add tests for new functionality
- Update documentation as needed
- Ensure all tests pass

### 3. Test Your Changes
```bash
# Run validation scripts
./validate-warpio.sh
.claude/validate-mcp-setup.sh

# Test specific functionality
claude
> /expert-list
> /expert-status
> /config-validate
```

### 4. Commit Your Changes
```bash
# Add your changes
git add .

# Commit with descriptive message
git commit -m "feat: add new expert capability for data validation

- Add data validation functions to data-expert
- Include comprehensive error handling
- Update documentation with examples
- Add test cases for validation scenarios"

# Push to your branch
git push origin feature/your-feature-name
```

## 📝 Code Style Guidelines

### Python Code
```python
# Use type hints
def optimize_hdf5(file_path: str, chunk_size: tuple[int, ...]) -> bool:
    """Optimize HDF5 file with given chunk size.

    Args:
        file_path: Path to HDF5 file
        chunk_size: Desired chunk dimensions

    Returns:
        True if optimization successful
    """
    pass

# Use descriptive variable names
data_array = np.array(...)  # Not 'arr' or 'x'
```

### Shell Scripts
```bash
#!/bin/bash
set -euo pipefail  # Always use these flags

# Use functions for reusable code
validate_input() {
    local input="$1"
    if [[ -z "$input" ]]; then
        echo "Error: Input cannot be empty" >&2
        return 1
    fi
}

# Use consistent error handling
validate_input "$USER_INPUT" || exit 1
```

### Documentation
- Use clear, concise language
- Include code examples
- Document parameters and return values
- Explain complex algorithms or workflows

## 🧪 Testing

### Running Tests
```bash
# Run all validation scripts
./validate-warpio.sh
.claude/validate-mcp-setup.sh

# Test specific experts
claude
> /expert-delegate data-expert "test HDF5 optimization"
> /expert-delegate hpc-expert "test SLURM script generation"
```

### Writing Tests
- Add test cases for new features
- Include edge cases and error conditions
- Test both success and failure scenarios
- Document expected behavior

## 📦 Pull Request Process

### 1. Before Submitting
- ✅ Code follows project style guidelines
- ✅ All tests pass
- ✅ Documentation is updated
- ✅ Changes are tested in development environment
- ✅ No sensitive information (API keys, passwords) in code

### 2. Creating the PR
1. **Title**: Use clear, descriptive titles
   - `feat: add HDF5 compression support`
   - `fix: resolve SLURM job submission timeout`
   - `docs: update installation guide`

2. **Description**: Include:
   - What changes were made
   - Why these changes are needed
   - How to test the changes
   - Screenshots or examples (if applicable)

3. **Labels**: Add appropriate labels
   - `enhancement`, `bug`, `documentation`, `testing`
   - `data-expert`, `hpc-expert`, `analysis-expert`

### 3. PR Review Process
- At least one maintainer will review your PR
- Address any requested changes
- Once approved, a maintainer will merge your PR
- Your contribution will be acknowledged!

## 🐛 Bug Reports

### How to Report a Bug
1. **Check Existing Issues**: Search for similar issues first
2. **Create New Issue**: Use the Bug Report template
3. **Provide Details**:
   - Warpio version
   - Operating system and environment
   - Steps to reproduce
   - Expected vs actual behavior
   - Error messages or logs
   - Configuration details

### Bug Report Template
```markdown
**Describe the Bug**
A clear description of what the bug is.

**To Reproduce**
Steps to reproduce the behavior:
1. Go to '...'
2. Click on '....'
3. Scroll down to '....'
4. See error

**Expected Behavior**
A clear description of what you expected to happen.

**Environment**
- Warpio Version: [e.g., 1.0.0]
- OS: [e.g., Ubuntu 22.04]
- Claude CLI Version: [e.g., 0.1.0]
- Python Version: [e.g., 3.9.7]

**Additional Context**
Add any other context about the problem here.
```

## ✨ Feature Requests

### How to Request a Feature
1. **Check Existing Issues**: Search for similar requests
2. **Create Feature Request**: Use the Feature Request template
3. **Provide Details**:
   - Clear description of the feature
   - Use case and benefits
   - Implementation suggestions (optional)
   - Examples or mockups (if applicable)

### Feature Request Template
```markdown
**Feature Description**
Brief description of the feature.

**Use Case**
Describe when and why this feature would be useful.

**Proposed Solution**
How do you think this should be implemented?

**Alternatives**
Any alternative solutions or workarounds?

**Additional Context**
Screenshots, examples, or references.
```

## 🎯 Adding New Experts

### 1. Create Expert Definition
Create a new file in `warpio/agents/`:
```bash
# warpio/agents/new-expert.md
---
name: new-expert
description: Brief description of expertise
tools: List of MCP tools and capabilities
---
```

### 2. Define MCP Tools
Add MCP configurations in `warpio/mcps/warpio-mcps.json`:
```json
{
  "mcpServers": {
    "new-tool": {
      "command": "uvx",
      "args": ["iowarp-mcps", "new-tool"],
      "description": "Description of the tool"
    }
  }
}
```

### 3. Add Activation Keywords
Update `warpio/WARPIO.md` with new expert routing rules.

### 4. Test Integration
```bash
# Test new expert activation
claude
> /expert-list  # Should show new expert
> /expert-delegate new-expert "test query"
```

## 📚 Documentation Contributions

### Types of Documentation
- **Installation Guides**: Setup and configuration
- **User Guides**: How to use specific features
- **API Documentation**: Expert and tool interfaces
- **Tutorials**: Step-by-step examples
- **Troubleshooting**: Common issues and solutions

### Documentation Standards
- Use clear, concise language
- Include practical examples
- Provide code snippets where helpful
- Update README.md for major features
- Test instructions for accuracy

## 🌍 Community Guidelines

### Code of Conduct
- Be respectful and inclusive
- Use welcoming language
- Be collaborative
- Focus on what is best for the community
- Show empathy toward other community members

### Communication
- Use GitHub issues for bug reports and feature requests
- Join discussions in GitHub discussions
- Be patient and helpful in responses
- Acknowledge contributions from others

### Recognition
- All contributors are acknowledged in our README
- Significant contributions may be highlighted
- We value all forms of contribution equally

## 🤝 Getting Help

### Where to Ask Questions
- **GitHub Issues**: For bugs and feature requests
- **GitHub Discussions**: For questions and community discussion
- **Documentation**: Check existing guides first

### Support Channels
- 📧 Email: [your-email@domain.com]
- 💬 Discord: [Discord server link]
- 📖 Documentation: [documentation site]

## 📄 License

By contributing to Warpio, you agree that your contributions will be licensed under the same license as the project (MIT License).

## 🙏 Acknowledgments

Thank you for contributing to Warpio! Your efforts help make scientific computing more accessible to researchers and developers worldwide.

---

*This contributing guide is inspired by open source best practices and is continuously improved by our community.*
