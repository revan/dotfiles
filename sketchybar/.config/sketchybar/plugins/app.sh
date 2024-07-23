#!/bin/bash

update() {
  source "$CONFIG_DIR/colors.sh"
  COLOR=$BACKGROUND_2
  if [ "$SELECTED" = "true" ]; then
    COLOR=$GREY
  fi
}

mouse_clicked() {
  index=$(echo "$NAME" | sed -e "s/^app\.//")
  window_id="$(yabai -m query --windows | jq -r "[.[] | select(.\"is-visible\")][$((index - 1))].id ")"
  yabai -m window "$window_id" --focus 2>/dev/null

  # TODO sort windows here and in yabai.sh to avoid reordering on click
  sketchybar --trigger windows_on_spaces
}

case "$SENDER" in
"mouse.clicked")
  mouse_clicked
  ;;
*)
  update
  ;;
esac
