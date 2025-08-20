#!/bin/bash
# ========================================================================
# WARPIO SHARED UTILITIES
# Common functions used across all Warpio scripts
# ========================================================================

# Colors for output
export RED='\033[0;31m'
export GREEN='\033[0;32m'
export YELLOW='\033[1;33m'
export BLUE='\033[0;34m'
export MAGENTA='\033[0;35m'
export CYAN='\033[0;36m'
export BOLD='\033[1m'
export NC='\033[0m' # No Color

# ========================================================================
# LOGGING FUNCTIONS
# ========================================================================

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}✓${NC} $1"
}

log_error() {
    echo -e "${RED}✗${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

log_step() {
    local step_num=$1
    local total_steps=$2
    local message=$3
    echo -e "${BLUE}[$step_num/$total_steps]${NC} $message"
}

# ========================================================================
# ENVIRONMENT FUNCTIONS
# ========================================================================

load_env() {
    local env_file="${1:-.env}"
    if [ -f "$env_file" ]; then
        export $(grep -v '^#' "$env_file" | xargs) 2>/dev/null
        return 0
    fi
    return 1
}

get_custom_api_config() {
    # Returns the API configuration based on LOCAL_AI_PROVIDER
    case "$LOCAL_AI_PROVIDER" in
        "lmstudio")
            echo "CUSTOM_API_URL=$LMSTUDIO_API_URL"
            echo "CUSTOM_MODEL_NAME=$LMSTUDIO_MODEL"
            echo "CUSTOM_API_KEY=$LMSTUDIO_API_KEY"
            ;;
        "ollama")
            echo "CUSTOM_API_URL=$OLLAMA_API_URL"
            echo "CUSTOM_MODEL_NAME=$OLLAMA_MODEL"
            echo "CUSTOM_API_KEY=$OLLAMA_API_KEY"
            ;;
        *)
            echo "CUSTOM_API_URL="
            echo "CUSTOM_MODEL_NAME="
            echo "CUSTOM_API_KEY="
            ;;
    esac
}

# ========================================================================
# DEPENDENCY CHECKING
# ========================================================================

check_command() {
    local cmd=$1
    local name=${2:-$1}
    if command -v "$cmd" &> /dev/null; then
        log_success "$name detected: $(which $cmd)"
        return 0
    else
        return 1
    fi
}

check_uv() {
    if ! check_command uv "UV package manager"; then
        log_warning "UV not installed"
        echo "   Install with: curl -LsSf https://astral.sh/uv/install.sh | sh"
        return 1
    fi
    return 0
}

check_claude_cli() {
    if ! check_command claude "Claude CLI"; then
        log_warning "Claude CLI not installed"
        echo "   Install with: npm install -g @anthropic-ai/claude-cli"
        return 1
    fi
    return 0
}

check_jq() {
    if ! check_command jq "jq JSON processor"; then
        log_warning "jq not installed (optional but recommended)"
        echo "   Install with: sudo apt-get install jq (Linux) or brew install jq (Mac)"
        return 1
    fi
    return 0
}

# ========================================================================
# LOCAL AI DETECTION
# ========================================================================

detect_lmstudio() {
    local api_url="${1:-http://localhost:1234}"
    if timeout 2 curl -s "$api_url/v1/models" >/dev/null 2>&1; then
        log_success "LM Studio detected at $api_url"
        return 0
    fi
    return 1
}

detect_ollama() {
    if command -v ollama &> /dev/null; then
        if ollama list &>/dev/null; then
            log_success "Ollama detected and running"
            return 0
        else
            log_warning "Ollama installed but not running"
            echo "   Start with: ollama serve"
            return 1
        fi
    fi
    return 1
}

detect_local_ai() {
    local found=false
    
    log_info "Detecting local AI services..."
    
    # Check LM Studio on common ports
    for port in 1234 8080 5000; do
        if detect_lmstudio "http://localhost:$port"; then
            echo "   Port: $port"
            found=true
            break
        fi
    done
    
    # Check Ollama
    if detect_ollama; then
        found=true
    fi
    
    if ! $found; then
        log_warning "No local AI services detected"
        echo "   Options:"
        echo "   - Install Ollama: https://ollama.ai"
        echo "   - Install LM Studio: https://lmstudio.ai"
        return 1
    fi
    return 0
}

# ========================================================================
# CONNECTION TESTING
# ========================================================================

test_ai_connection() {
    local api_url=$1
    local model=$2
    local provider=$3
    
    log_info "Testing $provider connection..."
    
    case "$provider" in
        "lmstudio")
            if timeout 2 curl -s "$api_url/models" >/dev/null 2>&1; then
                log_success "Connected to LM Studio"
                return 0
            fi
            ;;
        "ollama")
            if curl -s "$api_url/api/tags" >/dev/null 2>&1; then
                log_success "Connected to Ollama"
                return 0
            fi
            ;;
    esac
    
    log_error "Failed to connect to $provider at $api_url"
    return 1
}

# ========================================================================
# FILE OPERATIONS
# ========================================================================

backup_file() {
    local file=$1
    if [ -f "$file" ]; then
        local backup="${file}.backup.$(date +%Y%m%d%H%M%S)"
        cp "$file" "$backup"
        log_info "Backed up $file to $backup"
    fi
}

ensure_executable() {
    local file=$1
    if [ -f "$file" ]; then
        chmod +x "$file"
    fi
}

# ========================================================================
# VALIDATION HELPERS
# ========================================================================

validate_directory() {
    local dir=$1
    local name=$2
    if [ -d "$dir" ]; then
        log_success "$name exists: $dir"
        return 0
    else
        log_error "$name missing: $dir"
        return 1
    fi
}

validate_file() {
    local file=$1
    local name=$2
    if [ -f "$file" ]; then
        log_success "$name exists: $file"
        return 0
    else
        log_error "$name missing: $file"
        return 1
    fi
}

# ========================================================================
# BANNER FUNCTIONS
# ========================================================================

print_warpio_banner() {
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║              🚀 WARPIO FOR CLAUDE CODE v1.0.0              ║${NC}"
    echo -e "${CYAN}║                  Powered by IOWarp.ai                       ║${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

print_section_header() {
    local title=$1
    echo ""
    echo -e "${BLUE}${BOLD}$title${NC}"
    echo -e "${BLUE}$(printf '=%.0s' {1..64})${NC}"
    echo ""
}