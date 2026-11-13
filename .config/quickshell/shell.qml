import Quickshell
import QtQuick
import QtQuick.Layouts

Variants {
    model: Quickshell.screens

    PanelWindow {
        required property var modelData
        screen: modelData
        anchors { top: true; left: true; right: true }
        implicitHeight: 40
        color: "transparent"

        Island {
            anchors { left: parent.left; right: parent.right; top: parent.top; bottom: parent.bottom; topMargin: 4; leftMargin: 6; rightMargin: 6; bottomMargin: 4 }
            readonly property int gap: 6
            readonly property int barHeight: 34

            RowLayout {
                anchors { left: parent.left; leftMargin: 6; verticalCenter: parent.verticalCenter }
                spacing: 4
                Clock {}
                Music {}
                Weather {}
            }

            Workspaces { anchors.centerIn: parent }

            RowLayout {
                anchors { right: parent.right; rightMargin: 6; verticalCenter: parent.verticalCenter }
                spacing: 2
                Tray {}
                Mic {}
                Bt {}
                Volume {}
                Net {}
                Battery {}
                Bell {}
            }
        }
    }
}