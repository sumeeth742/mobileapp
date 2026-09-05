import json
from abc import ABC, abstractmethod
from uuid import uuid4

import httpx
from pydantic import ValidationError

from app.config import Settings
from app.repositories import StoredInterview
from app.schemas import InterviewQuestion


class AiProviderError(RuntimeError):
    pass


class AiInterviewProvider(ABC):
    @abstractmethod
    async def next_question(self, interview: StoredInterview, latest_answer: str | None) -> InterviewQuestion:
        """Return a validated structured question; never free-form provider text."""


class MockAiInterviewProvider(AiInterviewProvider):
    """Deterministic provider used exclusively for local API development and tests."""

    async def next_question(self, interview: StoredInterview, latest_answer: str | None) -> InterviewQuestion:
        config = interview.configuration
        if latest_answer is None:
            question = {
                "hr": "Tell me about yourself and the role you want next.",
                "technical": f"Describe a {config.programming_language or 'technical'} problem you solved and your reasoning.",
                "project": "Describe a project objective and the contribution you personally made.",
                "behavioral": "Tell me about a challenging teamwork situation using Situation, Task, Action, and Result.",
            }[config.interview_type.value]
            expected = ["context", "actions", "outcome"]
            follow_up = False
        elif len(latest_answer.split()) < 35:
            question = "Please add concrete actions, constraints, and a measurable result to your answer."
            expected = ["actions", "constraints", "result"]
            follow_up = True
        else:
            focus = " ".join(word.strip(".,!?;:") for word in latest_answer.split()[:4])
            question = f"You mentioned '{focus}'. What trade-offs did you consider, and how did you validate the outcome?"
            expected = ["trade-offs", "validation", "outcome"]
            follow_up = True
        return InterviewQuestion(id=uuid4(), question=question, question_type=config.interview_type, difficulty=config.difficulty, expected_topics=expected, follow_up=follow_up)


class OpenAiCompatibleProvider(AiInterviewProvider):
    def __init__(self, settings: Settings) -> None:
        if not settings.llm_api_key:
            raise AiProviderError("LLM_API_KEY must be configured for openai_compatible provider.")
        self._settings = settings

    async def next_question(self, interview: StoredInterview, latest_answer: str | None) -> InterviewQuestion:
        schema = InterviewQuestion.model_json_schema()
        context = {
            "configuration": interview.configuration.model_dump(mode="json"),
            "previous_questions": [question.model_dump(mode="json") for question in interview.questions],
            "previous_answers": [answer.answer for answer in interview.answers],
            "latest_answer": latest_answer,
        }
        payload = {
            "model": self._settings.llm_model,
            "messages": [
                {"role": "system", "content": "You are a realistic mock interviewer. Return only JSON matching the supplied schema. Use previous answers for a contextual follow-up. Do not evaluate or score yet."},
                {"role": "user", "content": json.dumps(context)},
            ],
            "response_format": {"type": "json_schema", "json_schema": {"name": "interview_question", "strict": True, "schema": schema}},
        }
        try:
            async with httpx.AsyncClient(base_url=self._settings.llm_base_url.rstrip("/"), timeout=25) as client:
                response = await client.post("/chat/completions", headers={"Authorization": f"Bearer {self._settings.llm_api_key}"}, json=payload)
                response.raise_for_status()
            content = response.json()["choices"][0]["message"]["content"]
            return InterviewQuestion.model_validate_json(content)
        except (httpx.HTTPError, KeyError, TypeError, ValidationError, ValueError) as error:
            raise AiProviderError("The AI provider returned an invalid structured question.") from error


def build_ai_provider(settings: Settings) -> AiInterviewProvider:
    if settings.ai_provider == "mock":
        return MockAiInterviewProvider()
    if settings.ai_provider == "openai_compatible":
        return OpenAiCompatibleProvider(settings)
    raise AiProviderError(f"Unsupported AI_PROVIDER: {settings.ai_provider}")
