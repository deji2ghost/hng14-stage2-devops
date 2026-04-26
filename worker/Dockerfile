FROM python:3.11-alpine AS builder

WORKDIR /app
COPY requirements.txt .
# hadolint ignore=DL3013
RUN pip install --no-cache-dir --upgrade pip setuptools wheel && \
  pip install --no-cache-dir --prefix=/install -r requirements.txt

FROM python:3.11-alpine

WORKDIR /app
COPY --from=builder /install /usr/local
COPY worker.py .

RUN adduser -D appuser
USER appuser

# The worker doesn't serve HTTP, so health check pings Redis instead
HEALTHCHECK --interval=30s --timeout=10s --start-period=10s --retries=3 \
  CMD python -c "import redis, os; r = redis.Redis(host=os.getenv('REDIS_HOST','redis')); r.ping()"

CMD ["python", "worker.py"]