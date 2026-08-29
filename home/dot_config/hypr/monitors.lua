-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
-- List current monitors and supported resolutions with: hyprctl monitors all

-- Both displays are 1080p, so no UI upscaling for GTK/JetBrains apps.
-- This is set via hl.env, which propagates into the systemd user environment
-- and takes precedence over ~/.config/uwsm/env.d.
local omarchy_gdk_scale = 1
local omarchy_monitor_scale = 1

hl.env("GDK_SCALE", tostring(omarchy_gdk_scale))

-- Preferred resolution, auto-positioned. Connect or swap monitors freely:
-- whichever is wired to DP-1 becomes "left", DP-2 becomes "right".
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = omarchy_monitor_scale })
