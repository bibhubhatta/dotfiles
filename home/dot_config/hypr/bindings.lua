-- Keep only your personal keybinding overrides here. Add new bindings or
-- unbind defaults before replacing them.

-- See current bindings and descriptions:
--   omarchy menu keybindings --print

-- Omarchy's defaults load before this file, so a key it already claims has to
-- be unbound before it can be rebound. The comment on each unbind records what
-- the key does by default.

-- Default: Spotify
hl.unbind("SUPER + SHIFT + M")
o.bind("SUPER + SHIFT + M", "YouTube Music", { webapp = "https://music.youtube.com", focus = true })

-- Default: Signal
hl.unbind("SUPER + SHIFT + G")
o.bind("SUPER + SHIFT + G", "GitHub", { webapp = "https://github.com" })

-- Default: Email (Hey)
hl.unbind("SUPER + SHIFT + E")
o.bind("SUPER + SHIFT + E", "Email", { webapp = "https://mail.google.com" })

-- Default: Grok
hl.unbind("SUPER + SHIFT + ALT + A")
o.bind("SUPER + SHIFT + ALT + A", "Gemini", { webapp = "https://gemini.google.com/app" })

-- Unclaimed by Omarchy's defaults, so no unbind needed.
o.bind("SUPER + SHIFT + L", "Linear", { webapp = "https://linear.app", focus = true })

-- Default: File manager (nautilus)
hl.unbind("SUPER + SHIFT + F")
o.bind("SUPER + SHIFT + F", "File manager", { launch = "kitty --class=org.omarchy.yazi -e yazi" })

-- Default: File manager in the active terminal's directory (nautilus)
hl.unbind("SUPER + ALT + SHIFT + F")
o.bind("SUPER + ALT + SHIFT + F", "File manager (cwd)", { launch = 'kitty --class=org.omarchy.yazi -e yazi "$(omarchy-cmd-terminal-cwd)"' })

-- Unclaimed by Omarchy's defaults, so no unbind needed.
o.bind("SUPER + SHIFT + K", "Google Keep", { webapp = "https://keep.google.com", focus = true })

-- Workspaces: per-monitor numbering via split-monitor-workspaces (configured
-- in hypr/monitors.lua). Default SUPER+1..0 target global workspace ids 1-10,
-- which no longer match the on-screen numbering, so they are rebound.
local smw = require("hypr.plugins.split-monitor-workspaces.init")

for workspace = 1, 10 do
  local key = "code:" .. tostring(workspace + 9)
  -- Default: Switch to / Move window to / Move window silently to workspace N
  hl.unbind("SUPER + " .. key)
  hl.unbind("SUPER + SHIFT + " .. key)
  hl.unbind("SUPER + SHIFT + ALT + " .. key)
end

-- SUPER+0 is workspace 10 (code:19).
for workspace = 1, smw.get_amount_of_workspaces() do
  local key = "code:" .. tostring(workspace + 9)
  local n = tostring(workspace)
  o.bind("SUPER + " .. key, "Switch to workspace " .. n, smw.workspace(n))
  o.bind("SUPER + SHIFT + " .. key, "Move window to workspace " .. n, smw.move_to_workspace(n))
  o.bind("SUPER + SHIFT + ALT + " .. key, "Move window silently to workspace " .. n, smw.move_to_workspace_silent(n))
end

-- Default: Next/Previous workspace (e+1/e-1) and SUPER+scroll, which step
-- through global ids. Cycle within the monitor's own range instead.
hl.unbind("SUPER + TAB")
hl.unbind("SUPER + SHIFT + TAB")
hl.unbind("SUPER + mouse_down")
hl.unbind("SUPER + mouse_up")
o.bind("SUPER + TAB", "Next workspace", smw.cycle_workspaces("next"))
o.bind("SUPER + SHIFT + TAB", "Previous workspace", smw.cycle_workspaces("prev"))
o.bind("SUPER + mouse_down", "Scroll active workspace forward", smw.cycle_workspaces("next"))
o.bind("SUPER + mouse_up", "Scroll active workspace backward", smw.cycle_workspaces("prev"))

-- Default: Swap window left/right/up/down (swapwindow), which stops at the
-- monitor edge. Move instead: within a monitor the window is re-inserted next
-- to its neighbour, and past the edge it flows onto the adjacent monitor
-- (binds.window_direction_monitor_fallback, on by default), so both screens
-- feel like one wide tiling area.
hl.unbind("SUPER + SHIFT + LEFT")
hl.unbind("SUPER + SHIFT + RIGHT")
hl.unbind("SUPER + SHIFT + UP")
hl.unbind("SUPER + SHIFT + DOWN")
o.bind("SUPER + SHIFT + LEFT", "Move window left", hl.dsp.window.move({ direction = "l" }))
o.bind("SUPER + SHIFT + RIGHT", "Move window right", hl.dsp.window.move({ direction = "r" }))
o.bind("SUPER + SHIFT + UP", "Move window up", hl.dsp.window.move({ direction = "u" }))
o.bind("SUPER + SHIFT + DOWN", "Move window down", hl.dsp.window.move({ direction = "d" }))
