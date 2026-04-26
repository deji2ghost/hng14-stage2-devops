import fakeredis  # pretends to be Redis without needing a real server
# import pytest
from fastapi.testclient import TestClient

# We patch (replace) the real Redis with a fake one for testing
import main
from main import app

main.r = fakeredis.FakeRedis()


client = TestClient(app)


def test_create_job_returns_job_id():
    """Test that submitting a job gives back a job_id"""
    response = client.post("/jobs")
    assert response.status_code == 200
    assert "job_id" in response.json()


def test_get_job_status_is_queued():
    """Test that a newly created job has status 'queued'""" 
    create_response = client.post("/jobs")
    job_id = create_response.json()["job_id"]

    status_response = client.get(f"/jobs/{job_id}")
    assert status_response.status_code == 200
    assert status_response.json()["status"] == "queued"


def test_get_nonexistent_job_returns_error():
    """Test that asking for a fake job ID returns an error"""
    response = client.get("/jobs/fake-id-that-doesnt-exist")
    assert response.status_code == 200
    assert "error" in response.json()
