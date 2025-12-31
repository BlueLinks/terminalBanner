#!/bin/bash
# Display Library
# Provides formatting and display functions for the banner

# Color codes (using simple variables for compatibility with older bash)
BLACK='\033[0;30m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[0;37m'
BOLD_BLACK='\033[1;30m'
BOLD_RED='\033[1;31m'
BOLD_GREEN='\033[1;32m'
BOLD_YELLOW='\033[1;33m'
BOLD_BLUE='\033[1;34m'
BOLD_PURPLE='\033[1;35m'
BOLD_CYAN='\033[1;36m'
BOLD_WHITE='\033[1;37m'
NC='\033[0m'  # No Color

# Initialize display settings
USE_COLORS=true
COLOR_PRIMARY="GREEN"
COLOR_ACCENT="BLUE"
BANNER_WIDTH=53

# Get color by name
get_color() {
    local color_name=$1
    
    case "$color_name" in
        BLACK) echo "$BLACK" ;;
        RED) echo "$RED" ;;
        GREEN) echo "$GREEN" ;;
        YELLOW) echo "$YELLOW" ;;
        BLUE) echo "$BLUE" ;;
        PURPLE) echo "$PURPLE" ;;
        CYAN) echo "$CYAN" ;;
        WHITE) echo "$WHITE" ;;
        BOLD_BLACK) echo "$BOLD_BLACK" ;;
        BOLD_RED) echo "$BOLD_RED" ;;
        BOLD_GREEN) echo "$BOLD_GREEN" ;;
        BOLD_YELLOW) echo "$BOLD_YELLOW" ;;
        BOLD_BLUE) echo "$BOLD_BLUE" ;;
        BOLD_PURPLE) echo "$BOLD_PURPLE" ;;
        BOLD_CYAN) echo "$BOLD_CYAN" ;;
        BOLD_WHITE) echo "$BOLD_WHITE" ;;
        NC) echo "$NC" ;;
        *) echo "" ;;
    esac
}

# Initialize colors
init_colors() {
    local use_colors="${1:-true}"
    USE_COLORS="$use_colors"
    
    if [ "$USE_COLORS" != "true" ]; then
        # Disable all colors
        BLACK=''
        RED=''
        GREEN=''
        YELLOW=''
        BLUE=''
        PURPLE=''
        CYAN=''
        WHITE=''
        BOLD_BLACK=''
        BOLD_RED=''
        BOLD_GREEN=''
        BOLD_YELLOW=''
        BOLD_BLUE=''
        BOLD_PURPLE=''
        BOLD_CYAN=''
        BOLD_WHITE=''
        NC=''
    fi
}

# Set color scheme
set_color_scheme() {
    COLOR_PRIMARY="${1:-GREEN}"
    COLOR_ACCENT="${2:-BLUE}"
}

# Get terminal width
get_terminal_width() {
    if command -v tput &>/dev/null; then
        tput cols
    else
        echo "80"
    fi
}

# Auto-detect banner width
auto_detect_width() {
    local term_width=$(get_terminal_width)
    
    # Use 80% of terminal width or max 100
    local calculated_width=$(( term_width * 80 / 100 ))
    if [ "$calculated_width" -gt 100 ]; then
        calculated_width=100
    fi
    
    # Minimum width of 50
    if [ "$calculated_width" -lt 50 ]; then
        calculated_width=50
    fi
    
    echo "$calculated_width"
}

# Draw separator line
draw_separator() {
    local width="${1:-$BANNER_WIDTH}"
    local color=$(get_color "$COLOR_PRIMARY")
    local reset=$(get_color "NC")
    
    printf "${color}"
    printf '─%.0s' $(seq 1 "$width")
    printf "${reset}\n"
}

# Draw header with timestamp
draw_header() {
    local title="$1"
    local timestamp="$2"
    local width="${3:-$BANNER_WIDTH}"
    
    local color=$(get_color "$COLOR_PRIMARY")
    local reset=$(get_color "NC")
    
    draw_separator "$width"
    printf " %s : %s\n" "$title" "$timestamp"
    draw_separator "$width"
}

# Draw info line with label and value
draw_info_line() {
    local label="$1"
    local value="$2"
    local label_width="${3:-15}"
    
    local color=$(get_color "$COLOR_PRIMARY")
    local reset=$(get_color "NC")
    
    # Pad label to fixed width
    local padded_label=$(printf "%-${label_width}s" "$label")
    
    printf "${color} -${reset} %s${color}:${reset} %s\n" "$padded_label" "$value"
}

# Draw service block for LXC containers
draw_service_block() {
    local service_name="$1"
    local port="$2"
    local description="$3"
    local ip="$4"
    local web_path="${5:-}"
    
    local color=$(get_color "$COLOR_PRIMARY")
    local reset=$(get_color "NC")
    
    draw_info_line "Service" "$service_name"
    
    if [ -n "$port" ]; then
        local url="http://${ip}:${port}"
        draw_info_line "Access URL" "$url"
        
        if [ -n "$web_path" ]; then
            draw_info_line "Web UI" "${url}${web_path}"
        fi
    fi
    
    if [ -n "$description" ]; then
        draw_info_line "Description" "$description"
    fi
}

# Draw custom commands section
draw_commands_section() {
    local commands="$@"
    
    local color=$(get_color "$COLOR_PRIMARY")
    local reset=$(get_color "NC")
    
    echo ""
    echo "Quick Commands:"
    
    # Default commands
    if [ -z "$commands" ]; then
        echo "  htop          : System resource monitor"
        echo "  banner-toggle : Enable/disable this banner"
    else
        echo "$commands"
    fi
}

# Display macOS banner
display_macos_banner() {
    local config_vars="$1"
    
    # Parse config (this is a simple approach, variables should be set by caller)
    local os_version="${OS_VERSION:-macOS}"
    local timestamp="${TIMESTAMP:-$(date '+%H:%M - %a %m/%d/%y')}"
    local hostname="${HOSTNAME_VAR:-$(hostname)}"
    local uptime="${UPTIME:-N/A}"
    local cpu_temp="${CPU_TEMP:-N/A}"
    local lan_ip="${LAN_IP:-N/A}"
    local wan_ip="${WAN_IP:-}"
    local vpn_status="${VPN_STATUS:-}"
    local cpu_usage="${CPU_USAGE:-N/A}"
    local memory_usage="${MEMORY_USAGE:-N/A}"
    local disk_usage="${DISK_USAGE:-N/A}"
    local hostname_ascii="${HOSTNAME_ASCII:-}"
    
    # Clear screen if enabled
    if [ "$CLEAR_SCREEN" = "true" ]; then
        clear
    fi
    
    # Header
    draw_header "$os_version" "$timestamp" "$BANNER_WIDTH"
    
    # ASCII hostname if available
    if [ -n "$hostname_ascii" ]; then
        echo "$hostname_ascii"
        echo ""
    fi
    
    # System info
    draw_info_line "Hostname" "$hostname"
    draw_info_line "Uptime" "$uptime"
    
    if [ -n "$lan_ip" ] && [ "$lan_ip" != "N/A" ]; then
        draw_info_line "LAN IP" "$lan_ip"
    fi
    
    if [ -n "$wan_ip" ] && [ "$wan_ip" != "N/A" ]; then
        draw_info_line "WAN IP" "$wan_ip"
    fi
    
    if [ -n "$vpn_status" ]; then
        draw_info_line "VPN Status" "$vpn_status"
    fi
    
    if [ "$cpu_temp" != "N/A" ]; then
        draw_info_line "CPU Temp" "$cpu_temp"
    fi
    
    draw_info_line "CPU Usage" "$cpu_usage"
    draw_info_line "Memory" "$memory_usage"
    draw_info_line "Disk Usage" "$disk_usage"
    
    # Footer
    draw_separator "$BANNER_WIDTH"
    draw_commands_section
    draw_separator "$BANNER_WIDTH"
}

# Display Linux banner
display_linux_banner() {
    local os_version="${OS_VERSION:-Linux}"
    local timestamp="${TIMESTAMP:-$(date '+%H:%M - %a %m/%d/%y')}"
    local hostname="${HOSTNAME_VAR:-$(hostname)}"
    local device_model="${DEVICE_MODEL:-}"
    local uptime="${UPTIME:-N/A}"
    local cpu_temp="${CPU_TEMP:-N/A}"
    local lan_ip="${LAN_IP:-N/A}"
    local cpu_usage="${CPU_USAGE:-N/A}"
    local memory_usage="${MEMORY_USAGE:-N/A}"
    local disk_usage="${DISK_USAGE:-N/A}"
    local arch="${ARCH:-}"
    
    # Clear screen if enabled
    if [ "$CLEAR_SCREEN" = "true" ]; then
        clear
    fi
    
    # Header
    draw_header "$os_version" "$timestamp" "$BANNER_WIDTH"
    
    # System info
    if [ -n "$device_model" ] && [ "$device_model" != "Unknown" ]; then
        draw_info_line "Device model" "$device_model${arch:+ ($arch)}"
    else
        draw_info_line "Hostname" "$hostname"
    fi
    
    draw_info_line "Uptime" "$uptime"
    
    if [ "$cpu_temp" != "N/A" ]; then
        draw_info_line "CPU temp" "$cpu_temp"
    fi
    
    draw_info_line "LAN IP" "$lan_ip"
    draw_info_line "CPU Usage" "$cpu_usage"
    draw_info_line "Memory" "$memory_usage"
    draw_info_line "Disk Usage" "$disk_usage"
    
    # Footer
    draw_separator "$BANNER_WIDTH"
    draw_commands_section
    draw_separator "$BANNER_WIDTH"
}

# Display LXC container banner
display_lxc_banner() {
    local container_name="${CONTAINER_NAME:-$(hostname)}"
    local timestamp="${TIMESTAMP:-$(date '+%H:%M - %a %m/%d/%y')}"
    local service_name="${SERVICE_NAME:-}"
    local service_port="${SERVICE_PORT:-}"
    local service_desc="${SERVICE_DESC:-}"
    local service_url="${SERVICE_URL:-}"
    local lan_ip="${LAN_IP:-N/A}"
    local cpu_usage="${CPU_USAGE:-N/A}"
    local memory_usage="${MEMORY_USAGE:-N/A}"
    
    # Clear screen if enabled
    if [ "$CLEAR_SCREEN" = "true" ]; then
        clear
    fi
    
    # Header
    draw_header "Container: $container_name" "$timestamp" "$BANNER_WIDTH"
    
    # Service info if detected
    if [ -n "$service_name" ]; then
        draw_service_block "$service_name" "$service_port" "$service_desc" "$lan_ip" "$service_url"
    fi
    
    # Resource info
    draw_info_line "CPU Usage" "$cpu_usage"
    draw_info_line "Memory" "$memory_usage"
    
    # Footer
    draw_separator "$BANNER_WIDTH"
}

