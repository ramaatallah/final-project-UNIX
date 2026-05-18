# =============================================================================
# Dockerfile – Node.js Backend (also serves the frontend as static files)
# Build context: project ROOT (docker-compose.yml sets context: .)
# =============================================================================

# ─────────────────────────────────────────────────────────────────────────────
# Stage 1 – deps: install production dependencies (heavily cached layer)
# ─────────────────────────────────────────────────────────────────────────────
FROM node:18-alpine AS deps

WORKDIR /app/backend

# Copy only manifests first – Docker cache is only broken when these files change
COPY backend/package.json backend/package-lock.json ./

# Install production deps only (no devDependencies)
RUN npm ci --omit=dev

# ─────────────────────────────────────────────────────────────────────────────
# Stage 2 – runner: lean production image
# ─────────────────────────────────────────────────────────────────────────────
FROM node:18-alpine AS runner

# Create a non-root user for security (never run as root in production)
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

WORKDIR /app

# Copy production node_modules from the deps stage
COPY --from=deps /app/backend/node_modules ./backend/node_modules

# Copy backend source files
COPY backend/ ./backend/

# Copy the frontend (index.html) to the project root inside the image.
# server.js uses: express.static(path.join(__dirname, '..'))
# __dirname is /app/backend, so /app/backend/../ = /app/ -> serves index.html ✅
COPY index.html ./index.html

# Switch to non-root user
USER appuser

# Expose the port Express listens on
EXPOSE 3000

# Health-check – Docker (and Jenkins) uses this to know the app is ready
HEALTHCHECK --interval=15s --timeout=5s --start-period=30s --retries=3 \
  CMD wget -qO- "http://localhost:3000/recommend?input=hot" || exit 1

# Working directory for CMD must be the backend folder (where server.js lives)
WORKDIR /app/backend

# Start the server
CMD ["node", "server.js"]
