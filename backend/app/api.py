from typing import Annotated
from uuid import UUID

from fastapi import APIRouter, Depends, Request, status

from app.schemas import AnswerCreate, InterviewCreate, InterviewResponse
from app.security import get_current_user
from app.services.interview_service import InterviewService

router = APIRouter(prefix="/interviews", tags=["interviews"])


def get_interview_service(request: Request) -> InterviewService:
    return request.app.state.interview_service


@router.post("", response_model=InterviewResponse, status_code=status.HTTP_201_CREATED)
async def create_interview(request: InterviewCreate, owner_id: Annotated[str, Depends(get_current_user)], service: Annotated[InterviewService, Depends(get_interview_service)]) -> InterviewResponse:
    return await service.create(owner_id, request)


@router.get("/{interview_id}", response_model=InterviewResponse)
async def get_interview(interview_id: UUID, owner_id: Annotated[str, Depends(get_current_user)], service: Annotated[InterviewService, Depends(get_interview_service)]) -> InterviewResponse:
    return await service.get(interview_id, owner_id)


@router.post("/{interview_id}/answer", response_model=InterviewResponse)
async def submit_answer(interview_id: UUID, request: AnswerCreate, owner_id: Annotated[str, Depends(get_current_user)], service: Annotated[InterviewService, Depends(get_interview_service)]) -> InterviewResponse:
    return await service.answer(interview_id, owner_id, request)
