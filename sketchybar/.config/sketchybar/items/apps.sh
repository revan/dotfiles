#!/bin/bash

APP_NUMS=("1" "2" "3" "4" "5" "6" "7" "8" "9" "10" "11" "12" "13" "14" "15")

apps_bracket=(
  background.color=$BACKGROUND_2
  background.border_color=$BACKGROUND_1
)

for i in "${!APP_NUMS[@]}"; do
    app=(
      script="$PLUGIN_DIR/app.sh"
      updates=on
      padding_left=2
      padding_right=2
      label.padding_right=10
    )

    sketchybar --add item "app.${APP_NUMS[i]}" left \
        --set "app.${APP_NUMS[i]}" "${app[@]}" \
        --subscribe "app.${APP_NUMS[i]}" mouse.clicked

    sketchybar --add bracket "apps_bracket.${APP_NUMS[i]}" "app.${APP_NUMS[i]}" \
        --set "apps_bracket.${APP_NUMS[i]}" "${apps_bracket[@]}"
done

