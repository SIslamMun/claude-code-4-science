#!/bin/bash
# Warpio Status Line - Default (Intermediate Version)
# Enhanced with more Warpio-specific information and proper theming
# This script uses the intermediate version as the default for balanced information display

input=$(cat)

# Extract values using jq
MODEL_DISPLAY=$(echo "$input" | jq -r '.model.display_name // "Claude"')
CURRENT_DIR=$(echo "$input" | jq -r '.workspace.current_dir // "."')
PROJECT_DIR=$(echo "$input" | jq -r '.workspace.project_dir // "."')
TOKEN_COUNT=$(echo "$input" | jq -r '.usage.total_tokens // 0')
SESSION_ID=$(echo "$input" | jq -r '.session_id // ""')

# Colors from Warpio theme (blue to green to orange spectrum)
BLUE='\033[38;5;39m'      # Bright blue
CYAN='\033[38;5;51m'      # Cyan
GREEN='\033[38;5;46m'     # Bright green
YELLOW='\033[38;5;226m'   # Yellow
ORANGE='\033[38;5;208m'   # Orange
RED='\033[38;5;196m'      # Bright red
RESET='\033[0m'

# Get directory name
DIR_NAME="${CURRENT_DIR##*/}"
[ -z "$DIR_NAME" ] && DIR_NAME="root"

# Check git status
GIT_INFO=""
if git rev-parse --git-dir > /dev/null 2>&1; then
    BRANCH=$(git branch --show-current 2>/dev/null)
    if [ -n "$BRANCH" ]; then
        # Check for uncommitted changes
        if git status --porcelain | grep -q .; then
            GIT_INFO=" ${YELLOW}🌿${BRANCH}*${RESET}"
        else
            GIT_INFO=" ${GREEN}🌿${BRANCH}${RESET}"
        fi
    fi
fi

# Check for active persona
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

# Check for active local AI with more detail
LOCAL_AI=""
if pgrep -f "ollama" > /dev/null 2>&1; then
    LOCAL_AI=" ${CYAN}🤖Ollama${RESET}"
elif lsof -i:1234 > /dev/null 2>&1; then
    LOCAL_AI=" ${CYAN}🤖LMStudio${RESET}"
fi

# Check for active workflows
WORKFLOW_COUNT=0
if [ -d "/tmp/warpio-workflows" ]; then
    WORKFLOW_COUNT=$(find /tmp/warpio-workflows -name "*.jsonl" -mmin -60 2>/dev/null | wc -l)
fi
WORKFLOW_INFO=""
if [ "$WORKFLOW_COUNT" -gt 0 ]; then
    WORKFLOW_INFO=" ${ORANGE}⚡${WORKFLOW_COUNT}${RESET}"
fi

# Check MCP status (simplified)
MCP_COUNT=0
if [ -f ".mcp.json" ]; then
    MCP_COUNT=$(jq '.mcpServers | length' .mcp.json 2>/dev/null || echo "0")
fi
MCP_INFO=""
if [ "$MCP_COUNT" -gt 0 ]; then
    MCP_INFO=" ${BLUE}🔧${MCP_COUNT}${RESET}"
fi

# Format token count with color coding
if [ "$TOKEN_COUNT" -gt 1000000 ]; then
    TOKEN_DISPLAY="$(echo "scale=1; $TOKEN_COUNT/1000000" | bc)M"
    TOKEN_COLOR=$RED
elif [ "$TOKEN_COUNT" -gt 100000 ]; then
    TOKEN_DISPLAY="$(echo "scale=1; $TOKEN_COUNT/1000" | bc)K"
    TOKEN_COLOR=$YELLOW
elif [ "$TOKEN_COUNT" -gt 1000 ]; then
    TOKEN_DISPLAY="$(echo "scale=1; $TOKEN_COUNT/1000" | bc)K"
    TOKEN_COLOR=$GREEN
else
    TOKEN_DISPLAY="$TOKEN_COUNT"
    TOKEN_COLOR=$BLUE
fi

# Build enhanced status line with proper theming
echo -e "${BLUE}${PERSONA_ICON} Warpio${RESET}${MCP_INFO}${WORKFLOW_INFO} | ${CYAN}📁${DIR_NAME}${GIT_INFO}${LOCAL_AI}${RESET} | ${GREEN}[$MODEL_DISPLAY]${RESET} | ${TOKEN_COLOR}🎯${TOKEN_DISPLAY}${RESET} | ${ORANGE}iowarp.ai${RESET}"