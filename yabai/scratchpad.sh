#!/bin/bash

window=$(yabai -m query --windows | jq '.[] | select(.app=="'$1'").id')
current_space=$(yabai -m query --spaces --space | jq '.index')
is_visible=$(yabai -m query --windows --window $window | jq '."is-visible"')
is_minimized=$(yabai -m query --windows --window $window | jq '."is-minimized"')

yabai -m query --windows | jq -r ".[] | select(.\"is-topmost\" == "true") | .id" | while read -r window; do yabai -m window "$window" --toggle topmost; done

if [[ "$is_minimized" == "true" ]]; then
	yabai -m window $window --space $current_space
	yabai -m window --focus $window
	sketchybar --trigger windows_on_spaces
elif [[ "$is_visible" == "false" ]]; then
	yabai -m window $window --space $current_space
	yabai -m window --focus $window
elif [[ -z "$window" ]]; then
	open "/Applications/$1.app"
        sleep 1
	window=$(yabai -m query --windows | jq '.[] | select(.app=="'$1'").id')
        yabai -m window "$window" --toggle float
        yabai -m window "$window" --grid 4:4:1:1:2:2
else
	yabai -m window $window --minimize
fi

is_sticky=$(yabai -m query --windows --window $window | jq '."is-sticky"')
if [[ $"is_sticky" == "true" ]]; then
	yabai -m window $window --toggle sticky
fi
is_topmost=$(yabai -m query --windows --window $window | jq '."is-topmost"')
if [[ $"is_topmost" != "true" ]]; then
	yabai -m window $window --toggle topmost
fi
sketchybar --trigger windows_on_spaces
