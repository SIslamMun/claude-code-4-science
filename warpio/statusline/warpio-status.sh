#!/bin/bash
# Dynamic Warpio status line with orchestration information

input=$(cat)

# Extract values using jq
MODEL_DISPLAY=$(echo "$input" | jq -r '.model.display_name // "Claude"')
CURRENT_DIR=$(echo "$input" | jq -r '.workspace.current_dir // "."')
TOKEN_COUNT=$(echo "$input" | jq -r '.usage.total_tokens // 0')

# Get just the directory name, not full path
DIR_NAME="${CURRENT_DIR##*/}"
[ -z "$DIR_NAME" ] && DIR_NAME="root"

# Check for active persona (from environment or default)
PERSONA="${WARPIO_PERSONA:-warpio}"
PERSONA_ICON=""
case "$PERSONA" in
    "data-expert") PERSONA_ICON="📊" ;;
    "hpc-expert") PERSONA_ICON="🖥️" ;;
    "analysis-expert") PERSONA_ICON="📈" ;;
    "research-expert") PERSONA_ICON="🔬" ;;
    "workflow-expert") PERSONA_ICON="⚙️" ;;
    *) PERSONA_ICON="🚀" ;;
esac

# Check for active local AI
LOCAL_AI_STATUS=""
if pgrep -f "ollama" > /dev/null 2>&1; then
    LOCAL_AI_STATUS=" | 🤖 Ollama"
elif lsof -i:1234 > /dev/null 2>&1; then
    LOCAL_AI_STATUS=" | 🤖 LMStudio"
fi

# Check for active workflows
WORKFLOW_COUNT=0
if [ -d "/tmp/warpio-workflows" ]; then
    WORKFLOW_COUNT=$(find /tmp/warpio-workflows -name "*.jsonl" -mmin -60 2>/dev/null | wc -l)
fi
WORKFLOW_STATUS=""
if [ "$WORKFLOW_COUNT" -gt 0 ]; then
    WORKFLOW_STATUS=" | ⚡ $WORKFLOW_COUNT active"
fi

# Format token count
if [ "$TOKEN_COUNT" -gt 1000000 ]; then
    TOKEN_DISPLAY="$(echo "scale=1; $TOKEN_COUNT/1000000" | bc)M"
elif [ "$TOKEN_COUNT" -gt 1000 ]; then
    TOKEN_DISPLAY="$(echo "scale=1; $TOKEN_COUNT/1000" | bc)K"
else
    TOKEN_DISPLAY="$TOKEN_COUNT"
fi

# Build status line
echo "$PERSONA_ICON Warpio | 📁 $DIR_NAME | [$MODEL_DISPLAY]$LOCAL_AI_STATUS$WORKFLOW_STATUS | 🎯 $TOKEN_DISPLAY tokens | iowarp.ai"