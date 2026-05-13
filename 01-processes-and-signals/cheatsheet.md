# Processes and Signals — Cheatsheet

## `ps` grammar styles

Three syntaxes coexist in the same `ps` binary. Pick one and stick with it.

| Style | Example | Use when |
|---|---|---|
| **BSD** (no dash) | `ps aux`, `ps auxf` | Interactive eyeballing |
| **UNIX/POSIX** (single dash) | `ps -ef`, `ps -eo pid,stat,cmd` | Scripts, explicit column control |
| **GNU long** (double dash) | `ps --pid 1234`, `ps --forest` | Mixed with either above |

**Rule for scripts**: always UNIX-style with explicit `-o`. Column contract is stable, parsing is safe.

## Process states (STAT column)

| Code | Name | Meaning |
|---|---|---|
| `R` | Running | On CPU or in runqueue, ready to run |
| `S` | Interruptible sleep | Waiting for event (I/O, timer, signal). Signals deliver. Most common state. |
| `D` | Uninterruptible sleep | Waiting on low-level I/O (usually disk/NFS). **Cannot be killed**, not even by SIGKILL |
| `T` | Stopped | Paused by SIGSTOP/SIGTSTP. Alive, memory intact, resumable with SIGCONT |
| `t` | Traced | Stopped by debugger (gdb, strace) |
| `Z` | Zombie | Exited but parent has not called `wait()`. Hangs in process table |
| `X` | Dead | Should never be seen |

### Modifiers (appended to state code)

| Symbol | Meaning |
|---|---|
| `+` | In foreground process group of the controlling terminal — receives Ctrl+C |
| `<` | High priority (nice < 0) |
| `N` | Low priority (nice > 0) |
| `s` | Session leader |
| `l` | Multi-threaded (uses kernel threads via `clone()`) |

## Signals worth knowing by number

| Num | Name | Default action | Catchable | Notes |
|---|---|---|---|---|
| 1 | SIGHUP | Terminate | Yes | Originally "terminal hangup". Now widely used as "reload config" by daemons |
| 2 | SIGINT | Terminate | Yes | What Ctrl+C sends |
| 3 | SIGQUIT | Core dump | Yes | What Ctrl+\ sends |
| 9 | SIGKILL | Terminate | **No** | Cannot be caught, blocked, or ignored. Kernel kills the process unconditionally |
| 15 | SIGTERM | Terminate | Yes | Default of `kill`. Polite "please exit cleanly" |
| 17/18 | SIGCHLD | Ignore | Yes | Sent to parent when child exits |
| 18 | SIGCONT | Continue | Yes | Resume a stopped process |
| 19 | SIGSTOP | Stop | **No** | Cannot be caught. Kernel pauses the process |
| 20 | SIGTSTP | Stop | Yes | What Ctrl+Z sends. Catchable version of STOP |

Numbers vary slightly by architecture — always prefer `kill -TERM` over `kill -15`.

### Decision tree

- Want graceful shutdown → `SIGTERM` (default)
- TERM ignored or process unresponsive after a wait → `SIGKILL`
- Want to inspect state without termination → `SIGSTOP`, later `SIGCONT`
- Daemon and want it to reload config → `SIGHUP` (check daemon documentation first)
- Process in `D` state → neither TERM nor KILL helps. Fix the underlying I/O

## Useful `ps -o` columns

| Column | Shows |
|---|---|
| `pid` | Process ID |
| `ppid` | Parent process ID |
| `pgid` | Process group ID |
| `sid` | Session ID |
| `tty` | Controlling terminal |
| `stat` | State (see above) |
| `pcpu` | % CPU |
| `pmem` | % RAM |
| `rss` | Resident set size in KB |
| `vsz` | Virtual memory size in KB |
| `etime` | Elapsed wall-clock time since start |
| `start` | Start time of the process |
| `wchan` | Kernel function the process is sleeping in |
| `cmd` / `args` | Command line (full) |
| `comm` | Command name (just the executable) |

Example: `ps -eo pid,ppid,stat,pcpu,pmem,etime,cmd`

## Finding processes

| Goal | Command |
|---|---|
| By exact command name | `pgrep -x firefox` |
| By substring of cmdline | `pgrep -a yes` |
| By owner | `pgrep -u arseny` |
| By parent PID | `pgrep -P 1234` |
| Tree view | `pstree -p` or `ps auxf` |
| What holds this file open | `lsof /path/to/file` |
| What listens on this port | `ss -tlnp 'sport = :8080'` |

## Pitfalls

- **`ps | grep` matches itself** — the grep command line literally contains the search pattern. Use `pgrep` or `ps aux | grep '[y]es'` (the bracket trick).
- **`kill -9` is rarely the right first move** — it gives the process no chance to flush buffers, close sockets, or release locks. Try `SIGTERM`, wait 5–10 seconds, then escalate.
- **`T` does not mean terminated** — it means stopped (paused). Process is alive in memory.
- **`D` state cannot be killed** — including by SIGKILL. The kernel is mid-syscall and will not return until the I/O completes (or never, if the device is dead).
- **Zombie processes are not "running"** — they consume only a slot in the process table. They go away when their parent reaps them or when their parent dies and `init` reaps them.
