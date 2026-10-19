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

# 4. Copy or download antigravity.lua
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

# 5. Update init.lua
INIT_LUA="$HS_DIR/init.lua"
MARKER_START="-- START antigravity-enter-macos"
MARKER_END="-- END antigravity-enter-macos"

if [ ! -f "$INIT_LUA" ]; then
    cat << 'EOF' > "$INIT_LUA"
-- START antigravity-enter-macos
pcall(require, "antigravity")
-- END antigravity-enter-macos
EOF
    echo -e "${GREEN}✓ Created $INIT_LUA with antigravity module loaded${NC}"
else
    if ! grep -q "antigravity" "$INIT_LUA"; then
        cat << EOF >> "$INIT_LUA"

$MARKER_START
pcall(require, "antigravity")
$MARKER_END
EOF
        echo -e "${GREEN}✓ Added antigravity loader to existing $INIT_LUA${NC}"
    else
        echo -e "${GREEN}✓ Antigravity module already configured in $INIT_LUA${NC}"
    fi
fi

# 6. Launch or reload Hammerspoon
if pgrep -x "Hammerspoon" >/dev/null 2>&1; then
    echo -e "${BLUE}Reloading Hammerspoon configuration...${NC}"
    if command -v hs >/dev/null 2>&1; then
        hs -c "hs.reload()" >/dev/null 2>&1 || true
    else
        killall Hammerspoon 2>/dev/null || true
        sleep 0.5
        open -a Hammerspoon
    fi
else
    echo -e "${BLUE}Launching Hammerspoon...${NC}"
    open -a Hammerspoon
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
echo -e "${YELLOW}IMPORTANT:${NC} Hammerspoon requires macOS ${BLUE}Accessibility${NC} permissions."
echo "If this is your first time using Hammerspoon, grant permission in:"
echo "  System Settings -> Privacy & Security -> Accessibility -> Enable 'Hammerspoon'"
echo ""
