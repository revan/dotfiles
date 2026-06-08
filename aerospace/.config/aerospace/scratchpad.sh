#!/usr/bin/env bash
#
# AeroSpace scratchpad toggle.
#
#   scratchpad.sh <app-bundle-id> <stash-workspace>
#
# - App not running        -> launch it (window lands on the focused workspace).
# - Window on this WS       -> stash it on the hidden <stash-workspace>.
# - Window on another WS    -> summon it to the focused workspace and focus it.
#
# The stash workspaces (e.g. "obsidian", "spotify", "beeper") are never shown in
# sketchybar because the bar only iterates workspaces 1..10.

set -euo pipefail

bundle="$1"
stash="$2"

focused="$(aerospace list-workspaces --focused)"

# First window of this app, as "<window-id>|<workspace>" (empty if not running).
info="$(aerospace list-windows --monitor all --app-bundle-id "$bundle" \
  --format '%{window-id}|%{workspace}' | head -n1)"

if [ -z "$info" ]; then
  open -b "$bundle"
  exit 0
fi

wid="${info%%|*}"
ws="${info##*|}"
ws="${ws#"${ws%%[![:space:]]*}"}"  # trim leading whitespace from the padded field

if [ "$ws" = "$focused" ]; then
  aerospace move-node-to-workspace --window-id "$wid" "$stash"
else
  aerospace move-node-to-workspace --window-id "$wid" --focus-follows-window "$focused"
fi
