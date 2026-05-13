#!/usr/bin/env bash
# pause-experiment.sh — automated SIGSTOP/SIGCONT timing demonstration.
# Spawns a sleep, observes it, stops it, observes the frozen state, resumes it.
# Run interactively. No arguments.

set -eu

SLEEP_DURATION=30
PAUSE_DURATION=10

echo "=== Starting sleep $SLEEP_DURATION in background ==="
sleep "$SLEEP_DURATION" &
PID=$!
echo "  PID = $PID"
sleep 1

echo
echo "=== State immediately after start ==="
ps -p "$PID" -o pid,stat,etime,cmd

echo
echo "=== Sending SIGSTOP ==="
kill -STOP "$PID"
sleep 1
ps -p "$PID" -o pid,stat,etime,cmd

echo
echo "=== Waiting $PAUSE_DURATION seconds while process is paused ==="
echo "    (etime should grow even though the process is frozen)"
sleep "$PAUSE_DURATION"
ps -p "$PID" -o pid,stat,etime,cmd

echo
echo "=== Sending SIGCONT ==="
kill -CONT "$PID"
sleep 1
if kill -0 "$PID" 2>/dev/null; then
    ps -p "$PID" -o pid,stat,etime,cmd
    echo "  Process is alive again — waiting for it to finish naturally..."
    wait "$PID" 2>/dev/null || true
    echo "  Process exited."
else
    echo "  Process exited on CONT — its internal timer expired during the pause."
fi

echo
echo "=== Done ==="

