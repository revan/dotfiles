#!/usr/bin/env bash
#
# AeroSpace prev/next workspace, skipping the scratchpad stash workspaces.
#
#   cycle-workspace.sh <focus|move> <next|prev>
#
# - focus -> switch to the prev/next workspace.
# - move  -> move the focused window to the prev/next workspace.
#
# Only the numbered workspaces of the focused monitor are fed in via stdin, so
# the stash workspaces (e.g. "obsidian", "spotify", "beeper") are never visited.

set -euo pipefail

action="$1"
direction="$2"

case "$action" in
  focus) cmd=workspace ;;
  move)  cmd=move-node-to-workspace ;;
  *)     echo "usage: $0 <focus|move> <next|prev>" >&2; exit 1 ;;
esac

aerospace list-workspaces --monitor focused | grep -E '^[0-9]+$' \
  | aerospace "$cmd" --stdin --wrap-around "$direction"
