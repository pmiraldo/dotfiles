#!/usr/bin/env bash

set -euo pipefail

MODE="${1:-light}"
LIGHT_WALLPAPER="${HOME}/.config/i3/background_.jpg"
DARK_WALLPAPER="${HOME}/.config/i3/background.jpg"
BASE_CFG="${HOME}/.config/polybar/config.ini"
LIGHT_CFG="/tmp/polybar-config-light.ini"

if [ ! -f "${BASE_CFG}" ]; then
  echo "Missing polybar config: ${BASE_CFG}" >&2
  exit 1
fi

launch_polybar() {
  local config_path="$1"

  polybar-msg cmd quit >/dev/null 2>&1 || true
  echo "---" | tee -a /tmp/polybar1.log /tmp/polybar2.log >/dev/null
  polybar --config="${config_path}" top 2>&1 | tee -a /tmp/polybar1.log & disown
}

case "${MODE}" in
  light)
    if [ ! -f "${LIGHT_WALLPAPER}" ]; then
      echo "Missing wallpaper: ${LIGHT_WALLPAPER}" >&2
      exit 1
    fi

    feh --bg-fill "${LIGHT_WALLPAPER}"

    perl -0pe '
      s/^background\s*=\s*#?[0-9A-Fa-f]+\s*$/background = #D9D9D9/m;
      s/^background-alt\s*=\s*#?[0-9A-Fa-f]+\s*$/background-alt = #C8C8C8/m;
      s/^foreground\s*=\s*#?[0-9A-Fa-f]+\s*$/foreground = #000000/m;
      s/^primary\s*=\s*#?[0-9A-Fa-f]+\s*$/primary = #000000/m;
      s/^secondary\s*=\s*#?[0-9A-Fa-f]+\s*$/secondary = #000000/m;
      s/^disabled\s*=\s*.*$/disabled = #666666/m;
      s/^border-color\s*=\s*#?[0-9A-Fa-f]+\s*$/border-color = #B0B0B0/m;
    ' "${BASE_CFG}" > "${LIGHT_CFG}"

    launch_polybar "${LIGHT_CFG}"
    ;;
  dark)
    if [ ! -f "${DARK_WALLPAPER}" ]; then
      echo "Missing wallpaper: ${DARK_WALLPAPER}" >&2
      exit 1
    fi

    feh --bg-fill "${DARK_WALLPAPER}"
    launch_polybar "${BASE_CFG}"
    ;;
  *)
    echo "Usage: $0 [light|dark]" >&2
    exit 1
    ;;
esac
