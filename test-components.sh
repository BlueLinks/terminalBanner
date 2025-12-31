#!/bin/bash
# Component testing script
# Run this to test individual components of the banner system

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source libraries
. "${SCRIPT_DIR}/lib/detect.sh"
. "${SCRIPT_DIR}/lib/system-info.sh"

echo "===================================="
echo "Terminal Banner Component Tests"
echo "===================================="
echo ""

echo "1. Platform Detection"
echo "   OS: $(detect_os)"
echo "   Architecture: $(detect_architecture)"
echo "   LXC Container: $(detect_lxc && echo "Yes" || echo "No")"
if [ "$(detect_os)" = "linux" ]; then
    echo "   Distribution: $(detect_linux_distro)"
    echo "   Device Model: $(detect_device_model)"
fi
echo ""

echo "2. System Information"
echo "   Hostname: $(get_hostname)"
echo "   OS Version: $(get_os_version)"
echo "   Uptime: $(get_uptime)"
echo "   CPU Temp: $(get_cpu_temp)"
echo "   IP Addresses: $(get_ip_addresses)"
echo ""

echo "3. Resource Usage"
echo "   CPU Usage: $(get_cpu_usage)"
echo "   Memory: $(get_memory_usage)"
echo "   Disk: $(get_disk_usage)"
echo ""

echo "4. Optional Features"
echo "   Available features: $(detect_available_features)"
if command -v figlet &>/dev/null; then
    echo "   Figlet: ✓ Available"
else
    echo "   Figlet: ✗ Not installed"
fi
if command -v curl &>/dev/null && command -v jq &>/dev/null; then
    echo "   WAN IP (curl+jq): ✓ Available"
else
    echo "   WAN IP (curl+jq): ✗ Missing dependencies"
fi
echo ""

echo "5. Services (if in LXC container)"
if detect_lxc; then
    local services_conf="${HOME}/.config/terminal-banner/services.conf"
    if [ ! -f "$services_conf" ]; then
        services_conf="${SCRIPT_DIR}/config/services.conf"
    fi
    
    if [ -f "$services_conf" ]; then
        echo "   Detected services:"
        detect_services "$services_conf"
    else
        echo "   No services config found"
    fi
else
    echo "   Not running in LXC container"
fi
echo ""

echo "===================================="
echo "Component test complete"
echo "===================================="

