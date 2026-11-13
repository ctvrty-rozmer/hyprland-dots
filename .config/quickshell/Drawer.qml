// import QtQuick
// import QtQuick.Layouts

// RowLayout {
//     id: root
//     property string icon
//     property bool open: false
//     default property alias content: inner.data
//     spacing: 6

//     Pill {
//         pad: 6
//         color: Theme.c(3)
//         onClicked: root.open = !root.open
//         Label { text: root.icon; color: Theme.fg }
//     }
//     RowLayout {
//         id: inner
//         clip: true
//         spacing: 6
//         Layout.preferredWidth: root.open ? implicitWidth : 0
//         Behavior on Layout.preferredWidth { NumberAnimation { duration: 350; easing.type: Easing.OutQuart } }
//     }
// }
import QtQuick
import QtQuick.Layouts

RowLayout {
    id: root
    property bool open: false
    default property alias content: inner.data
    spacing: 6

    Pill {
        pad: 6
        hoverFill: true
        onClicked: root.open = !root.open
        Eye { open: root.open }
    }
    RowLayout {
        id: inner
        clip: true
        spacing: 6
        Layout.preferredWidth: root.open ? implicitWidth : 0
        Behavior on Layout.preferredWidth { NumberAnimation { duration: 350; easing.type: Easing.OutQuart } }
    }
}