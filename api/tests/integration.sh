#!/usr/bin/env bash
# Integration test: start stack → submit job → assert it completes

set -e

echo "==> Starting full stack..."
docker compose up -d --build

echo "==> Waiting 30s for services to become healthy..."
sleep 30

echo "==> Submitting a job via the frontend..."
RESPONSE=$(curl -sf -X POST http://localhost:3000/submit)
JOB_ID=$(echo "$RESPONSE" | python3 -c "import sys,json; print(json.load(sys.stdin)['job_id'])")
echo "Job ID: $JOB_ID"

# Poll for completion with a 60 second timeout
TIMEOUT=60
ELAPSED=0
SUCCESS=false

while [ $ELAPSED -lt $TIMEOUT ]; do
  STATUS=$(curl -sf "http://localhost:3000/status/$JOB_ID" | \
    python3 -c "import sys,json; print(json.load(sys.stdin)['status'])")
  echo "[$ELAPSED s] Status: $STATUS"

  if [ "$STATUS" = "completed" ]; then
    SUCCESS=true
    break
  fi

  sleep 3
  ELAPSED=$((ELAPSED + 3))
done

echo "==> Tearing down stack..."
docker compose down -v

if [ "$SUCCESS" = "true" ]; then
  echo "✅ Integration test passed"
  exit 0
else
  echo "❌ Job did not complete within ${TIMEOUT}s"
  exit 1
fi