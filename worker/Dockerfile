FROM python:3.11-slim AS builder

WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir --prefix=/install -r requirements.txt

FROM python:3.11-slim

WORKDIR /app
COPY --from=builder /install /usr/local
COPY worker.py .

RUN adduser --disabled-password --gecos "" appuser
USER appuser

# The worker doesn't serve HTTP, so health check pings Redis instead
HEALTHCHECK --interval=30s --timeout=10s --start-period=10s --retries=3 \
  CMD python -c "import redis, os; r = redis.Redis(host=os.getenv('REDIS_HOST','redis')); r.ping()"

CMD ["python", "worker.py"]