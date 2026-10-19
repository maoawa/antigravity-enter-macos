# antigravity-enter-macos

[![macOS](https://img.shields.io/badge/platform-macOS%2013%2B-black?logo=apple)](https://github.com/maoawa/antigravity-enter-macos)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Hammerspoon](https://img.shields.io/badge/powered%20by-Hammerspoon-orange)](https://www.hammerspoon.org/)

> **Enter for New Line.** <kbd>⌘ Cmd</kbd> + <kbd>Enter</kbd> to Send in **Antigravity** on macOS.  
> *Fixes the annoying accidental sends that Google bro never did.*

---

### ⌨️ Key Mappings

| Key Combination | Action in Antigravity |
| :--- | :--- |
| <kbd>⌘ Cmd</kbd> + <kbd>Enter</kbd> *(or <kbd>⌃ Ctrl</kbd> + <kbd>Enter</kbd>)* | 🚀 **Send Message** |
| <kbd>Enter</kbd> | ↵ **New Line** |
| <kbd>⇧ Shift</kbd> + <kbd>Enter</kbd> | ↵ **New Line** |

> 🔒 **100% Isolated:** Keystroke remapping is strictly scoped to Antigravity (`com.google.antigravity`). All your other apps (VS Code, browsers, terminal, Slack) are completely unaffected.

---

## ⚡ Quick Start (One-Key Install)

Paste and run this single command in your macOS **Terminal**:

```bash
curl -fsSL https://raw.githubusercontent.com/maoawa/antigravity-enter-macos/main/install.sh | bash
```

### 3-Step Setup:
1. **Run the command above** — It automatically checks for [Hammerspoon](https://www.hammerspoon.org/) (installs via Homebrew if needed), configures the remapper, and enables Launch-at-Login.
2. **Grant Permission** — macOS will prompt you to grant Accessibility access to **Hammerspoon**:
   > Open **System Settings** $\to$ **Privacy & Security** $\to$ **Accessibility** $\to$ Toggle **ON** for **Hammerspoon**.
3. **Done!** — Jump into Antigravity and start typing with normal line breaks.

---

## 🗑️ One-Key Uninstall

Want to revert back to default Antigravity behavior? Run:

```bash
curl -fsSL https://raw.githubusercontent.com/maoawa/antigravity-enter-macos/main/uninstall.sh | bash
```

* **Default:** Cleans up the configuration and restores default Antigravity behavior, keeping Hammerspoon for any other uses.
* **Complete Purge:** Type `y` when prompted (or pass `./uninstall.sh --all`) to uninstall the Hammerspoon app entirely.

---

## ⚙️ Options & Utilities

### Hide / Show Status Bar Icon
Keep your macOS menu bar clean and distraction-free:
```bash
# Toggle Hammerspoon status bar icon on / off anytime:
hs -c "hs.menuIcon(not hs.menuIcon())"
```
*(If you cloned the repo locally, you can also run `./toggle-menu-bar.sh`)*

### Silent / Headless Install
To install non-interactively with the menu bar icon hidden by default:
```bash
curl -fsSL https://raw.githubusercontent.com/maoawa/antigravity-enter-macos/main/install.sh | bash -s -- --hide-menu-icon -y
```

---

## 💻 Manual / Local Setup

If you prefer to clone and inspect the code locally:

```bash
git clone https://github.com/maoawa/antigravity-enter-macos.git
cd antigravity-enter-macos

# Install
./install.sh

# Toggle status bar icon
./toggle-menu-bar.sh

# Uninstall (prompts whether to remove Hammerspoon app too)
./uninstall.sh

# Complete uninstall including Hammerspoon application
./uninstall.sh --all
```

---

## 💡 How It Works

Antigravity 2.0's desktop chat composer is built on React and Meta's Lexical framework, where <kbd>Enter</kbd> is hardcoded to submit. Web assets are packed inside a signed Mach-O Go binary (`language_server`), making direct file patching prone to breaking macOS Gatekeeper and being wiped by auto-updates.

`antigravity-enter-macos` uses **Hammerspoon**'s lightweight event tap (`hs.eventtap`):
- It intercepts keystrokes only when Antigravity is the frontmost application.
- Remaps pure <kbd>Enter</kbd> $\to$ <kbd>Shift</kbd>+<kbd>Enter</kbd> (triggering a newline).
- Remaps <kbd>⌘ Cmd</kbd>+<kbd>Enter</kbd> $\to$ plain <kbd>Enter</kbd> (triggering send).
- Fast path filter: ignores all non-Enter keystrokes instantly with **zero CPU latency**.

---

### License

If you like this repo, please donate a little ⭐️Star!
