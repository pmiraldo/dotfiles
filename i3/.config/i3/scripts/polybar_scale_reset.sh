#!/usr/bin/env bash
set -euo pipefail

BASE_CFG="${HOME}/.config/polybar/config.ini"

if [ ! -f "${BASE_CFG}" ]; then
  echo "Missing polybar config: ${BASE_CFG}" >&2
  exit 1
fi

polybar-msg cmd quit >/dev/null 2>&1 || true
echo "---" | tee -a /tmp/polybar1.log /tmp/polybar2.log >/dev/null
polybar --config="${BASE_CFG}" top 2>&1 | tee -a /tmp/polybar1.log & disown
