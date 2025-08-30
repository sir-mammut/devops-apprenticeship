# Makefile (repo root)
export DOCKER_BUILDKIT ?= 1

SHELL := /bin/bash
.ONESHELL:
.DEFAULT_GOAL := help

APP_DIR   := app
IMAGE     := devops-apprentice-app
TAG       := latest
CONTAINER := devops-apprentice-container

NPM     := npm --prefix $(APP_DIR)

.PHONY: ci lint test build clean

help:    ## Show this help (default)
	@awk 'BEGIN {FS":.*?#"} /^[a-zA-Z0-9_.-]+:.*?#/ { printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2 }' $(MAKEFILE_LIST)

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

app-build:  ## Build Docker image from ./app
	@echo "Building Docker image with Buildx..."
	docker buildx build --load -t $(IMAGE):$(TAG) $(APP_DIR)

app-run:    ## Run the app container (detached)
	-docker stop $(CONTAINER) 2>/dev/null || true
	-docker rm $(CONTAINER) 2>/dev/null || true
	docker run -d --name $(CONTAINER) -p 3000:3000 $(IMAGE):$(TAG)

app-logs:   ## Tail logs from the running app (Ctrl+C to stop)
	docker logs -f $(CONTAINER)

app-health: ## Health check the running app (expects /health)
	curl -sf http://localhost:3000/health || (echo "❌ Health check failed" && exit 1)

app-stop:   ## Stop & remove the app container
	docker stop $(CONTAINER) 2>/dev/null || true
	docker rm $(CONTAINER) 2>/dev/null || true
docker-lint:
	@docker run --rm -i hadolint/hadolint < app/Dockerfile

# Run all CI steps: lint, test, and build (in that order)
ci: clean deps lint test build
	@echo "✅ CI workflow completed successfully."

deps:
	@echo "→ Installing deps in $(APP_DIR)…"
	@if [ -f $(APP_DIR)/package-lock.json ]; then \
		$(NPM) ci; \
	else \
		$(NPM) install; \
	fi

# Lint the code (example: run ESLint for JS, or other linters)
lint:
	@echo "→ Linting…"
	@if [ -f $(APP_DIR)/package.json ] && grep -q '"lint" *:' $(APP_DIR)/package.json; then \
		$(NPM) run lint; \
	else \
		echo "ℹ️  No lint script found; skipping"; \
	fi

# Run tests (example command, could be a test framework like Jest or Mocha for Node.js)
test:
	@echo "→ Testing…"
	@if [ -f $(APP_DIR)/package.json ] && grep -q '"test" *:' $(APP_DIR)/package.json; then \
		NODE_ENV=test $(NPM) test; \
	else \
		echo "ℹ️  No test script found; skipping"; \
	fi

# Build the Docker image using the IMAGE and TAG from environment
build:
	@echo "→ Building Docker image $(IMAGE):$(TAG)..."
	docker build -t $(IMAGE):$(TAG) $(APP_DIR)

# Clean up build artifacts to ensure a fresh state
clean:
	@echo "→ Cleaning project…"
	rm -rf $(APP_DIR)/node_modules $(APP_DIR)/dist || true
	docker image rm -f $(IMAGE):$(TAG) 2>/dev/null || true

format:        ## Format code with Prettier
	npx prettier --write .

test:          ## Run Jest test suite
	npx jest --coverage

quality:       ## Run all quality checks (format, lint, test)
	npx prettier --check . && npx eslint . && npx jest

# NEW: delegate new-day work to a script for reliability
new-day:   ## Create new day branch and journal file: make new-day DAY=02-bootstrap
ifndef DAY
	$(error "Please provide DAY argument, e.g. make new-day DAY=02-setup")
endif
	chmod +x ./scripts/new-day.sh
	./scripts/new-day.sh $(DAY)
