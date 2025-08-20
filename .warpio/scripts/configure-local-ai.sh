#!/bin/bash
# ========================================================================
# WARPIO LOCAL AI CONFIGURATION
# Auto-detects and configures local AI services for zen-mcp
# ========================================================================

set -e

# Source utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils/warpio-utils.sh"

# Configuration
PROJECT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
ENV_FILE="$PROJECT_DIR/.env"
DETECTED_SERVICES=()
AUTO_MODE=false
SELECTED_PROVIDER=""

# ========================================================================
# DETECTION FUNCTIONS
# ========================================================================

detect_all_services() {
    log_info "Auto-detecting local AI services..."
    echo ""
    
    # Check LM Studio on various ports
    local lm_ports=(1234 8080 5000 5001)
    for port in "${lm_ports[@]}"; do
        if timeout 2 curl -s "http://localhost:$port/v1/models" &>/dev/null; then
            log_success "LM Studio detected on port $port"
            DETECTED_SERVICES+=("lmstudio:localhost:$port")
            
            # Try to get model list
            local models=$(curl -s "http://localhost:$port/v1/models" | jq -r '.data[].id' 2>/dev/null | head -3)
            if [ -n "$models" ]; then
                echo "   Available models:"
                echo "$models" | sed 's/^/     - /'
            fi
            break
        fi
    done
    
    # Check for network LM Studio instances
    log_info "Checking network for LM Studio..."
    local network_ips=("192.168.1.0/24" "192.168.86.0/24" "10.0.0.0/24")
    for subnet in "${network_ips[@]}"; do
        # Quick scan for port 1234 on local network (timeout quickly)
        local ip_base=$(echo $subnet | cut -d'.' -f1-3)
        for i in {1..254}; do
            local ip="$ip_base.$i"
            if timeout 0.1 curl -s "http://$ip:1234/v1/models" &>/dev/null; then
                log_success "LM Studio detected at $ip:1234"
                DETECTED_SERVICES+=("lmstudio:$ip:1234")
                break 2
            fi
        done &
    done
    wait
    
    # Check Ollama
    if command -v ollama &>/dev/null; then
        log_success "Ollama installed"
        
        # Check if running
        if ollama list &>/dev/null; then
            log_success "Ollama service running"
            DETECTED_SERVICES+=("ollama:localhost:11434")
            
            # List models
            local models=$(ollama list 2>/dev/null | tail -n +2 | head -5)
            if [ -n "$models" ]; then
                echo "   Available models:"
                echo "$models" | awk '{print "     - " $1}' 
            else
                log_warning "No Ollama models installed"
                echo "   Install with: ollama pull llama3.2"
            fi
        else
            log_warning "Ollama not running"
            echo "   Start with: ollama serve"
        fi
    fi
    
    # Check vLLM
    if lsof -i:8000 &>/dev/null; then
        if curl -s "http://localhost:8000/v1/models" &>/dev/null; then
            log_success "vLLM detected on port 8000"
            DETECTED_SERVICES+=("vllm:localhost:8000")
        fi
    fi
    
    echo ""
    if [ ${#DETECTED_SERVICES[@]} -eq 0 ]; then
        log_warning "No local AI services detected"
        echo ""
        echo "Options to install local AI:"
        echo "  1. LM Studio: https://lmstudio.ai"
        echo "  2. Ollama: curl -fsSL https://ollama.ai/install.sh | sh"
        echo "  3. vLLM: pip install vllm"
        return 1
    else
        log_success "Found ${#DETECTED_SERVICES[@]} local AI service(s)"
    fi
    
    return 0
}

configure_provider() {
    local provider=$1
    local host=$2
    local port=$3
    
    log_info "Configuring $provider..."
    
    # Backup existing .env
    backup_file "$ENV_FILE"
    
    case "$provider" in
        "lmstudio")
            # Update .env
            sed -i "s|^LOCAL_AI_PROVIDER=.*|LOCAL_AI_PROVIDER=lmstudio|" "$ENV_FILE"
            sed -i "s|^LMSTUDIO_API_URL=.*|LMSTUDIO_API_URL=http://$host:$port/v1|" "$ENV_FILE"
            
            # Try to detect model
            local model=$(curl -s "http://$host:$port/v1/models" | jq -r '.data[0].id' 2>/dev/null)
            if [ -n "$model" ]; then
                sed -i "s|^LMSTUDIO_MODEL=.*|LMSTUDIO_MODEL=$model|" "$ENV_FILE"
                log_success "Configured for model: $model"
            else
                log_warning "Could not detect model, using default"
            fi
            ;;
            
        "ollama")
            # Update .env
            sed -i "s|^LOCAL_AI_PROVIDER=.*|LOCAL_AI_PROVIDER=ollama|" "$ENV_FILE"
            sed -i "s|^OLLAMA_API_URL=.*|OLLAMA_API_URL=http://$host:$port/v1|" "$ENV_FILE"
            
            # Try to detect model
            local model=$(ollama list 2>/dev/null | grep -E "llama|qwen|mistral" | head -1 | awk '{print $1}')
            if [ -n "$model" ]; then
                sed -i "s|^OLLAMA_MODEL=.*|OLLAMA_MODEL=$model|" "$ENV_FILE"
                log_success "Configured for model: $model"
            else
                log_warning "No suitable model found"
                echo "   Recommended: ollama pull llama3.2"
            fi
            ;;
            
        "vllm")
            # Update .env  
            sed -i "s|^LOCAL_AI_PROVIDER=.*|LOCAL_AI_PROVIDER=custom|" "$ENV_FILE"
            sed -i "s|^CUSTOM_API_URL=.*|CUSTOM_API_URL=http://$host:$port/v1|" "$ENV_FILE"
            log_success "Configured for vLLM"
            ;;
    esac
    
    log_success "Configuration updated in .env"
}

test_configuration() {
    log_info "Testing configuration..."
    
    # Load updated environment
    load_env "$ENV_FILE"
    
    case "$LOCAL_AI_PROVIDER" in
        "lmstudio")
            if test_ai_connection "$LMSTUDIO_API_URL" "$LMSTUDIO_MODEL" "lmstudio"; then
                # Try inference
                local response=$(curl -s -X POST "$LMSTUDIO_API_URL/chat/completions" \
                    -H "Content-Type: application/json" \
                    -d "{\"model\":\"$LMSTUDIO_MODEL\",\"messages\":[{\"role\":\"user\",\"content\":\"Say OK\"}],\"max_tokens\":10}" \
                    2>/dev/null | jq -r '.choices[0].message.content' 2>/dev/null)
                
                if [ -n "$response" ]; then
                    log_success "Inference test passed"
                    echo "   Response: $response"
                else
                    log_warning "Connection OK but inference failed"
                fi
            fi
            ;;
            
        "ollama")
            if test_ai_connection "$OLLAMA_API_URL" "$OLLAMA_MODEL" "ollama"; then
                # Try inference
                local response=$(curl -s -X POST "http://localhost:11434/api/generate" \
                    -d "{\"model\":\"$OLLAMA_MODEL\",\"prompt\":\"Say OK\",\"stream\":false}" \
                    2>/dev/null | jq -r '.response' 2>/dev/null)
                
                if [ -n "$response" ]; then
                    log_success "Inference test passed"
                    echo "   Response: $response"
                else
                    log_warning "Connection OK but inference failed"
                fi
            fi
            ;;
    esac
}

interactive_selection() {
    print_section_header "Select Local AI Provider"
    
    if [ ${#DETECTED_SERVICES[@]} -gt 0 ]; then
        echo "Detected services:"
        local i=1
        for service in "${DETECTED_SERVICES[@]}"; do
            local provider=$(echo $service | cut -d: -f1)
            local host=$(echo $service | cut -d: -f2)
            local port=$(echo $service | cut -d: -f3)
            echo "  $i) $provider at $host:$port"
            ((i++))
        done
        echo "  $i) Configure manually"
        echo "  0) Skip configuration"
        echo ""
        
        read -p "Select option [0-$i]: " choice
        
        if [ "$choice" -eq 0 ]; then
            log_info "Skipping configuration"
            return
        elif [ "$choice" -eq "$i" ]; then
            manual_configuration
        elif [ "$choice" -ge 1 ] && [ "$choice" -lt "$i" ]; then
            local selected="${DETECTED_SERVICES[$((choice-1))]}"
            local provider=$(echo $selected | cut -d: -f1)
            local host=$(echo $selected | cut -d: -f2)
            local port=$(echo $selected | cut -d: -f3)
            configure_provider "$provider" "$host" "$port"
            test_configuration
        else
            log_error "Invalid selection"
        fi
    else
        manual_configuration
    fi
}

manual_configuration() {
    print_section_header "Manual Configuration"
    
    echo "Select provider type:"
    echo "  1) LM Studio"
    echo "  2) Ollama"
    echo "  3) vLLM"
    echo "  4) Custom OpenAI-compatible"
    echo ""
    
    read -p "Select [1-4]: " provider_choice
    
    case "$provider_choice" in
        1)
            read -p "Enter LM Studio host (default: localhost): " host
            host=${host:-localhost}
            read -p "Enter LM Studio port (default: 1234): " port
            port=${port:-1234}
            configure_provider "lmstudio" "$host" "$port"
            ;;
        2)
            read -p "Enter Ollama host (default: localhost): " host
            host=${host:-localhost}
            read -p "Enter Ollama port (default: 11434): " port
            port=${port:-11434}
            configure_provider "ollama" "$host" "$port"
            ;;
        3)
            read -p "Enter vLLM host (default: localhost): " host
            host=${host:-localhost}
            read -p "Enter vLLM port (default: 8000): " port
            port=${port:-8000}
            configure_provider "vllm" "$host" "$port"
            ;;
        4)
            read -p "Enter API URL: " api_url
            read -p "Enter model name: " model
            sed -i "s|^LOCAL_AI_PROVIDER=.*|LOCAL_AI_PROVIDER=custom|" "$ENV_FILE"
            sed -i "s|^CUSTOM_API_URL=.*|CUSTOM_API_URL=$api_url|" "$ENV_FILE"
            sed -i "s|^CUSTOM_MODEL_NAME=.*|CUSTOM_MODEL_NAME=$model|" "$ENV_FILE"
            ;;
    esac
    
    test_configuration
}

# ========================================================================
# MAIN EXECUTION
# ========================================================================

main() {
    print_warpio_banner
    echo -e "${BOLD}Local AI Configuration for Warpio${NC}"
    echo ""
    
    # Check for .env file
    if [ ! -f "$ENV_FILE" ]; then
        log_error ".env file not found"
        echo "   Creating from template..."
        cp "$PROJECT_DIR/.claude/.env.example" "$ENV_FILE"
    fi
    
    # Detect services
    detect_all_services
    
    if [ "$AUTO_MODE" = true ]; then
        # Auto-configure first detected service
        if [ ${#DETECTED_SERVICES[@]} -gt 0 ]; then
            local first="${DETECTED_SERVICES[0]}"
            local provider=$(echo $first | cut -d: -f1)
            local host=$(echo $first | cut -d: -f2)
            local port=$(echo $first | cut -d: -f3)
            log_info "Auto-configuring $provider"
            configure_provider "$provider" "$host" "$port"
            test_configuration
        else
            log_error "No services detected for auto-configuration"
            exit 1
        fi
    else
        # Interactive mode
        interactive_selection
    fi
    
    # Summary
    print_section_header "Configuration Complete"
    
    load_env "$ENV_FILE"
    echo "Provider: ${LOCAL_AI_PROVIDER:-none}"
    
    case "$LOCAL_AI_PROVIDER" in
        "lmstudio")
            echo "API URL: $LMSTUDIO_API_URL"
            echo "Model: $LMSTUDIO_MODEL"
            ;;
        "ollama")
            echo "API URL: $OLLAMA_API_URL"
            echo "Model: $OLLAMA_MODEL"
            ;;
        "custom")
            echo "API URL: $CUSTOM_API_URL"
            echo "Model: $CUSTOM_MODEL_NAME"
            ;;
    esac
    
    echo ""
    log_success "Configuration saved to .env"
    echo ""
    echo "To test zen-mcp integration:"
    echo "  1. Restart Claude Code"
    echo "  2. Use zen-mcp tools for local AI delegation"
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --auto)
            AUTO_MODE=true
            shift
            ;;
        --help|-h)
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Configure local AI services for Warpio zen-mcp integration"
            echo ""
            echo "Options:"
            echo "  --auto    Auto-configure first detected service"
            echo "  --help    Show this help message"
            exit 0
            ;;
        *)
            shift
            ;;
    esac
done

main