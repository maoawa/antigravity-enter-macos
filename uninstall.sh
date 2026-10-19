#!/usr/bin/env bash
set -e

# antigravity-enter-macos uninstaller
# https://github.com/maoawa/antigravity-enter-macos

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== Uninstalling antigravity-enter-macos ===${NC}"

HS_DIR="$HOME/.hammerspoon"
TARGET_LUA="$HS_DIR/antigravity.lua"
INIT_LUA="$HS_DIR/init.lua"

# 1. Remove antigravity.lua
if [ -f "$TARGET_LUA" ]; then
    rm -f "$TARGET_LUA"
    echo -e "${GREEN}✓ Removed $TARGET_LUA${NC}"
else
    echo -e "${YELLOW}- $TARGET_LUA not found, skipping.${NC}"
fi

# 2. Clean init.lua
if [ -f "$INIT_LUA" ]; then
    MARKER_START="-- START antigravity-enter-macos"
    MARKER_END="-- END antigravity-enter-macos"

    if grep -qF -- "$MARKER_START" "$INIT_LUA" 2>/dev/null; then
        # Remove lines between markers
        sed -i '' '/-- START antigravity-enter-macos/,/-- END antigravity-enter-macos/d' "$INIT_LUA"
        echo -e "${GREEN}✓ Removed antigravity block from $INIT_LUA${NC}"
    fi

    # Fallback: remove any leftover require lines
    sed -i '' '/pcall(require, *"antigravity"*)/d' "$INIT_LUA" 2>/dev/null || true
    sed -i '' '/require(["'"'"']antigravity["'"'"'])/d' "$INIT_LUA" 2>/dev/null || true
    sed -i '' '/pcall(require, *"hs.ipc"*)/d' "$INIT_LUA" 2>/dev/null || true

    # If init.lua is empty or only whitespace, remove it cleanly
    if [ -f "$INIT_LUA" ] && [ -z "$(tr -d '[:space:]' < "$INIT_LUA")" ]; then
        rm -f "$INIT_LUA"
        echo -e "${GREEN}✓ Removed empty $INIT_LUA${NC}"
    fi
fi

# 3. Reload Hammerspoon if running
if pgrep -x "Hammerspoon" >/dev/null 2>&1; then
    echo -e "${BLUE}Reloading Hammerspoon configuration...${NC}"
    if command -v hs >/dev/null 2>&1; then
        hs -c "hs.reload()" >/dev/null 2>&1 || true
    else
        killall Hammerspoon 2>/dev/null || true
        sleep 0.5
        open -a Hammerspoon
    fi
fi

echo ""
echo -e "${GREEN}======================================================${NC}"
echo -e "${GREEN}  antigravity-enter-macos successfully uninstalled!   ${NC}"
echo -e "${GREEN}======================================================${NC}"
echo "Default Antigravity keybindings have been restored."
echo ""
