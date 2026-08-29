import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import qs.Commons
import qs.Ui

// Per-monitor workspace switcher.
//
// The stock omarchy.workspaces widget lists every workspace on every screen.
// Workspaces here are pinned one range per monitor (see hypr/monitors.lua), so
// each bar should show only the range belonging to the screen it is drawn on.
//
// The rules mark those workspaces persistent, which is what makes an idle
// workspace exist at all — Hyprland destroys empty non-persistent ones, and a
// workspace that does not exist has no monitor to be filtered by.
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

  function workspaceIds() {
    var ids = []
    var values = Hyprland.workspaces.values

    for (var i = 0; i < values.length; i++) {
      var workspace = values[i]
      // Negative ids are special/scratchpad workspaces, which belong to no
      // numbered range and are reached by their own bindings.
      if (workspace.id < 1) continue
      if (!workspace.monitor || String(workspace.monitor.name) !== root.screenName) continue
      if (ids.indexOf(workspace.id) === -1) ids.push(workspace.id)
    }

    ids.sort(function (left, right) { return left - right })
    return ids
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
        text: current ? "󱓻" : (modelData === 10 ? "0" : String(modelData))
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
