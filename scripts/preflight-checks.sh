#!/usr/bin/env bash
# scripts/preflight-checks.sh
# ------------------------------------------------------------
# Sanity checks before running local dev tasks
# Exits non-zero on failure with actionable messages.
# ------------------------------------------------------------
set -euo pipefail

die()  { printf "❌ %s\n" "$1" >&2; exit 1; }
ok()   { printf "✅ %s\n" "$1"; }

# Program existence check
need() {
  if ! command -v "$1" >/dev/null 2>&1; then
    die "Required command not found: $1"
  fi
}

printf "Running preflight checks...\n"

# Required CLIs for this repo
for cmd in git make docker colima jq yq; do
  need "$cmd"
done
ok "CLI binaries: present"

# ---- Colima status check (robust, case-insensitive) ----
# We capture the status output (stdout+stderr) and inspect it for the words
# 'running' or 'started' (case-insensitive). This is more tolerant of
# colima output format changes across versions.
COLIMA_STATUS="$(colima status 2>&1 || true)"
# (optional) echo the status for debugging but don't treat as failure yet
# printf "%s\n" "$COLIMA_STATUS" | sed -n '1,6p'

# Look for common indicators of running state
if echo "$COLIMA_STATUS" | grep -Eiq 'running|started'; then
  ok "Colima: running"
else
  die "Colima is not running. Start it with: colima start"
fi

# Docker connectivity
if docker info >/dev/null 2>&1; then
  ok "Docker daemon: reachable"
else
  die "Docker daemon not reachable (check Colima)"
fi

# Buildx check (BuildKit recommended)
if docker buildx version >/dev/null 2>&1; then
  ok "docker buildx (BuildKit): available"
else
  die "docker buildx not found. Install 'docker-buildx' via brew or enable BuildKit."
fi

# Network sanity: can reach GitHub (used by some install scripts)
if curl -I -s https://github.com >/dev/null 2>&1; then
  ok "Network: reachable (github.com)"
else
  die "Network: failed to reach github.com"
fi

ok "All preflight checks passed."
