#!/bin/bash
# Terminal Banner Installation Script
# This script installs the terminal banner system

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Installation paths
INSTALL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="${HOME}/.config/terminal-banner"
MARKER_START="# ============ Terminal Banner ============"
MARKER_END="# ============ End Terminal Banner ============"

# Print colored message
print_message() {
    local color=$1
    shift
    echo -e "${color}$@${NC}"
}

# Detect user's shell
detect_shell() {
    local shell_path="$SHELL"
    local shell_name=$(basename "$shell_path")
    
    case "$shell_name" in
        bash)
            echo "bash"
            ;;
        zsh)
            echo "zsh"
            ;;
        *)
            echo "$shell_name"
            ;;
    esac
}

# Get shell profile file path
get_profile_file() {
    local shell_type=$1
    
    case "$shell_type" in
        bash)
            if [ -f "${HOME}/.bashrc" ]; then
                echo "${HOME}/.bashrc"
            elif [ -f "${HOME}/.bash_profile" ]; then
                echo "${HOME}/.bash_profile"
            else
                echo "${HOME}/.bashrc"
            fi
            ;;
        zsh)
            echo "${HOME}/.zshrc"
            ;;
        *)
            echo ""
            ;;
    esac
}

# Check if already installed
check_existing_installation() {
    local profile_file=$1
    
    if [ -f "$profile_file" ]; then
        if grep -q "$MARKER_START" "$profile_file"; then
            return 0
        fi
    fi
    
    return 1
}

# Create config directory
create_config_directory() {
    print_message "$BLUE" "Creating configuration directory..."
    
    mkdir -p "$CONFIG_DIR"
    mkdir -p "${CONFIG_DIR}/lib"
    
    # Copy configuration files
    cp "${INSTALL_DIR}/config/banner.conf" "${CONFIG_DIR}/banner.conf"
    cp "${INSTALL_DIR}/config/services.conf" "${CONFIG_DIR}/services.conf"
    
    # Copy library files
    cp "${INSTALL_DIR}/lib/detect.sh" "${CONFIG_DIR}/lib/"
    cp "${INSTALL_DIR}/lib/system-info.sh" "${CONFIG_DIR}/lib/"
    cp "${INSTALL_DIR}/lib/display.sh" "${CONFIG_DIR}/lib/"
    
    # Copy main banner script
    cp "${INSTALL_DIR}/banner.sh" "${CONFIG_DIR}/banner.sh"
    
    # Copy banner-toggle script
    cp "${INSTALL_DIR}/banner-toggle.sh" "${CONFIG_DIR}/banner-toggle.sh"
    
    # Make scripts executable
    chmod +x "${CONFIG_DIR}/banner.sh"
    chmod +x "${CONFIG_DIR}/banner-toggle.sh"
    chmod +x "${CONFIG_DIR}/lib/"*.sh
    
    print_message "$GREEN" "✓ Configuration directory created at: $CONFIG_DIR"
}

# Add banner to shell profile
install_to_profile() {
    local profile_file=$1
    local install_date=$(date "+%Y-%m-%d")
    
    print_message "$BLUE" "Adding banner to shell profile: $profile_file"
    
    # Backup profile file
    cp "$profile_file" "${profile_file}.backup-$(date +%s)"
    print_message "$GREEN" "✓ Created backup of profile file"
    
    # Append banner configuration (minimal version)
    cat >> "$profile_file" << 'EOF'

# ============ Terminal Banner ============
# To customize: edit ~/.config/terminal-banner/banner.conf
# To toggle: run 'banner-toggle'
[ -f "$HOME/.config/terminal-banner/banner.sh" ] && source "$HOME/.config/terminal-banner/banner.sh"
alias banner-toggle="$HOME/.config/terminal-banner/banner-toggle.sh"
# ============ End Terminal Banner ============
EOF
    
    print_message "$GREEN" "✓ Banner added to profile"
}

# Main installation
main() {
    print_message "$GREEN" "==================================="
    print_message "$GREEN" "  Terminal Banner Installation"
    print_message "$GREEN" "==================================="
    echo ""
    
    # Detect shell
    local shell_type=$(detect_shell)
    print_message "$BLUE" "Detected shell: $shell_type"
    
    # Get profile file
    local profile_file=$(get_profile_file "$shell_type")
    
    if [ -z "$profile_file" ]; then
        print_message "$RED" "Error: Unsupported shell type: $shell_type"
        exit 1
    fi
    
    print_message "$BLUE" "Profile file: $profile_file"
    echo ""
    
    # Check for existing installation
    if check_existing_installation "$profile_file"; then
        print_message "$YELLOW" "Warning: Terminal banner is already installed in $profile_file"
        read -p "Do you want to reinstall? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            print_message "$BLUE" "Installation cancelled."
            exit 0
        fi
        
        # Remove old installation
        print_message "$BLUE" "Removing old installation..."
        # Use sed to remove lines between markers
        if [[ "$OSTYPE" == "darwin"* ]]; then
            sed -i '.bak' "/$MARKER_START/,/$MARKER_END/d" "$profile_file"
        else
            sed -i.bak "/$MARKER_START/,/$MARKER_END/d" "$profile_file"
        fi
    fi
    
    # Create config directory
    create_config_directory
    echo ""
    
    # Install to profile
    install_to_profile "$profile_file"
    echo ""
    
    # Check for optional dependencies
    print_message "$BLUE" "Checking for optional dependencies..."
    
    local missing_deps=""
    command -v figlet &>/dev/null || missing_deps="${missing_deps}figlet "
    command -v jq &>/dev/null || missing_deps="${missing_deps}jq "
    command -v curl &>/dev/null || missing_deps="${missing_deps}curl "
    
    if [ -n "$missing_deps" ]; then
        print_message "$YELLOW" "Optional dependencies not found: $missing_deps"
        print_message "$YELLOW" "Some features will be disabled. To enable them, install:"
        
        if [[ "$OSTYPE" == "darwin"* ]]; then
            print_message "$YELLOW" "  brew install $missing_deps"
        else
            print_message "$YELLOW" "  sudo apt install $missing_deps"
        fi
    else
        print_message "$GREEN" "✓ All optional dependencies found"
    fi
    echo ""
    
    # Installation complete
    print_message "$GREEN" "==================================="
    print_message "$GREEN" "  Installation Complete!"
    print_message "$GREEN" "==================================="
    echo ""
    print_message "$BLUE" "The banner will appear when you open a new terminal."
    print_message "$BLUE" "To customize, edit: ${CONFIG_DIR}/banner.conf"
    echo ""
    print_message "$BLUE" "Commands:"
    print_message "$BLUE" "  banner-toggle  - Enable/disable the banner"
    print_message "$BLUE" "  source $profile_file  - Reload your profile to see the banner now"
    echo ""
    print_message "$GREEN" "Enjoy your new terminal banner!"
}

# Run installation
main

