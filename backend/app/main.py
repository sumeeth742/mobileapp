import logging
from contextlib import asynccontextmanager

from fastapi import FastAPI

from app.api import router
from app.config import get_settings
from app.repositories import InMemoryInterviewRepository
from app.services.ai_provider import build_ai_provider
from app.services.interview_service import InterviewService

logging.basicConfig(level=logging.INFO, format="%(asctime)s %(levelname)s %(name)s %(message)s")


@asynccontextmanager
async def lifespan(app: FastAPI):
    settings = get_settings()
    app.state.interview_service = InterviewService(InMemoryInterviewRepository(), build_ai_provider(settings))
    yield


settings = get_settings()
app = FastAPI(title="AI Mock Interview API", version="0.1.0", lifespan=lifespan)
app.include_router(router, prefix=settings.api_prefix)


@app.get("/health", tags=["health"])
async def health() -> dict[str, str]:
    return {"status": "ok"}
