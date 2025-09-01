# Day 04 – Containers Deep Dive 🐳

**Date:** 2025-08-27  
**Day Branch:** `day-04-containers`  
**Topic:** Multi-stage Docker builds, BuildKit/Buildx, CI workflow integration

---

## 🎯 Goals

- [x] Understand Docker multi-stage builds and why they matter.
- [x] Refactor `app/Dockerfile` for production-ready builds:
  - Split into builder + runtime stages.
  - Use slim base image.
  - Prune dev dependencies.
- [x] Enable BuildKit/Buildx both locally and in GitHub Actions.
- [x] Implement caching of Docker layers for faster CI builds.
- [x] Validate image health with `docker history` and image size check.
- [x] Extend `pr-check.yml` CI workflow to build, lint, and inspect images.

---

## ✅ What I Did

- **Dockerfile Refactor:**  
  Converted to a two-stage build:
  1. `builder` stage installs all deps, runs build, then prunes to prod-only.
  2. `runtime` stage uses `node:18-slim` and copies the pruned `/app`.  
     This reduced the final image size and eliminated dev-only artifacts.

- **BuildKit & Buildx:**
  - Enabled `DOCKER_BUILDKIT=1` in Makefile and CI.
  - Used `docker buildx build` for modern, parallelized builds.
  - Confirmed local builds worked with Colima (on macOS).

- **Layer Caching in CI:**  
  Added GitHub Actions caching around `.buildx-cache`.  
  Subsequent PR builds reuse unchanged layers (e.g., `npm ci`), reducing build times significantly.

- **Image Validation:**
  - Integrated **Hadolint** to lint Dockerfile best practices.
  - Used `docker history` to confirm only necessary layers remain.
  - Logged final image size to verify slimming worked.

- **CI Workflow Update:**  
  Extended `.github/workflows/pr-check.yml` to:
  - Run `make preflight`.
  - Build with Buildx + caching.
  - Run Dockerfile lint.
  - Inspect layers + print final image size.
  - Cleanup Colima VM after job.

---

## 🛠 Commands I Ran

```bash
# Build locally with BuildKit
DOCKER_BUILDKIT=1 docker build -t devops-app:latest ./app

# Run container & test /health
docker run -d --name devops-app -p 3000:3000 devops-app:latest
curl -sf http://localhost:3000/health && echo "OK"

# Inspect layers and size
docker history --no-trunc devops-app:latest
docker image ls devops-app:latest

# Clean up
docker stop devops-app && docker rm devops-app
```
