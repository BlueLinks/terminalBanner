#!/bin/bash
# Terminal Banner Uninstallation Script
# This script removes the terminal banner system

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Installation paths
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

# Check if installed
check_installation() {
    local profile_file=$1
    
    if [ -f "$profile_file" ]; then
        if grep -q "$MARKER_START" "$profile_file"; then
            return 0
        fi
    fi
    
    return 1
}

# Remove from shell profile
remove_from_profile() {
    local profile_file=$1
    
    print_message "$BLUE" "Removing banner from shell profile: $profile_file"
    
    # Backup profile file
    cp "$profile_file" "${profile_file}.backup-$(date +%s)"
    print_message "$GREEN" "✓ Created backup of profile file"
    
    # Remove lines between markers
    if [[ "$OSTYPE" == "darwin"* ]]; then
        sed -i '.bak' "/$MARKER_START/,/$MARKER_END/d" "$profile_file"
    else
        sed -i.bak "/$MARKER_START/,/$MARKER_END/d" "$profile_file"
    fi
    
    # Remove any empty lines at the end
    if [[ "$OSTYPE" == "darwin"* ]]; then
        sed -i '.bak' -e :a -e '/^\n*$/{$d;N;ba' -e '}' "$profile_file"
    fi
    
    print_message "$GREEN" "✓ Banner removed from profile"
}

# Remove config directory
remove_config_directory() {
    print_message "$BLUE" "Removing configuration directory..."
    
    if [ -d "$CONFIG_DIR" ]; then
        rm -rf "$CONFIG_DIR"
        print_message "$GREEN" "✓ Configuration directory removed: $CONFIG_DIR"
    else
        print_message "$YELLOW" "Configuration directory not found: $CONFIG_DIR"
    fi
}

# Main uninstallation
main() {
    print_message "$RED" "==================================="
    print_message "$RED" "  Terminal Banner Uninstallation"
    print_message "$RED" "==================================="
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
    
    # Check if installed
    if ! check_installation "$profile_file"; then
        print_message "$YELLOW" "Terminal banner is not installed in $profile_file"
        
        # Check if config dir exists
        if [ -d "$CONFIG_DIR" ]; then
            print_message "$YELLOW" "But configuration directory exists: $CONFIG_DIR"
            read -p "Do you want to remove it? (y/N): " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                remove_config_directory
            fi
        fi
        
        exit 0
    fi
    
    # Confirm uninstallation
    print_message "$YELLOW" "This will remove the terminal banner from your system."
    read -p "Are you sure you want to continue? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_message "$BLUE" "Uninstallation cancelled."
        exit 0
    fi
    echo ""
    
    # Remove from profile
    remove_from_profile "$profile_file"
    echo ""
    
    # Remove config directory
    read -p "Do you want to remove configuration files? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        remove_config_directory
    else
        print_message "$BLUE" "Configuration files kept at: $CONFIG_DIR"
    fi
    echo ""
    
    # Uninstallation complete
    print_message "$GREEN" "==================================="
    print_message "$GREEN" "  Uninstallation Complete!"
    print_message "$GREEN" "==================================="
    echo ""
    print_message "$BLUE" "The banner will no longer appear in new terminal sessions."
    print_message "$BLUE" "Reload your profile: source $profile_file"
    echo ""
}

# Run uninstallation
main

