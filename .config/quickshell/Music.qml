import Quickshell.Services.Mpris
import QtQuick.Layouts

Label {
    readonly property var player: Mpris.players.values.find(p => !p.dbusName.includes("firefox"))
    readonly property bool active: !!player && player.playbackState !== MprisPlaybackState.Stopped && player.trackTitle !== ""

    Layout.leftMargin: 6
    text: player
        ? (player.isPlaying ? "󰏤 " : "󰐊  ") + player.trackArtist + " - " + player.trackTitle
        : ""
}