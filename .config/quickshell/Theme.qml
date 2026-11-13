pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick

// Singleton {
//     id: root
//     property var wal: ({})

//     readonly property color fg: c(15)

//     function c(n) { return wal.colors?.["color" + n] ?? "#888888" }
Singleton {
    id: root
    property bool useWal: true
    readonly property int gap: 6
    readonly property int barTop: 4
    readonly property int barHeight: 32
    property bool leftOpen: false
    property bool rightOpen: false
    property real leftPopupX: 0
    property real leftPopupWidth: 0
    property real rightPopupX: 0
    property real rightPopupWidth: 0

    property var wal: ({})
    readonly property var special: [
        "#f2c299", "#1c2126", "#7b8da6", "#474f59", "#593122",
        "#bf6550", "#f28d77", "#d49365", "#45312e", "#df9672"
    ]  // special1..special10, use as Theme.special[0]..[9]

    function c(n) { return wal.colors?.["color" + n] ?? "#888888" }
    function mix(a, b, t) {
        a = typeof a === "string" ? Qt.color(a) : a
        b = typeof b === "string" ? Qt.color(b) : b
        return Qt.rgba(a.r + (b.r - a.r) * t, a.g + (b.g - a.g) * t, a.b + (b.b - a.b) * t, 1)
    }


    // fonts yay
    readonly property string icons: "BitstromWeraNerdFontPropo"
    readonly property string font: "IM Fell English SC"
    readonly property string gothic: "UnifrakturCook"
    readonly property int fontSize: 12
   
    // time of day plum onlyyy
    SystemClock { id: clock; precision: SystemClock.Minutes }
    readonly property real hour: clock.date.getHours() + clock.date.getMinutes() / 60
    readonly property real daylight: Math.max(0, Math.sin(Math.PI * (hour - 6) / 12))

    // palette
    // the only block that differs between themes
    readonly property color island: useWal ? mix(wal.special?.background ?? c(0), c(1), 0.6)
                                           : mix(Qt.darker(c(4), 2.6), mix("#14122a", "#2c1c28", daylight), 0.75)
    readonly property color gold:    useWal ? special[0] : mix("#c9a77a", "#f2c299", daylight)
    readonly property color bone:    useWal ? c(15) : "#e6ddd0"
    readonly property color dim:     useWal ? c(7)  : "#8f857d"
    readonly property color crimson: useWal ? c(2) : "#bf6550"
    readonly property color tarnished: useWal ? c(13) : "#f2c299"

    // derived, same in both
    readonly property color popup: Qt.darker(island, 1.5)
    readonly property color lift: mix(island, gold, 0.15)
    readonly property color fg: bone

    
    FileView {
        path: Quickshell.env("HOME") + "/.cache/wal/colors.json"
        watchChanges: true
        onFileChanged: reload()
        onLoaded: root.wal = JSON.parse(text())
    }
}
