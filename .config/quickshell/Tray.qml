import Quickshell
import Quickshell.Widgets
import Quickshell.Services.SystemTray
import QtQuick

Drawer {
    layoutDirection: Qt.RightToLeft

    Pill {
        pad: 1
        color: Theme.lift
        Repeater {
            model: SystemTray.items
            IconImage {
                id: item
                required property var modelData
                implicitSize: 16
                source: modelData.icon

                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
                    onClicked: e => {
                        const t = item.modelData
                        if (e.button === Qt.MiddleButton) t.secondaryActivate()
                        else if (e.button === Qt.LeftButton && !t.onlyMenu) t.activate()
                        else if (t.hasMenu) menu.visible = !menu.visible
                    }
                }

                TrayMenu { id: menu; target: item; handle: item.modelData.menu }
            }
        }
    }
    Label { text: "|"; color: Theme.gold }
}