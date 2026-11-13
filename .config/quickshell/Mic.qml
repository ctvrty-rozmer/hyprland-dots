import Quickshell.Services.Pipewire
import QtQuick

Pill {
    id: root
    readonly property var audio: Pipewire.defaultAudioSource?.audio
    readonly property bool muted: audio?.muted ?? false
    hoverFill: false
    onClicked: if (audio) audio.muted = !audio.muted

    PwObjectTracker { objects: [Pipewire.defaultAudioSource] }

    Canvas {
        implicitWidth: 22; implicitHeight: 24
        property real closed: root.muted ? 1 : 0          // the beak closes first, then the stitches sew
        property color beak: root.muted ? Theme.dim : Theme.gold
        property color thread: Theme.crimson
        Behavior on closed { NumberAnimation { duration: 800; easing.type: Easing.InOutQuad } }
        onClosedChanged: requestPaint()

        onPaint: {
            const ctx = getContext("2d")
            ctx.reset()
            ctx.lineCap = "round"
            ctx.lineJoin = "round"
            ctx.strokeStyle = beak
            ctx.fillStyle = beak

            ctx.globalAlpha = 0.9                                 // star above the head (delete this block to remove it)
            ctx.beginPath()
            for (let i = 0; i < 8; i++) {
                const a = i * Math.PI / 4 - Math.PI / 2, l = i % 2 === 0 ? 2.2 : 0.7
                ctx.lineTo(11 + Math.cos(a) * l, 3.6 + Math.sin(a) * l)
            }
            ctx.closePath()
            ctx.fill()

            ctx.save()
            // Flip horizontally around the canvas center
            ctx.translate(22, 0)
            ctx.scale(-1, 1)
            
            // Original positioning
            ctx.translate(11, 13)
            ctx.translate(-12.25, -13)
            ctx.globalAlpha = 1

            ctx.lineWidth = 0.8
            ctx.fillStyle = Qt.alpha(beak, 0.1)

            ctx.beginPath()                                       // head and upper beak
            ctx.moveTo(3.9, 14.2)
            ctx.quadraticCurveTo(6.5, 9.4, 11.5, 9)
            ctx.bezierCurveTo(14, 6.8, 19, 7.5, 20, 12)
            ctx.bezierCurveTo(20.6, 15.5, 18.5, 18.2, 15.5, 18.8)
            ctx.quadraticCurveTo(12.5, 18.6, 11.5, 16)
            ctx.lineTo(11.2, 13.2)
            ctx.lineTo(3.9, 14.2)
            ctx.closePath()
            ctx.fill(); ctx.stroke()

            ctx.save()                                            // lower beak, hinged at the mouth corner
            ctx.translate(11.2, 13.2)
            ctx.rotate(-0.34 * Math.max(0, 1 - closed * 2.5))
            ctx.translate(-11.2, -13.2)
            ctx.beginPath()
            ctx.moveTo(11.2, 13.2)
            ctx.lineTo(4.2, 14.3)
            ctx.quadraticCurveTo(7, 16.3, 11.6, 16)
            ctx.closePath()
            ctx.fill(); ctx.stroke()
            ctx.restore()

            ctx.fillStyle = beak                                  // eye
            ctx.beginPath(); ctx.arc(14.6, 11.2, 0.9, 0, 2 * Math.PI); ctx.fill()

            // ctx.strokeStyle = thread                              // stitches across the seam, once the beak is shut
            // ctx.fillStyle = thread
            // ctx.lineWidth = 1.1
            // const N = 4, prog = Math.max(0, (sewn - 0.4) / 0.6)
            // for (let i = 0; i < N; i++) {
            //     const f = Math.max(0, Math.min(1, prog * N - i))
            //     if (f <= 0) continue
            //     const t = (i + 0.5) / N
            //     const x = 4.6 + 6 * t, y = 14.1 - 0.8 * t
            //     const hl = 0.9 + 1.6 * Math.sin(Math.PI * t)
            //     ctx.beginPath()
            //     ctx.moveTo(x - 0.5, y - hl)
            //     ctx.lineTo(x - 0.5 + f, y - hl + 2 * hl * f)
            //     ctx.stroke()
            // }

            // const tail = Math.max(0, (sewn - 0.95) * 20)          // loose threads once fully sewn
            // if (tail > 0) {
            //     ctx.globalAlpha = tail
            //     ctx.lineWidth = 0.9
            //     ctx.beginPath(); ctx.moveTo(5.85, 15.5); ctx.quadraticCurveTo(6.3, 17.5, 4.6, 19); ctx.stroke()
            //     ctx.beginPath(); ctx.moveTo(10.35, 14.9); ctx.quadraticCurveTo(11.8, 17, 10.8, 19.5); ctx.stroke()
            //     ctx.beginPath(); ctx.arc(4.6, 19.4, 0.8, 0, 2 * Math.PI); ctx.fill()
            //     ctx.beginPath(); ctx.arc(10.8, 19.9, 0.8, 0, 2 * Math.PI); ctx.fill()
            // }
            // ctx.restore()
        }
    }
}