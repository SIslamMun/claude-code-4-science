---
description: Test local AI connectivity and functionality
allowed-tools: Bash
---

# Local AI Connection Test

## Testing Local AI Connection

I'll test your local AI provider to ensure it's working correctly with Warpio.

### Test Results

**Connection Test:**
- **API Endpoint:** Testing connectivity...
- **Authentication:** Verifying credentials...
- **Model Availability:** Checking model status...
- **Response Time:** Measuring latency...

**Functionality Test:**
- **Simple Query:** Testing basic text generation...
- **Tool Usage:** Testing MCP tool integration...
- **Error Handling:** Testing error scenarios...

### Expected Results

✅ **Connection:** Should be successful
✅ **Response Time:** Should be < 2 seconds
✅ **Model:** Should respond with valid output
✅ **Tools:** Should work with MCP integration

### Troubleshooting

If tests fail:

1. **Connection Failed**
   - Check if LM Studio/Ollama is running
   - Verify API URL in `.env` file
   - Check firewall settings

2. **Authentication Failed**
   - Verify API key is correct
   - Check API key format
   - Ensure proper permissions

3. **Slow Response**
   - Check system resources (CPU/GPU usage)
   - Verify model is loaded in memory
   - Consider using a smaller model

4. **Model Not Found**
   - Check model name spelling
   - Verify model is installed and available
   - Try a different model

### Quick Fix Commands

```bash
# Check if LM Studio is running
curl http://192.168.86.20:1234/v1/models

# Check if Ollama is running
curl http://localhost:11434/v1/models

# Test API key
curl -H "Authorization: Bearer your-api-key" http://your-api-url/v1/models
```

Run `/warpio-local-config` to update your configuration if needed.