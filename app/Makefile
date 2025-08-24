# app/Makefile
# ---------------------------------------------
# Automation for Docker workflow
# ---------------------------------------------

APP_NAME=devops-apprentice-app
APP_TAG=latest

# Build Docker image
build:
	docker build -t $(APP_NAME):$(APP_TAG) .

# Run container (detached mode)
run:
	docker run -d -p 3000:3000 --name $(APP_NAME) $(APP_NAME):$(APP_TAG)

# Stop & remove container
stop:
	docker stop $(APP_NAME) || true && docker rm $(APP_NAME) || true

# Health check (curl endpoint inside container)
health:
	curl -f http://localhost:3000/health || (echo "❌ Health check failed" && exit 1)

# Clean all images (dangerous in real projects!)
clean:
	docker rmi -f $(APP_NAME):$(APP_TAG) || true

# ---------------------------------------------