#!/usr/bin/env bash
# verify-env.sh — confirm the VM baseline matches Linux Foundation Practice requirements.
# Exits 0 on success, 1 on any failure.

set -u

FAIL=0
pass() { printf '  \033[32m✓\033[0m %s\n' "$1"; }
fail() { printf '  \033[31m✗\033[0m %s\n' "$1"; FAIL=1; }
info() { printf '\n\033[1m%s\033[0m\n' "$1"; }

info "Distribution"
if grep -q '^NAME="Fedora Linux"' /etc/os-release; then
    VERSION=$(grep '^VERSION_ID=' /etc/os-release | cut -d= -f2)
    pass "Fedora Linux $VERSION"
else
    fail "Not Fedora — this repo assumes Fedora"
fi

info "Kernel"
pass "$(uname -r)"

info "PID 1"
INIT=$(ps -p 1 -o comm=)
if [ "$INIT" = "systemd" ]; then
    pass "PID 1 = systemd"
else
    fail "PID 1 = $INIT (expected systemd)"
fi

info "System state"
STATE=$(systemctl is-system-running 2>/dev/null || true)
case "$STATE" in
    running)  pass "systemctl is-system-running: running" ;;
    degraded) pass "systemctl is-system-running: degraded (non-fatal, some unit failed)" ;;
    *)        fail "systemctl is-system-running: $STATE" ;;
esac

info "Required tools"
TOOLS="ps top htop ss lsof strace netstat kill pkill pgrep grep find awk xargs systemctl journalctl tmux"
for t in $TOOLS; do
    if command -v "$t" >/dev/null 2>&1; then
        pass "$t"
    else
        fail "$t — install via dnf"
    fi
done

info "Privileges"
if sudo -n true 2>/dev/null; then
    pass "sudo works without password (cached or NOPASSWD)"
elif sudo -v 2>/dev/null; then
    pass "sudo works (password may be required)"
else
    fail "sudo not configured for $(whoami)"
fi

echo
if [ "$FAIL" -eq 0 ]; then
    printf '\033[32mEnvironment OK.\033[0m\n'
    exit 0
else
    printf '\033[31mEnvironment has issues — fix before proceeding.\033[0m\n'
    exit 1
fi
