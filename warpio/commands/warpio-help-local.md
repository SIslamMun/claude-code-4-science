---
description: Detailed help for Warpio local AI management
allowed-tools: Read
---

# Warpio Local AI Help

## Local AI Overview

Warpio uses local AI providers for quick, cost-effective, and low-latency tasks while reserving Claude (the main AI) for complex reasoning and planning.

## Supported Providers

### 🤖 LM Studio (Recommended)
**Best for:** Most users with GPU-enabled systems

**Setup:**
1. Download from https://lmstudio.ai
2. Install models (qwen3-4b-instruct-2507 recommended)
3. Start local server on port 1234
4. Configure in Warpio with `/warpio-local-config`

**Configuration:**
```bash
LOCAL_AI_PROVIDER=lmstudio
LMSTUDIO_API_URL=http://192.168.86.20:1234/v1
LMSTUDIO_MODEL=qwen3-4b-instruct-2507
LMSTUDIO_API_KEY=lm-studio
```

### 🦙 Ollama
**Best for:** CPU-only systems or alternative models

**Setup:**
1. Install Ollama from https://ollama.ai
2. Pull models: `ollama pull llama3.2`
3. Start service: `ollama serve`
4. Configure in Warpio

**Configuration:**
```bash
LOCAL_AI_PROVIDER=ollama
OLLAMA_API_URL=http://localhost:11434/v1
OLLAMA_MODEL=llama3.2
```

## Local AI Commands

### Check Status
```bash
/warpio-local-status
```
Shows connection status, response times, and capabilities.

### Configure Provider
```bash
/warpio-local-config
```
Interactive setup for LM Studio, Ollama, or custom providers.

### Test Connection
```bash
/warpio-local-test
```
Tests connectivity, authentication, and basic functionality.

## When to Use Local AI

### ✅ Ideal for Local AI
- **Quick Analysis:** Statistical summaries, data validation
- **Format Conversion:** HDF5→Parquet, data restructuring
- **Documentation:** Code documentation, README generation
- **Simple Queries:** Lookups, basic explanations
- **Real-time Tasks:** Interactive analysis, quick iterations

### ✅ Best for Claude (Main AI)
- **Complex Reasoning:** Multi-step problem solving
- **Creative Tasks:** Brainstorming, design decisions
- **Deep Analysis:** Comprehensive research and planning
- **Large Tasks:** Code generation, architectural decisions
- **Context-Heavy:** Tasks requiring extensive conversation history

## Performance Optimization

### Speed Benefits
- **Local Processing:** No network latency
- **Direct Access:** Immediate response to local resources
- **Optimized Hardware:** Uses your local GPU/CPU efficiently

### Cost Benefits
- **No API Costs:** Free for local model inference
- **Scalable:** Run multiple models simultaneously
- **Privacy:** Data stays on your machine

## Configuration Examples

### Basic LM Studio Setup
```bash
# .env file
LOCAL_AI_PROVIDER=lmstudio
LMSTUDIO_API_URL=http://localhost:1234/v1
LMSTUDIO_MODEL=qwen3-4b-instruct-2507
LMSTUDIO_API_KEY=lm-studio
```

### Advanced LM Studio Setup
```bash
# .env file
LOCAL_AI_PROVIDER=lmstudio
LMSTUDIO_API_URL=http://192.168.1.100:1234/v1
LMSTUDIO_MODEL=qwen3-8b-instruct
LMSTUDIO_API_KEY=your-custom-key
```

### Ollama Setup
```bash
# .env file
LOCAL_AI_PROVIDER=ollama
OLLAMA_API_URL=http://localhost:11434/v1
OLLAMA_MODEL=llama3.2:8b
```

## Troubleshooting

### Connection Issues
**Problem:** "Connection failed"
- Check if LM Studio/Ollama is running
- Verify API URL is correct
- Check firewall settings
- Try different port

**Problem:** "Authentication failed"
- Verify API key matches server configuration
- Check API key format
- Ensure proper permissions

### Performance Issues
**Problem:** "Slow response times"
- Check system resources (CPU/GPU usage)
- Verify model is loaded in memory
- Consider using a smaller/faster model
- Close other resource-intensive applications

### Model Issues
**Problem:** "Model not found"
- Check model name spelling
- Verify model is installed and available
- Try listing available models
- Reinstall model if corrupted

## Integration with Experts

Local AI is automatically used by experts for appropriate tasks:

- **Data Expert:** Quick format validation, metadata extraction
- **Analysis Expert:** Statistical summaries, basic plotting
- **Research Expert:** Literature search, citation formatting
- **Workflow Expert:** Pipeline validation, simple automation

## Best Practices

1. **Start Simple:** Use default configurations initially
2. **Test Thoroughly:** Use `/warpio-local-test` after changes
3. **Monitor Performance:** Check `/warpio-local-status` regularly
4. **Choose Right Model:** Balance speed vs. capability
5. **Keep Updated:** Update models periodically for best performance

## Advanced Configuration

### Custom API Endpoints
```bash
# For custom OpenAI-compatible APIs
LOCAL_AI_PROVIDER=custom
CUSTOM_API_URL=https://your-api-endpoint/v1
CUSTOM_API_KEY=your-api-key
CUSTOM_MODEL=your-model-name
```

### Multiple Models
You can configure different models for different tasks by updating the `.env` file and restarting your local AI provider.

### Resource Management
- Monitor GPU/CPU usage during intensive tasks
- Adjust model parameters for your hardware
- Use model quantization for better performance on limited hardware