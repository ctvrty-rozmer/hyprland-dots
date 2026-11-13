import Quickshell
import QtQuick
import QtQuick.Layouts

PopupWindow {
    id: root
    required property Item target
    property bool shown: false
    property bool flushRight: false     // hang from the bar's right edge and open leftward
    property real inset: 0              // 0 = flush with the bar's edge (the island squares its corner to match)
    readonly property real overlap: 1   // tucks 1px under the bar to hide the seam
    readonly property real tear: 6      // depth of the torn edge
    readonly property real paperH: col.implicitHeight + 20
    property real reveal: shown ? 1 : 0
    default property alias content: col.data
    Behavior on reveal { NumberAnimation { duration: 500; easing.type: Easing.OutCubic } }

    visible: shown || reveal > 0.001
    function updatePopupCutout() {
        if (!target || !target.QsWindow.window) return
        const popupWidth = visible ? implicitWidth : 0
        if (flushRight) {
            Theme.rightOpen = visible
            Theme.rightPopupX = target.QsWindow.window.width - Theme.gap - inset - popupWidth - Theme.gap
            Theme.rightPopupWidth = popupWidth
        } else {
            Theme.leftOpen = visible
            Theme.leftPopupX = inset
            Theme.leftPopupWidth = popupWidth
        }
    }
    onVisibleChanged: updatePopupCutout()
    onImplicitWidthChanged: if (visible) updatePopupCutout()
    onInsetChanged: {
        if (visible) updatePopupCutout()
        updateAnchorRect()
    }
    onFlushRightChanged: {
        if (visible) updatePopupCutout()
        updateAnchorRect()
    }
    color: "transparent"
    implicitWidth: col.implicitWidth + 32
    implicitHeight: overlap + paperH + tear

    anchor.item: target
    anchor.edges: Edges.Bottom
    anchor.gravity: flushRight ? Edges.Bottom | Edges.Left : Edges.Bottom | Edges.Right
    function updateAnchorRect() {
        if (!target || !target.QsWindow.window) return
        const p = target.mapToItem(null, 0, 0)       // target position inside the bar window
        const x = flushRight ? target.QsWindow.window.width - Theme.gap - inset : Theme.gap + inset
        anchor.rect = Qt.rect(x - p.x - 1, Theme.barTop + Theme.barHeight - p.y - overlap - 1, 2, 1)
    }
    anchor.onAnchoring: updateAnchorRect()

    Item {                                           // reveals the paper from the top down
        width: parent.width
        height: root.overlap + root.paperH * root.reveal + root.tear
        clip: true

        Canvas {                                     // the paper; its torn edge rides the bottom of the reveal
            id: paper
            y: -root.paperH * (1 - root.reveal)
            width: parent.width
            height: root.overlap + root.paperH + root.tear
            property color fill: Theme.island
            property color edge: Theme.gold
            property color star: Theme.bone
            onFillChanged: requestPaint()
            onEdgeChanged: requestPaint()
            onStarChanged: requestPaint()
            onWidthChanged: requestPaint()
            onHeightChanged: requestPaint()

            onPaint: {
                const ctx = getContext("2d")
                ctx.reset()
                const w = width, h = height, t = root.tear
                let s = 11                                         // fixed seed, so the paper looks the same every time
                const rnd = () => (s = (s * 16807) % 2147483647) / 2147483647

                const pts = [[0.5, h - t * rnd()]]
                for (let x = 3 + rnd() * 4; x < w - 3; x += 3 + rnd() * 4) pts.push([x, h - t * rnd()])
                pts.push([w - 0.5, h - t * rnd()])

                const outline = () => {
                    ctx.beginPath()
                    ctx.moveTo(0.5, 0)
                    pts.forEach(([x, y]) => ctx.lineTo(x, y))
                    ctx.lineTo(w - 0.5, 0)
                }

                outline(); ctx.closePath()
                ctx.fillStyle = fill
                ctx.fill()

                ctx.save()                                         // starfield, clipped to the paper
                outline(); ctx.closePath(); ctx.clip()
                ctx.fillStyle = star
                for (let i = 0; i < w * h / 480; i++) {
                    ctx.globalAlpha = 0.08 + rnd() * 0.14
                    ctx.beginPath(); ctx.arc(rnd() * w, rnd() * h, 0.4 + rnd() * 0.5, 0, 2 * Math.PI); ctx.fill()
                }
                ctx.restore()

                outline()                                          // border down the sides and along the tear, none on top
                ctx.strokeStyle = Qt.alpha(edge, 0.45)
                ctx.lineWidth = 1
                ctx.stroke()
            }

            Repeater {                                             // stars that fade in and out
                model: 6
                Rectangle {
                    required property int index
                    x: paper.width * ((index * 0.37 + 0.11) % 1)
                    y: root.paperH * ((index * 0.53 + 0.2) % 0.85)
                    width: 2; height: 2; radius: 1
                    color: Theme.bone
                    opacity: 0.05
                    SequentialAnimation on opacity {
                        running: root.visible
                        loops: Animation.Infinite
                        PauseAnimation { duration: index * 600 }
                        NumberAnimation { to: 0.4; duration: 2500 + index * 400; easing.type: Easing.InOutSine }
                        NumberAnimation { to: 0.05; duration: 2500 + index * 400; easing.type: Easing.InOutSine }
                    }
                }
            }
        }

        ColumnLayout {
            id: col
            x: (parent.width - width) / 2
            y: root.overlap + 10
            spacing: 6
        }
    }
}