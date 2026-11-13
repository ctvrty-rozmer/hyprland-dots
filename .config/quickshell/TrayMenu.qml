import Quickshell
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts

PopupWindow {
    id: root
    required property Item target
    required property var handle   // the tray item's .menu

    anchor.item: target
    anchor.edges: Edges.Bottom
    anchor.gravity: Edges.Bottom | Edges.Left
    implicitWidth: top.implicitWidth + 16
    implicitHeight: top.implicitHeight + 16
    color: "transparent"

    HyprlandFocusGrab { windows: [root]; active: root.visible; onCleared: root.visible = false }
    


    // one menu level; entries with children load another copy of this inline
    Component {
        id: level

        ColumnLayout {
            id: list
            property var handle
            spacing: 2

            QsMenuOpener { id: opener; menu: list.handle }

            Repeater {
                model: opener.children

                ColumnLayout {
                    id: entry
                    required property var modelData
                    property bool open: false
                    Layout.fillWidth: true
                    spacing: 2

                    Rectangle {
                        id: row
                        readonly property bool sep: entry.modelData.isSeparator
                        Layout.fillWidth: true
                        implicitWidth: label.implicitWidth + 44
                        implicitHeight: sep ? 1 : 24
                        radius: 20
                        color: sep ? Qt.alpha(Theme.gold, 0.25)
                            : (hov.hovered || entry.open) && entry.modelData.enabled ? Qt.alpha(Theme.gold, 0.25) : "transparent"
                        Behavior on color { ColorAnimation { duration: 300 } }

                        HoverHandler { id: hov }
                        TapHandler {
                            enabled: !row.sep && entry.modelData.enabled
                            onTapped: {
                                if (entry.modelData.hasChildren) entry.open = !entry.open
                                else { entry.modelData.triggered(); root.visible = false }
                            }
                        }
                        Label {
                            id: label
                            visible: !row.sep
                            anchors { left: parent.left; leftMargin: 14; verticalCenter: parent.verticalCenter }
                            text: (entry.modelData.checkState === Qt.Checked ? "󰄬 " : "") + entry.modelData.text
                            opacity: entry.modelData.enabled ? 1 : 0.4
                        }
                        Label {
                            visible: entry.modelData.hasChildren
                            anchors { right: parent.right; rightMargin: 12; verticalCenter: parent.verticalCenter }
                            text: entry.open ? "󰅀" : "󰅂"
                        }
                    }

                    Loader {
                        Layout.fillWidth: true
                        Layout.leftMargin: 12
                        active: entry.open
                        visible: entry.open
                        sourceComponent: level
                        onLoaded: item.handle = entry.modelData
                    }
                }
            }
        }
    }

    Rectangle {
        anchors.fill: parent
        radius: 20
        color: Theme.popup

        Loader {
            id: top
            anchors.centerIn: parent
            sourceComponent: level
            onLoaded: item.handle = root.handle
        }
    }
}