import logging
from typing import Any

from psycopg.types.json import Json

from ..config import get_settings
from . import pool

log = logging.getLogger("mettle.results")


def _score(turn: dict[str, Any], key: str) -> int | None:
    score = turn.get("score") or {}
    value = score.get(key)
    return int(value) if value is not None else None


async def save(scorecard: dict[str, Any], user_id: str, question_total: int) -> None:
    if not pool.enabled():
        return

    dimensions = scorecard.get("dimensions") or {}
    turns = list(scorecard.get("turns") or [])

    async with pool.connection() as handle, handle.transaction():
        await handle.execute(
            """
            insert into public.sessions
              (id, user_id, topic, difficulty, model, overall,
               correctness, depth, clarity, structure, missing)
            values (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
            on conflict (id) do update
               set overall      = excluded.overall,
                   correctness  = excluded.correctness,
                   depth        = excluded.depth,
                   clarity      = excluded.clarity,
                   structure    = excluded.structure,
                   missing      = excluded.missing,
                   completed_at = now()
            """,
            (
                scorecard["session_id"],
                user_id,
                scorecard["topic"],
                scorecard["difficulty"],
                get_settings().anthropic_model,
                int(scorecard.get("overall") or 0),
                int(dimensions.get("correctness") or 0),
                int(dimensions.get("depth") or 0),
                int(dimensions.get("clarity") or 0),
                int(dimensions.get("structure") or 0),
                Json(scorecard.get("missing") or []),
            ),
        )

        await handle.execute(
            "delete from public.turns where session_id = %s",
            (scorecard["session_id"],),
        )

        for ordinal, turn in enumerate(turns):
            score = turn.get("score") or {}
            await handle.execute(
                """
                insert into public.turns
                  (session_id, ordinal, position, question_id, question, total,
                   kind, reason, answer, correctness, depth, clarity, structure, missing)
                values (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
                """,
                (
                    scorecard["session_id"],
                    ordinal,
                    int(turn.get("index") or 0),
                    turn.get("question_id") or "",
                    turn.get("question") or "",
                    question_total,
                    turn.get("kind") or "initial",
                    turn.get("reason"),
                    turn.get("answer") or "",
                    _score(turn, "correctness"),
                    _score(turn, "depth"),
                    _score(turn, "clarity"),
                    _score(turn, "structure"),
                    Json(score.get("missing") or []),
                ),
            )

    log.info("persisted session=%s turns=%s", scorecard["session_id"], len(turns))
