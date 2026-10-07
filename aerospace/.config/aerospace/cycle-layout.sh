#!/usr/bin/env bash
#
# AeroSpace layout cycle for the focused window's container.
#
#   cycle-layout.sh
#
# Cycles h_tiles -> v_tiles -> accordion. `layout` alone only toggles between
# two, so branch on the current layout. Nested containers have their
# orientation forced by normalization, so there it just toggles
# tiles/accordion.

set -euo pipefail

case "$(aerospace list-windows --focused --format '%{window-parent-container-layout}')" in
  h_tiles) aerospace layout v_tiles ;;
  v_tiles) aerospace layout h_accordion ;;
  *)       aerospace layout h_tiles ;;
esac
