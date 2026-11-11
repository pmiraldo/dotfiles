#!/bin/sh

STATE_DIR="${XDG_RUNTIME_DIR:-}"
if [ -z "$STATE_DIR" ] || [ ! -d "$STATE_DIR" ] || [ ! -w "$STATE_DIR" ]; then
    STATE_DIR="/tmp"
fi
STATE_FILE="$STATE_DIR/polybar-cpu-active-cores-${UID:-$(id -u)}.state"
THRESHOLD=10

sample() {
    awk '
        /^cpu( |[0-9]+ )/ {
            total = 0
            for (i = 2; i <= NF; i++) {
                total += $i
            }

            idle = $5 + $6
            print $1, total, idle
        }
    ' /proc/stat
}

format_cpu_status() {
    awk -v threshold="$THRESHOLD" '
        NR == FNR {
            prev_total[$1] = $2
            prev_idle[$1] = $3
            next
        }

        {
            delta_total = $2 - prev_total[$1]
            delta_idle = $3 - prev_idle[$1]

            if (delta_total <= 0) {
                next
            }

            usage = ((delta_total - delta_idle) * 100) / delta_total

            if ($1 == "cpu") {
                total_usage = int(usage + 0.5)
                next
            }

            if (usage > threshold) {
                active++
            }
        }

        END {
            printf " %d%% (%d >%d%%)\n", total_usage + 0, active + 0, threshold
        }
    ' "$1" "$2"
}

prev_snapshot="$(mktemp)"
curr_snapshot="$(mktemp)"
trap 'rm -f "$prev_snapshot" "$curr_snapshot"' EXIT

if [ -s "$STATE_FILE" ]; then
    cp "$STATE_FILE" "$prev_snapshot"
    sample > "$curr_snapshot"
else
    sample > "$prev_snapshot"
    sleep 0.5
    sample > "$curr_snapshot"
fi

format_cpu_status "$prev_snapshot" "$curr_snapshot"
cp "$curr_snapshot" "$STATE_FILE"
