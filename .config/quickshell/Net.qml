import Quickshell
import Quickshell.Io
import QtQuick

Pill {
    id: root
    property string kind: "none"
    property int strength: 0
    hoverFill: true
    onClicked: Quickshell.execDetached(["kitty", "nmtui"])

    Process {
        id: typeProc
        command: ["nmcli", "-t", "-f", "TYPE", "connection", "show", "--active"]
        stdout: StdioCollector {
            onStreamFinished: root.kind = text.includes("wireless") ? "wifi" : text.includes("ethernet") ? "ethernet" : "none"
        }
    }
    Process {
        id: sigProc
        command: ["sh", "-c", "nmcli -t -f IN-USE,SIGNAL device wifi list | grep '^\\*' | cut -d: -f2"]
        stdout: StdioCollector { onStreamFinished: root.strength = parseInt(text) || 0 }
    }
    Timer {
        interval: 5000; running: true; repeat: true; triggeredOnStart: true
        onTriggered: { typeProc.running = true; sigProc.running = true }
    }

    Canvas {
        id: sky
        implicitWidth: 30; implicitHeight: 22
        property int lit: root.kind === "ethernet" ? 5 : root.kind === "wifi" ? Math.max(1, Math.ceil(root.strength / 20)) : 0
        property bool wired: root.kind === "ethernet"
        property int tick: 0
        property color gold: Theme.tarnished
        property color dim: Theme.dim
        onLitChanged: requestPaint()
        onTickChanged: requestPaint()
        onGoldChanged: requestPaint()
        onDimChanged: requestPaint()
        Timer { interval: 150; running: sky.lit > 0; repeat: true; onTriggered: sky.tick++ }   // slow twinkle

        onPaint: {
            const ctx = getContext("2d")
            ctx.reset()
            ctx.lineCap = "round"
            const col = lit > 0 ? gold : dim
            const pts = [[3, 15], [9, 9], [15, 13], [21, 5], [27, 9]]
            ctx.strokeStyle = col
            ctx.fillStyle = col

            ctx.globalAlpha = 0.2                                  // background stars
            for (const [x, y] of [[5, 4], [13, 3], [19, 10], [24, 15], [8, 12]]) {
                ctx.beginPath(); ctx.arc(x, y, 0.5, 0, 2 * Math.PI); ctx.fill()
            }

            ctx.globalAlpha = wired ? 0.7 : 0.3                    // horizon arc with a diamond at the center
            ctx.lineWidth = 0.8
            ctx.beginPath(); ctx.moveTo(1, 20); ctx.quadraticCurveTo(15, 17, 29, 20); ctx.stroke()
            ctx.beginPath()
            ctx.moveTo(15, 17.2); ctx.lineTo(16.1, 18.6); ctx.lineTo(15, 20); ctx.lineTo(13.9, 18.6)
            ctx.closePath(); ctx.fill()

            for (let i = 0; i < 4; i++) {                          // constellation lines
                const [x1, y1] = pts[i], [x2, y2] = pts[i + 1]
                ctx.globalAlpha = i + 1 < lit ? 0.75 : 0.2
                ctx.beginPath()
                if (lit === 0) {                                   // broken when disconnected
                    ctx.moveTo(x1, y1); ctx.lineTo(x1 + (x2 - x1) * 0.3, y1 + (y2 - y1) * 0.3)
                    ctx.moveTo(x2 - (x2 - x1) * 0.3, y2 - (y2 - y1) * 0.3); ctx.lineTo(x2, y2)
                } else {
                    ctx.moveTo(x1, y1); ctx.lineTo(x2, y2)
                }
                ctx.stroke()
            }

            for (let i = 0; i < 5; i++) {                          // lit stars twinkle, unlit are dim dots
                const [x, y] = pts[i]
                if (i < lit) {
                    const s = 1 + 0.18 * Math.sin(tick * 0.6 + i * 1.7)
                    ctx.globalAlpha = 1
                    ctx.beginPath()
                    for (let j = 0; j < 8; j++) {
                        const a = j * Math.PI / 4 - Math.PI / 2, l = (j % 2 === 0 ? 2.6 : 0.8) * s
                        ctx.lineTo(x + Math.cos(a) * l, y + Math.sin(a) * l)
                    }
                    ctx.closePath(); ctx.fill()
                } else {
                    ctx.globalAlpha = 0.25
                    ctx.beginPath(); ctx.arc(x, y, 1, 0, 2 * Math.PI); ctx.fill()
                }
            }
        }
    }
}