# Day 02 – macOS Bootstrap, Preflight Checks & Project Tooling

**Date:** 2025-08-25  
**Day Branch:** `day-02-bootstrap`  
**Topic:** Environment bootstrap, reproducibility, preflight validation, Makefile orchestration

---

## 🎯 Goals

- [x] Set up an idempotent macOS bootstrap script (Homebrew, Colima, Docker CLI, direnv, asdf).
- [x] Add a preflight check script to validate toolchain before development.
- [x] Add root `Makefile` for reproducible app lifecycle (`app-build`, `app-run`, `app-health`, etc).
- [x] Configure `.envrc` for project-scoped environment variables.
- [x] Automate journal stub/branch creation with `scripts/new-day.sh`.

---

## ✅ What I did

- Wrote **`scripts/bootstrap-macos.sh`**: installs core CLIs (git, jq, yq, colima, docker, direnv, asdf), ensures Colima VM is running, and validates Docker connectivity.
- Wrote **`scripts/preflight-checks.sh`**: defensive sanity checks (CLIs, Colima running, Docker reachable, BuildKit available, GitHub network reachability).
- Created **root `Makefile`**: orchestrates bootstrap, preflight, Colima lifecycle, and Node app lifecycle (`app-build`, `app-run`, `app-health`, `app-logs`, `app-stop`).
- Added **`.envrc`** for safe environment defaults (NODE_ENV, image/tag vars).
- Wrote **`scripts/new-day.sh`**: scaffolds new day branch + journal stub (Conventional Commits + branch discipline).
- Verified full lifecycle: `make bootstrap`, `source ~/.zshrc`, `direnv allow`, `make preflight`, `make app-build`, `make app-run`, `make app-health`, `make app-logs`, `make app-stop` → all passed.
- Documented everything in this journal for reproducibility and recruiter-facing proof.

---

## 🛠 Commands I ran

```bash
make bootstrap
source ~/.zshrc
direnv allow
make preflight

make app-build
make app-run
make app-health && echo "APP OK"
make app-logs   # (Ctrl+C to exit)
make app-stop

./scripts/new-day.sh 02-bootstrap --no-push   # branch+stub automation
```
