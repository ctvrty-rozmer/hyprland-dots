import Quickshell
import QtQuick
import QtQuick.Layouts

Pill {
    id: root
    hoverFill: true

    SystemClock { id: clock; precision: SystemClock.Minutes }
    readonly property var now: clock.date
    readonly property real phase: Moon.phase(now)

    function ordinal(n) {
        const s = ["th", "st", "nd", "rd"], v = n % 100
        return n + "<sup>" + (s[(v - 20) % 10] || s[v] || s[0]) + "</sup>"
    }

    MoonIcon { phase: root.phase }
    Label {
        textFormat: Text.RichText
        font { family: Theme.font; pixelSize: Theme.fontSize + 2 }
        text: Qt.formatDateTime(root.now, "ddd, MMMM ") + root.ordinal(root.now.getDate())
    }
    Label { text: "✦"; color: Theme.gold }
    Label { text: Qt.formatDateTime(root.now, "HH:mm"); font.letterSpacing: 1.5; font.family: Theme.gothic; font.pixelSize: Theme.fontSize + 3 }

    SlidePopup {
        target: root
        shown: root.hovered
        inset: 1

        ColumnLayout {
            id: cal
            spacing: 6

            readonly property int year: root.now.getFullYear()
            readonly property int month: root.now.getMonth()
            readonly property int offset: new Date(year, month, 1).getDay()
            readonly property int days: new Date(year, month + 1, 0).getDate()

            Label {
                Layout.alignment: Qt.AlignHCenter
                font { family: Theme.gothic; pixelSize: Theme.fontSize + 3 }
                color: Theme.gold
                text: Qt.formatDateTime(root.now, "MMMM yyyy")
            }

            GridLayout {
                columns: 7; rowSpacing: 2; columnSpacing: 2

                Repeater {
                    model: ["su", "mo", "tu", "we", "th", "fr", "sa"]
                    Label { required property string modelData; text: modelData; color: Theme.dim; Layout.alignment: Qt.AlignHCenter }
                }
                Repeater {
                    model: Math.ceil((cal.offset + cal.days) / 7) * 7
                    Rectangle {
                        id: cell
                        required property int index
                        readonly property int day: index - cal.offset + 1
                        readonly property bool inMonth: day >= 1 && day <= cal.days

                        implicitWidth: 32; implicitHeight: 36
                        radius: 12
                        color: inMonth && day === root.now.getDate() ? Qt.alpha(Theme.gold, 0.3) : "transparent"

                        ColumnLayout {
                            anchors.centerIn: parent
                            visible: cell.inMonth
                            spacing: 2
                            Label { text: cell.day; Layout.alignment: Qt.AlignHCenter }
                            MoonIcon {
                                implicitWidth: 10; implicitHeight: 10
                                Layout.alignment: Qt.AlignHCenter
                                phase: Moon.phase(new Date(cal.year, cal.month, cell.day, 12))
                            }
                        }
                    }
                }
            }
        }
    }
}