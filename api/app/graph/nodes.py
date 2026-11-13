import asyncio
import logging
from typing import Any

from langgraph.types import interrupt

from ..data.catalog import Topic, resolve
from ..providers.base import DIMENSIONS, GradeRequest, QuestionRequest, TurnScore
from ..providers.factory import get_provider
from ..session import bus
from ..store import results
from .rubric import MAX_FOLLOW_UP_DEPTH, WEAK_DIMENSION_THRESHOLD
from .state import InterviewState, PendingQuestion, Turn

log = logging.getLogger("mettle.graph")

SCRIPTED_WORD_DELAY = 0.02


async def _emit(session_id: str, event: str, data: dict[str, Any]) -> None:
    emitter = bus.emitter_for(session_id)
    if emitter is not None:
        await emitter.emit(event, data)


def scripted_question(topic: Topic, asked_count: int) -> str | None:
    if asked_count < len(topic.questions):
        return topic.questions[asked_count]
    return None


async def _stream_scripted(session_id: str, text: str) -> str:
    for position, word in enumerate(text.split()):
        await _emit(
            session_id,
            "question.delta",
            {"text": word if position == 0 else f" {word}"},
        )
        await asyncio.sleep(SCRIPTED_WORD_DELAY)
    return text


async def _stream_generated(session_id: str, request: QuestionRequest) -> str:
    pieces: list[str] = []
    async for piece in get_provider().stream_question(request):
        pieces.append(piece)
        await _emit(session_id, "question.delta", {"text": piece})
    return "".join(pieces)


def should_probe(score: TurnScore, answer: str, follow_up_depth: int) -> bool:
    if follow_up_depth >= MAX_FOLLOW_UP_DEPTH:
        return False
    if not answer.strip():
        return False
    if score.is_non_answer:
        return False
    return score.weakest_substantive <= WEAK_DIMENSION_THRESHOLD


async def plan_interview(state: InterviewState) -> dict[str, Any]:
    return {"questions_remaining": state["question_total"]}


async def ask_question(state: InterviewState) -> dict[str, Any]:
    session_id = state["session_id"]
    is_follow_up = state["follow_up_depth"] > 0
    index = state["asked_count"] + 1
    total = state["question_total"]
    kind = "follow_up" if is_follow_up else "initial"
    reason = state["follow_up_reason"] if is_follow_up else None

    await _emit(
        session_id,
        "turn.started",
        {
            "index": index,
            "total": total,
            "kind": kind,
            "reason": reason,
            "topic": state["topic"],
        },
    )

    level, topic = resolve(state["topic"])
    previous = state["history"][-1] if state["history"] else None
    request = QuestionRequest(
        topic=topic.id,
        topic_label=topic.label,
        topic_covers=topic.covers,
        difficulty=level.id,
        seniority=level.seniority,
        difficulty_brief=level.brief,
        index=index,
        total=total,
        is_follow_up=is_follow_up,
        weak_dimension=reason,
        previous_question=previous["question"] if previous else None,
        previous_answer=previous["answer"] if previous else None,
        asked=[turn["question"] for turn in state["history"]],
    )

    scripted = None if is_follow_up else scripted_question(topic, state["asked_count"])
    text = (
        await _stream_scripted(session_id, scripted)
        if scripted is not None
        else await _stream_generated(session_id, request)
    )

    question_id = f"q-{state['asked_count']}-{state['follow_up_depth']}"

    pending = PendingQuestion(
        question_id=question_id,
        text=text,
        index=index,
        total=total,
        kind=kind,
        reason=reason,
    )

    await _emit(
        session_id,
        "question.done",
        {
            "question_id": question_id,
            "text": text,
            "index": index,
            "total": total,
            "kind": kind,
            "reason": reason,
        },
    )

    return {"pending": pending}


async def await_answer(state: InterviewState) -> dict[str, Any]:
    pending = state["pending"]
    answer = interrupt({"question_id": pending["question_id"] if pending else None})
    return {"last_answer": answer if isinstance(answer, str) else ""}


async def grade_answer(state: InterviewState) -> dict[str, Any]:
    session_id = state["session_id"]
    pending = state["pending"]
    if pending is None:
        return {}

    await _emit(session_id, "grade.started", {})

    level, topic = resolve(state["topic"])
    score = await get_provider().grade(
        GradeRequest(
            topic_label=topic.label,
            difficulty=level.id,
            seniority=level.seniority,
            question=pending["text"],
            answer=state["last_answer"],
        )
    )

    await _emit(
        session_id,
        "grade.done",
        {
            "correctness": score.correctness,
            "depth": score.depth,
            "clarity": score.clarity,
            "structure": score.structure,
            "missing": score.missing,
            "notes": score.notes,
        },
    )

    turn = Turn(
        question_id=pending["question_id"],
        question=pending["text"],
        answer=state["last_answer"],
        index=pending["index"],
        kind=pending["kind"],
        reason=pending["reason"],
        score=score.model_dump(),
    )

    probe = should_probe(score, state["last_answer"], state["follow_up_depth"])
    history = [*state["history"], turn]

    if probe:
        return {
            "history": history,
            "pending": None,
            "probe": True,
            "follow_up_depth": state["follow_up_depth"] + 1,
            "follow_up_reason": score.weakest_substantive_dimension,
        }

    asked_count = state["asked_count"] + 1
    return {
        "history": history,
        "pending": None,
        "probe": False,
        "follow_up_depth": 0,
        "follow_up_reason": None,
        "asked_count": asked_count,
        "questions_remaining": max(state["question_total"] - asked_count, 0),
    }


async def _persist(scorecard: dict[str, Any], state: InterviewState) -> None:
    try:
        await results.save(
            scorecard,
            user_id=state.get("user_id") or "",
            question_total=state["question_total"],
        )
    except Exception:
        log.exception("could not persist session=%s", state["session_id"])


async def summarize(state: InterviewState) -> dict[str, Any]:
    history = state["history"]
    scored = [turn["score"] for turn in history if turn.get("score")]

    def mean(dimension: str) -> int:
        if not scored:
            return 0
        return round(sum(int(s[dimension]) for s in scored) / len(scored))

    dimensions = {name: mean(name) for name in DIMENSIONS}
    total = sum(dimensions.values())
    overall = round(total / (len(DIMENSIONS) * 5) * 100)

    missing: list[str] = []
    for item in scored:
        for entry in item.get("missing", []):
            if entry not in missing:
                missing.append(entry)

    scorecard = {
        "session_id": state["session_id"],
        "topic": state["topic"],
        "difficulty": state["difficulty"],
        "overall": overall,
        "dimensions": dimensions,
        "missing": missing,
        "turns": history,
    }

    await _persist(scorecard, state)

    await _emit(
        state["session_id"],
        "session.done",
        {"scorecard_url": f"/v1/sessions/{state['session_id']}/scorecard"},
    )

    return {"scorecard": scorecard}
