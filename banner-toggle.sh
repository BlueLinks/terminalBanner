#!/bin/bash
# Banner toggle script
# Called by 'banner-toggle' command

CONFIG="$HOME/.config/terminal-banner/banner.conf"

if [ ! -f "$CONFIG" ]; then
    echo "Banner config not found at $CONFIG"
    exit 1
fi

CURRENT=$(grep "^ENABLED=" "$CONFIG" | cut -d'=' -f2)

if [ "$CURRENT" = "true" ]; then
    # Use appropriate sed syntax based on OS
    if [[ "$OSTYPE" == "darwin"* ]]; then
        sed -i '.bak' 's/^ENABLED=true/ENABLED=false/' "$CONFIG"
    else
        sed -i.bak 's/^ENABLED=true/ENABLED=false/' "$CONFIG"
    fi
    echo "✓ Terminal banner disabled (takes effect on next login)"
else
    # Use appropriate sed syntax based on OS
    if [[ "$OSTYPE" == "darwin"* ]]; then
        sed -i '.bak' 's/^ENABLED=false/ENABLED=true/' "$CONFIG"
    else
        sed -i.bak 's/^ENABLED=false/ENABLED=true/' "$CONFIG"
    fi
    echo "✓ Terminal banner enabled (takes effect on next login)"
fi

