import QtQuick

Canvas {
    id: eye
    property bool open: false
    property real amount: open ? 1 : 0
    property color tint: Theme.gold

    implicitWidth: 20; implicitHeight: 20
    Behavior on amount { NumberAnimation { duration: 350; easing.type: Easing.OutQuart } }
    onAmountChanged: requestPaint()
    onTintChanged: requestPaint()

    onPaint: {
        const ctx = getContext("2d")
        ctx.reset()
        const cx = width / 2, cy = height / 2, w = width / 2 - 1
        const a = amount
        const sag = 6 * (1 - a)                            // closed lid bows downward
        const upY = cy + sag - 2 * 5 * a                   // upper lid control point
        const loY = cy + sag + 2 * 5 * 0.85 * a            // lower lid control point

        ctx.strokeStyle = tint
        ctx.fillStyle = tint
        ctx.lineWidth = 1.2
        ctx.lineCap = "round"

        ctx.beginPath()                                    // lids
        ctx.moveTo(cx - w, cy)
        ctx.quadraticCurveTo(cx, upY, cx + w, cy)
        ctx.quadraticCurveTo(cx, loY, cx - w, cy)
        ctx.closePath()
        ctx.stroke()

        if (a > 0.3) {                                     // iris and pupil, clipped to the lids
            ctx.save()
            ctx.clip()
            ctx.beginPath(); ctx.arc(cx, cy, 3.2, 0, 2 * Math.PI); ctx.stroke()
            ctx.beginPath(); ctx.arc(cx, cy, 1.3, 0, 2 * Math.PI); ctx.fill()
            ctx.restore()
        }

        // lashes along the lower lid; they ride the lid as it opens and closes
        ctx.lineWidth = 1
        const gap = 3 *a
        for (const t of [0.2, 0.5, 0.8]) {
            const u = 1 - t
            const px = u * u * (cx - w) + 2 * u * t * cx + t * t * (cx + w)
            const py = u * u * cy + 2 * u * t * loY + t * t * cy + gap
            ctx.beginPath()
            ctx.moveTo(px, py)
            ctx.lineTo(px + (t - 0.5) * 4, py + 3)         // fan slightly outward
            ctx.stroke()
        }
    }
}