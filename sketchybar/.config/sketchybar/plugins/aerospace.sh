#!/bin/bash

# Per-workspace sketchybar plugin: highlight the focused workspace and draw an
# app-icon strip for the windows it contains. $1 is the workspace name.
#
# Invoked on the aerospace_workspace_change event (with $FOCUSED_WORKSPACE set)
# and on the item's update_freq tick (env unset -> query the focused workspace).

source "$CONFIG_DIR/colors.sh"

sid="$1"
FOCUSED="${FOCUSED_WORKSPACE:-$(aerospace list-workspaces --focused)}"

# App-icon strip for the windows on this workspace.
icons=""
while read -r app; do
  [ -n "$app" ] && icons+=" $("$CONFIG_DIR/plugins/icon_map.sh" "$app")"
done < <(aerospace list-windows --workspace "$sid" --format '%{app-name}')

args=(--set "$NAME")
if [ "$sid" = "$FOCUSED" ]; then
  args+=(background.drawing=on icon.highlight=on label.highlight=on)
else
  args+=(background.drawing=off icon.highlight=off label.highlight=off)
fi

if [ -n "$icons" ]; then
  args+=(label="$icons" label.drawing=on)
else
  args+=(label.drawing=off)
fi

sketchybar "${args[@]}"
