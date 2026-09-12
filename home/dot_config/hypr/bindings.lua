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

-- Workspace switching in most-recently-used order.
--
-- Hyprland keeps an MRU list of workspaces internally but exposes only the
-- single most recent entry to config (`workspace previous`), and that
-- dispatcher speaks global workspace ids, so it moves one screen and leaves
-- linked monitors out of step. The stack below is kept here instead: it
-- records per-monitor workspace indices and switches through
-- smw.workspace(), so both screens keep moving together.
--
-- Hold SUPER and tap TAB to walk back through the stack, SHIFT+TAB to walk
-- forward again. Releasing SUPER commits wherever the walk landed, which is
-- what lets repeated taps reach the second and third most recent workspace
-- instead of bouncing between two. Workspaces that hold no windows are
-- skipped; the numeric steppers below stay exhaustive, so SUPER+CTRL+TAB and
-- SUPER+scroll remain the way to reach a blank workspace.
local smw_globals = require("hypr.plugins.split-monitor-workspaces.lua.globals")

-- monitor name -> array of workspace indices, most recent first.
local mru = {}
-- While a walk is open: the monitor it started on, the entries it may land on,
-- how deep into them it has reached, and the index it last switched to.
local walk = nil

-- Workspace names are global ("11".."20" on the second monitor) but the
-- bindings and smw.workspace() both speak per-monitor indices, so translate.
local function index_of(monitor, workspace_name)
  assert(smw_globals.monitor_workspace_map, "split-monitor-workspaces has not built its workspace map yet")
  local names = smw_globals.monitor_workspace_map[monitor.id]
  if not names then return nil end
  for index, name in ipairs(names) do
    if name == workspace_name then return index end
  end
  return nil
end

local function touch(monitor_name, index)
  assert(type(index) == "number", "MRU entries must be per-monitor workspace indices")
  local list = mru[monitor_name] or {}
  mru[monitor_name] = list
  for position, existing in ipairs(list) do
    if existing == index then
      table.remove(list, position)
      break
    end
  end
  table.insert(list, 1, index)
end

-- Re-read what every monitor is actually showing into the stack. Used to
-- commit a walk and to seed the stack on load, so the stack agrees with the
-- screen whatever link_monitors moved along the way.
local function record_visible_workspaces()
  for _, monitor in ipairs(hl.get_monitors()) do
    local active = monitor.active_workspace
    local index = active and index_of(monitor, active.name)
    if index then touch(monitor.name, index) end
  end
end

hl.on("workspace.active", function(workspace)
  local monitor = workspace.monitor
  local index = monitor and index_of(monitor, workspace.name)
  if not index then return end

  if walk then
    -- The walk's own switches must not reorder the stack, or every step would
    -- re-front its target and the walk could never reach further back.
    if index == walk.expected then return end
    -- Something else moved the workspace, so the walk no longer describes
    -- what is on screen; the next TAB starts a fresh one.
    walk = nil
  end

  touch(monitor.name, index)
end)

hl.on("config.reloaded", function()
  walk = nil
  record_visible_workspaces()
end)

-- An index names a workspace on every screen the switch will move, so it only
-- counts as empty when none of them holds a window. That keeps an index
-- reachable while any monitor still has something on it.
local function index_is_empty(index)
  local monitors = smw_globals.cfg.link_monitors and hl.get_monitors() or { hl.get_active_monitor() }
  for _, monitor in ipairs(monitors) do
    local names = monitor and smw_globals.monitor_workspace_map[monitor.id]
    local workspace = names and names[index] and hl.get_workspace(names[index])
    if workspace and not workspace.is_empty then return false end
  end
  return true
end

-- The entries a walk may land on. The workspace being walked away from anchors
-- the walk at position 1 and so is kept even when empty; everything behind it
-- has to hold a window to be worth stopping at.
local function walk_candidates(monitor_name)
  local candidates = {}
  for position, index in ipairs(mru[monitor_name] or {}) do
    if position == 1 or not index_is_empty(index) then
      candidates[#candidates + 1] = index
    end
  end
  return candidates
end

local function walk_mru(delta)
  return function()
    local monitor = hl.get_active_monitor()
    if not monitor then return end

    if walk and walk.monitor ~= monitor.name then walk = nil end
    if not walk then
      -- Emptiness is sampled once, as the walk opens: walking does not open or
      -- close windows, so re-testing every tap would only repeat the answer.
      -- Cursor 1 is the current workspace, which the handler above has already
      -- moved to the front of the stack.
      local candidates = walk_candidates(monitor.name)
      -- Nothing but the current workspace is worth landing on.
      if #candidates < 2 then return end
      walk = { monitor = monitor.name, candidates = candidates, cursor = 1 }
    end

    local candidates = walk.candidates
    assert(walk.cursor >= 1 and walk.cursor <= #candidates, "MRU cursor must stay inside the candidate list")

    -- Wrap at both ends so a walk can never dead-end mid-hold.
    walk.cursor = ((walk.cursor - 1 + delta) % #candidates) + 1
    walk.expected = candidates[walk.cursor]
    smw.workspace(tostring(walk.expected))()
  end
end

local function commit_mru_walk()
  if not walk then return end
  walk = nil
  record_visible_workspaces()
end

-- Default: Next/Previous workspace (e+1/e-1), stepping through global ids.
hl.unbind("SUPER + TAB")
hl.unbind("SUPER + SHIFT + TAB")
o.bind("SUPER + TAB", "Recent workspace back (hold SUPER + tap TAB)", walk_mru(1))
o.bind("SUPER + SHIFT + TAB", "Recent workspace forward", walk_mru(-1))
-- Fires on every SUPER release and is a no-op unless a walk is open.
-- ignore_mods so it still commits when SHIFT outlives SUPER on release, and
-- non_consuming so watching for the release does not swallow the SUPER key
-- from applications.
o.bind("SUPER + SUPER_L", "Commit workspace walk", commit_mru_walk,
  { release = true, ignore_mods = true, non_consuming = true })

-- Numeric stepping moves off TAB to make room for the MRU walk above.
-- Default SUPER+CTRL+TAB: Former workspace (workspace previous), which the
-- MRU walk supersedes. SUPER+CTRL+SHIFT+TAB is unclaimed by the defaults.
-- Default SUPER+scroll steps through global ids; keep it on the monitor's
-- own range.
hl.unbind("SUPER + CTRL + TAB")
hl.unbind("SUPER + mouse_down")
hl.unbind("SUPER + mouse_up")
o.bind("SUPER + CTRL + TAB", "Next workspace", smw.cycle_workspaces("next"))
o.bind("SUPER + CTRL + SHIFT + TAB", "Previous workspace", smw.cycle_workspaces("prev"))
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


-- Default: Herdr in the default terminal (ghostty), whose own ctrl+shift
-- chords would swallow the Ghostty-style bindings herdr now uses. Run it in
-- foot instead so ghostty keeps its defaults for general use. The app-id is
-- matched by Omarchy's terminal tag via the org.omarchy.* pattern.
hl.unbind("SUPER + CTRL + RETURN")
o.bind("SUPER + CTRL + RETURN", "Herdr", {
  launch = 'foot --app-id=org.omarchy.herdr --term=foot-extra --working-directory="$(omarchy-cmd-terminal-cwd)" herdr',
})
