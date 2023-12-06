#!/bin/bash

window_state() {
	source "$CONFIG_DIR/colors.sh"
	source "$CONFIG_DIR/icons.sh"

	WINDOW=$(yabai -m query --windows --window)
	STACK_INDEX=$(echo "$WINDOW" | jq '.["stack-index"]')

	COLOR=$BAR_BORDER_COLOR
	ICON=""

	if [ "$(echo "$WINDOW" | jq '.["is-floating"]')" = "true" ]; then
		ICON+=$YABAI_FLOAT
		COLOR=$MAGENTA
	elif [ "$(echo "$WINDOW" | jq '.["has-fullscreen-zoom"]')" = "true" ]; then
		ICON+=$YABAI_FULLSCREEN_ZOOM
		COLOR=$GREEN
	elif [ "$(echo "$WINDOW" | jq '.["has-parent-zoom"]')" = "true" ]; then
		ICON+=$YABAI_PARENT_ZOOM
		COLOR=$YELLOW
	elif [[ $STACK_INDEX -gt 0 ]]; then
		LAST_STACK_INDEX=$(yabai -m query --windows --window stack.last | jq '.["stack-index"]')
		ICON+=$YABAI_STACK
		LABEL="$(printf "[%s/%s]" "$STACK_INDEX" "$LAST_STACK_INDEX")"
		COLOR=$RED
	fi

	args=(--animate sin 10 --bar border_color=$COLOR
		--set $NAME icon.color=$COLOR)

	[ -z "$LABEL" ] && args+=(label.width=0) ||
		args+=(label="$LABEL" label.width=40)

	[ -z "$ICON" ] && args+=(icon.width=0) ||
		args+=(icon="$ICON" icon.width=30)
	sketchybar -m "${args[@]}"
}

windows_on_spaces() {
	CURRENT_SPACES="$(yabai -m query --displays | jq -r '.[].spaces | @sh')"

	args=(--set spaces_bracket drawing=off
		--set '/space\..*/' background.drawing=on
		--animate sin 10)

	while read -r line; do
		for space in $line; do
			icon_strip=" "
			apps=$(yabai -m query --windows --space $space | jq -r ".[] | select(.\"is-minimized\" == "false") | .app")
			if [ "$apps" != "" ]; then
				while IFS= read -r app; do
					icon_strip+=" $($CONFIG_DIR/plugins/icon_map.sh "$app")"
				done <<<"$apps"
			fi
			args+=(--set space.$space label="$icon_strip" label.drawing=on)
		done
	done <<<"$CURRENT_SPACES"

	sketchybar -m "${args[@]}"

	VISIBLE_APPS="$(yabai -m query --windows | jq -r ".[] | select(.\"is-visible\") | .title | @sh" | xargs)"

	sketchybar -m --set apps label="$VISIBLE_APPS"
}

mouse_clicked() {
	yabai -m window --toggle float
	window_state
}

mouse_scrolled() {
	if [ $1 -lt 0 ]; then
		id="$(yabai -m query --spaces --display $2 | jq 'sort_by(.index) | .[map(."is-visible") | index(true) - 1].index')" && yabai -m space --focus "${id}"
	elif [ $1 -gt 0 ]; then
		id="$(yabai -m query --spaces --display $2 | jq 'sort_by(.index) | reverse | .[map(."is-visible") | index(true) - 1].index')" && yabai -m space --focus "${id}"
	fi
}

case "$SENDER" in
"mouse.clicked")
	mouse_clicked
	;;
"forced")
	exit 0
	;;
"window_focus")
	window_state
	;;
"windows_on_spaces" | "space_change")
	windows_on_spaces
	;;
"mouse.scrolled.global") mouse_scrolled "$SCROLL_DELTA" "$DISPLAY" ;;
esac
