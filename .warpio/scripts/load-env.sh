#!/bin/bash
# Dynamic environment loader for Warpio

# Load .env from project root
if [ -f ".env" ]; then
    export $(grep -v '^#' .env | xargs) 2>/dev/null
    
    # Determine which API URL and model to use based on provider
    case "$LOCAL_AI_PROVIDER" in
        "lmstudio")
            export CUSTOM_API_URL="$LMSTUDIO_API_URL"
            export CUSTOM_MODEL_NAME="$LMSTUDIO_MODEL"
            export CUSTOM_API_KEY="$LMSTUDIO_API_KEY"
            ;;
        "ollama")
            export CUSTOM_API_URL="$OLLAMA_API_URL"
            export CUSTOM_MODEL_NAME="$OLLAMA_MODEL"
            export CUSTOM_API_KEY="$OLLAMA_API_KEY"
            ;;
        *)
            # No local AI or unknown provider
            export CUSTOM_API_URL=""
            export CUSTOM_MODEL_NAME=""
            export CUSTOM_API_KEY=""
            ;;
    esac
else
    # Create from example if not exists
    if [ -f ".claude/.env.example" ]; then
        cp .claude/.env.example .env
        echo "Created .env from template - please configure"
    fi
fi