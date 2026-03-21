#!/usr/bin/env bash
set -euo pipefail

config="$HOME/.config/swaync/config.json"
phrases=(
    "🌙 the night is endless 🌙"
    "🕸️ the only thing to do in losertown 
   is collect cobwebs 🕸️"
    "🖤 the void hums softly 🖤"
    "🌒 the streets of losertown are empty,
   and so is your inbox 🌒"
    "🌑 in losertown, the darkness swallows
   everything...even your notifications 🌑"
    "🪞 even your reflection looks away 🪞"
    "👻 each unsent message is a ghost 👻"
    "🌌 not even the abyss wants to stare back 🌌"
    "🪦 nobody answers in losertown 🪦"
    "🖤 welcome to losertown...population: you 🖤"
    "🌑 still nothing, it's just you here 🌑"
    "🌌 even nothingness feels 
   far away in losertown 🌌"
    "🕸️ this place hasn't been 
   touched in a while 🕸️"
    "🕯️ no light stays long in losertown 🕯️"
    "🖤 this emptiness feels familiar 🖤"
    "🪦 silence reigns in losertown 🪦"
)

# rotate by time or random
# idx=$(( $(date +%s) / 15 % ${#phrases[@]} ))
idx=$(( RANDOM % ${#phrases[@]} ))
phrase="${phrases[$idx]}"

# update JSON path
tmp="$(mktemp)"
jq --arg v "$phrase" '.["text-empty"] = $v' "$config" > "$tmp" && mv "$tmp" "$config"

# poll until swaync D-Bus is reachable (max ~2.5 s, typically <200 ms)
wait_for_swaync() {
    for _ in $(seq 1 50); do
        swaync-client -c &>/dev/null && return 0
        sleep 0.05
    done
    return 1
}

notifcount=$(swaync-client -c 2>/dev/null || echo 0)
pidofswaync=$(pgrep -x swaync || true)
if [[ "$notifcount" -gt 0 ]]; then
    swaync-client -t -sw
elif [[ -n "$pidofswaync" ]]; then
    pkill swaync
    swaync &
    disown
    wait_for_swaync
    swaync-client -t -sw
fi