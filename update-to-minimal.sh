#!/bin/bash
# Update to minimal shell profile installation
# This removes the old verbose installation and installs the new clean version

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_message() {
    local color=$1
    shift
    echo -e "${color}$@${NC}"
}

# Detect shell
SHELL_NAME=$(basename "$SHELL")
case "$SHELL_NAME" in
    bash)
        PROFILE_FILE="$HOME/.bashrc"
        [ ! -f "$PROFILE_FILE" ] && PROFILE_FILE="$HOME/.bash_profile"
        ;;
    zsh)
        PROFILE_FILE="$HOME/.zshrc"
        ;;
    *)
        print_message "$RED" "Unsupported shell: $SHELL_NAME"
        exit 1
        ;;
esac

print_message "$BLUE" "Updating to minimal installation..."
print_message "$BLUE" "Profile file: $PROFILE_FILE"
echo ""

# Backup
cp "$PROFILE_FILE" "${PROFILE_FILE}.backup-$(date +%s)"
print_message "$GREEN" "✓ Created backup"

# Remove old installation
MARKER_START="# ============ Terminal Banner ============"
MARKER_END="# ============ End Terminal Banner ============"

if grep -q "$MARKER_START" "$PROFILE_FILE"; then
    if [[ "$OSTYPE" == "darwin"* ]]; then
        sed -i '.bak' "/$MARKER_START/,/$MARKER_END/d" "$PROFILE_FILE"
    else
        sed -i.bak "/$MARKER_START/,/$MARKER_END/d" "$PROFILE_FILE"
    fi
    print_message "$GREEN" "✓ Removed old installation"
else
    print_message "$YELLOW" "No existing installation found"
fi

# Add new minimal installation
cat >> "$PROFILE_FILE" << 'EOF'

# ============ Terminal Banner ============
# To customize: edit ~/.config/terminal-banner/banner.conf
# To toggle: run 'banner-toggle'
[ -f "$HOME/.config/terminal-banner/banner.sh" ] && source "$HOME/.config/terminal-banner/banner.sh"
alias banner-toggle="$HOME/.config/terminal-banner/banner-toggle.sh"
# ============ End Terminal Banner ============
EOF

print_message "$GREEN" "✓ Added new minimal installation"
echo ""

# Update installed files
CONFIG_DIR="$HOME/.config/terminal-banner"
INSTALL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ -d "$CONFIG_DIR" ]; then
    print_message "$BLUE" "Updating installed files..."
    
    cp "${INSTALL_DIR}/banner.sh" "${CONFIG_DIR}/banner.sh"
    cp "${INSTALL_DIR}/banner-toggle.sh" "${CONFIG_DIR}/banner-toggle.sh"
    cp "${INSTALL_DIR}/lib/"*.sh "${CONFIG_DIR}/lib/"
    
    chmod +x "${CONFIG_DIR}/banner.sh"
    chmod +x "${CONFIG_DIR}/banner-toggle.sh"
    chmod +x "${CONFIG_DIR}/lib/"*.sh
    
    print_message "$GREEN" "✓ Updated all scripts"
fi

echo ""
print_message "$GREEN" "==================================="
print_message "$GREEN" "  Update Complete!"
print_message "$GREEN" "==================================="
echo ""
print_message "$BLUE" "Your $PROFILE_FILE now has just 3 clean lines:"
print_message "$BLUE" "  1. Comment about customization"
print_message "$BLUE" "  2. Source the banner"
print_message "$BLUE" "  3. banner-toggle alias"
echo ""
print_message "$BLUE" "Reload your shell: source $PROFILE_FILE"
echo ""

