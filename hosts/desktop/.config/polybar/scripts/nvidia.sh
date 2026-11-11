#!/bin/sh

# Query both GPUs (0 and 1) for:
#   - utilization.gpu  (GPU load %)
#   - memory.used      (MiB)
#   - memory.total     (MiB)
OUT=$(nvidia-smi --id=0,1 \
    --query-gpu=utilization.gpu,memory.used,memory.total \
    --format=csv,noheader,nounits)

echo "$OUT" | awk -F',' '
NR==1 {
    gsub(/ /, "", $1); gsub(/ /, "", $2); gsub(/ /, "", $3);
    g0_util = $1; g0_used = $2; g0_total = $3;
}
NR==2 {
    gsub(/ /, "", $1); gsub(/ /, "", $2); gsub(/ /, "", $3);
    g1_util = $1; g1_used = $2; g1_total = $3;
}
END {
    # g0_mem = int(g0_used * 100 / g0_total);
    # g1_mem = int(g1_used * 100 / g1_total);
    g0_mem = int(g0_used);
    g1_mem = int(g1_used);

    # Example output:
    # G0 35% 40%M | G1 12% 10%M
    printf "GPU0 %s%% (%dMiB) | GPU1 %s%% (%dMiB)\n", g0_util, g0_mem, g1_util, g1_mem;
}'