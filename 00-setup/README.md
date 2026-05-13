# 00 — Setup

This folder defines the baseline environment for every drill in this repo. The contract: every exercise assumes you are inside a clean Fedora VM where you have root via `sudo`, where breaking things has zero consequences for your host.

## VM baseline

- **Hypervisor**: GNOME Boxes (or VirtualBox / virt-manager — anything supporting snapshots)
- **Guest OS**: Fedora Workstation 43 or later (Workstation, not Server — we need a desktop session for clipboard via spice-vdagent)
- **Resources**: 2 vCPU, 4 GB RAM, 20 GB disk
- **Network**: NAT (default), internet inside VM
- **User**: regular user in the `wheel` group (sudo access)
- **Snapshot discipline**: take `clean-workstation-ready` after first setup. Take a snapshot before every destructive experiment.

## Required tools

Most are preinstalled on Fedora Workstation. If `verify-env.sh` reports anything missing:

```bash
sudo dnf install -y procps-ng psmisc iproute lsof strace net-tools htop util-linux tmux vim-enhanced
```

## Verification

Run `verify-env.sh` from this folder. It must report:

- Fedora 43+
- PID 1 = `systemd`
- `systemctl is-system-running` = `running` or `degraded`
- All listed tools present

If any check fails, fix it before starting any topic.

## Snapshot strategy

Snapshots are non-negotiable. Workflow:

1. `clean-workstation-ready` — baseline, never delete
2. Before any topic that modifies system state (systemd unit changes, package installs, network config) — take a topic-specific snapshot
3. After completing a destructive experiment — either keep the broken state for analysis, or roll back

Snapshots are stored inside the qcow2 disk image. If you delete the VM, snapshots die with it.
