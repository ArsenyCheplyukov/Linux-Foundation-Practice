# 01 — Processes and Signals

Foundation of every Linux debugging session: figuring out what is running, what state it is in, and how to interrupt it without making things worse.

## Why this matters

Most production incidents start with "something is hanging" or "something is eating CPU." The first 60 seconds determine the rest of the response. If you cannot quickly enumerate processes, read their state, and signal them appropriately, you are not debugging — you are guessing.

The goal of this topic is to make these moves reflexive:

- Find a process by name, command line, parent, or owner
- Read its state code and know what that implies
- Send the right signal for the situation (not always `SIGKILL`)
- Recognize processes that cannot be killed and understand why

## Definition of done

You can:

- Find a target process in under 30 seconds using the right tool, not `ps | grep`
- Explain what each STAT code means without lookup, including modifiers like `+`, `<`, `s`, `l`
- Pick between `SIGTERM`, `SIGKILL`, `SIGHUP`, `SIGSTOP`, `SIGCONT` based on intent
- Recognize a process stuck in `D` state and explain why `SIGKILL` will not help
- Use `ps -eo` with explicit columns instead of `ps aux` for any scripted use

## Recommended reading order

1. `cheatsheet.md` — keep open in another window during exercises
2. `exercises.md` — work through 1.1 → 1.2 → 1.3 in a fresh VM session
3. After completing, return to `cheatsheet.md` 24 hours later and verify recall without exercises

## Scripts

- `scripts/cpu-hog.sh` — spawns a CPU-bound background process for diagnostic practice
- `scripts/pause-experiment.sh` — automates the SIGSTOP/SIGCONT timing experiment from exercise 1.2

## Pitfalls fixed by this topic

- Confusing `T` (stopped) with terminated — `T` means alive on pause, not dead
- Confusing `SIGSTOP` with `SIGTERM` — first is pause, second is polite shutdown request
- Using `ps | grep` and being surprised the grep matches itself
- Reaching for `kill -9` first instead of `kill` (which defaults to `SIGTERM`)
- Mixing BSD-style (`ps aux`) with UNIX-style (`ps -eo`) without realizing they are different grammars
