# app/Dockerfile
# ---------------------------------------------
# Multi-stage Dockerfile for a small Node.js app
# - stage "builder": installs deps and prepares app
# - stage "runtime": minimal image with runtime-only artifacts
# - runs as a non-root user for better security
# ---------------------------------------------

# -----------------------
# Stage: builder
# -----------------------
FROM node:18-alpine AS builder
# set working dir
WORKDIR /usr/src/app

# copy only package manifests first to leverage Docker cache
COPY package.json package-lock.json ./

# install production dependencies deterministically
# `npm ci` prefers package-lock.json and is reproducible
RUN npm ci --omit=dev

# copy application source
COPY . .

# run any build steps (uncomment if you have a build step)
# RUN npm run build

# -----------------------
# Stage: runtime
# -----------------------
FROM node:18-alpine AS runtime
WORKDIR /usr/src/app

# Create a non-root user 'app' and group for better security
RUN addgroup -S app && adduser -S app -G app

# Copy only the necessary files from builder stage
# (if you have a built output, copy that; otherwise copy full app)
COPY --from=builder /usr/src/app /usr/src/app

# Set NODE_ENV to production by default
ENV NODE_ENV=production
EXPOSE 3000

# Use the non-root user created above
USER app

# Start the application
CMD ["node", "server.js"]
