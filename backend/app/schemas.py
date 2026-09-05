from datetime import datetime
from enum import StrEnum
from uuid import UUID

from pydantic import BaseModel, ConfigDict, Field


class InterviewType(StrEnum):
    HR = "hr"
    TECHNICAL = "technical"
    PROJECT = "project"
    BEHAVIORAL = "behavioral"


class Difficulty(StrEnum):
    BEGINNER = "beginner"
    INTERMEDIATE = "intermediate"
    ADVANCED = "advanced"


class InterviewCreate(BaseModel):
    interview_type: InterviewType
    difficulty: Difficulty
    question_count: int = Field(ge=1, le=15)
    job_role: str = Field(min_length=2, max_length=100)
    programming_language: str | None = Field(default=None, max_length=50)
    topics: list[str] = Field(default_factory=list, max_length=10)


class InterviewQuestion(BaseModel):
    id: UUID
    question: str = Field(min_length=10, max_length=1500)
    question_type: InterviewType
    difficulty: Difficulty
    expected_topics: list[str] = Field(min_length=1, max_length=8)
    follow_up: bool


class AnswerCreate(BaseModel):
    answer: str = Field(min_length=1, max_length=5000)


class AnswerRecord(BaseModel):
    question_id: UUID
    answer: str
    created_at: datetime


class InterviewResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: UUID
    interview_type: InterviewType
    difficulty: Difficulty
    question_count: int
    job_role: str
    current_question: InterviewQuestion | None
    answered_count: int
    is_complete: bool
    created_at: datetime
