#!/bin/bash
# Warpio Status Line - Basic Version
# Blue-Green-Orange color spectrum theme

input=$(cat)

# Extract values using jq
MODEL_DISPLAY=$(echo "$input" | jq -r '.model.display_name // "Claude"')
CURRENT_DIR=$(echo "$input" | jq -r '.workspace.current_dir // "."')
PROJECT_DIR=$(echo "$input" | jq -r '.workspace.project_dir // "."')
TOKEN_COUNT=$(echo "$input" | jq -r '.usage.total_tokens // 0')

# Colors from Warpio theme (matching warpio-theme.json)
BLUE='\033[38;2;0;180;255m'    # #00B4FF - persona color
CYAN='\033[38;2;0;208;255m'    # #00D0FF - secondary blue
GREEN='\033[38;2;0;255;136m'   # #00FF88 - directory color
YELLOW='\033[38;2;255;255;0m'  # #FFFF00 - git color
ORANGE='\033[38;2;255;136;0m'  # #FF8800 - tokens color
RESET='\033[0m'

# Get directory name
DIR_NAME="${CURRENT_DIR##*/}"
[ -z "$DIR_NAME" ] && DIR_NAME="root"

# Check git branch
GIT_BRANCH=""
if git rev-parse --git-dir > /dev/null 2>&1; then
    BRANCH=$(git branch --show-current 2>/dev/null)
    if [ -n "$BRANCH" ]; then
        GIT_BRANCH=" ${GREEN}🌿${BRANCH}${RESET}"
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

# Check for active local AI
LOCAL_AI=""
if pgrep -f "ollama" > /dev/null 2>&1; then
    LOCAL_AI=" ${CYAN}🤖O${RESET}"
elif lsof -i:1234 > /dev/null 2>&1; then
    LOCAL_AI=" ${CYAN}🤖L${RESET}"
fi

# Format token count
if [ "$TOKEN_COUNT" -gt 1000000 ]; then
    TOKEN_DISPLAY="$(echo "scale=1; $TOKEN_COUNT/1000000" | bc)M"
elif [ "$TOKEN_COUNT" -gt 1000 ]; then
    TOKEN_DISPLAY="$(echo "scale=1; $TOKEN_COUNT/1000" | bc)K"
else
    TOKEN_DISPLAY="$TOKEN_COUNT"
fi

# Build status line with color spectrum
echo -e "${BLUE}${PERSONA_ICON} Warpio${RESET} | ${CYAN}📁${DIR_NAME}${GIT_BRANCH}${LOCAL_AI}${RESET} | ${GREEN}[$MODEL_DISPLAY]${RESET} | ${YELLOW}🎯${TOKEN_DISPLAY}${RESET} | ${ORANGE}iowarp.ai${RESET}"