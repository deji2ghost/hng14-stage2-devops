# ── Stage 1: Builder ──────────────────────────────────────────
# We use a full Python image to install dependencies
FROM python:3.11-alpine AS builder

WORKDIR /app

# Copy only the requirements file first (Docker caches this layer
# so if requirements don't change, it won't re-install everything)
COPY requirements.txt .

# Install dependencies into a specific folder we can copy later
RUN pip install --no-cache-dir --prefix=/install -r requirements.txt

# ── Stage 2: Final image ──────────────────────────────────────
# Start fresh with a clean slim image — no build tools included
FROM python:3.11-alpine

WORKDIR /app

# Copy the installed packages from the builder stage
COPY --from=builder /install /usr/local

# Copy only the application source code
COPY main.py .

# Create a non-root user called "appuser" and switch to it
# (Running as root inside a container is a security risk)
RUN adduser -D appuser
USER appuser

# Tell Docker this container listens on port 8000
EXPOSE 8000

# HEALTHCHECK: Docker will run this command every 30s to check
# if the API is alive. If it fails 3 times, container is "unhealthy"
HEALTHCHECK --interval=30s --timeout=10s --start-period=10s --retries=3 \
  CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:8000/docs')"

# Start the FastAPI server
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]