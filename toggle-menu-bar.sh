#!/usr/bin/env bash
# toggle-menu-bar.sh
# https://github.com/maoawa/antigravity-enter-macos
# Toggles the Hammerspoon status bar / menu bar icon on macOS

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

if ! command -v hs >/dev/null 2>&1; then
    echo -e "${YELLOW}Hammerspoon CLI 'hs' is not found.${NC}"
    exit 1
fi

if ! pgrep -x "Hammerspoon" >/dev/null 2>&1; then
    echo -e "${BLUE}Hammerspoon is not running. Launching it now...${NC}"
    open -a Hammerspoon
    sleep 1
fi

CURRENT=$(hs -c "return hs.menuIcon()" 2>/dev/null || echo "true")

if [ "$CURRENT" = "true" ]; then
    hs -c "hs.menuIcon(false)" >/dev/null 2>&1
    echo -e "${GREEN}✓ Hammerspoon menu bar icon is now HIDDEN.${NC}"
else
    hs -c "hs.menuIcon(true)" >/dev/null 2>&1
    echo -e "${GREEN}✓ Hammerspoon menu bar icon is now VISIBLE.${NC}"
fi
