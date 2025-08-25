#!/usr/bin/env bash
# scripts/bootstrap-macos.sh
# ------------------------------------------------------------
# Idempotent macOS bootstrap for this apprenticeship repo
# - installs Homebrew if missing
# - installs a set of CLI packages (brew)
# - installs container runtime (Colima + Docker CLI)
# - installs direnv & asdf
# - starts Colima if it's not already running
# This script is safe to re-run multiple times.
# ------------------------------------------------------------
set -euo pipefail

# Utility functions
log()    { printf "➡️  %s\n" "$1"; }
ok()     { printf "✅ %s\n" "$1"; }
die()    { printf "❌ %s\n" "$1" >&2; exit 1; }

# Check macOS
if [[ "$(uname -s)" != "Darwin" ]]; then
  die "This bootstrap script is macOS-only. Running on $(uname -s)."
fi

# Install Homebrew if missing
if ! command -v brew >/dev/null 2>&1; then
  log "Homebrew not found — installing Homebrew. This will prompt for your password."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  # Ensure brew is on PATH for the rest of the script (Apple Silicon vs Intel)
  eval "$(/opt/homebrew/bin/brew shellenv)" 2>/dev/null || true
  ok "Homebrew installed"
else
  ok "Homebrew already installed"
fi

# Helper: brew install formula if missing
brew_install() {
  local pkg="$1"
  if brew list --formula | grep -q "^${pkg}\$"; then
    ok "$pkg (already installed)"
  else
    log "Installing $pkg"
    brew install "$pkg"
  fi
}

log "Installing core developer tooling (may take a few minutes)..."
brew_install git
brew_install make
brew_install jq
brew_install yq
brew_install coreutils
brew_install gnu-sed
brew_install findutils
brew_install gawk
brew_install curl
brew_install wget

log "Installing container tooling..."
brew_install colima
brew_install docker
brew_install docker-buildx

log "Installing environment managers..."
brew_install direnv
brew_install asdf

# Ensure Colima is running (start if not)
if colima status >/dev/null 2>&1; then
  ok "Colima status: running"
else
  log "Starting Colima..."
  # Recommended minimal resources for local dev
  colima start --cpu 2 --memory 4 --disk 20
  ok "Colima started"
fi

# Verify Docker CLI can reach daemon
if docker version >/dev/null 2>&1; then
  ok "Docker CLI can reach daemon"
else
  die "Docker CLI failed to reach daemon. Ensure Colima is running."
fi

ok "Bootstrap complete — recommended: run 'make preflight' and add direnv hook to your shell."
