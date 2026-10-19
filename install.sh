#!/usr/bin/env bash
set -e

# antigravity-enter-macos installer
# https://github.com/maoawa/antigravity-enter-macos

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== Installing antigravity-enter-macos ===${NC}"

# Parse flags
HIDE_MENU_ICON=""
AUTO_YES=false

for arg in "$@"; do
    case "$arg" in
        --hide-menu-icon|--hide-icon|--headless)
            HIDE_MENU_ICON="true"
            ;;
        --show-menu-icon|--show-icon)
            HIDE_MENU_ICON="false"
            ;;
        -y|--yes)
            AUTO_YES=true
            ;;
    esac
done

# 1. OS check
if [[ "$(uname)" != "Darwin" ]]; then
    echo -e "${RED}Error: This tool is only designed for macOS.${NC}"
    exit 1
fi

# 2. Check / Install Hammerspoon
if ! [ -d "/Applications/Hammerspoon.app" ] && ! [ -d "$HOME/Applications/Hammerspoon.app" ]; then
    echo -e "${YELLOW}Hammerspoon not found.${NC}"
    if command -v brew >/dev/null 2>&1; then
        echo -e "${BLUE}Installing Hammerspoon via Homebrew...${NC}"
        brew install --cask hammerspoon
    else
        echo -e "${RED}Error: Homebrew is not installed. Please install Hammerspoon manually from:${NC}"
        echo "https://github.com/Hammerspoon/hammerspoon/releases/latest"
        exit 1
    fi
fi

# 3. Setup configuration directory
HS_DIR="$HOME/.hammerspoon"
mkdir -p "$HS_DIR"

# 4. Prompt for hiding menu bar icon if not specified
if [ -z "$HIDE_MENU_ICON" ]; then
    menu_choice=""
    if [ "$AUTO_YES" = "true" ]; then
        menu_choice="y"
    elif [ -t 0 ]; then
        read -r -p "Do you want to hide the Hammerspoon icon from your macOS status / menu bar? [Y/n]: " menu_choice
    elif [ -e /dev/tty ]; then
        read -r -p "Do you want to hide the Hammerspoon icon from your macOS status / menu bar? [Y/n]: " menu_choice </dev/tty
    else
        menu_choice="y"
    fi

    case "$menu_choice" in
        [nN]|[nN][oO])
            HIDE_MENU_ICON="false"
            ;;
        *)
            HIDE_MENU_ICON="true"
            ;;
    esac
fi

# 5. Copy or download antigravity.lua
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
TARGET_LUA="$HS_DIR/antigravity.lua"

if [ -f "$SCRIPT_DIR/antigravity.lua" ]; then
    cp "$SCRIPT_DIR/antigravity.lua" "$TARGET_LUA"
    echo -e "${GREEN}✓ Copied antigravity.lua to $TARGET_LUA${NC}"
else
    echo -e "${BLUE}Downloading antigravity.lua from GitHub...${NC}"
    curl -fsSL "https://raw.githubusercontent.com/maoawa/antigravity-enter-macos/main/antigravity.lua" -o "$TARGET_LUA"
    echo -e "${GREEN}✓ Downloaded antigravity.lua to $TARGET_LUA${NC}"
fi

# 6. Update init.lua
INIT_LUA="$HS_DIR/init.lua"
MARKER_START="-- START antigravity-enter-macos"
MARKER_END="-- END antigravity-enter-macos"

MENU_LUA_LINE=""
if [ "$HIDE_MENU_ICON" = "true" ]; then
    MENU_LUA_LINE="if hs and hs.menuIcon then hs.menuIcon(false) end"
else
    MENU_LUA_LINE="if hs and hs.menuIcon then hs.menuIcon(true) end"
fi

CONFIG_BLOCK=$(cat << EOF
$MARKER_START
pcall(require, "hs.ipc")
if hs and hs.autoLaunch then hs.autoLaunch(true) end
$MENU_LUA_LINE
pcall(require, "antigravity")
$MARKER_END
EOF
)

if [ ! -f "$INIT_LUA" ]; then
    echo "$CONFIG_BLOCK" > "$INIT_LUA"
    echo -e "${GREEN}✓ Created $INIT_LUA with antigravity module loaded${NC}"
else
    # Remove existing antigravity block if re-installing
    if grep -qF -- "$MARKER_START" "$INIT_LUA" 2>/dev/null; then
        sed -i '' '/-- START antigravity-enter-macos/,/-- END antigravity-enter-macos/d' "$INIT_LUA"
    fi
    echo "" >> "$INIT_LUA"
    echo "$CONFIG_BLOCK" >> "$INIT_LUA"
    echo -e "${GREEN}✓ Updated $INIT_LUA with antigravity configuration${NC}"
fi

# 7. Launch or reload Hammerspoon
if pgrep -x "Hammerspoon" >/dev/null 2>&1; then
    echo -e "${BLUE}Reloading Hammerspoon configuration...${NC}"
    if ! command -v hs >/dev/null 2>&1 || ! hs -c "hs.reload()" >/dev/null 2>&1; then
        killall Hammerspoon 2>/dev/null || true
        sleep 0.5
        open -a Hammerspoon
        sleep 1.5
    fi
else
    echo -e "${BLUE}Launching Hammerspoon...${NC}"
    open -a Hammerspoon
    sleep 1.5
fi

# Apply menu icon setting immediately via IPC if available
if command -v hs >/dev/null 2>&1; then
    if [ "$HIDE_MENU_ICON" = "true" ]; then
        hs -c "hs.menuIcon(false)" >/dev/null 2>&1 || true
    else
        hs -c "hs.menuIcon(true)" >/dev/null 2>&1 || true
    fi
    hs -c "hs.autoLaunch(true)" >/dev/null 2>&1 || true
fi

# 8. Check Accessibility Permissions
IS_ACCESSIBLE="false"
if command -v hs >/dev/null 2>&1; then
    IS_ACCESSIBLE=$(hs -c "return hs.accessibilityState()" 2>/dev/null || echo "false")
fi

echo ""
echo -e "${GREEN}======================================================${NC}"
echo -e "${GREEN}  antigravity-enter-macos successfully installed!     ${NC}"
echo -e "${GREEN}======================================================${NC}"
echo -e "Keybindings in Antigravity:"
echo -e "  • ${YELLOW}Cmd + Enter${NC} (or ${YELLOW}Ctrl + Enter${NC}) -> ${GREEN}Send Message${NC}"
echo -e "  • ${YELLOW}Enter${NC}                          -> ${GREEN}New Line${NC}"
echo -e "  • ${YELLOW}Shift + Enter${NC}                  -> ${GREEN}New Line${NC}"
echo ""
if [ "$HIDE_MENU_ICON" = "true" ]; then
    echo -e "Status Bar Icon: ${YELLOW}Hidden${NC} (run ./toggle-menu-bar.sh to show/hide anytime)"
else
    echo -e "Status Bar Icon: ${GREEN}Visible${NC} (run ./toggle-menu-bar.sh to show/hide anytime)"
fi
echo -e "Auto-Launch on Login: ${GREEN}Enabled${NC}"
echo ""

if [ "$IS_ACCESSIBLE" != "true" ]; then
    echo -e "${YELLOW}IMPORTANT:${NC} Hammerspoon requires macOS ${BLUE}Accessibility${NC} permissions to remap keys."
    echo "Opening System Settings for you now..."
    hs -c "hs.accessibilityState(true)" >/dev/null 2>&1 || true
    open "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility"
    echo "Please toggle the switch ON for 'Hammerspoon' in the Settings window."
    echo ""
else
    echo -e "${GREEN}✓ Accessibility permission is active.${NC}"
    echo "You're all set! Try typing in Antigravity."
    echo ""
fi
