#!/bin/bash

update() {
	source "$CONFIG_DIR/colors.sh"
	COLOR=$BACKGROUND_2
	if [ "$SELECTED" = "true" ]; then
		COLOR=$GREY
	fi

	sketchybar --set $NAME icon.highlight=$SELECTED \
		label.highlight=$SELECTED \
		background.border_color=$COLOR
}

mouse_clicked() {
	# yabai -m window $SID --focus 2>/dev/null
	echo "apps clicked"
}

case "$SENDER" in
"mouse.clicked")
	mouse_clicked
	;;
*)
	update
	;;
esac
