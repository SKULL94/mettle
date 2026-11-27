from typing import Any

from pydantic import BaseModel, Field


class CreateSessionRequest(BaseModel):
    topic: str
    question_count: int = Field(default=5, ge=1, le=10)


class CreateSessionResponse(BaseModel):
    session_id: str
    first_turn_url: str


MAX_ANSWER_CHARS = 8000


class AnswerRequest(BaseModel):
    turn_id: str
    answer: str = Field(default="", max_length=MAX_ANSWER_CHARS)


class SkipRequest(BaseModel):
    turn_id: str


class MetaResponse(BaseModel):
    version: str
    model: str
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


class TopicProgressOut(BaseModel):
    id: str
    name: str
    covers: str
    difficulty: str
    status: str
    score: int | None = None


class InterviewSummaryOut(BaseModel):
    session_id: str
    title: str
    date: str | None = None
    questions: int
    score: int | None = None


class RecommendationOut(BaseModel):
    topic_id: str
    topic_name: str
    reason: str
    difficulty: str
    question_count: int
    minutes: int


class ProgressSummaryOut(BaseModel):
    first_score: int
    latest_score: int
    strongest: str
    most_improved: str
    practise_next: str


class SummaryResponse(BaseModel):
    first_name: str = ""
    plan: str
    free_total: int
    free_remaining: int
    completed_interviews: int
    readiness: int | None = None
    readiness_band: str | None = None
    topics: list[TopicProgressOut] = Field(default_factory=list)
    recent: list[InterviewSummaryOut] = Field(default_factory=list)
    next: RecommendationOut | None = None
    progress: ProgressSummaryOut | None = None
    pro_price: str | None = None
    next_free_interview_at: str | None = None
    referral_available: bool = False
