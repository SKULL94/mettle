import logging
from datetime import UTC, datetime

from ..config import get_settings
from . import pool

log = logging.getLogger("mettle.quota")

CENTS_PER_QUESTION = {
    "claude-haiku-4-5": 1,
    "claude-sonnet-5": 5,
}
DEFAULT_CENTS_PER_QUESTION = 5


class QuotaExceeded(Exception):
    pass


class SpendCapReached(Exception):
    pass


def estimate_cents(question_count: int) -> int:
    model = get_settings().anthropic_model
    per_question = next(
        (cents for prefix, cents in CENTS_PER_QUESTION.items() if model.startswith(prefix)),
        DEFAULT_CENTS_PER_QUESTION,
    )
    return question_count * per_question


def _period() -> str:
    return datetime.now(UTC).strftime("%Y-%m")


async def claim(user_id: str, question_count: int) -> None:
    if not pool.enabled():
        return

    settings = get_settings()
    estimate = estimate_cents(question_count)

    async with pool.connection() as handle, handle.transaction():
        spend = await handle.execute(
            """
            insert into public.monthly_spend (period, cents)
            values (%s, %s)
            on conflict (period) do update
               set cents = monthly_spend.cents + excluded.cents,
                   updated_at = now()
            returning cents
            """,
            (_period(), estimate),
        )
        row = await spend.fetchone()
        if row is not None and int(row["cents"]) > settings.monthly_spend_cap_cents:
            log.error(
                "monthly spend cap reached: %s > %s cents",
                row["cents"],
                settings.monthly_spend_cap_cents,
            )
            raise SpendCapReached("the service is at its monthly budget, try again later")

        claimed = await handle.execute(
            """
            insert into public.user_quota (user_id, sessions_used, session_limit)
            values (%s, 1, %s)
            on conflict (user_id) do update
               set sessions_used = user_quota.sessions_used + 1,
                   updated_at = now()
             where user_quota.sessions_used < user_quota.session_limit
            returning sessions_used, session_limit
            """,
            (user_id, settings.free_sessions_per_user),
        )
        if await claimed.fetchone() is None:
            raise QuotaExceeded("you have used all of your free interviews")


async def remaining(user_id: str) -> int | None:
    if not pool.enabled():
        return None

    async with pool.connection() as handle:
        found = await handle.execute(
            "select sessions_used, session_limit from public.user_quota where user_id = %s",
            (user_id,),
        )
        row = await found.fetchone()

    if row is None:
        return get_settings().free_sessions_per_user
    return max(int(row["session_limit"]) - int(row["sessions_used"]), 0)
