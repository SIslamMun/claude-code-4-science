#!/bin/bash
# Test zen-mcp connection to local AI

echo "🧪 Testing Zen-MCP Local AI Connection"
echo "======================================"
echo ""

# Test LM Studio connection
echo "1. Testing LM Studio at http://192.168.86.20:1234..."
if curl -s -X GET "http://192.168.86.20:1234/v1/models" > /dev/null 2>&1; then
    echo "   ✅ LM Studio is reachable!"
    echo "   Available models:"
    curl -s "http://192.168.86.20:1234/v1/models" | python3 -m json.tool 2>/dev/null | grep '"id"' | head -3
    
    # Test inference
    echo ""
    echo "2. Testing inference with qwen3-4b-thinking-2507..."
    RESPONSE=$(curl -s -X POST "http://192.168.86.20:1234/v1/chat/completions" \
        -H "Content-Type: application/json" \
        -d '{
            "model": "qwen3-4b-thinking-2507",
            "messages": [{"role": "user", "content": "Say hello in 5 words or less"}],
            "temperature": 0.7,
            "max_tokens": 50
        }' 2>/dev/null)
    
    if [ ! -z "$RESPONSE" ]; then
        echo "   ✅ Inference successful!"
        echo "   Response: $(echo $RESPONSE | python3 -c "import sys, json; print(json.load(sys.stdin)['choices'][0]['message']['content'])" 2>/dev/null || echo "Could not parse response")"
    else
        echo "   ❌ Inference failed - check model name"
    fi
else
    echo "   ❌ Cannot reach LM Studio at http://192.168.86.20:1234"
    echo "   Make sure LM Studio is running and the server is enabled"
fi

echo ""
echo "3. Testing Ollama at http://localhost:11434..."
if curl -s "http://localhost:11434/api/tags" > /dev/null 2>&1; then
    echo "   ✅ Ollama is reachable!"
    
    # Check if model exists
    if ollama list 2>/dev/null | grep -q "qwen3-4b-thinking-2507:latest"; then
        echo "   ✅ Model qwen3-4b-thinking-2507:latest is available"
        
        # Test inference
        echo ""
        echo "4. Testing Ollama inference..."
        RESPONSE=$(curl -s -X POST "http://localhost:11434/api/generate" \
            -d '{
                "model": "qwen3-4b-thinking-2507:latest",
                "prompt": "Say hello in 5 words or less",
                "stream": false
            }' 2>/dev/null)
        
        if [ ! -z "$RESPONSE" ]; then
            echo "   ✅ Inference successful!"
            echo "   Response: $(echo $RESPONSE | python3 -c "import sys, json; print(json.load(sys.stdin).get('response', 'No response'))" 2>/dev/null || echo "Could not parse")"
        fi
    else
        echo "   ⚠️  Model qwen3-4b-thinking-2507:latest not found"
        echo "   Install with: ollama pull qwen3-4b-thinking-2507:latest"
    fi
else
    echo "   ❌ Ollama not running. Start with: ollama serve"
fi

echo ""
echo "5. Testing zen-mcp-server installation..."
if uvx --from git+https://github.com/BeehiveInnovations/zen-mcp-server.git zen-mcp-server --help > /dev/null 2>&1; then
    echo "   ✅ zen-mcp-server can be installed/run"
else
    echo "   ⚠️  zen-mcp-server test failed, but will be installed on first use"
fi

echo ""
echo "======================================"
echo "Configuration Summary:"
echo "  Primary: LM Studio (192.168.86.20:1234)"
echo "  Model: qwen3-4b-thinking-2507"
echo "  Fallback: Ollama (localhost:11434)"
echo "  Model: qwen3-4b-thinking-2507:latest"
echo ""
echo "To switch between backends, run: ./.warpio/switch-local-ai.sh"