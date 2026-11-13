// import QtQuick
// import QtQuick.Layouts

// Rectangle {
//     id: root
//     property int pad: 8
//     property bool hoverFill: false
//     property alias hovered: hov.hovered
//     default property alias data: row.data
//     signal clicked

//     implicitWidth: row.implicitWidth + 2 * pad
//     implicitHeight: 18
//     radius: 8
//     color: hoverFill && hovered ? Theme.c(3) : "transparent"
//     Behavior on color { ColorAnimation { duration: 300 } }

//     HoverHandler { id: hov }
//     TapHandler { onTapped: root.clicked() }
//     RowLayout { id: row; anchors.centerIn: parent; spacing: 8 }
// }
import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root
    property int pad: 8
    property bool hoverFill: false
    property alias hovered: hov.hovered
    default property alias data: row.data
    signal clicked
    signal rightClicked

    implicitWidth: row.implicitWidth + 2 * pad
    implicitHeight: 16
    radius: 6
    color: "transparent"

    Canvas {
        anchors.fill: parent
        property color tint: Theme.gold
        opacity: root.hoverFill && root.hovered ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: 350 } }
        onWidthChanged: requestPaint()
        onTintChanged: requestPaint()
        onPaint: {
            const ctx = getContext("2d")
            ctx.reset()
            if (width < 2) return
            ctx.translate(width / 2, height / 2)
            ctx.scale(width / height, 1)
            const g = ctx.createRadialGradient(0, 0, 0, 0, 0, height / 2)
            g.addColorStop(0, Qt.alpha(tint, 0.4))
            g.addColorStop(1, Qt.alpha(tint, 0))
            ctx.fillStyle = g
            ctx.fillRect(-height / 2, -height / 2, height, height)
        }
    }

    HoverHandler { id: hov }
    TapHandler { onTapped: root.clicked() }
    TapHandler { acceptedButtons: Qt.RightButton; onTapped: root.rightClicked() } 
    RowLayout { id: row; anchors.centerIn: parent; spacing: 8 }
}