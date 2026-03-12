#!/bin/bash
# @requires: mplayer, brightnessctl

# Delay for startup
sleep 5

# Change your sound path here
SOUND_FILE="$(dirname "$(readlink -f "$0")")/sounds/default_sound.mp3"

playsound() {
    mplayer "$SOUND_FILE"
}


#sendNotification() {
 #   local title="$1"
  #  local message="$2"
   # notify-send -h string:x-canonical-private-synchronous:sys-notify -e -u low "$title" "$message"
#}

# Runs full time in background
x=0
while true; do
    Battery_Status="$(cat /sys/class/power_supply/BAT*/status)"
    Battery_Capacity=$(cat /sys/class/power_supply/BAT*/capacity)

    case "$Battery_Status" in
        "Discharging")
            if [ $x -eq 1 ]; then
                notify-send "Laptop unplugged" "Remaining battery: <b>${Battery_Capacity}%</b>"
                playsound
                x=0
            fi
            ;;
        "Charging")
            if [ $x -eq 0 ]; then
                notify-send "Laptop plugged in" "Charging: <b>${Battery_Capacity}%</b>"
                playsound
                x=1
            fi
            ;;
        "Full")
            if [ $x -eq 0 ]; then
                notify-send "Fully Charged" "Battery: <b>${Battery_Capacity}%</b>"
                playsound
                x=1
            fi
            ;;
    esac

    sleep 1
done
