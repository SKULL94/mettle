from collections.abc import AsyncIterator
from typing import Protocol

from pydantic import BaseModel, Field

DIMENSIONS = ("correctness", "depth", "clarity", "structure")


class QuestionRequest(BaseModel):
    topic: str
    topic_label: str
    topic_covers: str
    difficulty: str
    seniority: str
    difficulty_brief: str
    index: int
    total: int
    is_follow_up: bool = False
    weak_dimension: str | None = None
    previous_question: str | None = None
    previous_answer: str | None = None
    asked: list[str] = Field(default_factory=list)


class GradeRequest(BaseModel):
    topic_label: str
    difficulty: str
    seniority: str
    question: str
    answer: str


class TurnScore(BaseModel):
    correctness: int = Field(ge=1, le=5)
    depth: int = Field(ge=1, le=5)
    clarity: int = Field(ge=1, le=5)
    structure: int = Field(ge=1, le=5)
    missing: list[str] = Field(default_factory=list)
    notes: str = ""

    @property
    def weakest(self) -> int:
        return min(getattr(self, name) for name in DIMENSIONS)

    @property
    def weakest_dimension(self) -> str:
        lowest = self.weakest
        return next(name for name in DIMENSIONS if getattr(self, name) == lowest)


class LLMProvider(Protocol):
    def stream_question(self, req: QuestionRequest) -> AsyncIterator[str]: ...

    async def grade(self, req: GradeRequest) -> TurnScore: ...
