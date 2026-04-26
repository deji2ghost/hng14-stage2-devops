# FIXES.md — All Bugs Found and Fixed

## Fix 1
- **File:** `api/main.py`
- **Line:** 8
- **Problem:** Redis client hardcoded `host="localhost"`. In Docker, containers
  cannot reach each other via localhost — each container is isolated.
- **Fix:** Changed to `host=os.getenv("REDIS_HOST", "redis")` to use
  the Docker service name, configurable via environment variable.

## Fix 2
- **File:** `worker/worker.py`
- **Line:** 4
- **Problem:** Same `host="localhost"` issue as above.
- **Fix:** Changed to `host=os.getenv("REDIS_HOST", "redis")`.

## Fix 3
- **File:** `worker/worker.py`
- **Line:** 4 (import signal unused)
- **Problem:** `signal` module was imported but no signal handlers were
  registered. This means the worker ignores Docker's SIGTERM and gets
  force-killed, potentially losing in-flight jobs.
- **Fix:** Added `SIGTERM` and `SIGINT` handlers that set a `running = False`
  flag, allowing the `while` loop to exit cleanly.

## Fix 4
- **File:** `frontend/app.js`
- **Line:** 5
- **Problem:** `API_URL` hardcoded to `http://localhost:8000`. The frontend
  container cannot reach the API container via localhost.
- **Fix:** Changed to `process.env.API_URL || "http://api:8000"` so it uses
  the Docker service name.

## Fix 5
- **File:** `api/.env`
- **Problem:** A `.env` file with real credentials existed and risked being
  committed to version control.
- **Fix:** Added `.env` to `.gitignore`. Created `.env.example` with
  placeholder values.