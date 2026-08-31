import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.Commons

Item {
  id: root

  Variants {
    model: Quickshell.screens

    PanelWindow {
      id: overlayWindow
      required property var modelData
      screen: modelData

      anchors {
        top: true
        left: true
        right: true
      }
      height: Style.space(60)
      color: "transparent"

      WlrLayershell.namespace: "omarchy-chef-overlay"
      WlrLayershell.layer: WlrLayer.Overlay
      WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
      exclusionMode: ExclusionMode.Ignore
      mask: Region {}

      Text {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: Style.space(14)

        text: "Chef OS"
        color: Util.alpha(Color.foreground, 0.25)
        font.family: Style.font.family
        font.pixelSize: Style.font.title
        font.bold: true
        font.letterSpacing: 2
      }
    }
  }
}
