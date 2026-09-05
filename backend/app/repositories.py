import asyncio
from dataclasses import dataclass, field
from datetime import UTC, datetime
from uuid import UUID, uuid4

from app.schemas import AnswerRecord, InterviewCreate, InterviewQuestion


@dataclass
class StoredInterview:
    id: UUID
    owner_id: str
    configuration: InterviewCreate
    questions: list[InterviewQuestion]
    answers: list[AnswerRecord] = field(default_factory=list)
    created_at: datetime = field(default_factory=lambda: datetime.now(UTC))

    @property
    def is_complete(self) -> bool:
        return len(self.answers) >= self.configuration.question_count

    @property
    def current_question(self) -> InterviewQuestion | None:
        if self.is_complete:
            return None
        return self.questions[-1]


class InMemoryInterviewRepository:
    """Thread-safe development repository; replace with PostgreSQL in Phase 5."""

    def __init__(self) -> None:
        self._interviews: dict[UUID, StoredInterview] = {}
        self._lock = asyncio.Lock()

    async def create(self, owner_id: str, configuration: InterviewCreate, first_question: InterviewQuestion) -> StoredInterview:
        interview = StoredInterview(id=uuid4(), owner_id=owner_id, configuration=configuration, questions=[first_question])
        async with self._lock:
            self._interviews[interview.id] = interview
        return interview

    async def get_owned(self, interview_id: UUID, owner_id: str) -> StoredInterview | None:
        async with self._lock:
            interview = self._interviews.get(interview_id)
            return interview if interview and interview.owner_id == owner_id else None

    async def add_answer_and_question(self, interview: StoredInterview, answer: AnswerRecord, next_question: InterviewQuestion | None) -> StoredInterview:
        async with self._lock:
            interview.answers.append(answer)
            if next_question is not None:
                interview.questions.append(next_question)
        return interview
