# Processes and Signals — Exercises

Work through these in order, in a fresh VM session. Each exercise lists the commands, what to observe, self-check questions, and the pitfalls already encountered by previous learners. If you cannot answer the self-check questions without scrolling up, redo the exercise.

---

## 1.1 — Spawn and find a process

### Setup

```bash
yes > /dev/null &
```

`yes` prints `y\n` forever. `> /dev/null` discards output. `&` puts it in the background. Result: a CPU-bound process you can experiment with safely.

### Find it five ways

```bash
ps aux | grep yes
ps -eo pid,ppid,stat,pcpu,pmem,cmd | grep yes
pgrep yes
pgrep -a yes
pgrep -x yes
```

### Observe

- BSD-style `ps aux` returns a fixed column set
- UNIX-style `ps -eo` lets you pick exactly the columns you need
- `pgrep` returns just PIDs (`-a` adds the cmdline, `-x` requires exact name match)
- `ps | grep` always includes the grep process itself in the output — this is the canonical pitfall

### Self-check

1. Why does `ps aux | grep yes` always show a `grep` line in addition to `yes`?
2. What is the difference between `pgrep yes` and `pgrep -x yes`?
3. In the UNIX-style output, what column would you add to see how long the process has been alive?

### Cleanup

Leave `yes` running — exercise 1.2 uses it.

---

## 1.2 — Process states and SIGSTOP/SIGCONT

### Setup

`yes` should still be running from 1.1. Add a second process:

```bash
sleep 60 &
```

### Observe states

```bash
ps -eo pid,stat,etime,cmd | grep -E 'yes|sleep'
```

Expected: `yes` in `R` (running on CPU), `sleep` in `S` (interruptible sleep, waiting on a kernel timer).

### Pause `sleep`

```bash
kill -STOP <PID_of_sleep>
```

Predict the new STAT code before running the next command. Write it down.

```bash
ps -eo pid,stat,etime,cmd | grep -E 'yes|sleep'
```

Actual: `T` (stopped).

### Critical observation

Wait 15–20 seconds, then check `etime` again:

```bash
ps -eo pid,stat,etime,cmd | grep sleep
```

`etime` has grown — wall-clock time keeps moving — but the process is paused. Its internal timer is frozen.

### Resume

```bash
kill -CONT <PID_of_sleep>
```

```bash
ps -eo pid,stat,etime,cmd | grep -E 'yes|sleep'
```

If less than 60 seconds of real time passed since `sleep` started, it returns to `S` and finishes when its internal timer runs out. If more than 60 seconds passed during the pause, it terminates immediately on CONT — the timer fired while it was stopped and exits as soon as it is allowed to run.

### Self-check

1. What is the difference between `T` and a terminated process? How would you tell them apart in `ps`?
2. Why does `etime` keep growing while a process is in `T` state?
3. SIGSTOP and SIGKILL share one important property — what is it, and why does it matter operationally?
4. Why does Ctrl+C kill processes in the foreground but not background ones? What field in `ps` output reveals this?

### Pitfalls encountered

- Naming SIGSTOP as "terminate" — it is **not**. STOP pauses, TERM and KILL end. Different sigfns, different intents.
- Reading `T` as "terminated" — it is **s**T**opped**. Terminated processes do not appear in `ps` at all (unless they are zombies, which show `Z`).

### Cleanup

```bash
kill %1 %2   # by job number, kills both background jobs
# or
pkill yes
pkill sleep
```

---

## 1.3 — SIGTERM vs SIGKILL (next session)

To be added: experiment with a script that catches SIGTERM and shuts down cleanly, demonstrating why `kill -9` is the wrong first move.

