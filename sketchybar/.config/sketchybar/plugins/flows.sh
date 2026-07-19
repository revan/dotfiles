#!/bin/bash

# Flow strip controller (bash 3.2 — no associative arrays).
#
# Renders one "flow.<name>" item per flow, active flow highlighted, inactive
# dimmed; clicking a flow switches to it. Items are rebuilt only when the flow
# list changes (signature-gated, same pattern as plugins/aerospace.sh) and are
# kept just before the static flow_add "+" anchor. Flows are global state, so
# the strip lives on the main display's bar only.
#
# Driven by flow_change (fired by flow.sh), aerospace_workspace_change (first
# paint on bar load), and the item's 5s tick as fallback.

source "$CONFIG_DIR/colors.sh"

STATE_DIR="$HOME/.local/state/aerospace"
SIGFILE="${TMPDIR:-/tmp}/sketchybar_flows.sig"
ITEMSFILE="${TMPDIR:-/tmp}/sketchybar_flows.items"

flows=$(cat "$STATE_DIR/flows" 2>/dev/null)
[ -n "$flows" ] || flows="main"
active=$(cat "$STATE_DIR/active-flow" 2>/dev/null)
[ -n "$active" ] || active="main"

accent=$BLUE
bg_strong="0x66${accent:4}"

# --- structural rebuild only when the flow list changes -----------------------
if [ "$flows" != "$(cat "$SIGFILE" 2>/dev/null)" ]; then
  old=$(cat "$ITEMSFILE" 2>/dev/null)
  for it in $old; do
    sketchybar --remove "$it" >/dev/null 2>&1
  done

  new_items=""
  while IFS= read -r f; do
    [ -n "$f" ] || continue
    it="flow.$f"
    sketchybar --add item "$it" left \
      --set "$it" display=1 \
        icon="$f" \
        icon.padding_left=8 \
        icon.padding_right=8 \
        padding_left=2 \
        padding_right=2 \
        background.height=26 \
        background.corner_radius=9 \
        background.drawing=off \
        click_script="$HOME/.config/aerospace/flow.sh switch $f" \
      --move "$it" before flow_add >/dev/null
    new_items="$new_items $it"
  done < <(printf '%s\n' "$flows")

  printf '%s' "$flows" >"$SIGFILE"
  printf '%s' "$new_items" >"$ITEMSFILE"
fi

# --- apply visuals (every render, one atomic call) ----------------------------
set_args=()
while IFS= read -r f; do
  [ -n "$f" ] || continue
  it="flow.$f"
  if [ "$f" = "$active" ]; then
    set_args+=(--set "$it" background.drawing=on background.color="$bg_strong" \
      background.border_color="$accent" background.border_width=2 \
      icon.color="$WHITE")
  else
    set_args+=(--set "$it" background.drawing=off icon.color="$GREY")
  fi
done < <(printf '%s\n' "$flows")

[ ${#set_args[@]} -gt 0 ] && sketchybar "${set_args[@]}" >/dev/null
