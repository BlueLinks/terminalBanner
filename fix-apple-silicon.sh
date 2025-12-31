#!/bin/bash
# Fix for Apple Silicon Macs
# This script helps with CPU temperature detection issues

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_message() {
    local color=$1
    shift
    echo -e "${color}$@${NC}"
}

echo ""
print_message "$BLUE" "==================================="
print_message "$BLUE" "  Apple Silicon Mac Detected"
print_message "$BLUE" "==================================="
echo ""

# Check chip type
CHIP=$(system_profiler SPHardwareDataType | grep "Chip:" | awk '{print $2, $3}')
print_message "$BLUE" "Chip: $CHIP"
echo ""

# Check osx-cpu-temp
if command -v osx-cpu-temp &>/dev/null; then
    print_message "$BLUE" "Testing osx-cpu-temp..."
    TEMP_OUTPUT=$(osx-cpu-temp 2>&1)
    
    if echo "$TEMP_OUTPUT" | grep -q "Error:"; then
        print_message "$YELLOW" "⚠️  osx-cpu-temp has permission issues on your Mac"
        print_message "$YELLOW" "   This is common on Apple Silicon"
        echo ""
        print_message "$BLUE" "Options:"
        echo ""
        print_message "$BLUE" "Option 1: Disable CPU temperature (recommended)"
        echo "  sed -i '' 's/SHOW_CPU_TEMP=true/SHOW_CPU_TEMP=false/' ~/.config/terminal-banner/banner.conf"
        echo ""
        print_message "$BLUE" "Option 2: Try alternative tools"
        echo "  brew install stats       # Menu bar system monitor (has temp)"
        echo "  sudo gem install iStats  # Command line tool (may work better)"
        echo ""
        print_message "$BLUE" "Option 3: Run osx-cpu-temp with sudo (not recommended for banner)"
        echo "  sudo osx-cpu-temp"
        echo ""
    else
        TEMP=$(echo "$TEMP_OUTPUT" | grep -oE '[0-9]+\.[0-9]+' | head -1)
        if [ "$TEMP" = "0.0" ] || [ -z "$TEMP" ]; then
            print_message "$YELLOW" "⚠️  osx-cpu-temp returns 0.0°C"
            print_message "$BLUE" "Suggesting to disable CPU temp display..."
        else
            print_message "$GREEN" "✓ osx-cpu-temp is working! Temperature: ${TEMP}°C"
            echo ""
            print_message "$BLUE" "If you're still seeing 0°C in the banner, update your scripts:"
            echo "  cd $(dirname "${BASH_SOURCE[0]}")"
            echo "  cp lib/system-info.sh ~/.config/terminal-banner/lib/"
            echo "  source ~/.zshrc"
        fi
    fi
else
    print_message "$YELLOW" "⚠️  osx-cpu-temp not installed"
    echo ""
    print_message "$BLUE" "Install options:"
    echo "  brew install osx-cpu-temp  # May not work on all M-series Macs"
    echo "  sudo gem install iStats     # Alternative tool"
    echo ""
    print_message "$BLUE" "Or simply disable CPU temp:"
    echo "  sed -i '' 's/SHOW_CPU_TEMP=true/SHOW_CPU_TEMP=false/' ~/.config/terminal-banner/banner.conf"
fi

echo ""
print_message "$BLUE" "Would you like to disable CPU temperature display? (y/N)"
read -r response

if [[ "$response" =~ ^[Yy]$ ]]; then
    CONFIG="$HOME/.config/terminal-banner/banner.conf"
    if [ -f "$CONFIG" ]; then
        sed -i '' 's/SHOW_CPU_TEMP=true/SHOW_CPU_TEMP=false/' "$CONFIG"
        print_message "$GREEN" "✓ CPU temperature disabled"
        print_message "$BLUE" "Reload your shell: source ~/.zshrc"
    else
        print_message "$YELLOW" "Config file not found at $CONFIG"
    fi
fi

echo ""

