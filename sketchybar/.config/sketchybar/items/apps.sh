#!/bin/bash

app=(
	label="apps"
	script="$PLUGIN_DIR/app.sh"
	updates=on
)
sketchybar --add item apps left \
	--set apps "${app[@]}" \
	--subscribe apps mouse.clicked
exit

sid=0
apps=$(yabai -m query --windows --space | jq -r ".[] | select(.\"is-minimized\" == "false") | .id")

if [ "$apps" != "" ]; then
	while IFS= read -r app; do
		echo "$app $sid"
		sid=$(($sid + 1))
		#title=$(yabai -m query --windows --window "$app" | jq -r ".title | @sh")
		app=(
			script="$PLUGIN_DIR/app.sh"
			updates=on
		)

		sketchybar --add item app.$sid right \
			--set app.$sid "${app[@]}" \
			--subscribe app.$sid mouse.clicked
	done <<<"$apps"
fi
