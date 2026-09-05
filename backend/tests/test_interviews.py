import os

os.environ["DEV_AUTH_TOKEN"] = "test-token"
os.environ["AI_PROVIDER"] = "mock"

from fastapi.testclient import TestClient

from app.main import app


AUTH = {"Authorization": "Bearer test-token"}
PAYLOAD = {
    "interview_type": "technical",
    "difficulty": "intermediate",
    "question_count": 2,
    "job_role": "Software Engineer",
    "programming_language": "Python",
    "topics": ["Algorithms"],
}


def test_interview_requires_bearer_auth() -> None:
    with TestClient(app) as client:
        response = client.post("/api/v1/interviews", json=PAYLOAD)
    assert response.status_code == 401


def test_interview_returns_validated_follow_up_and_completes() -> None:
    with TestClient(app) as client:
        created = client.post("/api/v1/interviews", headers=AUTH, json=PAYLOAD)
        assert created.status_code == 201
        initial = created.json()
        assert initial["current_question"]["question_type"] == "technical"

        first_answer = client.post(f"/api/v1/interviews/{initial['id']}/answer", headers=AUTH, json={"answer": "I used a list."})
        assert first_answer.status_code == 200
        follow_up = first_answer.json()
        assert follow_up["answered_count"] == 1
        assert follow_up["current_question"]["follow_up"] is True

        completed = client.post(f"/api/v1/interviews/{initial['id']}/answer", headers=AUTH, json={"answer": "I gathered requirements, compared approaches, documented the trade-offs, tested edge cases, and shared the result with the team."})
        assert completed.status_code == 200
        assert completed.json()["is_complete"] is True
        assert completed.json()["current_question"] is None
