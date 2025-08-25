#!/usr/bin/env bash
# scripts/asdf-install-latest.sh
# ------------------------------------------------------------
# Installs and pins latest stable versions for a small set of CLIs
# - terraform, kubectl, helm
# This is optional and safe to rerun.
# ------------------------------------------------------------
set -euo pipefail

die() { printf "❌ %s\n" "$1" >&2; exit 1; }
need() { command -v "$1" >/dev/null 2>&1 || die "Missing: $1"; }

need asdf

# Add plugin helper (only adds if missing)
add_plugin() {
  local name="$1"
  if ! asdf plugin list | grep -q "^${name}\$"; then
    asdf plugin add "$name"
  fi
}

# Plugins we want for the apprenticeship
add_plugin terraform
add_plugin kubectl
add_plugin helm

# Install latest for each plugin
for tool in terraform kubectl helm; do
  latest="$(asdf latest "$tool")"
  asdf install "$tool" "$latest"
  asdf global  "$tool" "$latest"
  printf "Pinned %s -> %s\n" "$tool" "$latest"
done

asdf reshim
asdf current
