#!/bin/bash
# System Information Library
# Provides cross-platform functions for gathering system information

# Get hostname
get_hostname() {
    hostname
}

# Get OS version
get_os_version() {
    local os=$(detect_os)
    
    case "$os" in
        macos)
            if command -v sw_vers &>/dev/null; then
                local version=$(sw_vers -productVersion)
                local name=$(sw_vers -productName)
                echo "$name $version"
            else
                echo "macOS $(uname -r)"
            fi
            ;;
        linux)
            if [ -f /etc/os-release ]; then
                . /etc/os-release
                echo "$PRETTY_NAME"
            elif [ -f /etc/dietpi/.version ]; then
                local version=$(cat /etc/dietpi/.version 2>/dev/null | head -1)
                echo "DietPi $version"
            else
                echo "Linux $(uname -r)"
            fi
            ;;
        *)
            uname -sr
            ;;
    esac
}

# Get uptime formatted
get_uptime() {
    local os=$(detect_os)
    local uptime_output=$(uptime)
    
    # Try to parse uptime output - handle multiple formats
    local days=$(echo "$uptime_output" | grep -oE '[0-9]+ day' | awk '{print $1}')
    
    # Extract time portion (between "up" and "users" or ",")
    local time_part=""
    if echo "$uptime_output" | grep -q "day"; then
        time_part=$(echo "$uptime_output" | sed -E 's/.*up[[:space:]]+[0-9]+[[:space:]]+day[s]?,?[[:space:]]+//; s/,[[:space:]]+[0-9]+[[:space:]]+user.*//')
    else
        time_part=$(echo "$uptime_output" | sed -E 's/.*up[[:space:]]+//; s/,[[:space:]]+[0-9]+[[:space:]]+user.*//')
    fi
    
    # Extract hours and minutes
    local hrs=""
    local mins=""
    
    # Format: HH:MM or H:MM
    if echo "$time_part" | grep -qE '[0-9]+:[0-9]+'; then
        hrs=$(echo "$time_part" | grep -oE '[0-9]+:[0-9]+' | cut -d: -f1)
        mins=$(echo "$time_part" | grep -oE '[0-9]+:[0-9]+' | cut -d: -f2)
    # Format: "X hrs" or "X mins"
    elif echo "$time_part" | grep -q "hr"; then
        hrs=$(echo "$time_part" | grep -oE '[0-9]+[[:space:]]*hr' | grep -oE '[0-9]+')
        mins=$(echo "$time_part" | grep -oE '[0-9]+[[:space:]]*min' | grep -oE '[0-9]+')
    # Format: "X mins" only
    elif echo "$time_part" | grep -q "min"; then
        hrs="0"
        mins=$(echo "$time_part" | grep -oE '[0-9]+[[:space:]]*min' | grep -oE '[0-9]+')
    fi
    
    # Build formatted string
    local formatted=""
    
    if [ -n "$days" ] && [ "$days" -gt 0 ]; then
        formatted="${days} days"
    fi
    
    if [ -n "$hrs" ] && [ "$hrs" -gt 0 ]; then
        [ -n "$formatted" ] && formatted="${formatted}, "
        formatted="${formatted}${hrs} hrs"
    fi
    
    if [ -n "$mins" ] && [ "$mins" -gt 0 ]; then
        [ -n "$formatted" ] && formatted="${formatted}, "
        formatted="${formatted}${mins} mins"
    fi
    
    # Fallback if parsing failed
    if [ -z "$formatted" ]; then
        # Just show simplified version
        formatted=$(echo "$uptime_output" | sed -E 's/.*up[[:space:]]+//; s/,[[:space:]]+[0-9]+[[:space:]]+user.*//')
    fi
    
    echo "$formatted"
}

# Get CPU temperature
get_cpu_temp() {
    local os=$(detect_os)
    local temp=""
    local temp_c=""
    
    case "$os" in
        macos)
            # Try osx-cpu-temp first (brew install osx-cpu-temp)
            if command -v osx-cpu-temp &>/dev/null; then
                local temp_output=$(osx-cpu-temp 2>&1)
                # Check for errors (common on Apple Silicon)
                if ! echo "$temp_output" | grep -q "Error:"; then
                    temp_c=$(echo "$temp_output" | grep -oE '[0-9]+\.[0-9]+' | head -1)
                    # Verify it's not 0.0
                    if [ "$temp_c" = "0.0" ]; then
                        temp_c=""
                    fi
                fi
            fi
            
            # Try istats if available (gem install iStats)
            if [ -z "$temp_c" ] && command -v istats &>/dev/null; then
                temp_c=$(istats cpu temp --value-only 2>/dev/null | grep -oE '[0-9]+\.[0-9]+')
            fi
            
            # Try asitop for Apple Silicon (brew install asitop)
            if [ -z "$temp_c" ] && command -v asitop &>/dev/null; then
                # asitop requires sudo, skip for now
                temp_c=""
            fi
            
            # Try smc tool if available (older Intel Macs)
            if [ -z "$temp_c" ] && command -v smc &>/dev/null; then
                temp_c=$(smc -k TC0P -r 2>/dev/null | awk '{print $3}' | tr -d 'C°')
            fi
            
            # Try powermetrics (requires sudo, so we skip it for banner)
            # if [ -z "$temp_c" ] && command -v powermetrics &>/dev/null; then
            #     temp_c=$(sudo powermetrics --samplers smc -i1 -n1 2>/dev/null | grep "CPU die temperature" | awk '{print $4}')
            # fi
            ;;
        linux)
            # Try thermal zones
            if [ -d /sys/class/thermal/thermal_zone0 ]; then
                local temp_millis=$(cat /sys/class/thermal/thermal_zone0/temp 2>/dev/null)
                if [ -n "$temp_millis" ]; then
                    temp_c=$(awk "BEGIN {printf \"%.1f\", $temp_millis/1000}")
                fi
            fi
            
            # Try vcgencmd for Raspberry Pi
            if [ -z "$temp_c" ] && command -v vcgencmd &>/dev/null; then
                temp_c=$(vcgencmd measure_temp 2>/dev/null | grep -o '[0-9]\+\.[0-9]\+')
            fi
            
            # Try sensors command if available
            if [ -z "$temp_c" ] && command -v sensors &>/dev/null; then
                temp_c=$(sensors 2>/dev/null | grep -i "core 0" | awk '{print $3}' | tr -d '+°C' | head -1)
            fi
            ;;
    esac
    
    if [ -n "$temp_c" ]; then
        # Calculate Fahrenheit
        local temp_f=$(awk "BEGIN {printf \"%.0f\", ($temp_c * 9/5) + 32}")
        # Round Celsius
        local temp_c_rounded=$(awk "BEGIN {printf \"%.0f\", $temp_c}")
        echo "${temp_c_rounded}°C / ${temp_f}°F"
    else
        echo "N/A"
    fi
}

# Get network IP addresses
get_ip_addresses() {
    local os=$(detect_os)
    local ips=""
    
    case "$os" in
        macos)
            # Check common interfaces on macOS
            for iface in en0 en1 en2; do
                if [ -d "/sys/class/net/$iface" ] || ifconfig "$iface" &>/dev/null; then
                    local ip=$(ipconfig getifaddr "$iface" 2>/dev/null)
                    if [ -n "$ip" ]; then
                        ips="${ips}${ip} (${iface}) "
                    fi
                fi
            done
            ;;
        linux)
            # Check common interfaces on Linux
            for iface in eth0 eth1 wlan0 wlan1 enp0s3 ens18; do
                if [ -d "/sys/class/net/$iface" ]; then
                    local ip=$(ip addr show "$iface" 2>/dev/null | grep "inet " | awk '{print $2}' | cut -d/ -f1 | head -1)
                    if [ -n "$ip" ]; then
                        ips="${ips}${ip} (${iface}) "
                    fi
                fi
            done
            
            # Fallback: use ip command to get first non-loopback
            if [ -z "$ips" ] && command -v ip &>/dev/null; then
                local ip=$(ip -4 addr show scope global 2>/dev/null | grep inet | awk '{print $2}' | cut -d/ -f1 | head -1)
                if [ -n "$ip" ]; then
                    ips="$ip"
                fi
            fi
            ;;
    esac
    
    # Remove trailing space
    ips=$(echo "$ips" | sed 's/ *$//')
    
    if [ -z "$ips" ]; then
        echo "N/A"
    else
        echo "$ips"
    fi
}

# Get CPU usage
get_cpu_usage() {
    local os=$(detect_os)
    local usage=""
    
    case "$os" in
        macos)
            # Use top command
            usage=$(top -l 1 | grep "CPU usage" | awk '{print $3}' | tr -d '%')
            if [ -n "$usage" ]; then
                echo "${usage}%"
            else
                echo "N/A"
            fi
            ;;
        linux)
            # Use top command
            usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | tr -d '%us,')
            if [ -n "$usage" ]; then
                echo "${usage}%"
            else
                echo "N/A"
            fi
            ;;
        *)
            echo "N/A"
            ;;
    esac
}

# Get memory usage
get_memory_usage() {
    local os=$(detect_os)
    local usage=""
    
    case "$os" in
        macos)
            # Use vm_stat
            if command -v vm_stat &>/dev/null; then
                local page_size=$(pagesize 2>/dev/null || echo 4096)
                local vm_stat_output=$(vm_stat)
                local pages_active=$(echo "$vm_stat_output" | grep "Pages active" | awk '{print $3}' | tr -d '.')
                local pages_wired=$(echo "$vm_stat_output" | grep "Pages wired" | awk '{print $4}' | tr -d '.')
                local pages_compressed=$(echo "$vm_stat_output" | grep "Pages occupied by compressor" | awk '{print $5}' | tr -d '.')
                
                local used_bytes=$(( ($pages_active + $pages_wired + ${pages_compressed:-0}) * $page_size ))
                local used_gb=$(awk "BEGIN {printf \"%.1f\", $used_bytes/1024/1024/1024}")
                
                # Get total memory
                local total_bytes=$(sysctl -n hw.memsize 2>/dev/null)
                local total_gb=$(awk "BEGIN {printf \"%.1f\", $total_bytes/1024/1024/1024}")
                
                local percent=$(awk "BEGIN {printf \"%.0f\", ($used_gb/$total_gb)*100}")
                
                echo "${used_gb}GB / ${total_gb}GB (${percent}%)"
            else
                echo "N/A"
            fi
            ;;
        linux)
            # Use free command
            if command -v free &>/dev/null; then
                local mem_info=$(free -m | grep Mem:)
                local total=$(echo "$mem_info" | awk '{print $2}')
                local used=$(echo "$mem_info" | awk '{print $3}')
                
                local total_gb=$(awk "BEGIN {printf \"%.1f\", $total/1024}")
                local used_gb=$(awk "BEGIN {printf \"%.1f\", $used/1024}")
                local percent=$(awk "BEGIN {printf \"%.0f\", ($used/$total)*100}")
                
                echo "${used_gb}GB / ${total_gb}GB (${percent}%)"
            else
                echo "N/A"
            fi
            ;;
        *)
            echo "N/A"
            ;;
    esac
}

# Get disk usage
get_disk_usage() {
    if command -v df &>/dev/null; then
        local os=$(detect_os)
        local disk_info=""
        local used=""
        local total=""
        local percent=""
        local mount_point="/"
        
        # Get disk info based on OS
        if [ "$os" = "macos" ]; then
            # On modern macOS (APFS), check if /System/Volumes/Data exists
            # This is where actual user data lives, not on / (System volume)
            if [ -d "/System/Volumes/Data" ]; then
                mount_point="/System/Volumes/Data"
            fi
            # On macOS, use -H for 1000-based units (GB instead of GiB)
            disk_info=$(df -H "$mount_point" 2>/dev/null | tail -1)
        else
            # On Linux, use -h for human-readable
            disk_info=$(df -h / 2>/dev/null | tail -1)
        fi
        
        used=$(echo "$disk_info" | awk '{print $3}')
        total=$(echo "$disk_info" | awk '{print $2}')
        percent=$(echo "$disk_info" | awk '{print $5}')
        
        # Standardize unit naming (replace Gi with GB, Mi with MB, etc.)
        # Also ensure units are present (add GB if just a number with G)
        used=$(echo "$used" | sed 's/Gi/GB/g; s/Mi/MB/g; s/Ki/KB/g; s/Ti/TB/g; s/G$/GB/g; s/M$/MB/g; s/K$/KB/g; s/T$/TB/g')
        total=$(echo "$total" | sed 's/Gi/GB/g; s/Mi/MB/g; s/Ki/KB/g; s/Ti/TB/g; s/G$/GB/g; s/M$/MB/g; s/K$/KB/g; s/T$/TB/g')
        
        echo "$used / $total ($percent)"
    else
        echo "N/A"
    fi
}

# Get hostname as ASCII art (requires figlet)
get_hostname_ascii() {
    if command -v figlet &>/dev/null; then
        local hostname=$(get_hostname)
        figlet "$hostname" 2>/dev/null
    fi
}

# Get WAN IP with caching
get_wan_ip() {
    local cache_file="/tmp/banner-wan-ip.cache"
    local cache_duration=3600  # 1 hour in seconds
    local current_time=$(date +%s)
    
    # Check if cache exists and is still valid
    if [ -f "$cache_file" ]; then
        local cache_time=$(stat -f %m "$cache_file" 2>/dev/null || stat -c %Y "$cache_file" 2>/dev/null)
        local cache_age=$(( current_time - cache_time ))
        
        if [ "$cache_age" -lt "$cache_duration" ]; then
            # Cache is still valid
            cat "$cache_file"
            return 0
        fi
    fi
    
    # Fetch new data with timeout
    if command -v curl &>/dev/null && command -v jq &>/dev/null; then
        local wan_info=$(curl -s --max-time 2 https://ipinfo.io 2>/dev/null)
        
        if [ -n "$wan_info" ]; then
            local wan_ip=$(echo "$wan_info" | jq -r '.ip' 2>/dev/null)
            local wan_city=$(echo "$wan_info" | jq -r '.city' 2>/dev/null)
            local wan_region=$(echo "$wan_info" | jq -r '.region' 2>/dev/null)
            local wan_country=$(echo "$wan_info" | jq -r '.country' 2>/dev/null)
            
            if [ -n "$wan_ip" ] && [ "$wan_ip" != "null" ]; then
                local result="$wan_ip ($wan_city, $wan_region $wan_country)"
                echo "$result" > "$cache_file"
                echo "$result"
                return 0
            fi
        fi
    fi
    
    # If fetch failed but we have old cache, use it
    if [ -f "$cache_file" ]; then
        cat "$cache_file"
        return 0
    fi
    
    echo "N/A"
}

# Get VPN status
get_vpn_status() {
    local vpn_interfaces="${1:-utun tun wg}"
    local vpn_names="${2:-}"
    
    # Check netstat or ip command for VPN interfaces
    local connected_iface=""
    
    if command -v netstat &>/dev/null; then
        for pattern in $vpn_interfaces; do
            if netstat -nr 2>/dev/null | grep -q "$pattern"; then
                connected_iface=$(netstat -nr 2>/dev/null | grep "$pattern" | awk '{print $NF}' | head -1)
                break
            fi
        done
    elif command -v ip &>/dev/null; then
        for pattern in $vpn_interfaces; do
            if ip link show 2>/dev/null | grep -q "$pattern"; then
                connected_iface=$(ip link show 2>/dev/null | grep "$pattern" | awk -F: '{print $2}' | tr -d ' ' | head -1)
                break
            fi
        done
    fi
    
    if [ -n "$connected_iface" ]; then
        # Try to match with VPN names
        local vpn_name=""
        for mapping in $vpn_names; do
            local pattern=$(echo "$mapping" | cut -d: -f1)
            local name=$(echo "$mapping" | cut -d: -f2)
            if echo "$connected_iface" | grep -q "$pattern"; then
                vpn_name=" ($name)"
                break
            fi
        done
        
        echo "Connected${vpn_name}"
    else
        echo "Not Connected"
    fi
}

