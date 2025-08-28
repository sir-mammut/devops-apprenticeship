# Makefile (repo root)
export DOCKER_BUILDKIT ?= 1

SHELL := /bin/bash
.ONESHELL:
.DEFAULT_GOAL := help

APP_DIR   := app
IMAGE     := devops-apprentice-app
TAG       := latest
CONTAINER := devops-apprentice-container

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
	
# NEW: delegate new-day work to a script for reliability
new-day:   ## Create new day branch and journal file: make new-day DAY=02-bootstrap
ifndef DAY
	$(error "Please provide DAY argument, e.g. make new-day DAY=02-setup")
endif
	chmod +x ./scripts/new-day.sh
	./scripts/new-day.sh $(DAY)
