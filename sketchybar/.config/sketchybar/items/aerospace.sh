#!/bin/bash

# AeroSpace workspace + flow indicators.
#
# Workspaces: ten static slot items (the active flow's "<flow>.1".."<flow>.10"
# workspaces). Each monitor's bar shows only the slots that live on that
# monitor: the controller pins every slot item to its monitor's `display`. All
# the rendering is done by the single controller item below
# (plugins/aerospace.sh): it highlights every *visible* slot (one per monitor,
# the focused one emphasized), draws an app-icon strip per slot, and rebuilds
# the per-monitor groups whenever a workspace migrates between monitors.
#
# Flows: dynamic "flow.<name>" items (built by plugins/flows.sh) plus a static
# "+" item that prompts for a new flow's name. flow.sh triggers flow_change
# whenever the flow list or active flow changes.
#
# See: https://nikitabobko.github.io/AeroSpace/goodies#show-aerospace-workspaces-in-sketchybar

# Drop the controllers' cached layouts so the first render after a reload
# always rebuilds the brackets and flow items (which a reload wipes).
rm -f "${TMPDIR:-/tmp}/sketchybar_aerospace.sig" "${TMPDIR:-/tmp}/sketchybar_aerospace.brk" \
  "${TMPDIR:-/tmp}/sketchybar_flows.sig" "${TMPDIR:-/tmp}/sketchybar_flows.items"

sketchybar --add event aerospace_workspace_change
sketchybar --add event flow_change

# "+" — create a new flow (osascript name prompt). Also anchors the dynamic
# flow.<name> items, which flows.sh inserts before it.
flow_add=(
  display=1
  icon="+"
  icon.color="$GREY"
  icon.padding_left=8
  icon.padding_right=8
  padding_left=2
  padding_right=2
  background.height=26
  background.corner_radius=9
  background.drawing=off
  click_script="$HOME/.config/aerospace/flow.sh new"
)
sketchybar --add item flow_add left \
  --set flow_add "${flow_add[@]}"

# One item per workspace slot. Slots exist independently of the underlying
# workspaces (empty flow workspaces die; the bar still shows all ten). Order
# and bracketing are fixed up by the controller; the static props below are
# everything that never changes.
for sid in 1 2 3 4 5 6 7 8 9 10; do
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
    click_script="$HOME/.config/aerospace/flow.sh go $sid"
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

# Flow-strip controller. Subscribed to aerospace_workspace_change too so the
# sketchybarrc load trigger paints it; the 5s tick is the catch-all fallback.
sketchybar --add item flows_ctrl left \
  --set flows_ctrl drawing=off updates=on update_freq=5 \
        script="$PLUGIN_DIR/flows.sh" \
  --subscribe flows_ctrl flow_change aerospace_workspace_change
