import logging

from . import pool

log = logging.getLogger("mettle.progress")


async def record_answer(
    session_id: str,
    user_id: str,
    topic: str | None,
    difficulty: str,
    mode: str,
) -> bool:
    if not pool.enabled():
        return False

    async with pool.connection() as handle:
        found = await handle.execute(
            """
            insert into public.sessions
              (id, user_id, topic, difficulty, mode, model, answered_count)
            values (%s, %s, %s, %s, %s, '', 1)
            on conflict (id) do update
               set answered_count = public.sessions.answered_count + 1
            returning answered_count
            """,
            (session_id, user_id, topic, difficulty, mode),
        )
        row = await found.fetchone()

    return row is not None and int(row["answered_count"]) == 1
