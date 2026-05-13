#!/usr/bin/env bash
# cpu-hog.sh — spawn N background CPU-bound processes for diagnostic practice.
# Usage: ./cpu-hog.sh [count]
#   count: number of CPU hogs to spawn (default: 1)
# Output: PIDs of spawned processes, one per line.
# Cleanup: kill the PIDs manually, or use `pkill -P $$` from the same shell.

set -eu

COUNT=${1:-1}

if ! [[ "$COUNT" =~ ^[0-9]+$ ]] || [ "$COUNT" -lt 1 ]; then
    echo "usage: $0 [count]  (count must be a positive integer)" >&2
    exit 1
fi

echo "Spawning $COUNT CPU hog(s)..." >&2

PIDS=()
for i in $(seq 1 "$COUNT"); do
    yes > /dev/null &
    PIDS+=($!)
done

for pid in "${PIDS[@]}"; do
    echo "$pid"
done

echo "Done. To kill them all: kill ${PIDS[*]}" >&2
