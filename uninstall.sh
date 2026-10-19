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

# Parse flags
UNINSTALL_APP=false
for arg in "$@"; do
    case "$arg" in
        --all|--purge|-a)
            UNINSTALL_APP=true
            ;;
    esac
done

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

# 3. Prompt whether to also uninstall Hammerspoon if flag wasn't provided
if [ "$UNINSTALL_APP" = "false" ]; then
    echo ""
    choice=""
    if [ -t 0 ]; then
        read -r -p "Do you also want to completely uninstall the Hammerspoon application? [y/N]: " choice
    elif [ -e /dev/tty ]; then
        read -r -p "Do you also want to completely uninstall the Hammerspoon application? [y/N]: " choice </dev/tty
    fi
    case "$choice" in
        [yY]|[yY][eE][sS])
            UNINSTALL_APP=true
            ;;
        *)
            UNINSTALL_APP=false
            ;;
    esac
fi

# 4. Handle Hammerspoon app removal or reload
if [ "$UNINSTALL_APP" = "true" ]; then
    echo -e "${YELLOW}Uninstalling Hammerspoon application...${NC}"
    killall Hammerspoon 2>/dev/null || true
    
    if command -v brew >/dev/null 2>&1 && brew list --cask hammerspoon >/dev/null 2>&1; then
        echo -e "${BLUE}Running 'brew uninstall --cask hammerspoon'...${NC}"
        brew uninstall --cask hammerspoon
    fi

    rm -rf "/Applications/Hammerspoon.app" "$HOME/Applications/Hammerspoon.app" 2>/dev/null || true
    rm -rf "$HS_DIR" 2>/dev/null || true
    echo -e "${GREEN}✓ Hammerspoon application and configurations removed.${NC}"
else
    # Reload Hammerspoon to apply cleaned configuration
    if pgrep -x "Hammerspoon" >/dev/null 2>&1; then
        echo -e "${BLUE}Reloading Hammerspoon configuration...${NC}"
        if ! command -v hs >/dev/null 2>&1 || ! hs -c "hs.reload()" >/dev/null 2>&1; then
            killall Hammerspoon 2>/dev/null || true
            sleep 0.5
            open -a Hammerspoon
        fi
    fi
fi

echo ""
echo -e "${GREEN}======================================================${NC}"
echo -e "${GREEN}  antigravity-enter-macos successfully uninstalled!   ${NC}"
echo -e "${GREEN}======================================================${NC}"
echo "Default Antigravity keybindings have been restored."
echo ""
