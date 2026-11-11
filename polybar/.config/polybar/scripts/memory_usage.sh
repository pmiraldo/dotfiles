#!/bin/sh

awk '
    /^MemTotal:/ {
        total_kb = $2
    }
    /^MemAvailable:/ {
        available_kb = $2
    }
    END {
        if (total_kb <= 0) {
            exit 1
        }

        used_kb = total_kb - available_kb
        used_pct = int((used_kb * 100 / total_kb) + 0.5)
        used_gb = int((used_kb / 1048576) + 0.5)

        printf " %d%% (%d GB)\n", used_pct, used_gb
    }
' /proc/meminfo
