#!/usr/bin/env bash
# graceful-victim.sh — demonstrates the difference between SIGTERM and SIGKILL.
# On SIGTERM: catches the signal, runs cleanup, exits gracefully.
# On SIGKILL: no chance to react — leaves cleanup file behind as evidence.
#
# Usage: ./graceful-victim.sh
# Watch /tmp/victim-state.log to see what happened.

set -u

STATE_FILE=/tmp/victim-state.log
PID_FILE=/tmp/victim.pid

echo "$$" > "$PID_FILE"
echo "[$(date +%T)] started, pid=$$" > "$STATE_FILE"

cleanup() {
    echo "[$(date +%T)] SIGTERM received — cleaning up..." >> "$STATE_FILE"
    sleep 2   # simulate flushing buffers, closing sockets
    echo "[$(date +%T)] cleanup done, exiting cleanly" >> "$STATE_FILE"
    rm -f "$PID_FILE"
    exit 0
}

trap cleanup TERM

echo "[$(date +%T)] running, will exit cleanly on SIGTERM" >> "$STATE_FILE"

# Busy loop that the trap can interrupt
while true; do
    sleep 1
done

