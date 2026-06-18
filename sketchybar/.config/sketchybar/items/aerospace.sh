#!/bin/bash

# AeroSpace workspace indicators.
#
# Workspaces are grouped into one bracket per monitor, so each monitor's
# workspaces read as a distinct set. All the rendering is done by the single
# controller item below (plugins/aerospace.sh): it highlights every *visible*
# workspace (one per monitor, the focused one emphasized), draws an app-icon
# strip per workspace, and rebuilds the per-monitor groups whenever a workspace
# migrates between monitors.
#
# See: https://nikitabobko.github.io/AeroSpace/goodies#show-aerospace-workspaces-in-sketchybar

# Drop the controller's cached layout so the first render after a reload always
# rebuilds the brackets (which a reload wipes).
rm -f "${TMPDIR:-/tmp}/sketchybar_aerospace.sig" "${TMPDIR:-/tmp}/sketchybar_aerospace.brk"

sketchybar --add event aerospace_workspace_change

# One item per numeric workspace (excludes the obsidian/spotify/beeper
# scratchpad stash workspaces). Order and bracketing are fixed up by the
# controller; the static props below are everything that never changes.
for sid in $(aerospace list-workspaces --all | grep -E '^[0-9]+$' | sort -n); do
  space=(
    icon="$sid"
    icon.padding_left=8
    icon.padding_right=8
    padding_left=2
    padding_right=2
    label.font="sketchybar-app-font:Regular:16.0"
    label.padding_right=12
    label.y_offset=-1
    label.drawing=off
    background.height=26
    background.corner_radius=9
    background.drawing=off
    click_script="aerospace workspace $sid"
  )
  sketchybar --add item space.$sid left \
    --set space.$sid "${space[@]}"
done

# Controller: a hidden item that renders every space item in one atomic pass.
# updates=on so it keeps ticking even though it is never drawn.
sketchybar --add item aerospace_ctrl left \
  --set aerospace_ctrl drawing=off updates=on update_freq=2 \
        script="$PLUGIN_DIR/aerospace.sh" \
  --subscribe aerospace_ctrl aerospace_workspace_change
