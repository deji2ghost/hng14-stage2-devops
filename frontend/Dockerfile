# ── Stage 1: Install dependencies ─────────────────────────────
FROM node:22-alpine AS builder

WORKDIR /app

# Copy package files first (caching trick — only re-installs if these change)
COPY package*.json ./
RUN npm ci --only=production
# RUN npm ci --omit=dev

# ── Stage 2: Final image ──────────────────────────────────────
FROM node:22-alpine

WORKDIR /app

# Copy installed node_modules from builder
COPY --from=builder /app/node_modules ./node_modules

# Copy application files
COPY app.js .
COPY views/ ./views/

# Create non-root user
RUN adduser --disabled-password --gecos "" appuser
USER appuser

EXPOSE 3000

HEALTHCHECK --interval=30s --timeout=10s --start-period=10s --retries=3 \
  CMD node -e "require('http').get('http://localhost:3000', r => process.exit(r.statusCode === 200 ? 0 : 1)).on('error', () => process.exit(1))"

CMD ["node", "app.js"]