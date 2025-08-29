# Day 05 – Reproducible Workflows & Tooling Discipline 🛠️

**Date:** 2025-08-28  
**Day Branch:** `day-05-reproducible-env`  
**Topic:** asdf version pinning, direnv auto-env, Makefile CI targets

---

## 🎯 Goals

- [x] Pin **tool versions** (Node.js, jq) in `.tool-versions` using `asdf`.
- [x] Automate environment setup with **direnv** and `.envrc`.
- [x] Add Makefile targets for **`ci`**, **`lint`**, **`test`**, and **`clean`**.
- [x] Ensure CI pipeline runs the **same steps** as local `make ci`.
- [x] Fix ESLint config to properly handle Node.js globals and ESM.

---

## ✅ What I Did

- **Toolchain Pinning:**

  - Added `.tool-versions` with Node.js `18.16.0` and `jq 1.6`.
  - Installed via `asdf install`. Now any developer or CI run gets the **exact same versions** .

- **Environment Automation:**

  - Created `.envrc` that:
    - Runs `use asdf` to auto-load pinned tools.
    - Exports `NODE_ENV`, `IMAGE`, and `TAG`.
  - Ran `direnv allow` → Now simply `cd` into the repo and the environment is loaded automatically.

- **Makefile Enhancements:**

  - Added `make ci` to run: `clean → deps → lint → test → build`.
  - Added `make deps` for deterministic `npm ci` installs.
  - Updated `make lint` and `make test` to only run if scripts exist in `app/package.json`, skipping gracefully otherwise.
  - Builds Docker image with `${IMAGE}:${TAG}`, defaulting to `devops-apprentice-app:dev`.

- **ESLint Setup:**

  - Fixed `.eslintrc.cjs` to enable Node globals (`process`) and ignore config files.
  - Converted `server.js` to **ESM (`import`)** to align with modern Node and linter rules.
  - Lint now passes with Node globals recognized, no false positives.

- **CI Workflow Update:**
  - Added `.github/workflows/ci.yml` using `asdf-vm/actions/install@v4`.
  - The workflow installs all tools from `.tool-versions`.
  - Runs `make ci` as a single source of truth.
  - CI environment matches local development — no more “works on my machine” issues .

---

## 🛠 Commands I Ran

```bash
# Pin and install tools
asdf plugin-add nodejs
asdf plugin-add jq
asdf install

# Approve direnv
direnv allow

# Run full CI flow locally
make ci IMAGE=devops-apprentice-app TAG=dev

# Lint (after fixing config)
npm --prefix app run lint

# Git flow
git checkout -b day-05-reproducible-env
git add .tool-versions .envrc Makefile .github/workflows/ci.yml journal/day05.md
git commit -S -m "ci(repro): asdf+direnv pinned tooling; add make ci; add CI workflow [Day 5]"
git push -u origin day-05-reproducible-env
```
