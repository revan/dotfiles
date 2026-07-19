#!/usr/bin/env bash
#
# AeroSpace "flows": named sets of workspaces, one active at a time.
#
#   flow.sh go <slot>            focus <active>.<slot> (creates + places it)
#   flow.sh move <slot>          move focused window to <active>.<slot>
#   flow.sh switch <flow>        activate a flow (focus its last-used slot)
#   flow.sh next|prev            cycle the active flow
#   flow.sh movewin-next|prev    move focused window to the same slot in the
#                                adjacent flow and follow it
#   flow.sh cycle next|prev      focus adjacent existing slot within the flow
#   flow.sh movecycle next|prev  move focused window to adjacent existing slot
#   flow.sh new                  prompt for a name, create + switch (bar "+")
#   flow.sh delete [<flow>]      delete a flow, relocating its windows
#   flow.sh list                 print flows, active marked with *
#   flow.sh resume               re-activate the saved flow (after-startup)
#
# A flow <f> owns AeroSpace workspaces "<f>.1".."<f>.10", created on the fly.
# Slots 1-6 live on the main monitor, 7-10 on the secondary, mirroring the old
# static [workspace-to-monitor-force-assignment] (which cannot cover dynamic
# names). Scratchpad stash workspaces ("obsidian" etc.) contain no dot and are
# ignored by all flow logic and by the bar.
#
# State (must survive reboot, so not TMPDIR):
#   ~/.local/state/aerospace/flows        ordered flow names, one per line
#   ~/.local/state/aerospace/active-flow  the active flow
#   ~/.local/state/aerospace/last-slots   "<flow>|<slot>" last focused per flow

set -euo pipefail

STATE_DIR="$HOME/.local/state/aerospace"
FLOWS_FILE="$STATE_DIR/flows"
ACTIVE_FILE="$STATE_DIR/active-flow"
SLOTS_FILE="$STATE_DIR/last-slots"
SLOTS=10

write_file() { # <path> <content>
  local tmp="$1.tmp.$$"
  printf '%s\n' "$2" >"$tmp"
  mv "$tmp" "$1"
}

active_flow() {
  cat "$ACTIVE_FILE" 2>/dev/null || echo main
}

get_last_slot() { # <flow>
  local s
  s=$(awk -F'|' -v f="$1" '$1==f{print $2}' "$SLOTS_FILE" | tail -n1)
  printf '%s' "${s:-1}"
}

set_last_slot() { # <flow> <slot>
  local tmp="$SLOTS_FILE.tmp.$$"
  {
    awk -F'|' -v f="$1" '$1!=f' "$SLOTS_FILE"
    printf '%s|%s\n' "$1" "$2"
  } >"$tmp"
  mv "$tmp" "$SLOTS_FILE"
}

# Slots 1-6 -> main monitor, 7-10 -> secondary (falls back to main when there
# is a single monitor). Replaces the static force-assignment table.
enforce_monitor() { # <workspace> <slot>
  if [ "$2" -le 6 ]; then
    aerospace move-workspace-to-monitor --workspace "$1" main >/dev/null 2>&1 || true
  else
    aerospace move-workspace-to-monitor --workspace "$1" secondary main >/dev/null 2>&1 || true
  fi
}

bar_refresh() {
  sketchybar --trigger flow_change >/dev/null 2>&1 || true
}

# First run: bootstrap state and adopt the legacy numeric workspaces 1..10
# into a "main" flow. The existence of the flows file suppresses this forever.
ensure_state() {
  mkdir -p "$STATE_DIR"
  if [ ! -f "$FLOWS_FILE" ]; then
    local n wid focused
    focused=$(aerospace list-workspaces --focused)
    write_file "$FLOWS_FILE" "main"
    write_file "$ACTIVE_FILE" "main"
    : >"$SLOTS_FILE"
    for n in $(seq 1 "$SLOTS"); do
      for wid in $(aerospace list-windows --workspace "$n" \
        --format '%{window-id}' 2>/dev/null); do
        aerospace move-node-to-workspace --window-id "$wid" "main.$n" || true
      done
    done
    case "$focused" in
      [1-9] | 10) set_last_slot main "$focused" ;;
    esac
  fi
  : >>"$SLOTS_FILE"
}

do_go() { # <slot>
  local f ws
  f=$(active_flow)
  ws="$f.$1"
  aerospace workspace "$ws" # creates the workspace if it died (all slots work)
  enforce_monitor "$ws" "$1"
  # Re-assert focus in case the move changed monitors. Errors are silenced:
  # this is a duplicate of the call above, which already surfaced any real
  # failure, and the usual output here is just the "already focused" noop tip.
  aerospace workspace "$ws" >/dev/null 2>&1 || true
  set_last_slot "$f" "$1"
}

do_move() { # <slot>
  local ws
  ws="$(active_flow).$1"
  aerospace move-node-to-workspace "$ws"
  enforce_monitor "$ws" "$1" # move-node may create the ws on the wrong monitor
}

do_switch() { # <flow>
  grep -qx "$1" "$FLOWS_FILE" || {
    echo "flow.sh: no such flow: $1" >&2
    exit 1
  }
  write_file "$ACTIVE_FILE" "$1"
  do_go "$(get_last_slot "$1")"
  bar_refresh
}

adjacent_flow() { # next|prev
  awk -v cur="$(active_flow)" -v dir="$1" '
    {a[NR]=$0; if($0==cur) c=NR}
    END{
      if(!c){print a[1]; exit}
      i = (dir=="next") ? c%NR+1 : (c-2+NR)%NR+1
      print a[i]
    }' "$FLOWS_FILE"
}

# Existing workspaces of the active flow, as numerically sorted slots.
# (AeroSpace's own next/prev is lexicographic and crosses into other flows
# and the scratchpad stashes, so cycling is done here instead.)
existing_slots() {
  aerospace list-workspaces --monitor all |
    awk -v f="$(active_flow)." 'index($0,f)==1{print substr($0,length(f)+1)}' |
    sort -n
}

adjacent_slot() { # <current-slot> <next|prev>  (reads slots from stdin)
  awk -v c="$1" -v dir="$2" '
    {a[NR]=$0; if($0==c) idx=NR}
    END{
      if(!NR) exit
      if(!idx){print a[1]; exit}
      i = (dir=="next") ? idx%NR+1 : (idx-2+NR)%NR+1
      print a[i]
    }'
}

do_cycle() { # <next|prev> <go|move>
  local f cur target
  f=$(active_flow)
  cur=$(aerospace list-workspaces --focused)
  case "$cur" in
    "$f".*) cur="${cur#"$f".}" ;;
    *) # focused a stash / foreign workspace: jump back into the flow
      [ "$2" = go ] && do_go "$(get_last_slot "$f")"
      return 0
      ;;
  esac
  target=$(existing_slots | adjacent_slot "$cur" "$1")
  [ -n "$target" ] || target=1
  if [ "$2" = go ]; then
    do_go "$target"
  else
    do_move "$target"
  fi
}

do_movewin() { # next|prev
  local cur f slot tf target
  f=$(active_flow)
  cur=$(aerospace list-workspaces --focused)
  case "$cur" in
    "$f".*) slot="${cur#"$f".}" ;;
    *) exit 0 ;; # stash / foreign workspace focused: nothing sensible to do
  esac
  tf=$(adjacent_flow "$1")
  [ "$tf" = "$f" ] && exit 0
  target="$tf.$slot"
  aerospace move-node-to-workspace --focus-follows-window "$target"
  enforce_monitor "$target" "$slot"
  aerospace workspace "$target"
  write_file "$ACTIVE_FILE" "$tf"
  set_last_slot "$tf" "$slot"
  bar_refresh
}

do_new() {
  local name
  name=$(osascript -e 'tell application "System Events"
    activate
    text returned of (display dialog "New flow name:" default answer "" with title "New flow")
  end tell' 2>/dev/null) || exit 0 # cancelled
  case "$name" in
    '' | *[!A-Za-z0-9_-]*)
      osascript -e 'display alert "Invalid flow name" message "Use letters, digits, - and _ only."' >/dev/null
      exit 1
      ;;
    obsidian | spotify | beeper)
      osascript -e 'display alert "Invalid flow name" message "That name is reserved for a scratchpad."' >/dev/null
      exit 1
      ;;
  esac
  if grep -qx "$name" "$FLOWS_FILE"; then
    osascript -e 'display alert "Flow exists" message "There is already a flow with that name."' >/dev/null
    exit 1
  fi
  printf '%s\n' "$name" >>"$FLOWS_FILE"
  do_switch "$name"
}

do_delete() { # [<flow>]
  local f fallback n ws wid tmp
  f="${1:-$(active_flow)}"
  grep -qx "$f" "$FLOWS_FILE" || {
    echo "flow.sh: no such flow: $f" >&2
    exit 1
  }
  if [ "$(grep -c . "$FLOWS_FILE")" -le 1 ]; then
    echo "flow.sh: refusing to delete the only flow" >&2
    exit 1
  fi
  fallback=$(awk -v cur="$f" '
    {a[NR]=$0; if($0==cur) c=NR}
    END{i=(c-2+NR)%NR+1; print a[i]}' "$FLOWS_FILE")
  # Relocate every window so nothing is stranded on an unreachable workspace.
  for n in $(seq 1 "$SLOTS"); do
    ws="$f.$n"
    for wid in $(aerospace list-windows --workspace "$ws" \
      --format '%{window-id}' 2>/dev/null); do
      aerospace move-node-to-workspace --window-id "$wid" "$fallback.$n" || true
    done
  done
  tmp="$FLOWS_FILE.tmp.$$"
  grep -vx "$f" "$FLOWS_FILE" >"$tmp"
  mv "$tmp" "$FLOWS_FILE"
  tmp="$SLOTS_FILE.tmp.$$"
  awk -F'|' -v f="$f" '$1!=f' "$SLOTS_FILE" >"$tmp"
  mv "$tmp" "$SLOTS_FILE"
  if [ "$(active_flow)" = "$f" ]; then
    do_switch "$fallback"
  else
    bar_refresh
  fi
}

do_list() {
  local active f
  active=$(active_flow)
  while IFS= read -r f; do
    [ -n "$f" ] || continue
    if [ "$f" = "$active" ]; then
      printf '* %s\n' "$f"
    else
      printf '  %s\n' "$f"
    fi
  done <"$FLOWS_FILE"
}

ensure_state

case "${1:-}" in
  go) do_go "$2" ;;
  move) do_move "$2" ;;
  switch) do_switch "$2" ;;
  next | prev) do_switch "$(adjacent_flow "$1")" ;;
  movewin-next) do_movewin next ;;
  movewin-prev) do_movewin prev ;;
  cycle) do_cycle "$2" go ;;
  movecycle) do_cycle "$2" move ;;
  new) do_new ;;
  delete) do_delete "${2:-}" ;;
  list) do_list ;;
  resume) do_switch "$(active_flow)" ;;
  *)
    echo "usage: flow.sh go|move <slot> | switch <flow> | next|prev |" >&2
    echo "       movewin-next|movewin-prev | cycle|movecycle next|prev |" >&2
    echo "       new | delete [<flow>] | list | resume" >&2
    exit 1
    ;;
esac
