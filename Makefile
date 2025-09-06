# ==============================================================================
# Makefile (repo root) — Day 7 ready
# - Local dev lifecycle (format/lint/test/build/run)
# - GHCR helpers (login, build, push, run)
# - Defensive (skips optional tools if not installed)
# - Uses BuildKit/Buildx everywhere
# ==============================================================================

export DOCKER_BUILDKIT ?= 1

SHELL := /bin/bash
.ONESHELL:
.DEFAULT_GOAL := help

# ---------------------------- Paths & Names -----------------------------------
APP_DIR        := app                      # where Dockerfile + Node app live

# Local image (for dev)
IMAGE          := devops-apprentice-app
TAG            := latest
FULL_IMAGE     := $(IMAGE):$(TAG)

# Registry image (for publish)
REGISTRY       ?= ghcr.io
# Extract owner from git remote (works with ssh/https remotes)
# OWNER          ?= $(shell git remote get-url origin 2>/dev/null | sed -E 's#.*[:/](.+)/.+\.git#\1#')
OWNER          ?= $(shell git remote get-url origin 2>/dev/null | sed 's/.*github.com[:/]\([^/]*\).*/\1/')
REMOTE_IMAGE   := $(REGISTRY)/$(OWNER)/$(IMAGE):$(TAG)

DOCKERFILE := $(APP_DIR)/Dockerfile
CONTEXT    := $(APP_DIR)

# npm helper (run inside app/)
NPM            := npm --prefix $(APP_DIR)

# ---------------------------- Help --------------------------------------------
.PHONY: help
help:    ## Show this help (default)
	@awk 'BEGIN {FS":.*?#"} /^[a-zA-Z0-9_.-]+:.*?#/ { printf "  \033[36m%-22s\033[0m %s\n", $$1, $$2 }' $(MAKEFILE_LIST)

# ---------------------------- Bootstrap & Checks ------------------------------
.PHONY: bootstrap preflight colima-up colima-down
bootstrap:  ## Install Homebrew packages and start Colima (macOS)
	chmod +x ./scripts/bootstrap-macos.sh
	./scripts/bootstrap-macos.sh

preflight:  ## Run preflight checks (ensures toolchain & docker ready)
	chmod +x ./scripts/preflight-checks.sh
	./scripts/preflight-checks.sh

colima-up:   ## Start Colima VM (no-op if running)
	colima start --cpu 2 --memory 4 --disk 20 || true

colima-down: ## Stop Colima
	colima stop || true

# ---------------------------- App lifecycle -----------------------------------
.PHONY: deps format format-check lint test quality clean \
        app-build app-run app-logs app-health app-stop docker-lint

deps:        ## Install Node deps in ./app (ci if lockfile present)
	@echo "→ Installing deps in $(APP_DIR)…"
	@if [ -f $(APP_DIR)/package-lock.json ]; then \
		$(NPM) ci; \
	else \
		$(NPM) install; \
	fi

format:      ## Format code with Prettier (writes changes)
	$(NPM) run format

format-check: ## Verify formatting (CI-safe)
	$(NPM) run format:check

lint:        ## Lint code with ESLint
	$(NPM) run lint

test:        ## Run Jest tests with coverage
	NODE_ENV=test $(NPM) run test

quality:     ## All quality gates: format-check → lint → test
	$(MAKE) format-check
	$(MAKE) lint
	$(MAKE) test

# app-build:   ## Build local image with Buildx (loads into Docker)
# 	@echo "→ Building local image $(FULL_IMAGE)…"
# 	docker buildx build --load -t $(FULL_IMAGE) -f $(APP_DIR)/Dockerfile $(APP_DIR)

app-build:
	@echo "→ Building local image devops-apprentice-app:latest…"
	docker buildx build --load -t devops-apprentice-app:latest -f app/Dockerfile app

app-run:     ## Run the app container (detached)
	-docker stop $(IMAGE) 2>/dev/null || true
	-docker rm $(IMAGE) 2>/dev/null || true
	docker run -d --name $(IMAGE) -p 3000:3000 $(FULL_IMAGE)

app-logs:    ## Tail logs from running app (Ctrl+C to exit)
	docker logs -f $(IMAGE)

app-health:  ## Health check the running app (expects /health)
	curl -sf http://localhost:3000/health || (echo "❌ Health check failed" && exit 1)

app-stop:    ## Stop & remove the app container
	-docker stop $(IMAGE) 2>/dev/null || true
	-docker rm $(IMAGE) 2>/dev/null || true

docker-lint: ## Lint Dockerfile with hadolint (skips if not installed)
	@if command -v hadolint >/dev/null 2>&1; then \
	  hadolint $(APP_DIR)/Dockerfile; \
	else \
	  echo "ℹ️ hadolint not installed; skipping (install with: brew install hadolint)"; \
	fi

clean:       ## Clean node_modules, dist, and local image tag
	@echo "→ Cleaning project…"
	rm -rf $(APP_DIR)/node_modules $(APP_DIR)/dist || true
	-docker image rm -f $(FULL_IMAGE) 2>/dev/null || true

# ---------------------------- Local CI convenience ----------------------------
.PHONY: ci build
ci: clean deps quality app-build  ## Local CI: clean → deps → quality → build
	@echo "✅ Local CI completed."

build:       ## Alias: build local Docker image
	$(MAKE) app-build

# ---------------------------- GHCR helpers (Day 7) ----------------------------
.PHONY: meta ghcr-login ghcr-build ghcr-push ghcr-build-push ghcr-run ghcr-scan ghcr-sign

meta:        ## Print computed image names/vars
	@echo "REGISTRY     = $(REGISTRY)"
	@echo "OWNER        = $(OWNER)"
	@echo "LOCAL IMAGE  = $(FULL_IMAGE)"
	@echo "REMOTE IMAGE = $(REMOTE_IMAGE)"

ghcr-login:  ## Login to GHCR using $$GITHUB_TOKEN (packages:write)
	@if [ -z "$$GITHUB_TOKEN" ]; then \
	  echo "❌ Set GITHUB_TOKEN env var (PAT with packages:write)"; exit 1; \
	fi
	echo "$$GITHUB_TOKEN" | docker login $(REGISTRY) -u $(OWNER) --password-stdin

ghcr-build:  ## Build registry-tagged image (loads locally)
	cd $(APP_DIR) && docker buildx build --load -t $(REMOTE_IMAGE) .

ghcr-push:   ## Push the previously built tag to GHCR
	docker push $(REMOTE_IMAGE)

ghcr-build-push: ## One-shot build & push with Buildx
	$(MAKE) ghcr-login
	docker buildx build --push \
	  -t $(REMOTE_IMAGE) \
	  -f $(APP_DIR)/Dockerfile $(APP_DIR)

ghcr-run:    ## Run the GHCR image and check /health
	-docker rm -f $(IMAGE) 2>/dev/null || true
	docker run -d --name $(IMAGE) -p 3000:3000 $(REMOTE_IMAGE)
	sleep 1 && curl -sf http://localhost:3000/health && echo " OK"

ghcr-scan:   ## Trivy scan the REMOTE image (skips if not installed)
	@if command -v trivy >/dev/null 2>&1; then \
	  trivy image --ignore-unfixed --severity HIGH,CRITICAL $(REMOTE_IMAGE); \
	else \
	  echo "ℹ️ trivy not installed; skipping (brew install trivy)"; \
	fi

ghcr-sign:   ## Cosign sign the REMOTE image tag (skips if not installed)
	@if command -v cosign >/dev/null 2>&1; then \
	  COSIGN_EXPERIMENTAL=1 cosign sign --yes $(REMOTE_IMAGE); \
	else \
	  echo "ℹ️ cosign not installed; skipping (brew install cosign)"; \
	fi

# ---------------------------- Journal scaffold --------------------------------
.PHONY: new-day
new-day:   ## Create new day branch and journal file: make new-day DAY=02-bootstrap
ifndef DAY
	$(error "Please provide DAY argument, e.g. make new-day DAY=02-setup")
endif
	chmod +x ./scripts/new-day.sh
	./scripts/new-day.sh $(DAY)
