import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts

RowLayout {
    spacing: 2

    Repeater {
        model: 5

        Item {
            id: w
            required property int index
            readonly property int ws: index + 1
            readonly property var info: Hyprland.workspaces.values.find(x => x.id === ws)
            readonly property bool active: Hyprland.focusedWorkspace?.id === ws
            readonly property bool used: !!info && info.toplevels.values.length > 0
            readonly property color accent: info?.urgent ? Theme.crimson : Theme.gold

            Layout.alignment: Qt.AlignVCenter
            implicitWidth: 26
            implicitHeight: 24

            // ---- sun (active) ----
            Item {
                anchors.centerIn: parent
                width: 26; height: 26
                opacity: w.active ? 1 : 0
                scale: w.active ? 1 : 0.4
                Behavior on opacity { NumberAnimation { duration: 300 } }
                Behavior on scale { NumberAnimation { duration: 400; easing.type: Easing.OutBack } }

                Canvas {
                    anchors.fill: parent
                    property color tint: w.accent
                    onTintChanged: requestPaint()

                    onPaint: {
                        const ctx = getContext("2d")
                        ctx.reset()
                        const cx = width / 2, cy = height / 2

                        // 8 long rays alternating with 8 short ones
                        ctx.fillStyle = tint
                        ctx.beginPath()
                        for (let i = 0; i < 16; i++) {
                            const a = i * Math.PI / 8 - Math.PI / 2
                            const tip = i % 2 === 0 ? 11 : 7
                            ctx.lineTo(cx + Math.cos(a) * tip, cy + Math.sin(a) * tip)
                            const v = a + Math.PI / 16
                            ctx.lineTo(cx + Math.cos(v) * 4.5, cy + Math.sin(v) * 4.5)
                        }
                        ctx.closePath()
                        ctx.fill()

                        // hollow ring, then a dot in the middle
                        ctx.globalCompositeOperation = "destination-out"
                        ctx.beginPath(); ctx.arc(cx, cy, 3, 0, Math.PI * 2); ctx.fill()
                        ctx.globalCompositeOperation = "source-over"
                        ctx.beginPath(); ctx.arc(cx, cy, 1.4, 0, Math.PI * 2); ctx.fill()
                    }

                    
                }
            }            

            // ---- crescent moon (inactive) ----
            Canvas {
                id: moon
                anchors.centerIn: parent
                width: 20; height: 20
                opacity: w.active ? 0 : (w.used ? 1 : 0.45)
                property color tint: info?.urgent ? Theme.crimson : Theme.dim
                property real rad: w.used ? 7 : 5
                property bool filled: w.used

                Behavior on opacity { NumberAnimation { duration: 300 } }
                Behavior on rad { NumberAnimation { duration: 300; easing.type: Easing.OutQuart } }
                onTintChanged: requestPaint()
                onRadChanged: requestPaint()
                onFilledChanged: requestPaint()

                onPaint: {
                    const ctx = getContext("2d")
                    ctx.reset()
                    const cx = width / 2, cy = height / 2
                    const th = -Math.PI / 4                 // direction the crescent opens toward
                    const d = rad * 0.55, r = rad * 0.85        // offset and radius of the bite
                    const phi = Math.acos((rad * rad + d * d - r * r) / (2 * rad * d))
                    const c2x = cx + d * Math.cos(th), c2y = cy + d * Math.sin(th)
                    const p1 = [cx + rad * Math.cos(th + phi), cy + rad * Math.sin(th + phi)]
                    const p2 = [cx + rad * Math.cos(th - phi), cy + rad * Math.sin(th - phi)]
                    const a1 = Math.atan2(p1[1] - c2y, p1[0] - c2x)
                    const a2 = Math.atan2(p2[1] - c2y, p2[0] - c2x)

                    // inner arc must run through the side of the bite facing the moon's center
                    const tau = Math.PI * 2
                    const delta = ((a1 - a2) % tau + tau) % tau
                    const cw = Math.cos(a2 + delta / 2 - (th + Math.PI)) > 0

                    ctx.beginPath()
                    ctx.arc(cx, cy, rad, th + phi, th - phi + tau, false)
                    ctx.arc(c2x, c2y, r, a2, a1, !cw)
                    ctx.closePath()

                    ctx.strokeStyle = tint
                    ctx.fillStyle = tint
                    ctx.lineWidth = 1.2
                    ctx.lineJoin = "round"
                    if (filled) ctx.fill()
                    ctx.stroke()

                    // tiny four-point star sitting in the crescent's opening (used workspaces only)
                    if (filled) {
                        const sx = cx + (d + rad * 0.55) * Math.cos(th)
                        const sy = cy + (d + rad * 0.55) * Math.sin(th)
                        ctx.beginPath()
                        for (let i = 0; i < 8; i++) {
                            const a = i * Math.PI / 4 - Math.PI / 2
                            const len = i % 2 === 0 ? 2.6 : 0.8
                            ctx.lineTo(sx + Math.cos(a) * len, sy + Math.sin(a) * len)
                        }
                        ctx.closePath()
                        ctx.fill()
                    }
                }
            }

            TapHandler { onTapped: Hyprland.dispatch("workspace " + w.ws) }
        }
    }
}