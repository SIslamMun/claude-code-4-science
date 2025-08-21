---
description: Configure local AI providers for Warpio
allowed-tools: Write, Read
---

# Local AI Configuration

## Current Configuration

### Primary Provider: LM Studio
- **API URL:** http://192.168.86.20:1234/v1
- **Model:** qwen3-4b-instruct-2507
- **API Key:** lm-studio
- **Status:** ✅ Active

### Supported Providers
- **LM Studio** (Current) - Local model hosting
- **Ollama** - Alternative local model hosting
- **Custom OpenAI-compatible** - Any OpenAI-compatible API

## Configuration Options

### 1. Switch to Ollama
If you prefer to use Ollama instead of LM Studio:

```bash
# Update your .env file
echo "LOCAL_AI_PROVIDER=ollama" >> .env
echo "OLLAMA_API_URL=http://localhost:11434/v1" >> .env
echo "OLLAMA_MODEL=your-model-name" >> .env
```

### 2. Change Model
To use a different model in LM Studio:

```bash
# Update your .env file
echo "LMSTUDIO_MODEL=your-new-model-name" >> .env
```

### 3. Custom Provider
For other OpenAI-compatible APIs:

```bash
# Update your .env file
echo "LOCAL_AI_PROVIDER=custom" >> .env
echo "CUSTOM_API_URL=your-api-url" >> .env
echo "CUSTOM_API_KEY=your-api-key" >> .env
echo "CUSTOM_MODEL=your-model-name" >> .env
```

## Testing Configuration

After making changes, test with:
```bash
/warpio-local-test
```

## Environment Variables

The following variables control local AI behavior:

- `LOCAL_AI_PROVIDER` - Provider type (lmstudio/ollama/custom)
- `LMSTUDIO_API_URL` - LM Studio API endpoint
- `LMSTUDIO_MODEL` - LM Studio model name
- `OLLAMA_API_URL` - Ollama API endpoint
- `OLLAMA_MODEL` - Ollama model name
- `CUSTOM_API_URL` - Custom provider URL
- `CUSTOM_MODEL` - Custom provider model

## Next Steps

1. Update your `.env` file with desired configuration
2. Test the connection with `/warpio-local-test`
3. Check status with `/warpio-local-status`