import QtQuick

Rectangle {
    id: root
    implicitHeight: 24
    radius: 6
    color: Theme.island
    Behavior on color { ColorAnimation { duration: 2000 } }

    // fixed starfield (seeded, so it doesn't change on reload)
    Canvas {
        anchors.fill: parent
        property color tint: Theme.bone
        onWidthChanged: requestPaint()
        onHeightChanged: requestPaint()
        onTintChanged: requestPaint()
        onPaint: {
            const ctx = getContext("2d")
            ctx.reset()
            let s = 7
            const rnd = () => (s = (s * 16807) % 2147483647) / 2147483647
            ctx.fillStyle = tint
            for (let i = 0; i < width / 14; i++) {
                ctx.globalAlpha = 0.08 + rnd() * 0.14
                ctx.beginPath()
                ctx.arc(rnd() * width, rnd() * height, 0.4 + rnd() * 0.5, 0, 2 * Math.PI)
                ctx.fill()
            }
        }
    }

    // a few stars that fade in and out
    Repeater {
        model: 6
        Rectangle {
            required property int index
            x: root.width * ((index * 0.37 + 0.11) % 1)
            y: root.height * ((index * 0.53 + 0.2) % 0.8)
            width: 2; height: 2; radius: 1
            color: Theme.bone
            opacity: 0.09
            SequentialAnimation on opacity {
                loops: Animation.Infinite
                PauseAnimation { duration: index * 600 }
                NumberAnimation { to: 0.4; duration: 2500 + index * 400; easing.type: Easing.InOutSine }
                NumberAnimation { to: 0.05; duration: 2500 + index * 400; easing.type: Easing.InOutSine }
            }
        }
    }

    // double-line frame
    Rectangle {
        anchors.fill: parent
        radius: root.radius
        color: "transparent"
        border { width: 1; color: Qt.alpha(Theme.gold, 0.45) }
    }
    Rectangle {
        anchors { fill: parent; margins: 2 }
        radius: root.radius - 3
        color: "transparent"
        border { width: 1; color: Qt.alpha(Theme.gold, 0.18) }
    }
    // squares off a bottom corner while a popup hangs from it
    component Cap: Item {
        property bool isRight: false
        property bool open: false
        width: parent.radius; height: parent.radius
        anchors { bottom: parent.bottom; left: isRight ? undefined : parent.left; right: isRight ? parent.right : undefined }
        opacity: open ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: 200 } }

        Rectangle { anchors.fill: parent; color: Theme.island }
        Rectangle { width: 1; height: parent.height; x: isRight ? parent.width - 1 : 0; color: Qt.alpha(Theme.gold, 0.45) }            // outer frame
        Rectangle { width: 1; height: parent.height - 3; x: isRight ? parent.width - 4 : 3; color: Qt.alpha(Theme.gold, 0.18) }        // inner frame
        Rectangle { width: parent.width - 3; height: 1; y: parent.height - 4; x: isRight ? 0 : 3; color: Qt.alpha(Theme.gold, 0.18) }
    }
    Cap { open: Theme.leftOpen }
    Cap { isRight: true; open: Theme.rightOpen }

    Rectangle {
        visible: Theme.leftOpen && Theme.leftPopupWidth > 0
        x: Theme.leftPopupX
        width: Theme.leftPopupWidth
        height: 3
        anchors.bottom: parent.bottom
        color: root.color
    }
    Rectangle {
        visible: Theme.rightOpen && Theme.rightPopupWidth > 0
        x: Theme.rightPopupX
        width: Theme.rightPopupWidth
        height: 3
        anchors.bottom: parent.bottom
        color: root.color
    }
}