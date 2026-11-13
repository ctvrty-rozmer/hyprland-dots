import Quickshell.Io
import QtQuick

Drawer {
    id: root
    property string forecast


    Process {
        id: proc
        command: ["sh", "-c", "~/.config/waybar/scripts/weather.py waybar"]
        stdout: SplitParser { onRead: d => root.forecast = JSON.parse(d).text }
    }
    Timer { interval: 900000; running: true; repeat: true; triggeredOnStart: true; onTriggered: proc.running = true }

    Label { text: "|"; color: Theme.c(10); font.weight: Font.Bold; }
    Pill {
        color: "transparent"
        Label { text: root.forecast; color: Theme.c(13); font.weight: Font.Bold; font.family: Theme.font; font.pixelSize: Theme.fontSize + 1; }
    }
}