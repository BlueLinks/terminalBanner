#!/bin/bash
# Terminal Banner - Main Script
# This script is sourced by your shell profile (.bashrc/.zshrc)

# Prevent double execution
if [ -n "$TERMINAL_BANNER_LOADED" ]; then
    return 0
fi
export TERMINAL_BANNER_LOADED=1

# Configuration directory
BANNER_CONFIG_DIR="${HOME}/.config/terminal-banner"
BANNER_INSTALL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Load configuration
load_config() {
    local config_file="${BANNER_CONFIG_DIR}/banner.conf"
    
    # Check if config exists
    if [ ! -f "$config_file" ]; then
        # Try to load from install directory (for first run)
        if [ -f "${BANNER_INSTALL_DIR}/config/banner.conf" ]; then
            config_file="${BANNER_INSTALL_DIR}/config/banner.conf"
        else
            return 1
        fi
    fi
    
    # Source config file
    . "$config_file"
    
    return 0
}

# Main function
main() {
    # Load configuration
    if ! load_config; then
        # Silently exit if no config found
        return 0
    fi
    
    # Check if banner is enabled
    if [ "$ENABLED" != "true" ]; then
        return 0
    fi
    
    # Determine library path
    local lib_dir="${BANNER_INSTALL_DIR}/lib"
    if [ ! -d "$lib_dir" ]; then
        lib_dir="${BANNER_CONFIG_DIR}/lib"
    fi
    
    # Source libraries
    if [ ! -f "${lib_dir}/detect.sh" ]; then
        return 0
    fi
    
    . "${lib_dir}/detect.sh"
    . "${lib_dir}/system-info.sh"
    . "${lib_dir}/display.sh"
    
    # Initialize display settings
    local width="$BANNER_WIDTH"
    if [ -z "$width" ]; then
        width=$(auto_detect_width)
    fi
    BANNER_WIDTH="$width"
    
    init_colors "$USE_COLORS"
    set_color_scheme "$COLOR_PRIMARY" "$COLOR_ACCENT"
    
    # Detect platform
    local os=$(detect_os)
    local is_lxc=false
    
    if detect_lxc; then
        is_lxc=true
    fi
    
    # Gather system information based on config
    export TIMESTAMP=$(date "+%H:%M - %a %m/%d/%y")
    
    if [ "$SHOW_HOSTNAME_ASCII" = "true" ]; then
        export HOSTNAME_ASCII=$(get_hostname_ascii)
    fi
    
    export HOSTNAME_VAR=$(get_hostname)
    export OS_VERSION=$(get_os_version)
    export UPTIME=$(get_uptime)
    
    if [ "$SHOW_NETWORK" = "true" ]; then
        export LAN_IP=$(get_ip_addresses)
    fi
    
    if [ "$SHOW_WAN_IP" = "true" ]; then
        export WAN_IP=$(get_wan_ip)
    fi
    
    if [ "$SHOW_VPN_STATUS" = "true" ]; then
        export VPN_STATUS=$(get_vpn_status "$VPN_INTERFACES" "$VPN_NAMES")
    fi
    
    if [ "$SHOW_CPU_TEMP" = "true" ]; then
        export CPU_TEMP=$(get_cpu_temp)
    fi
    
    if [ "$SHOW_RESOURCES" = "true" ]; then
        export CPU_USAGE=$(get_cpu_usage)
        export MEMORY_USAGE=$(get_memory_usage)
    fi
    
    if [ "$SHOW_DISK_USAGE" = "true" ]; then
        export DISK_USAGE=$(get_disk_usage)
    fi
    
    # Platform-specific info
    if [ "$os" = "linux" ]; then
        export DEVICE_MODEL=$(detect_device_model)
        export ARCH=$(detect_architecture)
    fi
    
    # Display banner based on platform
    if [ "$is_lxc" = "true" ]; then
        # LXC Container
        export CONTAINER_NAME=$(get_container_name)
        
        # Try to detect service
        local services_conf="${BANNER_CONFIG_DIR}/services.conf"
        if [ ! -f "$services_conf" ]; then
            services_conf="${BANNER_INSTALL_DIR}/config/services.conf"
        fi
        
        if [ -f "$services_conf" ]; then
            local detected_service=$(detect_services "$services_conf" | head -1)
            if [ -n "$detected_service" ]; then
                export SERVICE_NAME=$(echo "$detected_service" | cut -d'|' -f1)
                export SERVICE_PORT=$(echo "$detected_service" | cut -d'|' -f2)
                export SERVICE_DESC=$(echo "$detected_service" | cut -d'|' -f3)
                export SERVICE_URL=$(echo "$detected_service" | cut -d'|' -f4)
            fi
        fi
        
        display_lxc_banner
    elif [ "$os" = "macos" ]; then
        # macOS
        display_macos_banner
    else
        # Linux (non-LXC)
        display_linux_banner
    fi
}

# Run main function
main

