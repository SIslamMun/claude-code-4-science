#!/bin/bash
# Switch between Ollama and LMStudio for zen-mcp

echo "🤖 Warpio Local AI Configuration Switcher"
echo "========================================="
echo ""
echo "Select your local AI backend:"
echo "1) LM Studio (192.168.86.20:1234) - qwen3-4b-thinking-2507"
echo "2) Ollama (localhost:11434) - qwen3-4b-thinking-2507:latest"
echo ""
read -p "Enter choice [1-2]: " choice

MCP_CONFIG=".warpio/mcp-configs/warpio-mcps.json"
ENV_CONFIG=".warpio/zen-mcp.env"

case $choice in
    1)
        echo "Configuring for LM Studio..."
        # Update MCP config for LMStudio
        sed -i 's|"CUSTOM_API_URL": ".*"|"CUSTOM_API_URL": "http://192.168.86.20:1234/v1"|' "$MCP_CONFIG"
        sed -i 's|"CUSTOM_MODEL_NAME": ".*"|"CUSTOM_MODEL_NAME": "qwen3-4b-thinking-2507"|' "$MCP_CONFIG"
        sed -i 's|"description": "Multi-model AI orchestration.*"|"description": "Multi-model AI orchestration - LMStudio (192.168.86.20:1234) with qwen3-4b-thinking-2507"|' "$MCP_CONFIG"
        
        # Update env file
        sed -i '5s|^# ||' "$ENV_CONFIG"  # Uncomment LMStudio
        sed -i '6s|^# ||' "$ENV_CONFIG"
        sed -i '7s|^# ||' "$ENV_CONFIG"
        sed -i '10s|^|# |' "$ENV_CONFIG"  # Comment Ollama
        sed -i '11s|^|# |' "$ENV_CONFIG"
        sed -i '12s|^|# |' "$ENV_CONFIG"
        
        echo "✅ Configured for LM Studio at http://192.168.86.20:1234"
        
        # Test connection
        echo ""
        echo "Testing LM Studio connection..."
        if curl -s -X GET "http://192.168.86.20:1234/v1/models" > /dev/null 2>&1; then
            echo "✅ LM Studio is reachable!"
            curl -s "http://192.168.86.20:1234/v1/models" | jq -r '.data[].id' 2>/dev/null | head -5
        else
            echo "⚠️  Cannot reach LM Studio. Make sure it's running and accessible."
        fi
        ;;
        
    2)
        echo "Configuring for Ollama..."
        # Update MCP config for Ollama
        sed -i 's|"CUSTOM_API_URL": ".*"|"CUSTOM_API_URL": "http://localhost:11434/v1"|' "$MCP_CONFIG"
        sed -i 's|"CUSTOM_MODEL_NAME": ".*"|"CUSTOM_MODEL_NAME": "qwen3-4b-thinking-2507:latest"|' "$MCP_CONFIG"
        sed -i 's|"description": "Multi-model AI orchestration.*"|"description": "Multi-model AI orchestration - Ollama (localhost:11434) with qwen3-4b-thinking-2507:latest"|' "$MCP_CONFIG"
        
        # Update env file
        sed -i '5s|^|# |' "$ENV_CONFIG"  # Comment LMStudio
        sed -i '6s|^|# |' "$ENV_CONFIG"
        sed -i '7s|^|# |' "$ENV_CONFIG"
        sed -i '10s|^# ||' "$ENV_CONFIG"  # Uncomment Ollama
        sed -i '11s|^# ||' "$ENV_CONFIG"
        sed -i '12s|^# ||' "$ENV_CONFIG"
        
        echo "✅ Configured for Ollama at http://localhost:11434"
        
        # Test connection
        echo ""
        echo "Testing Ollama connection..."
        if ollama list > /dev/null 2>&1; then
            echo "✅ Ollama is running!"
            echo "Available models:"
            ollama list | grep -E "qwen|llama" | head -5
        else
            echo "⚠️  Ollama not running. Start with: ollama serve"
        fi
        ;;
        
    *)
        echo "Invalid choice. Exiting."
        exit 1
        ;;
esac

echo ""
echo "Configuration complete! Restart Claude Code to apply changes."