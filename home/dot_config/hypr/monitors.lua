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

-- Workspace-to-monitor bindings — 1-5 on the left port, 6-10 on the right.
-- The offset of five keeps a fixed pairing between the two screens:
-- (1,6) (2,7) (3,8) (4,9) (5,10).
--
-- persistent keeps an idle workspace alive instead of letting Hyprland destroy
-- it when the last window closes. The per-monitor bar widget filters
-- workspaces by the monitor they sit on, and a destroyed workspace sits on no
-- monitor, so without this the bar would drop workspaces as they empty.
for workspace = 1, 5 do
  hl.workspace_rule({
    workspace = tostring(workspace),
    monitor = "DP-1",
    default = workspace == 1,
    persistent = true,
  })
end

for workspace = 6, 10 do
  hl.workspace_rule({
    workspace = tostring(workspace),
    monitor = "DP-2",
    default = workspace == 6,
    persistent = true,
  })
end
