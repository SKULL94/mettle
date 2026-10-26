from typing import Any, TypedDict


class Turn(TypedDict):
    question_id: str
    question: str
    answer: str
    index: int
    kind: str
    reason: str | None
    score: dict[str, Any]


class PendingQuestion(TypedDict):
    question_id: str
    text: str
    index: int
    total: int
    kind: str
    reason: str | None
    bank_index: int


class InterviewState(TypedDict, total=False):
    session_id: str
    topic: str
    seniority: str
    question_total: int
    questions_remaining: int
    asked_count: int
    bank_index: int
    follow_up_depth: int
    follow_up_reason: str | None
    probe: bool
    last_answer: str
    history: list[Turn]
    pending: PendingQuestion | None
    scorecard: dict[str, Any] | None


def initial_state(
    session_id: str,
    topic: str,
    seniority: str,
    question_total: int,
) -> InterviewState:
    return InterviewState(
        session_id=session_id,
        topic=topic,
        seniority=seniority,
        question_total=question_total,
        questions_remaining=question_total,
        asked_count=0,
        bank_index=0,
        follow_up_depth=0,
        follow_up_reason=None,
        probe=False,
        last_answer="",
        history=[],
        pending=None,
        scorecard=None,
    )
