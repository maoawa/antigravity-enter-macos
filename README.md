# antigravity-enter-macos

> Enter to New Line, <kbd>⌘ Cmd</kbd> + <kbd>Enter</kbd> to Send in **Antigravity** desktop on macOS. That Google bro never did.

Antigravity’s desktop chat composer natively hardcodes <kbd>Enter</kbd> to send messages, which frequently leads to accidental sends when all you wanted was a line break. 

This repository provides an automated, lightweight Hammerspoon configuration to fix this behavior cleanly without modifying any signed application files or breaking macOS Gatekeeper.

---

### Key Mappings

| Key Combination | Action in Antigravity |
| :--- | :--- |
| <kbd>⌘ Cmd</kbd> + <kbd>Enter</kbd> *(or <kbd>⌃ Ctrl</kbd> + <kbd>Enter</kbd>)* | **Send Message** |
| <kbd>Enter</kbd> | **New Line** |
| <kbd>⇧ Shift</kbd> + <kbd>Enter</kbd> | **New Line** |

> **Scoped Only to Antigravity**: Keystroke remapping only triggers when Antigravity (`com.google.antigravity`) is the active frontmost window. All other applications remain completely unaffected.

---

### One-Key Install

Run this single-line command in your terminal:

```bash
curl -fsSL https://raw.githubusercontent.com/maoawa/antigravity-enter-macos/main/install.sh | bash
```

*What the installer does automatically:*
1. Checks if [Hammerspoon](https://www.hammerspoon.org/) is installed (and installs it via Homebrew if missing).
2. Prompts whether you'd like to hide the Hammerspoon icon from your macOS status / menu bar.
3. Enables **Launch at Login** automatically so the key mapping persists after system restarts.
4. Copies `antigravity.lua` to `~/.hammerspoon/antigravity.lua`.
5. Adds the loader safely to `~/.hammerspoon/init.lua` without overwriting existing configs.
6. Launches or reloads Hammerspoon immediately.

---

### Menu Bar Icon (Show / Hide)

You can choose whether Hammerspoon shows an icon in your macOS menu bar:
- **During installation**: You will be prompted with `[y/N]` (or use `--hide-menu-icon`).
- **Toggle anytime**: Run the included helper script:
  ```bash
  ./toggle-menu-bar.sh
  ```
  Or via one-liner in terminal:
  ```bash
  hs -c "hs.menuIcon(not hs.menuIcon())"
  ```

---

### One-Key Uninstall

Run the uninstaller command:

```bash
curl -fsSL https://raw.githubusercontent.com/maoawa/antigravity-enter-macos/main/uninstall.sh | bash
```

*Uninstall Options:*
- **Default**: Removes the Antigravity keymapping and restores default Antigravity behavior, keeping Hammerspoon installed for your other uses.
- **Complete Purge**: When prompted, type `y` (or pass `./uninstall.sh --all`) to completely remove the Hammerspoon application and its configurations.

---

### macOS Permissions (Important First-Time Setup)

Hammerspoon uses the standard macOS Accessibility API (`hs.eventtap`) to intercept and translate key events. 

When running for the first time:
1. macOS will prompt you to grant Accessibility access to **Hammerspoon**.
2. Go to **System Settings** $\to$ **Privacy & Security** $\to$ **Accessibility**.
3. Toggle the switch **ON** for **Hammerspoon**.
4. If Hammerspoon was already running when permission was granted, restart it or run:
   ```bash
   hs -c "hs.reload()"
   ```

---

### Manual / Local Usage

If you have cloned the repository locally:

```bash
# Clone the repository
git clone https://github.com/maoawa/antigravity-enter-macos.git
cd antigravity-enter-macos

# Install (interactive)
./install.sh

# Install silently (hidden icon)
./install.sh --hide-menu-icon -y

# Toggle status bar icon
./toggle-menu-bar.sh

# Uninstall (prompts whether to remove Hammerspoon app too)
./uninstall.sh

# Complete uninstall including Hammerspoon application
./uninstall.sh --all
```

---

### License

[MIT](LICENSE)
