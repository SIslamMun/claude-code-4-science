---
description: Delegate task to local AI model via zen-mcp
argument-hint: <task description>
allowed-tools: mcp__zen__chat, mcp__zen__analyze, Bash
---

## 🤖 Delegating to Local AI

Task: $ARGUMENTS

I'll delegate this task to a local AI model through the zen-mcp-server for efficient processing.

The zen-mcp-server will automatically route to:
- **Ollama** (if available on port 11434)
- **LM Studio** (if available on port 1234)
- **Cloud fallback** (if local models unavailable)

Processing your request through the orchestration layer...