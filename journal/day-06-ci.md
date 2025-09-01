# Day 06 – CI Pipeline & Code Quality 🤖

**Date:** 2025-08-29  
**Day Branch:** `day-06-ci`  
**Topic:** GitHub Actions CI, Prettier, ESLint, Jest

---

## 🎯 Goals

- [x] Install and configure **Prettier** (formatting) and **Jest** (testing).
- [x] Ensure ESLint + Prettier play nicely (no rule conflicts).
- [x] Add a Jest config with Node test environment.
- [x] Extend Makefile with `format`, `lint`, `test`, `quality` targets.
- [x] Update CI workflow (`ci.yml`) to enforce quality gates.
- [x] Add dependency caching to CI.
- [x] Verify pipeline runs green in GitHub Actions.

---

## ✅ What I Did

- **Prettier Setup:**
  - Installed Prettier as a dev dependency in `app/`.
  - Added `.prettierrc` with formatting rules (`singleQuote`, `trailingComma`).
  - Extended ESLint config with `eslint-config-prettier`【Prettier docs】 so ESLint stops complaining about stylistic issues Prettier fixes automatically.
  - Added `"format": "prettier --write ."` to `package.json` scripts.

- **Jest Setup:**
  - Installed Jest as a dev dependency.
  - Created `jest.config.js` with `testEnvironment: "node"` and `verbose: true`.
  - Added `"test": "jest --coverage"` to `package.json`.
  - Verified with a dummy test in `app/__tests__/`.

- **Makefile Enhancements:**
  - Added `make format`, `make lint`, `make test`, and `make quality`.
  - `make quality` runs Prettier in **check mode**, ESLint, and Jest in sequence.
  - Now a single command runs all quality gates locally and in CI.

- **CI Workflow Update:**
  - Edited `.github/workflows/ci.yml` to add jobs: `format`, `lint`, `test`, and `build`.
  - Each job sets up Node 18, installs deps with `npm ci`, restores cache for speed.
  - `format` runs `npm run format -- -c` (Prettier check).
  - `lint` runs ESLint.
  - `test` runs Jest with coverage.
  - `build` (Docker image) only runs if all quality checks pass.
  - Uploaded Docker image artifact as `.tar` (for later deployment stages).

---

## 🛠 Commands I Ran

```bash
# Install Prettier, Jest, ESLint-Prettier
npm --prefix app install -D prettier jest eslint-config-prettier

# Add config files
echo '{ "singleQuote": true, "trailingComma": "es5" }' > .prettierrc
echo "module.exports = { testEnvironment: 'node', verbose: true };" > jest.config.js

# Run quality checks locally
npx prettier --write .
npx eslint .
npm --prefix app test -- --coverage

# Makefile shortcut
make quality

# Git workflow
git checkout -b day-06-ci
git add .
git commit -S -m "ci: add linting, formatting, and testing pipeline [Day 6]"
git push -u origin day-06-ci
```
