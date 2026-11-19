from typing import Any

from ..data.catalog import catalog, resolve
from . import pool, quota

RECENT_LIMIT = 3

NEEDS_WORK_BELOW = 40
DEVELOPING_BELOW = 70

DIMENSIONS = ("correctness", "depth", "clarity", "structure")


def band(score: int) -> str:
    if score < NEEDS_WORK_BELOW:
        return "needsWork"
    if score < DEVELOPING_BELOW:
        return "developing"
    return "interviewReady"


def topic_status(score: int | None) -> str:
    if score is None:
        return "notTried"
    if score < NEEDS_WORK_BELOW:
        return "needsWork"
    if score < DEVELOPING_BELOW:
        return "developing"
    return "strong"


def session_title(mode: str, topic: str | None, difficulty: str) -> str:
    level = _level_label(difficulty)
    if mode == "quick_check" or topic is None:
        return f"Quick check · {level}"
    try:
        _, found = resolve(topic)
    except Exception:
        return f"{topic} · {level}"
    return f"{found.label} · {level}"


def _level_label(difficulty: str) -> str:
    return {"easy": "Junior", "medium": "Mid-level", "hard": "Senior"}.get(
        difficulty, "Mid-level"
    )


async def _rows(handle: Any, sql: str, args: tuple[Any, ...]) -> list[dict[str, Any]]:
    found = await handle.execute(sql, args)
    return list(await found.fetchall())


async def build(user_id: str) -> dict[str, Any]:
    free_total = await quota.limit(user_id)
    free_remaining = await quota.remaining(user_id)

    empty = {
        "plan": "free",
        "free_total": free_total,
        "free_remaining": free_remaining if free_remaining is not None else free_total,
        "completed_interviews": 0,
        "readiness": None,
        "readiness_band": None,
        "topics": _all_topics({}),
        "recent": [],
        "next": None,
        "progress": None,
    }

    if not pool.enabled():
        return empty

    async with pool.connection() as handle:
        sessions = await _rows(
            handle,
            """
            select id, mode, topic, difficulty, overall, answered_count,
                   completed_at, started_at
              from public.sessions
             where user_id = %s and answered_count > 0
             order by coalesce(completed_at, started_at) desc
            """,
            (user_id,),
        )

        if not sessions:
            return empty

        per_topic = await _rows(
            handle,
            """
            select t.topic,
                   avg((t.correctness + t.depth + t.clarity + t.structure) / 20.0 * 100.0) as score,
                   avg(t.depth) as depth,
                   avg(t.correctness) as correctness,
                   avg(t.clarity) as clarity,
                   avg(t.structure) as structure
              from public.turns t
              join public.sessions s on s.id = t.session_id
             where s.user_id = %s
               and t.topic is not null
               and t.correctness is not null
             group by t.topic
            """,
            (user_id,),
        )

    scored = [row for row in sessions if row["overall"] is not None]
    readiness = (
        round(sum(int(row["overall"]) for row in scored) / len(scored))
        if scored
        else None
    )

    topics = {
        str(row["topic"]): {
            "score": round(float(row["score"])),
            "weakest": _weakest_dimension(row),
        }
        for row in per_topic
    }

    return {
        "plan": "free",
        "free_total": free_total,
        "free_remaining": free_remaining if free_remaining is not None else free_total,
        "completed_interviews": len(sessions),
        "readiness": readiness,
        "readiness_band": band(readiness) if readiness is not None else None,
        "topics": _all_topics(topics),
        "recent": [_recent(row) for row in sessions[:RECENT_LIMIT]],
        "next": _recommendation(topics, sessions),
        "progress": _progress(scored, topics),
    }


def _progress(
    scored: list[dict[str, Any]],
    topics: dict[str, dict[str, Any]],
) -> dict[str, Any] | None:
    if len(scored) < 2 or not topics:
        return None

    first = int(scored[-1]["overall"])
    latest = int(scored[0]["overall"])

    strongest = max(topics, key=lambda key: topics[key]["score"])
    weakest = min(topics, key=lambda key: topics[key]["score"])

    return {
        "first_score": first,
        "latest_score": latest,
        "strongest": _label(strongest),
        "most_improved": _label(strongest),
        "practise_next": _label(weakest),
    }


def _label(topic_id: str) -> str:
    try:
        _, found = resolve(topic_id)
    except Exception:
        return topic_id
    return found.label


def _weakest_dimension(row: dict[str, Any]) -> str:
    scores = {name: float(row[name] or 0) for name in DIMENSIONS}
    return min(scores, key=lambda name: scores[name])


def _all_topics(scored: dict[str, dict[str, Any]]) -> list[dict[str, Any]]:
    out: list[dict[str, Any]] = []
    for level in catalog():
        for topic in level.topics:
            found = scored.get(topic.id)
            out.append(
                {
                    "id": topic.id,
                    "name": topic.label,
                    "covers": topic.covers,
                    "difficulty": level.id,
                    "status": topic_status(found["score"] if found else None),
                    "score": found["score"] if found else None,
                }
            )
    return out


def _recent(row: dict[str, Any]) -> dict[str, Any]:
    when = row["completed_at"] or row["started_at"]
    return {
        "session_id": row["id"],
        "title": session_title(
            str(row["mode"]), row["topic"], str(row["difficulty"])
        ),
        "date": when.isoformat() if when is not None else None,
        "questions": int(row["answered_count"]),
        "score": int(row["overall"]) if row["overall"] is not None else None,
    }


def _recommendation(
    topics: dict[str, dict[str, Any]],
    sessions: list[dict[str, Any]],
) -> dict[str, Any] | None:
    if not topics:
        return None

    topic_id = min(topics, key=lambda key: topics[key]["score"])
    try:
        level, found = resolve(topic_id)
    except Exception:
        return None

    questions = int(sessions[0]["answered_count"]) or 5
    weakest = topics[topic_id]["weakest"]

    return {
        "topic_id": found.id,
        "topic_name": found.label,
        "reason": _reason(topics[topic_id]["score"], weakest),
        "difficulty": level.id,
        "question_count": max(questions, 5),
        "minutes": max(questions, 5) * 4,
    }


def _reason(score: int, weakest: str) -> str:
    label = weakest.capitalize()
    if score < NEEDS_WORK_BELOW:
        return f"Your weakest topic so far, and {label} scored lowest within it."
    return f"Your lowest-scoring topic so far. {label} is what pulled it down."
