#!/usr/bin/env bash
# scripts/new-day.sh
# -----------------------------------------------------------------------------
# Create a new "day" branch and a journal stub for the apprenticeship.
#
# Usage:
#   ./scripts/new-day.sh 02-bootstrap        # create branch day-02-bootstrap
#   ./scripts/new-day.sh 02                  # create branch day-02 (no slug)
#   ./scripts/new-day.sh 02-bootstrap --no-push
#
# Behavior:
# - Validates argument format (two-digit day optionally with -slug)
# - Creates or checks out the branch (handles local and remote branches)
# - Creates journal file: journal/day<NN>-<slug>.md  (or journal/day<NN>.md)
# - Commits the new journal file if it was created
# - By default pushes branch to origin; pass --no-push to skip push
#
# Safe: idempotent (won't overwrite an existing journal file), fails early with
# helpful errors, suitable for use in CI/Make orchestration.
# -----------------------------------------------------------------------------
set -euo pipefail

usage() {
  cat <<USG
Usage: $0 <NN[-slug]> [--no-push]

Examples:
  $0 02-bootstrap        # creates day-02-bootstrap branch and journal/day02-bootstrap.md, then push
  $0 03                  # creates day-03 branch and journal/day03.md, then push
  $0 04-helm --no-push   # create locally, do NOT push to origin

Notes:
 - <NN> must be two digits (01..30).
 - Optional slug should be lowercase, letters/numbers/dashes only.
USG
  exit 2
}

# ---- parse args ----
if [ "$#" -lt 1 ]; then
  usage
fi

ARG="$1"
shift

NO_PUSH=false
while [ "$#" -gt 0 ]; do
  case "$1" in
    --no-push) NO_PUSH=true; shift ;;
    -h|--help) usage ;;
    *) echo "Unknown option: $1"; usage ;;
  esac
done

# ---- validate arg pattern: NN or NN-slug ----
if [[ ! "$ARG" =~ ^([0-9]{2})(-([a-z0-9][a-z0-9-]*))?$ ]]; then
  echo "ERROR: Invalid day identifier. Expect NN or NN-slug (e.g. 02 or 02-bootstrap)."
  usage
fi

DAY_NUM="${BASH_REMATCH[1]}"      # e.g. "02"
SLUG="${BASH_REMATCH[3]-}"        # e.g. "bootstrap" or empty
BRANCH="day-${ARG}"               # day-02-bootstrap or day-02

# journal filename: if slug present -> day02-bootstrap.md else day02.md
if [ -n "$SLUG" ]; then
  JOURNAL_FILE="journal/day${DAY_NUM}-${SLUG}.md"
else
  JOURNAL_FILE="journal/day${DAY_NUM}.md"
fi

# ---- pre-checks ----
if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "ERROR: Not inside a git repository. Run this script from the repo root."
  exit 3
fi

# warn if working tree is dirty (optional - let user decide)
if [ -n "$(git status --porcelain)" ]; then
  echo "WARNING: Your working tree has uncommitted changes."
  echo "It's recommended to commit or stash before creating a day branch."
  echo "Continue in 3s or Ctrl-C to abort..."
  sleep 3
fi

# ---- create or switch to branch ----
# If local branch exists, just checkout it
if git show-ref --verify --quiet "refs/heads/${BRANCH}"; then
  echo "Local branch ${BRANCH} already exists — checking out"
  git checkout "${BRANCH}"
else
  # if remote branch exists, create local tracking branch
  if git ls-remote --exit-code --heads origin "${BRANCH}" >/dev/null 2>&1; then
    echo "Remote branch origin/${BRANCH} exists — creating local tracking branch"
    git fetch origin "${BRANCH}"
    git checkout -b "${BRANCH}" "origin/${BRANCH}"
  else
    echo "Creating new branch ${BRANCH}"
    git checkout -b "${BRANCH}"
  fi
fi

# ---- create journal if missing ----
if [ -f "${JOURNAL_FILE}" ]; then
  echo "Journal file ${JOURNAL_FILE} already exists — leaving untouched."
  CREATED=false
else
  mkdir -p "$(dirname "${JOURNAL_FILE}")"

  # Use a here-doc that expands variables (we want to inject DAY_NUM, BRANCH, DATE)
  DATE="$(date -I)"   # ISO date yyyy-mm-dd

  cat > "${JOURNAL_FILE}" <<EOF
# Day ${DAY_NUM} – DevOps Apprenticeship

**Date:** ${DATE}  
**Day Branch:** \`${BRANCH}\`  
**Topic:** [Short title — fill this in]

---

## 🎯 Goals for today
- [ ] Goal 1
- [ ] Goal 2

## ✅ What I did
- Brief bullet list of actions you took today.

## 🛠 Commands & snippets I ran
\`\`\`bash
# Example:
# make preflight
# make app-build
\`\`\`

## 📝 Notes, obstacles & fixes
- Document what failed and how you fixed it.

## ✅ Acceptance criteria
- [ ] Local `make preflight` passes
- [ ] Image builds successfully with `make app-build`
- [ ] Journal updated with screenshots/links as needed

## 🔮 Next steps (preview)
- Next day focus and tasks
EOF

  echo "Created journal stub: ${JOURNAL_FILE}"
  CREATED=true
fi

# ---- commit the new journal (only if we created it) ----
if [ "${CREATED}" = true ]; then
  git add "${JOURNAL_FILE}"
  # Use conventional commit message with day tag
  git commit -m "chore(${BRANCH}): create journal stub"
  echo "Committed ${JOURNAL_FILE}"
else
  echo "No changes to commit."
fi

# ---- push to origin (unless --no-push) ----
if [ "${NO_PUSH}" = false ]; then
  # push new branch only if remote origin exists
  if git remote | grep -q '^origin$'; then
    echo "Pushing branch ${BRANCH} to origin..."
    # push and set upstream if new branch
    git push -u origin "${BRANCH}"
    echo "Pushed ${BRANCH}"
  else
    echo "No origin remote configured — skipping push."
  fi
else
  echo "Skipping push (user requested --no-push)."
fi

echo "Done. Journal file: ${JOURNAL_FILE}  | branch: ${BRANCH}"
