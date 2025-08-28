# app/Dockerfile
# syntax=docker/dockerfile:1       # Use Dockerfile syntax v1 (enables BuildKit features)

# === Stage 1: Builder ===
FROM node:18-slim AS builder
WORKDIR /app

# 1) Copy manifests first to leverage cache on dependency installs
COPY package*.json ./

# 2) Deterministic install; fall back to npm install if no lockfile
RUN npm ci --include=dev || npm install

# 3) Now copy the rest of the source
COPY . .

# 4) If a build script exists, run it; otherwise continue
RUN npm run build || true

# 5) Keep only production deps for the final image
RUN npm prune --production


# === Stage 2: Runtime ===
FROM node:18-slim AS runtime
WORKDIR /app

# Copy pruned deps and app files from builder
# COPY --from=builder /app/node_modules ./node_modules
# COPY --from=builder /app/package*.json ./
# # If you have a build step that emits dist/, this will exist; if not, COPY will fail.
# # To be safe, we copy the whole app and let prune keep it small:
# COPY --from=builder /app/. .

# Copy the complete pruned app from builder
COPY --from=builder /app /app

# Security: run as non-root
RUN adduser --disabled-password --gecos "" appuser \
  && chown -R appuser:appuser /app
USER appuser

EXPOSE 3000
CMD ["node", "server.js"]