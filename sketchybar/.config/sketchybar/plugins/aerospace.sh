#!/bin/bash

# AeroSpace workspace controller (bash 3.2 — no associative arrays).
#
# Renders every workspace indicator in a single atomic pass:
#   * pins each workspace to its monitor's bar via sketchybar's `display`
#     property, so every monitor shows only the workspaces that live on it;
#   * groups each monitor's workspaces into one bracket bordered in that
#     monitor's accent colour;
#   * highlights every *visible* workspace (one per monitor) — the focused one
#     gets the strong treatment, the other monitors' visible workspaces get a
#     dimmer "visible" treatment, everything else is dimmed;
#   * draws an app-icon strip per workspace.
#
# Driven by aerospace_workspace_change and the item's 2s tick (the tick is the
# fallback for window add/remove and for workspaces migrating between monitors,
# which AeroSpace has no dedicated event for).

source "$CONFIG_DIR/colors.sh"

# Accent colour per monitor, by monitor order.
PALETTE=("$BLUE" "$MAGENTA" "$GREEN" "$ORANGE" "$YELLOW" "$RED")
NP=${#PALETTE[@]}

SIGFILE="${TMPDIR:-/tmp}/sketchybar_aerospace.sig"
BRKFILE="${TMPDIR:-/tmp}/sketchybar_aerospace.brk"

# --- query AeroSpace once -----------------------------------------------------
# monitor-id paired with its NSScreen index — the latter is what sketchybar's
# `display` property keys off, so it maps each monitor to its own bar.
mon_screen=$(aerospace list-monitors \
  --format '%{monitor-id}|%{monitor-appkit-nsscreen-screens-id}')
monitors=$(printf '%s\n' "$mon_screen" | cut -d'|' -f1)
focused=$(aerospace list-workspaces --focused)
visible=" $(aerospace list-workspaces --monitor all --visible | tr '\n' ' ') "
ws_mon=$(aerospace list-workspaces --all --format '%{workspace}|%{monitor-id}')

# Map each window to a workspace icon line ("workspace|glyph"), calling the
# icon map once per window.
icon_lines=""
while IFS='|' read -r ws app; do
  [ -n "$app" ] || continue
  icon_lines="$icon_lines$ws|$("$CONFIG_DIR/plugins/icon_map.sh" "$app")
"
done < <(aerospace list-windows --all --format '%{workspace}|%{app-name}')

# --- build the per-item render + layout signature -----------------------------
set_args=()
order=""
member_lines=""   # "monitor|space.N" per shown workspace
sig=""
i=0
for m in $monitors; do
  accent=${PALETTE[$((i % NP))]}
  i=$((i + 1))
  bg_strong="0x66${accent:4}"   # focused background (translucent accent)
  bg_weak="0x26${accent:4}"     # visible background (fainter accent)

  # NSScreen index for this monitor → sketchybar display number.
  disp=$(printf '%s\n' "$mon_screen" | awk -F'|' -v m="$m" '$1==m{print $2}')

  # Numeric workspaces currently on this monitor, in numeric order.
  ws_on_m=$(printf '%s\n' "$ws_mon" | awk -F'|' -v m="$m" \
    '$2==m && $1 ~ /^[0-9]+$/ {print $1}' | sort -n)
  [ -n "$ws_on_m" ] || continue

  for w in $ws_on_m; do
    it="space.$w"
    order="$order $it"
    member_lines="$member_lines$m|$it
"
    sig="$sig$disp:$m=$w,"

    # Pin the item to its monitor's bar.
    set_args+=(--set "$it" display="$disp" padding_left=2)

    if [ "$w" = "$focused" ]; then
      set_args+=(background.drawing=on background.color="$bg_strong" \
        background.border_color="$accent" background.border_width=2 \
        icon.color="$WHITE" label.color="$WHITE")
    elif [ "$visible" != "${visible/ $w / }" ]; then
      set_args+=(background.drawing=on background.color="$bg_weak" \
        background.border_color="$accent" background.border_width=1 \
        icon.color="$accent" label.color="$WHITE")
    else
      set_args+=(background.drawing=off \
        icon.color="$GREY" label.color="$GREY")
    fi

    icons=$(printf '%s' "$icon_lines" | awk -F'|' -v w="$w" \
      '$1==w{printf " %s", $2}')
    if [ -n "$icons" ]; then
      set_args+=(label="$icons" label.drawing=on)
    else
      set_args+=(label.drawing=off)
    fi
  done
done

# --- apply per-item visuals (every render, one atomic call) -------------------
[ ${#set_args[@]} -gt 0 ] && sketchybar "${set_args[@]}" >/dev/null

# --- structural changes only when the grouping actually changes ---------------
if [ "$sig" != "$(cat "$SIGFILE" 2>/dev/null)" ]; then
  printf '%s' "$sig" >"$SIGFILE"

  # Order items so each monitor's workspaces are contiguous.
  [ -n "$order" ] && sketchybar --reorder $order >/dev/null

  # Rebuild the per-monitor brackets.
  old=$(cat "$BRKFILE" 2>/dev/null)
  [ -n "$old" ] && sketchybar --remove $old >/dev/null 2>&1

  newbrk=""
  i=0
  for m in $monitors; do
    accent=${PALETTE[$((i % NP))]}
    i=$((i + 1))
    disp=$(printf '%s\n' "$mon_screen" | awk -F'|' -v m="$m" '$1==m{print $2}')
    members=$(printf '%s' "$member_lines" | awk -F'|' -v m="$m" \
      '$1==m{printf " %s", $2}')
    [ -n "$members" ] || continue
    name="mon.$m.bracket"
    sketchybar --add bracket "$name" $members \
      --set "$name" display="$disp" background.drawing=on \
        background.color="$BACKGROUND_1" \
        background.border_color="$accent" background.border_width=2 \
        background.corner_radius=9 >/dev/null
    newbrk="$newbrk $name"
  done
  printf '%s' "$newbrk" >"$BRKFILE"
fi
