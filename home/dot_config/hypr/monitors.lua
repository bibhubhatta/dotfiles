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

-- Workspaces are managed by the split-monitor-workspaces Lua package
-- (~/.config/hypr/plugins/split-monitor-workspaces, branch release/0.56.x)
-- with linked monitors: ten workspaces per monitor, numbered 1-10 on each
-- screen, allocated in the order Hyprland reports the monitors (DP-1 owns
-- Hyprland workspaces 1-10, DP-2 owns 11-20), persistent while empty.
--
-- Update the package alongside Hyprland: `git pull` inside the plugin directory
-- and check out the matching release/0.XX.x branch after a Hyprland release.
require("hypr.plugins.split-monitor-workspaces.init").setup({
  -- SUPER+N switches every monitor to its own workspace N together, so
  -- workspace 1 on the left and workspace 1 on the right act as one.
  link_monitors = true,
})
