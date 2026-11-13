import Quickshell.Services.UPower
import QtQuick

Pill {
    id: root
    readonly property var bat: UPower.displayDevice
    readonly property int pct: Math.round(bat.percentage * 100)
    readonly property bool charging: bat.state === UPowerDeviceState.Charging
    readonly property bool out: !charging && pct <= 10
    readonly property bool low: !charging && pct <= 20
    property bool showPct: false
    onRightClicked: showPct = !showPct
    hoverFill: true
    visible: bat.isLaptopBattery

    Canvas {
        implicitWidth: 24; implicitHeight: 26
        property real wax: root.pct / 100
        property real t: 0
        property bool charging: root.charging
        property bool out: root.out
        property bool low: root.low
        property color gold: Theme.gold
        property color bone: Theme.bone
        property color dim: Theme.dim
        property color crimson: Theme.crimson

        Behavior on wax { NumberAnimation { duration: 400 } }
        NumberAnimation on t { running: root.charging; from: 0; to: 1; duration: 1400; loops: Animation.Infinite }
        onWaxChanged: requestPaint()
        onTChanged: requestPaint()
        onChargingChanged: requestPaint()
        onOutChanged: requestPaint()
        onLowChanged: requestPaint()
        onGoldChanged: requestPaint()
        onBoneChanged: requestPaint()

        onPaint: {
            const ctx = getContext("2d")
            ctx.reset()
            const cx = 9, base = 21
            const h = 1.5 + 9.5 * wax, top = base - h, ty = top - 2
            const f = 1 + 0.1 * Math.sin(2 * Math.PI * t) + 0.06 * Math.sin(6 * Math.PI * t)
            const sway = 0.7 * Math.sin(4 * Math.PI * t), hf = 7 * f
            const body = low ? crimson : bone
            ctx.lineCap = "round"
            ctx.lineJoin = "round"

            const flame = (hh, w) => {
                ctx.beginPath()
                ctx.moveTo(cx + sway, ty - hh)
                ctx.bezierCurveTo(cx + w, ty - hh * 0.5, cx + w * 0.8, ty, cx, ty)
                ctx.bezierCurveTo(cx - w * 0.8, ty, cx - w, ty - hh * 0.5, cx + sway, ty - hh)
                ctx.fill()
            }

            if (!out) {                                            // glow behind everything
                const g = ctx.createRadialGradient(cx, ty - hf * 0.4, 0, cx, ty - hf * 0.4, 7)
                g.addColorStop(0, Qt.alpha(gold, 0.35))
                g.addColorStop(1, Qt.alpha(gold, 0))
                ctx.fillStyle = g
                ctx.fillRect(0, 0, width, height)
            }

            ctx.strokeStyle = dim                                  // chamberstick dish and handle
            ctx.lineWidth = 1
            ctx.beginPath()
            ctx.moveTo(1.5, base); ctx.lineTo(16.5, base)
            ctx.quadraticCurveTo(15, 23.5, cx, 23.5)
            ctx.quadraticCurveTo(3, 23.5, 1.5, base)
            ctx.stroke()
            ctx.beginPath(); ctx.arc(16.6, 22.2, 1.7, -Math.PI / 2, Math.PI / 2); ctx.stroke()

            ctx.fillStyle = Qt.alpha(body, 0.3)                    // wax body with a melted dip
            ctx.strokeStyle = body
            ctx.lineWidth = 1.1
            ctx.beginPath()
            ctx.moveTo(6, base); ctx.lineTo(6, top)
            ctx.quadraticCurveTo(cx, top + 1.4, 12, top)
            ctx.lineTo(12, base)
            ctx.closePath()
            ctx.fill(); ctx.stroke()

            ctx.lineWidth = 1.3                                    // drips
            for (const [x, len] of [[7.4, 3.4], [10.6, 2.2]]) {
                if (h <= len + 2) continue
                ctx.beginPath(); ctx.moveTo(x, top + 1.2); ctx.lineTo(x, top + 1.2 + len); ctx.stroke()
            }

            ctx.strokeStyle = dim                                  // wick
            ctx.lineWidth = 1
            ctx.beginPath(); ctx.moveTo(cx, top + 0.7); ctx.lineTo(cx, ty); ctx.stroke()

            if (out) {                                             // flame out: a wisp of smoke
                ctx.globalAlpha = 0.5
                ctx.lineWidth = 0.9
                ctx.beginPath()
                ctx.moveTo(cx, ty)
                ctx.bezierCurveTo(cx + 3, ty - 3, cx - 3, ty - 5, cx + 1, ty - 8)
                ctx.stroke()
                return
            }

            ctx.fillStyle = gold; flame(hf, 3)                     // outer and inner flame
            ctx.fillStyle = Qt.alpha(bone, 0.85); flame(hf * 0.5, 1.5)

            if (charging) {                                        // embers drift up while charging
                ctx.fillStyle = gold
                for (let k = 0; k < 3; k++) {
                    const p = (t + k / 3) % 1
                    ctx.globalAlpha = 1 - p
                    ctx.beginPath(); ctx.arc(cx + 3 * Math.sin(p * 5 + k * 2), ty - hf - p * 5, 0.7, 0, 2 * Math.PI); ctx.fill()
                }
            }
        }
    }
    Label {
        visible: root.showPct
        text: root.pct + "%"
        color: root.charging ? Theme.gold : root.out ? Theme.crimson : Theme.fg
    }
}