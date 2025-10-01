#!/bin/bash
# Author: @fjcrujeiras
# inspired by: https://git.sr.ht/~oscarcp/ghostfiles/tree/master/item/sway_wm/scripts/sway_bar.sh

# Get battery information using upower
battery_percentage=$(upower -i $(upower -e | grep 'BAT') | grep 'percentage:' | awk '{print $2}')
battery_state=$(upower -i $(upower -e | grep 'BAT') | grep 'state:' | awk '{print $2}')

# Get date and time formatted
le_date=$(date +'%d/%m/%Y')
le_time=$(date +'%H:%M')

# Get keyboard layout
kb_layout=$(swaymsg -r -t get_inputs | awk '/1:1:AT_Translated_Set_2_keyboard/;/xkb_active_layout_name/' | grep -A1 '\b1:1:AT_Translated_Set_2_keyboard\b' | grep "xkb_active_layout_name" | awk -F '"' '{print $4}')

# Audio information
# PulseAudio tools like pamixer and pactl are needed
audio_volume=$(pamixer --sink `pactl list sinks short | grep RUNNING | awk '{ print $1}'` --get-volume)
audio_is_muted=$(pamixer --sink `pactl list sinks short | grep RUNNING | awk '{print $1}'` --get-mute)

# Network info
network=$(ip route get 1.1.1.1 | grep -Po '(?<=dev\s)\w+' | cut -f1 -d ' ')
ping=$(ping -c 1 www.google.es | tail -1| awk '{print $4}' | cut -d '/' -f 2 | cut -d '.' -f 1)

if ! [ $network ]
then
   network_active="⛔"
else
   network_active="⇆"
fi

if [ $audio_is_muted = "true" ]
then
    audio_active='🔇'
else
    audio_active='🔊'
fi

echo "⌨ $kb_layout | $network_active $network($ping ms) | $audio_active $audio_volume% | $battery_state $battery_percentage | $le_date 🕘$le_time"
