import logging
from collections.abc import AsyncIterator
from contextlib import asynccontextmanager
from typing import Any

from ..config import Settings

log = logging.getLogger(__name__)


@asynccontextmanager
async def open_checkpointer(settings: Settings) -> AsyncIterator[Any]:
    if settings.checkpoint_backend == "postgres":
        async with _postgres(settings) as saver:
            yield saver
    else:
        async with _sqlite(settings) as saver:
            yield saver


@asynccontextmanager
async def _sqlite(settings: Settings) -> AsyncIterator[Any]:
    from langgraph.checkpoint.sqlite.aio import AsyncSqliteSaver

    log.info("checkpointer=sqlite path=%s", settings.sqlite_path)
    async with AsyncSqliteSaver.from_conn_string(settings.sqlite_path) as saver:
        yield saver


@asynccontextmanager
async def _postgres(settings: Settings) -> AsyncIterator[Any]:
    from langgraph.checkpoint.postgres.aio import AsyncPostgresSaver
    from psycopg.rows import dict_row
    from psycopg_pool import AsyncConnectionPool

    connection_kwargs: dict[str, Any] = {"autocommit": True, "row_factory": dict_row}

    if settings.pg_disable_prepared_statements:
        connection_kwargs["prepare_threshold"] = None

    log.info(
        "checkpointer=postgres pool=%s-%s prepared_statements=%s pooler=%s",
        settings.pg_pool_min,
        settings.pg_pool_max,
        not settings.pg_disable_prepared_statements,
        "transaction" if settings.uses_transaction_pooler else "session/direct",
    )

    if settings.uses_transaction_pooler and not settings.pg_disable_prepared_statements:
        log.warning(
            "port 6543 is Supabase's transaction pooler, which does not support "
            "prepared statements. Set PG_DISABLE_PREPARED_STATEMENTS=true or use "
            "the direct connection on port 5432."
        )

    pool = AsyncConnectionPool(
        conninfo=settings.postgres_dsn,
        min_size=settings.pg_pool_min,
        max_size=settings.pg_pool_max,
        kwargs=connection_kwargs,
        open=False,
    )

    await pool.open(wait=True, timeout=15)
    try:
        saver = AsyncPostgresSaver(pool)
        await saver.setup()
        yield saver
    finally:
        await pool.close()
