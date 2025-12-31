#!/bin/bash
# Detection Library
# Provides OS, platform, architecture, and service detection

# Detect operating system
detect_os() {
    local os_type=$(uname -s)
    case "$os_type" in
        Darwin*)
            echo "macos"
            ;;
        Linux*)
            echo "linux"
            ;;
        *)
            echo "unknown"
            ;;
    esac
}

# Detect architecture
detect_architecture() {
    local arch=$(uname -m)
    case "$arch" in
        x86_64|amd64)
            echo "x86_64"
            ;;
        arm64|aarch64)
            echo "arm64"
            ;;
        armv7l)
            echo "armv7"
            ;;
        *)
            echo "$arch"
            ;;
    esac
}

# Detect if running in LXC container
detect_lxc() {
    # Check multiple indicators for LXC
    if [ -f "/proc/1/environ" ] && grep -qa "container=lxc" /proc/1/environ 2>/dev/null; then
        return 0
    fi
    
    if [ -f "/.dockerenv" ]; then
        return 1  # Docker, not LXC
    fi
    
    # Check systemd-detect-virt if available
    if command -v systemd-detect-virt &>/dev/null; then
        local virt=$(systemd-detect-virt 2>/dev/null)
        if [ "$virt" = "lxc" ]; then
            return 0
        fi
    fi
    
    # Check for LXC-specific files
    if [ -d "/dev/lxc" ] || [ -f "/run/container_type" ]; then
        return 0
    fi
    
    return 1
}

# Get container name (if in LXC)
get_container_name() {
    # Try hostname first
    local name=$(hostname)
    
    # Try to get from LXC config
    if [ -f "/proc/1/environ" ]; then
        local lxc_name=$(grep -ao "container_name=[^[:space:]]*" /proc/1/environ 2>/dev/null | cut -d= -f2)
        if [ -n "$lxc_name" ]; then
            name="$lxc_name"
        fi
    fi
    
    echo "$name"
}

# Detect Linux distribution
detect_linux_distro() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        echo "$ID"
    elif [ -f /etc/dietpi/.version ]; then
        echo "dietpi"
    elif [ -f /etc/debian_version ]; then
        echo "debian"
    elif [ -f /etc/redhat-release ]; then
        echo "rhel"
    else
        echo "linux"
    fi
}

# Detect device model (Raspberry Pi, etc.)
detect_device_model() {
    local model=""
    
    # Check /proc/device-tree/model (Raspberry Pi and others)
    if [ -f /proc/device-tree/model ]; then
        model=$(cat /proc/device-tree/model 2>/dev/null | tr -d '\0')
    fi
    
    # Check /sys/firmware/devicetree/base/model
    if [ -z "$model" ] && [ -f /sys/firmware/devicetree/base/model ]; then
        model=$(cat /sys/firmware/devicetree/base/model 2>/dev/null | tr -d '\0')
    fi
    
    # Check for virtual machine
    if [ -z "$model" ] && command -v systemd-detect-virt &>/dev/null; then
        local virt=$(systemd-detect-virt 2>/dev/null)
        if [ "$virt" != "none" ]; then
            model="Virtual Machine ($virt)"
        fi
    fi
    
    # Fallback to DMI info on x86
    if [ -z "$model" ] && [ -f /sys/class/dmi/id/product_name ]; then
        model=$(cat /sys/class/dmi/id/product_name 2>/dev/null)
    fi
    
    # Default fallback
    if [ -z "$model" ]; then
        model="Unknown"
    fi
    
    echo "$model"
}

# Check if a port is listening locally
check_port() {
    local port=$1
    
    # Try netstat first (most compatible)
    if command -v netstat &>/dev/null; then
        if netstat -tuln 2>/dev/null | grep -q ":$port "; then
            return 0
        fi
    fi
    
    # Try ss (faster, modern alternative)
    if command -v ss &>/dev/null; then
        if ss -tuln 2>/dev/null | grep -q ":$port "; then
            return 0
        fi
    fi
    
    # Try lsof
    if command -v lsof &>/dev/null; then
        if lsof -i ":$port" -sTCP:LISTEN &>/dev/null; then
            return 0
        fi
    fi
    
    return 1
}

# Detect services by checking ports
# Returns: SERVICE_NAME|PORT|DESCRIPTION
detect_services() {
    local services_file="${1:-$HOME/.config/terminal-banner/services.conf}"
    
    if [ ! -f "$services_file" ]; then
        return 1
    fi
    
    # Read services from config and check which ones are running
    while IFS='|' read -r service_name ip port description web_path; do
        # Skip comments and empty lines
        [[ "$service_name" =~ ^#.*$ ]] && continue
        [[ -z "$service_name" ]] && continue
        
        # Check if port is listening
        if check_port "$port"; then
            echo "$service_name|$port|$description|$web_path"
        fi
    done < "$services_file"
}

# Detect service by process name
detect_service_by_process() {
    local process_name=$1
    
    if command -v pgrep &>/dev/null; then
        if pgrep -x "$process_name" &>/dev/null; then
            return 0
        fi
    elif command -v pidof &>/dev/null; then
        if pidof "$process_name" &>/dev/null; then
            return 0
        fi
    fi
    
    return 1
}

# Check if a command/tool is available
has_command() {
    command -v "$1" &>/dev/null
}

# Detect available optional features
detect_available_features() {
    local features=""
    
    has_command "figlet" && features="${features}figlet "
    has_command "curl" && features="${features}curl "
    has_command "jq" && features="${features}jq "
    has_command "osx-cpu-temp" && features="${features}osx-cpu-temp "
    
    echo "$features"
}

