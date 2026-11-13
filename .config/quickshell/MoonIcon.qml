import QtQuick

Canvas {
    property real phase
    property color lit: Theme.bone
    property color rim: Theme.dim

    implicitWidth: 14; implicitHeight: 14
    onPhaseChanged: requestPaint()
    onLitChanged: requestPaint()
    onRimChanged: requestPaint()

    onPaint: {
        const ctx = getContext("2d")
        ctx.reset()
        const cx = width / 2, cy = height / 2, R = width / 2 - 1
        const side = phase < 0.5 ? 1 : -1              // which limb is lit
        const k = Math.cos(phase * 2 * Math.PI)        // terminator position

        ctx.strokeStyle = rim
        ctx.lineWidth = 1
        ctx.beginPath(); ctx.arc(cx, cy, R, 0, 2 * Math.PI); ctx.stroke()

        ctx.fillStyle = lit
        ctx.beginPath()
        for (let i = 0; i <= 24; i++) {                // lit limb, top to bottom
            const t = -Math.PI / 2 + Math.PI * i / 24
            ctx.lineTo(cx + side * R * Math.cos(t), cy + R * Math.sin(t))
        }
        for (let i = 24; i >= 0; i--) {                // terminator, bottom to top
            const t = -Math.PI / 2 + Math.PI * i / 24
            ctx.lineTo(cx + side * k * R * Math.cos(t), cy + R * Math.sin(t))
        }
        ctx.fill()
    }
}