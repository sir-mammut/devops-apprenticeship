# app/Dockerfile
# ---------------------------------------------
# Dockerfile to containerize our Node.js app
# ---------------------------------------------

# Stage 1: Build the app
FROM node:18-alpine AS base      # Use the official Node.js 18 image as the base
WORKDIR /usr/src/app             # Set the working directory inside the container

# Copy package.json and package-lock.json (if available) first
COPY package*.json ./            # This helps leverage Docker cache for faster builds
RUN npm install --production     # Install production dependencies

COPY . .                         # Copy the rest of the application source code

# Stage 2: Run the app in a clean container
EXPOSE 3000                      # Expose the app port (server.js listens on 3000)

CMD ["node", "server.js"]        # Start the application

# ---------------------------------------------













