# Linux Foundation Practice

Practical drill for operational Linux skills. Built around the principle: **observe before you touch, understand state before you change it.**

## Why this repo exists

Operating Linux blindly leads to broken systems. The goal here is to move from "near-zero operational awareness" to "can debug processes, sockets, services, and logs without breaking the host." Every topic is structured as: concept → cheatsheet → reproducible exercises → debugging recipes.

## Structure

```00-setup/                  VM prerequisites, environment verification
01-processes-and-signals/  ps, top, kill, signals, process states
02-network-sockets/        ss, lsof, netstat — who listens, who connects
03-systemd-and-logs/       systemctl, journalctl — services and their logs
04-filesystem-and-fds/     lsof, /proc, df, du — files, descriptors, space
99-debugging-recipes/      "X is broken, do this" — distilled playbooks

Each topic folder contains:

- `README.md` — concept overview, why it matters
- `cheatsheet.md` — compact tables for fast recall
- `exercises.md` — reproducible drills with expected outputs and pitfalls
- `scripts/` — helpers to set up scenarios (CPU hogs, fake services, etc.)

## How to use

1. Spin up a Fedora VM (see `00-setup/`). Never run these drills on a machine you care about.
2. Take a baseline snapshot.
3. Work through topics in order. Skipping is allowed only after you can answer the self-check questions in each `exercises.md` without lookup.
4. Revisit cheatsheets every 1–2 weeks — operational skills decay fast without use.

## Status

| Topic | Status |
|---|---|
| 00-setup | initial draft |
| 01-processes-and-signals | in progress (1.1–1.2 done, 1.3 SIGTERM vs SIGKILL next) |
| 02-network-sockets | not started |
| 03-systemd-and-logs | not started |
| 04-filesystem-and-fds | not started |
| 99-debugging-recipes | accumulated as topics complete |

