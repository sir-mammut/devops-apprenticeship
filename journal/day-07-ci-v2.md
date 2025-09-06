# Day 07 – CI v2: Build, Scan, Sign & Publish to GHCR 🔐🐳

**Date:** 2025-08-30  
**Day Branch:** `day-07-ci-v2`  
**Topic:** Container publishing to GHCR with security guardrails (Buildx cache, Trivy scan, Cosign signing, SBOM), Dependabot, and Makefile GHCR helpers

---

## 🎯 Goals

- [x] Build and **push Docker images** to **GitHub Container Registry (GHCR)** from CI.
- [x] Add **security gates** in CI: **Trivy** (fail on HIGH/CRITICAL), **Cosign** (keyless signing via OIDC), **SBOM** (Syft/SPDX).
- [x] Tag images with **latest**, **short SHA**, and **semver** on releases.
- [x] Configure **Dependabot** for npm (app) + GitHub Actions.
- [x] Harden the **Makefile** with robust **GHCR** helpers and eliminate token-splitting bugs in `docker buildx` args.

---

## ✅ What I Did

### 1) Release Workflow (CI v2)

Created `.github/workflows/release.yml` that:

- Uses **Buildx** and **GitHub cache** for faster builds.
- Generates multi-tags via `docker/metadata-action` (`latest`, `sha`, `vX.Y.Z`).
- On PRs: **build only**. On `main`/tags: **build + push** to GHCR.
- **Trivy** scans the built image (fail on HIGH/CRITICAL) and uploads a SARIF report.
- **Cosign** keyless signs images (no keys stored; uses GitHub OIDC).
- Generates an **SPDX SBOM** with Syft (Anchore action) and uploads as artifact.

### 2) Dependabot

Added `.github/dependabot.yml` to keep:

- **GitHub Actions** versions fresh.
- **npm** dependencies in `/app` up to date.

### 3) Makefile GHCR Targets

Refactored root `Makefile`:

- **No more split `-f app /Dockerfile`** nonsense — we `cd app` and build with context `.` to avoid path breakage on macOS/Make line wraps.
- Added `ghcr-login`, `ghcr-build`, `ghcr-push`, `ghcr-build-push`, `ghcr-run`, and optional `ghcr-scan`/`ghcr-sign`.
- Guarded `ghcr-push` to warn if the local tag doesn’t exist.

### 4) Publishing Flow

- For **local** pushes, used a **fine-grained PAT** with `packages:write`, loaded via `direnv` (no secrets committed).
- For **CI**, relied on built-in `GITHUB_TOKEN` + `id-token: write` for Cosign.

---

## 🛠 Commands I Ran

```bash
# New branch for day 7
git checkout -b day-07-ci-v2

# (Optional) local GHCR login (PAT stored via direnv in ~/.secrets/)
export GITHUB_TOKEN=<your_fine_grained_PAT_with_packages_write>
make ghcr-login OWNER=sir-mammut

# Build, tag, push locally (dev tag)
make ghcr-build OWNER=sir-mammut TAG=dev
make ghcr-push  OWNER=sir-mammut TAG=dev

# Or one-shot:
make ghcr-build-push OWNER=sir-mammut TAG=latest

# Validate the pushed image
docker pull ghcr.io/sir-mammut/devops-apprentice-app:latest
docker run -d --name app -p 3000:3000 ghcr.io/sir-mammut/devops-apprentice-app:latest
curl -sSf http://localhost:3000/health     # -> {"status":"ok"}

# Commit Day 7 work
git add .github/workflows/release.yml .github/dependabot.yml Makefile journal/day07.md
git commit -S -m "ci(day-07): GHCR publish + Trivy scan + Cosign sign + SBOM; Dependabot; Makefile GHCR helpers"
git push -u origin day-07-ci-v2
