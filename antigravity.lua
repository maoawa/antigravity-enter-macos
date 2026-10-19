-- antigravity.lua
-- Antigravity Enter Key Customization for macOS
-- https://github.com/maoawa/antigravity-enter-macos
--
-- Maps:
--   - Cmd+Enter (or Ctrl+Enter) -> Send message (sends plain Enter to Antigravity)
--   - Enter alone               -> New line (sends Shift+Enter to Antigravity)
--   - Shift+Enter               -> New line (native Antigravity behavior preserved)

local obj = {}
obj.name = "AntigravityEnter"
obj.version = "1.0.0"
obj.author = "maoawa"

local TARGET_BUNDLE_ID = "com.google.antigravity"
local KEY_RETURN = 36      -- Standard Return / Enter
local KEY_PAD_ENTER = 76   -- Keypad Enter

local eventTap = nil

function obj.start()
    if eventTap then
        eventTap:stop()
    end

    eventTap = hs.eventtap.new({
        hs.eventtap.event.types.keyDown,
        hs.eventtap.event.types.keyUp
    }, function(event)
        -- Fast path: ignore all keys other than Enter / Return immediately
        local keyCode = event:getKeyCode()
        if keyCode ~= KEY_RETURN and keyCode ~= KEY_PAD_ENTER then
            return false
        end

        -- Check if Antigravity is the active frontmost application
        local app = hs.application.frontmostApplication()
        if not app or app:bundleID() ~= TARGET_BUNDLE_ID then
            return false
        end

        local flags = event:getFlags()

        -- 1. Cmd+Enter or Ctrl+Enter -> Send Message
        -- Antigravity natively submits when receiving Return without Shift.
        if (flags.cmd or flags.ctrl) and not flags.alt then
            event:setFlags({})
            return false
        end

        -- 2. Plain Enter (no modifier keys) -> New Line
        -- Antigravity natively inserts a newline when receiving Shift+Return.
        if not (flags.cmd or flags.ctrl or flags.alt or flags.shift) then
            event:setFlags({ shift = true })
            return false
        end

        -- 3. Shift+Enter -> New Line (preserved natively)
        if flags.shift and not (flags.cmd or flags.ctrl or flags.alt) then
            return false
        end

        return false
    end)

    if eventTap then
        eventTap:start()
        print(string.format("[%s] Started successfully.", obj.name))
    else
        print(string.format("[%s] Failed to create event tap. Check macOS Accessibility permissions.", obj.name))
    end

    return obj
end

function obj.stop()
    if eventTap then
        eventTap:stop()
        eventTap = nil
        print(string.format("[%s] Stopped.", obj.name))
    end
    return obj
end

-- Auto-start when loaded
obj.start()

return obj
