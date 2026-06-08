#!/bin/bash

# AeroSpace workspace indicators.
# See: https://nikitabobko.github.io/AeroSpace/goodies#show-aerospace-workspaces-in-sketchybar
# The plugin draws the focus highlight and an app-icon strip per workspace.

sketchybar --add event aerospace_workspace_change

for sid in 1 2 3 4 5 6 7 8 9 10; do
  space=(
    icon="$sid"
    icon.padding_left=10
    icon.padding_right=10
    padding_left=2
    padding_right=2
    label.padding_right=20
    icon.highlight_color=$RED
    label.color=$GREY
    label.highlight_color=$WHITE
    label.font="sketchybar-app-font:Regular:16.0"
    label.y_offset=-1
    label.drawing=off
    background.color=$BACKGROUND_1
    background.border_color=$BACKGROUND_2
    background.drawing=off
    update_freq=2
    click_script="aerospace workspace $sid"
    script="$PLUGIN_DIR/aerospace.sh $sid"
  )

  sketchybar --add item space.$sid left \
    --set space.$sid "${space[@]}" \
    --subscribe space.$sid aerospace_workspace_change
done

spaces_bracket=(
  background.color=$BACKGROUND_1
  background.border_color=$BACKGROUND_2
)

sketchybar --add bracket spaces_bracket '/space\..*/' \
  --set spaces_bracket "${spaces_bracket[@]}"
