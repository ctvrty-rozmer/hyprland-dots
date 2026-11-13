import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts

Label {
    id: root
    property string bars
    readonly property bool silent: /^·*$/.test(bars)

    text: silent ? "✦ the night is quiet ✦" : bars
    color: Theme.gold
    opacity: silent ? 0.6 : 1
    font.letterSpacing: silent ? 0.5 : 2
    horizontalAlignment: Text.AlignHCenter
    Layout.preferredWidth: Math.max(150, implicitWidth)
    Behavior on opacity { NumberAnimation { duration: 400 } }

    Process {
        running: true
        command: ["cava", "-p", Quickshell.shellPath("cava.conf")]
        stdout: SplitParser {
            onRead: d => root.bars = d.split(";").filter(n => n).reverse().map(n => "·∙✦✶"[n]).join("")
        }
    }
}