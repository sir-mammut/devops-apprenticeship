# Day 03 – Git Discipline & Commit Signing 🔐

**Date:** 2025-08-26  
**Day Branch:** `day-03-git`  
**Topic:** Conventional Commits, repo hygiene, commit signing, PR workflow

---

## 🎯 Goals

- [x] Add `.gitignore` rules to keep repo clean (ignore `.vscode/`, `node_modules/`, logs, etc.).
- [x] Add `.github/CODEOWNERS` to set `@sir-mammut` as default reviewer.
- [x] Implement `.githooks/commit-msg` to enforce Conventional Commits format.
- [x] Generate and configure a GPG key for commit signing on macOS.
- [x] Make a signed Conventional Commit on branch `day-03-git`.
- [x] Open a PR and squash merge into `main`.

---

## ✅ What I Did

- **Repository Hygiene**

  - Updated root `.gitignore` to exclude `.vscode/`, `.DS_Store`, `node_modules/`, `logs/`, and `*.log`.
  - This prevents clutter and keeps only relevant files in version control.

- **Code Ownership**

  - Created `.github/CODEOWNERS` with:

    ```text
    * @sir-mammut
    ```

  - Ensures all PRs automatically request `@sir-mammut` as a reviewer.

- **Commit Discipline (Hooks)**

  - Added `.githooks/commit-msg` enforcing Conventional Commits format:
    - Example: `feat(repo): add commit hook`
    - Blocks invalid messages like `Update file` or `bad commit`.
  - Activated with:

    ```bash
    git config core.hooksPath .githooks
    chmod +x .githooks/commit-msg
    ```

- **GPG Commit Signing**

  - Installed GnuPG (`brew install gnupg pinentry-mac`).
  - Generated a new RSA 4096 key (`gpg --full-generate-key`).
  - Exported public key and added it to GitHub (Settings → SSH & GPG Keys).
  - Configured Git:

    ```bash
    git config --global user.signingkey <KEYID>
    git config --global commit.gpgSign true
    ```

  - Verified locally with:

    ```bash
    git log --show-signature -1
    ```

    → Shows **Good signature from "Muh'd Hamisu <muhd.hamisu03@gmail.com>"**.

  - Verified on GitHub with green **Verified** badge.

- **Squash Merge Workflow**

  - Created branch `day-03-git`.
  - Committed changes with:

    ```bash
    git commit -m "feat(repo): enforce commit conventions and add codeowners [Day 3]"
    ```

  - Pushed branch and opened PR with `journal/day03.md` as body.
  - Squash-merged PR → now `main` has one clean commit for Day 3’s work.

---

## 🛠 Commands I Ran

```bash
# Create branch for Day 3
git checkout -b day-03-git

# Stage new files
git add .gitignore .github/CODEOWNERS .githooks/commit-msg journal/day03.md

# Signed commit with Conventional Commit format
git commit -m "feat(repo): enforce commit conventions and add codeowners [Day 3]"

# Verify signature
git log --show-signature -1

# Push branch and create PR
git push -u origin day-03-git
gh pr create --title "day-03: Git discipline & signing" --body-file journal/day03.md --base main

# Merge with squash
gh pr merge --squash --delete-branch
```
