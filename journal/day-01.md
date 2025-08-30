# Day 01 – DevOps Apprenticeship 🚀

**Date:** 2025-08-24
**Topic:** Introduction, Git, SSH Setup, and Repo Initialization

---

## 🎯 Goals for Today

- Understand what DevOps really means (beyond buzzwords).
- Install and configure essential tools: Git, Docker, VS Code.
- Generate SSH keys for GitHub authentication.
- Create the `devops-apprenticeship` repo with a professional `README.md`.

---

## 📚 What I Learned

1. **DevOps Mindset**
   - DevOps isn’t just tools. It’s **culture + practices + automation**.
   - The goal is faster, reliable software delivery through **collaboration and automation**.

2. **Tooling Setup**
   - Installed Git for version control.
   - Installed Docker for containerization (will be used daily).
   - Setup VS Code as my IDE.

3. **SSH Authentication**
   - Generated SSH keys (`ed25519` algorithm).
   - Stored keys at `~/.ssh/id_ed25519` (private) and `~/.ssh/id_ed25519.pub` (public).
   - Added public key to GitHub → Settings → SSH and GPG keys.
   - Verified connection using:

     ```bash
     ssh -T git@github.com
     ```

4. **Repo Initialization**
   - Created GitHub repo: `devops-apprenticeship`.
   - Wrote `README.md` describing apprenticeship purpose, roadmap, and ground rules.

---

## 🛠️ Commands & Configurations Used

```bash
# Generate SSH key
ssh-keygen -t ed25519 -C "your_email@example.com"

# Copy public key to clipboard (macOS)
pbcopy < ~/.ssh/id_ed25519.pub

# Test GitHub connection
ssh -T git@github.com

# Initialize repo
git init
git remote add origin git@github.com:sir-mammut/devops-apprenticeship.git
git add .
git commit -m "chore: initial commit with README"
git push -u origin main
```

---

## ✅ Achievements

- GitHub repo is live and public.
- SSH authentication works.
- Documentation (`README.md`)
- Day 1 log file (`day01.md`) created.

---

## 🤔 Reflections

- Key insight: DevOps is more about **principles and culture** than shiny tools.
- Next time, I’ll automate my environment setup (Makefile / script).
- Excited for Docker deep dive tomorrow.

---

## 🔮 Next Steps (Day 2 Preview)

- Learn Docker basics: images, containers, volumes.
- Build and run a simple container.
- Document Docker workflow in `day02.md`.

---

⚡ _This marks the official start of my 30-day DevOps Apprenticeship. One day down, twenty-nine to go._
