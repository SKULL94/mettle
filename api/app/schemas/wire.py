from typing import Any

from pydantic import BaseModel, Field


class CreateSessionRequest(BaseModel):
    topic: str
    question_count: int = Field(default=5, ge=1, le=10)


class CreateSessionResponse(BaseModel):
    session_id: str
    first_turn_url: str


class AnswerRequest(BaseModel):
    turn_id: str
    answer: str = ""


class SkipRequest(BaseModel):
    turn_id: str


class MetaResponse(BaseModel):
    version: str
    model: str
    demo_mode: bool
    configured: bool


class TopicOut(BaseModel):
    id: str
    label: str
    covers: str


class DifficultyOut(BaseModel):
    id: str
    label: str
    seniority: str
    topics: list[TopicOut]


class CatalogResponse(BaseModel):
    difficulties: list[DifficultyOut]


class SessionStateResponse(BaseModel):
    session_id: str
    topic: str
    question_total: int
    asked_count: int
    questions_remaining: int
    pending: dict[str, Any] | None
    history: list[dict[str, Any]]
    finished: bool


class ScorecardResponse(BaseModel):
    session_id: str
    topic: str
    difficulty: str
    overall: int
    dimensions: dict[str, int]
    missing: list[str]
    turns: list[dict[str, Any]]
