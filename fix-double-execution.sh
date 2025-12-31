#!/bin/bash
# Fix double execution issue

echo "Checking for duplicate banner calls in shell profile..."
echo ""

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
        echo "Unsupported shell: $SHELL_NAME"
        exit 1
        ;;
esac

echo "Profile file: $PROFILE_FILE"
echo ""

# Count occurrences of banner references
echo "Searching for banner references..."
grep -n "terminal-banner\|banner.sh" "$PROFILE_FILE" 2>/dev/null || echo "No references found"
echo ""

# Count marker occurrences
MARKER_COUNT=$(grep -c "Terminal Banner" "$PROFILE_FILE" 2>/dev/null || echo "0")
echo "Found $MARKER_COUNT 'Terminal Banner' marker(s)"
echo ""

if [ "$MARKER_COUNT" -gt 1 ]; then
    echo "⚠️  WARNING: Multiple banner installations detected!"
    echo ""
    echo "This will cause the banner to run multiple times."
    echo ""
    echo "To fix this:"
    echo "1. Edit your profile: nano $PROFILE_FILE"
    echo "2. Remove duplicate '# ============ Terminal Banner ============' sections"
    echo "3. Keep only ONE banner section"
    echo ""
    echo "Or run: ./uninstall.sh && ./install.sh"
elif [ "$MARKER_COUNT" -eq 0 ]; then
    echo "ℹ️  No banner installation found in profile"
    echo ""
    echo "Run ./install.sh to install the banner"
else
    echo "✓ Banner installation looks correct"
    echo ""
    echo "If you're still seeing double execution, check:"
    echo "1. Do you have multiple terminal profiles?"
    echo "2. Is there a .bash_profile AND .bashrc both sourcing the banner?"
    echo "3. Are you using tmux or another multiplexer?"
fi
echo ""

# Check for the new guard variable
if grep -q "TERMINAL_BANNER_LOADED" "$HOME/.config/terminal-banner/banner.sh" 2>/dev/null; then
    echo "✓ Double-execution guard is in place"
else
    echo "⚠️  Double-execution guard not found - update banner.sh"
fi

