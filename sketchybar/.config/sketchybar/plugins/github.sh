#!/bin/bash

update() {
  source "$CONFIG_DIR/colors.sh"
  source "$CONFIG_DIR/icons.sh"

  PULLS="$(gh api "search/issues?q=is:open+is:pr+review-requested:$(gh config get user -h github.com)+archived:false")"
  COUNT="$(echo "$PULLS" | jq 'length')"
  args=()
  if [ "$PULLS" = "[]" ]; then
    args+=(--set $NAME icon=$GIT_PULL_REQUEST label="0")
  else
    args+=(--set $NAME icon=$GIT_PULL_REQUEST label="$COUNT")
  fi

  PREV_COUNT=$(sketchybar --query github.bell | jq -r .label.value)
  args+=(--remove '/github.notification\.*/')

  COUNTER=0
  COLOR=$GREEN
  args+=(--set github.bell icon.color=$COLOR)

  while read -r url number user title
  do
    COUNTER=$((COUNTER + 1))
    COLOR=$GREEN
    PADDING=0

    if [ "${url}" = "" ] && [ "${title}" = "" ]; then
      repo="Note"
      title="No new PRs"
    fi
    
    notification=(
      label="$(echo "$title" | sed -e "s/^'//" -e "s/'$//") - $(echo "$user" | sed -e "s/^'//" -e "s/'$//")"
      icon="$GIT_PULL_REQUEST #$number"
      icon.padding_left="$PADDING"
      label.padding_right="$PADDING"
      icon.color=$COLOR
      position=popup.github.bell
      icon.background.color=$COLOR
      drawing=on
      click_script="open $url; sketchybar --set github.bell popup.drawing=off"
    )

    args+=(--clone github.notification.$COUNTER github.template \
           --set github.notification.$COUNTER "${notification[@]}")
  done <<< "$(echo "$PULLS" | jq -r '.items[] | [.html_url, .number, .user.login, .title] | @sh')"

  sketchybar -m "${args[@]}" > /dev/null

  if [ $COUNT -gt $PREV_COUNT ] 2>/dev/null || [ "$SENDER" = "forced" ]; then
    sketchybar --animate tanh 15 --set github.bell label.y_offset=5 label.y_offset=0
  fi
}

popup() {
  sketchybar --set $NAME popup.drawing=$1
}

case "$SENDER" in
  "routine"|"forced") update
  ;;
  "mouse.entered") popup on
  ;;
  "mouse.exited.global") popup off
  ;;
  "mouse.clicked") popup toggle
  ;;
esac
