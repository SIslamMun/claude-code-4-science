#!/bin/bash
# Warpio Status Line - Advanced Version
# Comprehensive information display with full Warpio integration

input=$(cat)

# Extract values using jq
MODEL_DISPLAY=$(echo "$input" | jq -r '.model.display_name // "Claude"')
CURRENT_DIR=$(echo "$input" | jq -r '.workspace.current_dir // "."')
PROJECT_DIR=$(echo "$input" | jq -r '.workspace.project_dir // "."')
TOKEN_COUNT=$(echo "$input" | jq -r '.usage.total_tokens // 0')
SESSION_ID=$(echo "$input" | jq -r '.session_id // ""')
VERSION=$(echo "$input" | jq -r '.version // "1.0.0"')

# Colors from Warpio theme (matching warpio-theme.json)
BLUE='\033[38;2;0;180;255m'    # #00B4FF - persona color
CYAN='\033[38;2;0;208;255m'    # #00D0FF - secondary blue
GREEN='\033[38;2;0;255;136m'   # #00FF88 - directory color
YELLOW='\033[38;2;255;255;0m'  # #FFFF00 - git color
ORANGE='\033[38;2;255;136;0m'  # #FF8800 - tokens color
RED='\033[38;2;255;68;68m'     # #FF4444 - error color
PURPLE='\033[38;2;255;0;255m'  # #FF00FF - magenta
RESET='\033[0m'

# Get directory info
DIR_NAME="${CURRENT_DIR##*/}"
[ -z "$DIR_NAME" ] && DIR_NAME="root"
REL_PATH="."
if [ "$CURRENT_DIR" != "$PROJECT_DIR" ]; then
    REL_PATH="${CURRENT_DIR#$PROJECT_DIR}"
    REL_PATH="${REL_PATH#/}"
    [ -z "$REL_PATH" ] && REL_PATH="."
fi

# Enhanced git information
GIT_INFO=""
if git rev-parse --git-dir > /dev/null 2>&1; then
    BRANCH=$(git branch --show-current 2>/dev/null)
    if [ -n "$BRANCH" ]; then
        # Check for changes
        if git status --porcelain | grep -q .; then
            GIT_INFO=" ${YELLOW}🌿${BRANCH}*${RESET}"
        else
            GIT_INFO=" ${GREEN}🌿${BRANCH}${RESET}"
        fi

        # Add remote status if available
        REMOTE=$(git rev-list --count --left-right ${BRANCH}...origin/${BRANCH} 2>/dev/null | tr '\t' ' ')
        if [ -n "$REMOTE" ]; then
            BEHIND=$(echo $REMOTE | cut -d' ' -f1)
            AHEAD=$(echo $REMOTE | cut -d' ' -f2)
            if [ "$BEHIND" -gt 0 ]; then
                GIT_INFO="${GIT_INFO}${RED}↓${BEHIND}${RESET}"
            fi
            if [ "$AHEAD" -gt 0 ]; then
                GIT_INFO="${GIT_INFO}${GREEN}↑${AHEAD}${RESET}"
            fi
        fi
    fi
fi

# Enhanced persona information
PERSONA="${WARPIO_PERSONA:-warpio}"
PERSONA_ICON=""
PERSONA_NAME=""
case "$PERSONA" in
    "data-expert")
        PERSONA_ICON="📊"
        PERSONA_NAME="Data"
        ;;
    "hpc-expert")
        PERSONA_ICON="🖥️"
        PERSONA_NAME="HPC"
        ;;
    "analysis-expert")
        PERSONA_ICON="📈"
        PERSONA_NAME="Analysis"
        ;;
    "research-expert")
        PERSONA_ICON="🔬"
        PERSONA_NAME="Research"
        ;;
    "workflow-expert")
        PERSONA_ICON="⚙️"
        PERSONA_NAME="Workflow"
        ;;
    *)
        PERSONA_ICON="🚀"
        PERSONA_NAME="Warpio"
        ;;
esac

# Enhanced local AI detection
LOCAL_AI=""
LOCAL_MODEL=""
if pgrep -f "ollama" > /dev/null 2>&1; then
    # Try to get Ollama model info
    OLLAMA_MODEL=$(curl -s http://localhost:11434/api/tags 2>/dev/null | jq -r '.models[0].name' 2>/dev/null | head -1)
    if [ -n "$OLLAMA_MODEL" ]; then
        LOCAL_AI=" ${CYAN}🤖O:${OLLAMA_MODEL}${RESET}"
    else
        LOCAL_AI=" ${CYAN}🤖Ollama${RESET}"
    fi
elif lsof -i:1234 > /dev/null 2>&1; then
    LOCAL_AI=" ${CYAN}🤖LMStudio${RESET}"
fi

# Enhanced workflow information
WORKFLOW_INFO=""
if [ -d "/tmp/warpio-workflows" ]; then
    ACTIVE_COUNT=$(find /tmp/warpio-workflows -name "*.jsonl" -mmin -60 2>/dev/null | wc -l)
    TOTAL_COUNT=$(find /tmp/warpio-workflows -name "*.jsonl" 2>/dev/null | wc -l)

    if [ "$ACTIVE_COUNT" -gt 0 ]; then
        WORKFLOW_INFO=" ${ORANGE}⚡${ACTIVE_COUNT}/${TOTAL_COUNT}${RESET}"
    elif [ "$TOTAL_COUNT" -gt 0 ]; then
        WORKFLOW_INFO=" ${YELLOW}⚡${TOTAL_COUNT}${RESET}"
    fi
fi

# Enhanced MCP information
MCP_INFO=""
if [ -f ".mcp.json" ]; then
    MCP_COUNT=$(jq '.mcpServers | length' .mcp.json 2>/dev/null || echo "0")
    if [ "$MCP_COUNT" -gt 0 ]; then
        # Check which MCPs are critical for current persona
        case "$PERSONA" in
            "data-expert")
                HDF5_STATUS=$(jq 'has("mcpServers.hdf5")' .mcp.json 2>/dev/null || echo "false")
                [ "$HDF5_STATUS" = "true" ] && MCP_INFO="${MCP_INFO}${GREEN}H${RESET}" || MCP_INFO="${MCP_INFO}${RED}H${RESET}"
                ;;
            "hpc-expert")
                SLURM_STATUS=$(jq 'has("mcpServers.slurm")' .mcp.json 2>/dev/null || echo "false")
                [ "$SLURM_STATUS" = "true" ] && MCP_INFO="${MCP_INFO}${GREEN}S${RESET}" || MCP_INFO="${MCP_INFO}${RED}S${RESET}"
                ;;
            "analysis-expert")
                PANDAS_STATUS=$(jq 'has("mcpServers.pandas")' .mcp.json 2>/dev/null || echo "false")
                [ "$PANDAS_STATUS" = "true" ] && MCP_INFO="${MCP_INFO}${GREEN}P${RESET}" || MCP_INFO="${MCP_INFO}${RED}P${RESET}"
                ;;
            "research-expert")
                ARXIV_STATUS=$(jq 'has("mcpServers.arxiv")' .mcp.json 2>/dev/null || echo "false")
                [ "$ARXIV_STATUS" = "true" ] && MCP_INFO="${MCP_INFO}${GREEN}A${RESET}" || MCP_INFO="${MCP_INFO}${RED}A${RESET}"
                ;;
            *)
                MCP_INFO=" ${BLUE}🔧${MCP_COUNT}${RESET}"
                ;;
        esac
    fi
fi

# Enhanced token display with usage indicators
if [ "$TOKEN_COUNT" -gt 1000000 ]; then
    TOKEN_DISPLAY="$(echo "scale=1; $TOKEN_COUNT/1000000" | bc)M"
    TOKEN_COLOR=$RED
    TOKEN_ICON="🔥"
elif [ "$TOKEN_COUNT" -gt 500000 ]; then
    TOKEN_DISPLAY="$(echo "scale=1; $TOKEN_COUNT/1000" | bc)K"
    TOKEN_COLOR=$ORANGE
    TOKEN_ICON="⚠️"
elif [ "$TOKEN_COUNT" -gt 100000 ]; then
    TOKEN_DISPLAY="$(echo "scale=1; $TOKEN_COUNT/1000" | bc)K"
    TOKEN_COLOR=$YELLOW
    TOKEN_ICON="🎯"
elif [ "$TOKEN_COUNT" -gt 1000 ]; then
    TOKEN_DISPLAY="$(echo "scale=1; $TOKEN_COUNT/1000" | bc)K"
    TOKEN_COLOR=$GREEN
    TOKEN_ICON="🎯"
else
    TOKEN_DISPLAY="$TOKEN_COUNT"
    TOKEN_COLOR=$BLUE
    TOKEN_ICON="🎯"
fi

# Session information
SESSION_INFO=""
if [ -n "$SESSION_ID" ]; then
    SESSION_SHORT="${SESSION_ID:0:4}"
    SESSION_INFO=" ${PURPLE}🆔${SESSION_SHORT}${RESET}"
fi

# Build comprehensive status line
echo -e "${BLUE}${PERSONA_ICON}${PERSONA_NAME}${RESET}${MCP_INFO}${WORKFLOW_INFO}${SESSION_INFO} | ${CYAN}📁${DIR_NAME}${GIT_INFO}${LOCAL_AI}${RESET} | ${GREEN}[$MODEL_DISPLAY]${RESET} | ${TOKEN_COLOR}${TOKEN_ICON}${TOKEN_DISPLAY}${RESET} | ${ORANGE}v${VERSION}${RESET}"