import Quickshell
import Quickshell.Bluetooth
import QtQuick

Pill {
    id: root
    readonly property bool on: Bluetooth.defaultAdapter?.enabled ?? false
        readonly property int count: Bluetooth.devices.values.filter(d => d.connected).length
            hoverFill: true
            onClicked: Quickshell.execDetached(["blueman-manager"])

            Canvas {
                implicitWidth: 28; implicitHeight: 28
                property real closed: root.count > 0 ? 1 : 0          // 0 = open ring, 1 = completed circle
                    property int count: root.count
                        property bool on: root.on
                            property color tint: !root.on ? Theme.dim : root.count > 0 ? Theme.gold : Theme.tarnished
                                property color slash: Theme.crimson
                                    Behavior on closed { NumberAnimation { duration: 700; easing.type: Easing.InOutCubic } }
                                    onClosedChanged: requestPaint()
                                    onCountChanged: requestPaint()
                                    onOnChanged: requestPaint()
                                    onTintChanged: requestPaint()

                                    onPaint: {
                                        const ctx = getContext("2d")
                                        ctx.reset()
                                        const cx = width / 2, cy = height / 2, R = 10
                                        ctx.lineCap = "round"
                                        ctx.lineJoin = "round"
                                        ctx.strokeStyle = tint
                                        ctx.fillStyle = tint

                                        const star = (outer, inner) => {
                                        ctx.beginPath()
                                        for (let i = 0; i < 8; i++) {
                                            const a = i * Math.PI / 4 - Math.PI / 2
                                            const l = i % 2 === 0 ? outer : inner
                                            ctx.lineTo(cx + Math.cos(a) * l, cy + Math.sin(a) * l)
                                        }
                                        ctx.closePath()
                                        ctx.fill()
                                    }

                                    if (!on) {                                         // adapter off: faded, dashed circle with a slash
                                    ctx.globalAlpha = 0.4
                                    ctx.lineWidth = 1.1
                                    for (let i = 0; i < 5; i++) {
                                        const a0 = i * 2 * Math.PI / 5 + 0.25
                                        ctx.beginPath(); ctx.arc(cx, cy, R, a0, a0 + 0.8); ctx.stroke()
                                    }
                                    ctx.globalAlpha = 1
                                    ctx.strokeStyle = slash
                                    ctx.lineWidth = 1.4
                                    ctx.beginPath(); ctx.moveTo(3, 2); ctx.lineTo(width - 3, height - 2); ctx.stroke()
                                    return
                                }

                                // // outer ring, with a gap that closes as a device connects
                                // const g0 = -Math.PI / 2 + 0.6          // where the gap sits: clockwise from the top, in radians
                                // const gap = 2 * Math.PI * 0.15 * (1 - closed)
                                // ctx.lineWidth = 1.3
                                // ctx.beginPath(); ctx.arc(cx, cy, R, g0 + gap / 2, g0 + 2 * Math.PI - gap / 2); ctx.stroke()

                                // if (closed < 1) {                                  // chalk dots at the open ends
                                //     ctx.globalAlpha = 1 - closed
                                //     for (const s of [-1, 1]) {
                                //         const a = g0 + s * gap / 2
                                //         ctx.beginPath(); ctx.arc(cx + Math.cos(a) * R, cy + Math.sin(a) * R, 1.1, 0, 2 * Math.PI); ctx.fill()
                                //     }

                                //     const tr = 4.6                                 // triangle size

                                //     ctx.globalAlpha = 0.65 * (1 - closed)          // inscribed triangle, point facing down
                                //     ctx.lineWidth = 0.9
                                //     ctx.beginPath()
                                //     for (let i = 0; i < 3; i++) {
                                //         const a = Math.PI / 2 + i * 2 * Math.PI / 3
                                //         ctx.lineTo(cx + Math.cos(a) * tr, cy + Math.sin(a) * tr)
                                //     }
                                //     ctx.closePath()
                                //     ctx.stroke()
                                //     ctx.globalAlpha = 1 - closed
                                //     for (let i = 0; i < 3; i++) {
                                //         const a = Math.PI / 2 + i * 2 * Math.PI / 3
                                //         ctx.beginPath(); ctx.arc(cx + Math.cos(a) * tr, cy + Math.sin(a) * tr, 0.8, 0, 2 * Math.PI); ctx.fill()
                                //     }
                                // }

                                // Outer circle: incomplete until a device connects
                                const g0 = -Math.PI / 2 + 0.6
                                const gap = 2 * Math.PI * 0.15 * (1 - closed)

                                ctx.lineWidth = 1.2
                                ctx.beginPath()
                                ctx.arc(cx, cy, R, g0 + gap / 2, g0 + 2 * Math.PI - gap / 2)
                                ctx.stroke()

                                // Open endpoints
                                if (closed < 1)
                                {
                                    ctx.globalAlpha = 1 - closed
                                    for (const s of [-1, 1]) {
                                        const a = g0 + s * gap / 2
                                        ctx.beginPath()
                                        ctx.arc(
                                            cx + Math.cos(a) * R,
                                            cy + Math.sin(a) * R,
                                            1,
                                            0, 2 * Math.PI
                                        )

                                        ctx.fill()
                                    }
                                }

                                // Main seal and surrounding glyphs
                                ctx.globalAlpha = 1
                                ctx.lineWidth = 1
                                ctx.strokeStyle = tint
                                ctx.fillStyle = tint

                                // Central square
                                const s = 2.3
                                ctx.strokeRect(cx - s, cy - s, s * 2, s * 2)

                                // Inscribed diamond
                                ctx.beginPath()
                                ctx.moveTo(cx, cy - 3.1)
                                ctx.lineTo(cx + 4.2, cy)
                                ctx.lineTo(cx, cy + 4.2)
                                ctx.lineTo(cx - 4.2, cy)
                                ctx.closePath()
                                ctx.stroke()

                                // Four cardinal extensions
                                ctx.beginPath()
                                ctx.moveTo(cx, cy - 6.1)
                                ctx.lineTo(cx, cy - s)
                                ctx.moveTo(cx, cy + s)
                                ctx.lineTo(cx, cy + 6.1)
                                ctx.moveTo(cx - 6.1, cy)
                                ctx.lineTo(cx - s, cy)
                                ctx.moveTo(cx + s, cy)
                                ctx.lineTo(cx + 6.1, cy)
                                ctx.stroke()

                                // Eight surrounding signs
                                ctx.globalAlpha = closed
                                const signRadius = 8.5

                                // Four diagonal triangular signs
                                for (let i = 0; i < 4; i++) {
                                    const a = Math.PI / 4 + i * Math.PI / 2
                                    const x = cx + Math.cos(a) * signRadius
                                    const y = cy + Math.sin(a) * signRadius

                                    ctx.save()
                                    ctx.translate(x, y)
                                    ctx.rotate(a + Math.PI / 2)

                                    ctx.beginPath()
                                    ctx.moveTo(0, -1.7)
                                    ctx.lineTo(1.5, 1.3)
                                    ctx.lineTo(-1.5, 1.3)
                                    ctx.closePath()
                                    ctx.stroke()

                                    ctx.restore()
                                }

                                // Four cardinal glyphs
                                for (let i = 0; i < 4; i++) {
                                    const a = i * Math.PI / 2
                                    const x = cx + Math.cos(a) * signRadius
                                    const y = cy + Math.sin(a) * signRadius

                                    ctx.save()
                                    ctx.translate(x, y)
                                    ctx.rotate(a)

                                    ctx.beginPath()
                                    ctx.moveTo(0, -2)
                                    ctx.lineTo(0, 2)
                                    ctx.moveTo(-1.4, -0.8)
                                    ctx.lineTo(1.4, -0.8)
                                    ctx.stroke()

                                    ctx.restore()
                                }

                                ctx.globalAlpha = 1

                                // one inner ring per extra connected device, up to two
                                const extra = Math.max(0, Math.min(2, count - 1))
                                ctx.lineWidth = 0.9
                                ctx.globalAlpha = 0.6 * closed
                                for (let i = 0; i < extra; i++) {
                                    ctx.beginPath(); ctx.arc(cx, cy, 6.2 - i * 1.8, 0, 2 * Math.PI); ctx.stroke()
                                }

                                ctx.globalAlpha = 0.5 + 0.5 * closed               // center star
                                star(2.6, 0.8)
                            }
                        }
                    }