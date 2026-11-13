import Quickshell.Services.Pipewire
import QtQuick

Pill {
    id: root
    readonly property var audio: Pipewire.defaultAudioSink?.audio
    readonly property real vol: Math.max(0, Math.min(1, audio?.volume ?? 0))
    readonly property bool muted: audio?.muted ?? false
    property bool showPct: false
    onRightClicked: showPct = !showPct
    hoverFill: true
    onClicked: if (audio) audio.muted = !audio.muted

    PwObjectTracker { objects: [Pipewire.defaultAudioSink] }
    WheelHandler {
        onWheel: e => {
            if (root.audio) root.audio.volume = Math.max(0, Math.min(1, root.vol + (e.angleDelta.y > 0 ? 0.05 : -0.05)))
        }
    }

    Item {
        implicitWidth: 24; implicitHeight: 24

        Canvas {
            anchors.fill: parent
            property real vol: root.vol
            property bool muted: root.muted
            property color gold: Theme.tarnished
            property color disc: Theme.popup
            onVolChanged: requestPaint()
            onMutedChanged: requestPaint()
            onGoldChanged: requestPaint()
            onDiscChanged: requestPaint()

            onPaint: {
                const ctx = getContext("2d")
                ctx.reset()
                ctx.imageSmoothingEnabled = true
                const c = 12, lit = muted ? 0 : Math.round(vol * 12)
                const pt = (a, r) => [c + Math.cos(a) * r, c + Math.sin(a) * r]
                const circle = (r, fill) => { ctx.beginPath(); ctx.arc(c, c, r, 0, 2 * Math.PI); fill ? ctx.fill() : ctx.stroke() }
                ctx.lineCap = "round"
                ctx.strokeStyle = gold
                ctx.fillStyle = gold

                ctx.globalAlpha = muted ? 0.35 : 1                // double ring
                ctx.lineWidth = 1.2
                circle(10.5)
                ctx.globalAlpha = muted ? 0.2 : 0.5
                ctx.lineWidth = 0.8
                circle(8.5)

                ctx.lineWidth = 1.2                               // twelve ticks, lit clockwise from the top
                for (let i = 0; i < 12; i++) {
                    ctx.globalAlpha = i < lit ? 1 : 0.2
                    const a = -Math.PI / 2 + i * Math.PI / 6
                    const [x1, y1] = pt(a, 6), [x2, y2] = pt(a, 7.7)
                    ctx.beginPath(); ctx.moveTo(x1, y1); ctx.lineTo(x2, y2); ctx.stroke()
                }

                ctx.globalAlpha = muted ? 0.35 : 0.9              // compass stars on the ring
                for (let i = 0; i < 4; i++) {
                    const [sx, sy] = pt(i * Math.PI / 2, 9.8)
                    ctx.beginPath()
                    for (let j = 0; j < 8; j++) {
                        const b = j * Math.PI / 4, l = j % 2 === 0 ? 2 : 0.7
                        ctx.lineTo(sx + Math.cos(b) * l, sy + Math.sin(b) * l)
                    }
                    ctx.closePath()
                    ctx.fill()
                }

                if (muted) {                                      // eclipse in the middle
                    ctx.globalAlpha = 1
                    ctx.fillStyle = disc
                    circle(3.6, true)
                    ctx.strokeStyle = gold
                    ctx.lineWidth = 1.1
                    ctx.globalAlpha = 0.8
                    circle(4.5)
                    ctx.globalAlpha = 1
                    ctx.fillStyle = gold
                    ctx.beginPath(); ctx.arc(c + 3.2, c - 3.2, 1, 0, 2 * Math.PI); ctx.fill()
                }
            }
        }

        MoonIcon {
            anchors.centerIn: parent
            visible: !root.muted
            implicitWidth: 10; implicitHeight: 10
            phase: root.vol * 0.5            // new moon at silent, full moon at 100%
            lit: Theme.gold
            rim: Theme.dim
        }
    }
    Label {
        visible: root.showPct && !root.muted
        text: Math.round(root.vol * 100) + "%"
    }
}