#!/usr/bin/env bash
#
# AeroSpace scratchpad toggle.
#
#   scratchpad.sh <app-bundle-id> <stash-workspace>
#
# - App not running        -> launch it (window lands on the focused workspace).
# - Window on this WS       -> stash it on the hidden <stash-workspace>, and
#                              refocus the window that had focus before it was
#                              summoned.
# - Window on another WS    -> summon it to the focused workspace and focus it.
#
# Restoring focus explicitly matters for accordion layouts: if AeroSpace picks
# the next focus itself it falls back to the first window, which brings it to
# the front of the stack.
#
# The stash workspaces (e.g. "obsidian", "spotify", "beeper") are never shown in
# sketchybar because the bar only iterates workspaces 1..10.

set -euo pipefail

bundle="$1"
stash="$2"

focused="$(aerospace list-workspaces --focused)"

# Window focused before the scratchpad was summoned.
state="${TMPDIR:-/tmp}/aerospace-scratchpad-$stash"

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

focused_wid="$(aerospace list-windows --focused --format '%{window-id}' 2>/dev/null || true)"

if [ "$ws" = "$focused" ]; then
  # Only restore if the scratchpad still has focus and the previous window is
  # still on this workspace. Focus it *before* stashing so AeroSpace never
  # picks its own fallback.
  prev="$(cat "$state" 2>/dev/null || true)"
  if [ "$focused_wid" = "$wid" ] && [ -n "$prev" ] &&
    aerospace list-windows --workspace focused --format '%{window-id}' | grep -qx "$prev"; then
    aerospace focus --window-id "$prev"
  fi
  aerospace move-node-to-workspace --window-id "$wid" "$stash"
  rm -f "$state"
else
  printf '%s\n' "$focused_wid" > "$state"
  aerospace move-node-to-workspace --window-id "$wid" --focus-follows-window "$focused"
fi
