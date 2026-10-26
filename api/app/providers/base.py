from collections.abc import AsyncIterator
from typing import Protocol

from pydantic import BaseModel, Field

DIMENSIONS = ("correctness", "depth", "clarity", "structure")


class QuestionRequest(BaseModel):
    topic: str
    seniority: str
    index: int
    total: int
    bank_index: int = 0
    is_follow_up: bool = False
    weak_dimension: str | None = None
    previous_question: str | None = None
    previous_answer: str | None = None
    asked: list[str] = Field(default_factory=list)


class GradeRequest(BaseModel):
    topic: str
    question: str
    answer: str
    keywords: list[str] = Field(default_factory=list)


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

    def keywords_for(self, topic: str, bank_index: int) -> list[str]: ...
