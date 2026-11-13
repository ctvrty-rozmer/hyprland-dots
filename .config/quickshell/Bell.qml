import Quickshell
import Quickshell.Io
import QtQuick

Pill {
    id: root
    property int count: 0
    property bool dnd: false
    pad: 14
    hoverFill: true
    onClicked: Quickshell.execDetached(["sh", "-c", "$HOME/.config/swaync/rotate-text-empty.sh"])

    // swaync pushes {"count":N,"dnd":bool,...} on every change
    Process {
        running: true
        command: ["swaync-client", "-s"]
        stdout: SplitParser {
            onRead: d => {
                try {
                    const s = JSON.parse(d)
                    if (s.count > root.count) swing.restart()
                    root.count = s.count
                    root.dnd = s.dnd
                } catch (e) {}
            }
        }
    }

    TapHandler {
        acceptedButtons: Qt.RightButton
        onTapped: Quickshell.execDetached(["swaync-client", "-d", "-sw"])
    }

    SequentialAnimation {
        id: swing
        NumberAnimation { target: bell; property: "rotation"; to: -20; duration: 90; easing.type: Easing.OutQuad }
        NumberAnimation { target: bell; property: "rotation"; to: 16; duration: 150; easing.type: Easing.InOutQuad }
        NumberAnimation { target: bell; property: "rotation"; to: -10; duration: 130; easing.type: Easing.InOutQuad }
        NumberAnimation { target: bell; property: "rotation"; to: 5; duration: 110; easing.type: Easing.InOutQuad }
        NumberAnimation { target: bell; property: "rotation"; to: 0; duration: 100; easing.type: Easing.InQuad }
    }

    Item {
        implicitWidth: 16; implicitHeight: 18

        Canvas {
            id: bell
            anchors.fill: parent
            transformOrigin: Item.Top
            property color tint: root.dnd ? Theme.dim : root.count > 0 ? Theme.gold : Theme.tarnished
            property color slash: Theme.crimson
            property bool dnd: root.dnd
            onTintChanged: requestPaint()
            onSlashChanged: requestPaint()
            onDndChanged: requestPaint()

            onPaint: {
                const ctx = getContext("2d")
                ctx.reset()
                const cx = width / 2
                ctx.strokeStyle = tint
                ctx.fillStyle = tint
                ctx.lineWidth = 1.2
                ctx.lineCap = "round"
                ctx.lineJoin = "round"

                ctx.beginPath(); ctx.arc(cx, 2, 1, 0, 2 * Math.PI); ctx.stroke()   // hanging ring

                ctx.beginPath()                                                     // body
                ctx.moveTo(cx - 6, 12.5)
                ctx.bezierCurveTo(cx - 4.5, 11, cx - 4.5, 8, cx - 4, 6)
                ctx.bezierCurveTo(cx - 3.5, 3.5, cx - 1.5, 2.8, cx, 2.8)
                ctx.bezierCurveTo(cx + 1.5, 2.8, cx + 3.5, 3.5, cx + 4, 6)
                ctx.bezierCurveTo(cx + 4.5, 8, cx + 4.5, 11, cx + 6, 12.5)
                ctx.closePath()
                ctx.stroke()

                ctx.beginPath()                                                     // star clapper
                for (let i = 0; i < 8; i++) {
                    const a = i * Math.PI / 4 - Math.PI / 2
                    const len = i % 2 === 0 ? 2.2 : 0.7
                    ctx.lineTo(cx + Math.cos(a) * len, 15.2 + Math.sin(a) * len)
                }
                ctx.closePath()
                ctx.fill()

                if (dnd) {
                    ctx.strokeStyle = slash
                    ctx.lineWidth = 1.4
                    ctx.beginPath(); ctx.moveTo(1.5, 2); ctx.lineTo(width - 1.5, height - 2); ctx.stroke()
                }
            }
        }

        Rectangle {                                    // unread dot
            visible: root.count > 0 && !root.dnd
            x: 10; y: 1
            width: 5; height: 5; radius: 2.5
            color: Theme.crimson
        }
    }
}