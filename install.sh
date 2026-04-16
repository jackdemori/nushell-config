#!/usr/bin/env bash
#
# One-shot bootstrap. Downloads this nushell config from GitHub and invokes
# setup.nu to wire it into the current machine.
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/jackdemori/nushell-config/main/install.sh | bash
#
# Prerequisites on the target machine:
#   - Homebrew installed
#   - nushell installed (`brew install nushell`)

set -euo pipefail

REPO="jackdemori/nushell-config"
BRANCH="main"
TARGET="$HOME/.config/nushell"
ARCHIVE_URL="https://github.com/${REPO}/archive/${BRANCH}.tar.gz"

# Colors
GREEN=$'\e[1;32m'
YELLOW=$'\e[1;33m'
RED=$'\e[1;31m'
CYAN=$'\e[36m'
RESET=$'\e[0m'

ok()   { printf '%s✓%s  %s\n' "$GREEN"  "$RESET" "$*"; }
warn() { printf '%s⚠%s  %s\n' "$YELLOW" "$RESET" "$*"; }
fail() { printf '%s✗%s  %s\n' "$RED"    "$RESET" "$*" >&2; exit 1; }
note() { printf '%s%s%s\n'    "$CYAN"   "$*"     "$RESET"; }

# Prereqs
# Platform check — this installer is macOS-only.
[ "$(uname -s)" = "Darwin" ] || fail "this installer is macOS-only (detected: $(uname -s))"

command -v nu    >/dev/null 2>&1 || fail "nushell not installed. Run: brew install nushell"
command -v curl  >/dev/null 2>&1 || fail "curl not found"
command -v tar   >/dev/null 2>&1 || fail "tar not found"
command -v rsync >/dev/null 2>&1 || fail "rsync not found"

# If $TARGET is a git checkout, pull. Otherwise (missing, or a tarball
# install from an earlier run), download a fresh tarball and rsync it in.
if [ -d "$TARGET/.git" ]; then
    command -v git >/dev/null 2>&1 || fail "git not found — needed to update an existing checkout"
    note "updating existing git checkout at $TARGET..."
    git -C "$TARGET" pull --ff-only origin "$BRANCH"
    ok "pulled latest ${BRANCH}"
else
    tmp="$(mktemp -d)"
    trap 'rm -rf "$tmp"' EXIT

    note "downloading ${REPO}@${BRANCH}..."
    curl -fsSL "$ARCHIVE_URL" | tar -xz -C "$tmp"

    src="$(find "$tmp" -maxdepth 1 -mindepth 1 -type d | head -n 1)"
    [ -d "$src" ] || fail "archive extraction failed (no extracted directory found)"

    # Mirror the source into target: copy new, overwrite changed, and delete
    # anything the repository no longer contains. `.git`, `.claude`, and
    # `.DS_Store` are excluded so genuinely local state is preserved.
    mkdir -p "$TARGET"
    rsync -a --delete \
        --exclude='.git' \
        --exclude='.claude' \
        --exclude='.DS_Store' \
        "$src/" "$TARGET/"
    ok "synced to $TARGET"
fi

# Hand off to nushell setup (idempotent — safe to re-run).
note "running setup.nu..."
exec nu "$TARGET/setup.nu"
