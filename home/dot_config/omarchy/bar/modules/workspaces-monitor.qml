import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import qs.Commons
import qs.Ui

// Per-monitor workspace switcher.
//
// The stock omarchy.workspaces widget lists workspace ids 1-10 on every screen.
// Workspaces here are split by split-monitor-workspaces (see hypr/monitors.lua):
// each monitor owns a run of ten Hyprland workspaces, and this bar shows only
// the run belonging to the screen it is drawn on, labelled 1-0 by position in
// that run. The first five slots are always shown; the rest appear only while
// they hold a window or are the active workspace, matching how the stock
// widget reveals workspaces as they come into use.
BarWidget {
  id: root

  // One bar surface is created per monitor, so this widget's own window
  // identifies the screen it belongs to.
  readonly property var ownWindow: root.QsWindow ? root.QsWindow.window : null
  readonly property string screenName: ownWindow && ownWindow.screen ? String(ownWindow.screen.name || "") : ""

  // The workspace shown as current on this bar is the one active on this
  // monitor, not the globally focused one — otherwise the unfocused monitor's
  // bar would show no current workspace at all.
  readonly property int monitorActiveId: {
    var monitors = Hyprland.monitors.values
    for (var i = 0; i < monitors.length; i++) {
      if (String(monitors[i].name) !== root.screenName) continue
      return monitors[i].activeWorkspace ? monitors[i].activeWorkspace.id : -1
    }
    return -1
  }

  function workspaceById(id) {
    var values = Hyprland.workspaces.values
    for (var i = 0; i < values.length; i++) {
      if (values[i].id === id) return values[i]
    }

    return null
  }

  // Hyprland workspaces per monitor, as configured for split-monitor-workspaces.
  readonly property int perMonitor: 10
  readonly property int alwaysShown: 5

  // First Hyprland id of this monitor's run, derived from the workspace it is
  // currently showing: runs are contiguous blocks of perMonitor ids.
  readonly property int rangeBase: monitorActiveId > 0
    ? Math.floor((monitorActiveId - 1) / perMonitor) * perMonitor
    : -1

  function workspaceIds() {
    if (rangeBase < 0) return []

    var ids = []
    for (var slot = 1; slot <= alwaysShown; slot++) ids.push(rangeBase + slot)

    for (var slot = alwaysShown + 1; slot <= perMonitor; slot++) {
      var id = rangeBase + slot
      var workspace = workspaceById(id)
      var occupied = workspace !== null && workspace.toplevels.values.length > 0
      if (occupied || id === monitorActiveId) ids.push(id)
    }

    return ids
  }

  function labelFor(id) {
    var slot = id - rangeBase
    return slot === 10 ? "0" : String(slot)
  }

  function focusWorkspace(id) {
    if (!root.bar) return
    root.bar.run("hyprctl dispatch " + Util.shellQuote("hl.dsp.focus({ workspace = \"" + id + "\" })"))
  }

  readonly property real trailingGap: root.vertical ? 0 : Style.spaceReal(1.5)

  implicitWidth: grid.implicitWidth + trailingGap
  implicitHeight: grid.implicitHeight

  GridLayout {
    id: grid
    anchors.fill: parent
    anchors.rightMargin: root.trailingGap
    columns: root.vertical ? 1 : Math.max(1, root.workspaceIds().length)
    columnSpacing: root.vertical ? 0 : Style.space(1)
    rowSpacing: root.vertical ? Style.space(2) : 0

    Repeater {
      model: root.workspaceIds()

      WidgetButton {
        required property int modelData

        readonly property var workspace: root.workspaceById(modelData)
        readonly property bool occupied: workspace !== null && workspace.toplevels.values.length > 0
        readonly property bool current: modelData === root.monitorActiveId

        bar: root.bar
        text: current ? "󱓻" : root.labelFor(modelData)
        opacity: occupied || current ? 1 : 0.5
        horizontalMargin: 6
        verticalPadding: 6
        fixedWidth: root.vertical ? root.barSize : Style.space(20)
        fixedHeight: root.barSize
        onPressed: function () { root.focusWorkspace(modelData) }
      }
    }
  }
}
