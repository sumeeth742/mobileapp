from datetime import UTC, datetime
from uuid import UUID

from fastapi import HTTPException, status

from app.repositories import InMemoryInterviewRepository, StoredInterview
from app.schemas import AnswerCreate, AnswerRecord, InterviewCreate, InterviewResponse
from app.services.ai_provider import AiInterviewProvider, AiProviderError


class InterviewService:
    def __init__(self, repository: InMemoryInterviewRepository, ai_provider: AiInterviewProvider) -> None:
        self._repository = repository
        self._ai_provider = ai_provider

    async def create(self, owner_id: str, request: InterviewCreate) -> InterviewResponse:
        seed = StoredInterview(id=UUID(int=0), owner_id=owner_id, configuration=request, questions=[])
        first_question = await self._next_question(seed, None)
        interview = await self._repository.create(owner_id, request, first_question)
        return self._response(interview)

    async def get(self, interview_id: UUID, owner_id: str) -> InterviewResponse:
        return self._response(await self._get_owned(interview_id, owner_id))

    async def answer(self, interview_id: UUID, owner_id: str, request: AnswerCreate) -> InterviewResponse:
        interview = await self._get_owned(interview_id, owner_id)
        if interview.is_complete:
            raise HTTPException(status_code=status.HTTP_409_CONFLICT, detail="This interview is already complete.")
        current = interview.current_question
        assert current is not None
        answer = AnswerRecord(question_id=current.id, answer=request.answer.strip(), created_at=datetime.now(UTC))
        next_question = None if len(interview.answers) + 1 >= interview.configuration.question_count else await self._next_question(interview, answer.answer)
        updated = await self._repository.add_answer_and_question(interview, answer, next_question)
        return self._response(updated)

    async def _get_owned(self, interview_id: UUID, owner_id: str) -> StoredInterview:
        interview = await self._repository.get_owned(interview_id, owner_id)
        if interview is None:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Interview not found.")
        return interview

    async def _next_question(self, interview: StoredInterview, latest_answer: str | None):
        try:
            return await self._ai_provider.next_question(interview, latest_answer)
        except AiProviderError as error:
            raise HTTPException(status_code=status.HTTP_503_SERVICE_UNAVAILABLE, detail="The interview AI is temporarily unavailable.") from error

    def _response(self, interview: StoredInterview) -> InterviewResponse:
        return InterviewResponse(id=interview.id, interview_type=interview.configuration.interview_type, difficulty=interview.configuration.difficulty, question_count=interview.configuration.question_count, job_role=interview.configuration.job_role, current_question=interview.current_question, answered_count=len(interview.answers), is_complete=interview.is_complete, created_at=interview.created_at)
