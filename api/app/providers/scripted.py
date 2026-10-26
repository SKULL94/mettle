import asyncio
import re
from collections.abc import AsyncIterator
from functools import lru_cache
from pathlib import Path

import yaml
from pydantic import BaseModel, Field

from .base import GradeRequest, QuestionRequest, TurnScore

QUESTIONS_PATH = Path(__file__).resolve().parent.parent / "data" / "questions.yaml"

DEFAULT_TOPIC = "state-management"
NO_ANSWER_MISSING = "no answer given"

_SENTENCE_SPLIT = re.compile(r"[.!?]")
_WHITESPACE_SPLIT = re.compile(r"\s+")


class ScriptedQuestion(BaseModel):
    text: str
    keywords: list[str] = Field(default_factory=list)
    follow_up: str


@lru_cache
def load_bank() -> dict[str, list[ScriptedQuestion]]:
    raw = yaml.safe_load(QUESTIONS_PATH.read_text(encoding="utf-8"))
    return {
        topic: [ScriptedQuestion.model_validate(item) for item in items]
        for topic, items in raw.items()
    }


def bank_for(topic: str) -> list[ScriptedQuestion]:
    bank = load_bank()
    return bank.get(topic) or bank[DEFAULT_TOPIC]


def band(ratio: float) -> int:
    if ratio >= 0.85:
        return 5
    if ratio >= 0.6:
        return 4
    if ratio >= 0.4:
        return 3
    if ratio >= 0.2:
        return 2
    return 1


def score_answer(answer: str, keywords: list[str]) -> TurnScore:
    normalised = answer.lower()
    words = len([w for w in _WHITESPACE_SPLIT.split(normalised) if w])

    if words == 0:
        return TurnScore(
            correctness=1,
            depth=1,
            clarity=1,
            structure=1,
            missing=[NO_ANSWER_MISSING],
        )

    hit = [k for k in keywords if k in normalised]
    coverage = 1.0 if not keywords else len(hit) / len(keywords)
    sentences = len([s for s in _SENTENCE_SPLIT.split(normalised) if s.strip()])

    return TurnScore(
        correctness=band(coverage),
        depth=band(min(words / 70, 1)),
        clarity=band(min(words / 25, 1) * (1 if sentences > 1 else 0.7)),
        structure=band(min(sentences / 3, 1)),
        missing=[k for k in keywords if k not in hit],
    )


def chunk(text: str) -> list[str]:
    words = text.split(" ")
    return [w if i == len(words) - 1 else f"{w} " for i, w in enumerate(words)]


class ScriptedProvider:
    def __init__(self, token_delay_ms: int = 24, grade_delay_ms: int = 320) -> None:
        self._token_delay = token_delay_ms / 1000
        self._grade_delay = grade_delay_ms / 1000

    def question_for(self, topic: str, bank_index: int, is_follow_up: bool) -> ScriptedQuestion:
        bank = bank_for(topic)
        return bank[bank_index % len(bank)]

    def keywords_for(self, topic: str, bank_index: int) -> list[str]:
        return self.question_for(topic, bank_index, False).keywords

    async def stream_question(self, req: QuestionRequest) -> AsyncIterator[str]:
        scripted = self.question_for(req.topic, req.bank_index, req.is_follow_up)
        text = scripted.follow_up if req.is_follow_up else scripted.text
        for piece in chunk(text):
            if self._token_delay:
                await asyncio.sleep(self._token_delay)
            yield piece

    async def grade(self, req: GradeRequest) -> TurnScore:
        if self._grade_delay:
            await asyncio.sleep(self._grade_delay)
        return score_answer(req.answer, req.keywords)
