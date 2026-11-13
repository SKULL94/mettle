import logging
from collections.abc import AsyncIterator
from contextlib import asynccontextmanager
from typing import Any

from ..config import Settings

log = logging.getLogger("mettle.store")

_pool: Any = None


async def open_pool(settings: Settings) -> None:
    global _pool

    if settings.checkpoint_backend != "postgres":
        log.warning("DATABASE_URL is not postgres, so quotas and result persistence are disabled")
        return

    from psycopg.rows import dict_row
    from psycopg_pool import AsyncConnectionPool

    kwargs: dict[str, Any] = {"autocommit": True, "row_factory": dict_row}
    if settings.pg_disable_prepared_statements:
        kwargs["prepare_threshold"] = None

    pool = AsyncConnectionPool(
        conninfo=settings.postgres_dsn,
        min_size=settings.pg_pool_min,
        max_size=settings.pg_pool_max,
        kwargs=kwargs,
        open=False,
    )
    await pool.open(wait=True, timeout=15)
    _pool = pool
    await _migrate()
    log.info("store pool open")


async def close_pool() -> None:
    global _pool

    if _pool is not None:
        await _pool.close()
        _pool = None


def enabled() -> bool:
    return _pool is not None


@asynccontextmanager
async def connection() -> AsyncIterator[Any]:
    if _pool is None:
        raise RuntimeError("the store pool is not open")
    async with _pool.connection() as handle:
        yield handle


SCHEMA = """
create table if not exists public.user_quota (
  user_id        uuid primary key,
  sessions_used  int  not null default 0,
  session_limit  int  not null default 3,
  updated_at     timestamptz not null default now()
);

create table if not exists public.monthly_spend (
  period         text primary key,
  cents          int  not null default 0,
  updated_at     timestamptz not null default now()
);

alter table public.user_quota    enable row level security;
alter table public.monthly_spend enable row level security;

create table if not exists public.sessions (
  id            text primary key,
  user_id       uuid not null references auth.users on delete cascade,
  topic         text not null,
  difficulty    text not null,
  model         text not null,
  overall       int  not null,
  correctness   int  not null,
  depth         int  not null,
  clarity       int  not null,
  structure     int  not null,
  missing       jsonb not null default '[]',
  completed_at  timestamptz not null default now()
);

create table if not exists public.turns (
  id            bigint generated always as identity primary key,
  session_id    text not null references public.sessions on delete cascade,
  ordinal       int  not null,
  position      int  not null,
  question_id   text not null,
  question      text not null,
  total         int  not null,
  kind          text not null,
  reason        text,
  answer        text not null default '',
  correctness   int,
  depth         int,
  clarity       int,
  structure     int,
  missing       jsonb not null default '[]',
  unique (session_id, ordinal)
);

create index if not exists sessions_user_completed_idx
  on public.sessions (user_id, completed_at desc);

alter table public.sessions enable row level security;
alter table public.turns    enable row level security;

drop policy if exists "own sessions" on public.sessions;
create policy "own sessions" on public.sessions
  for select using (auth.uid() = user_id);

drop policy if exists "own turns" on public.turns;
create policy "own turns" on public.turns
  for select using (
    exists (
      select 1 from public.sessions s
      where s.id = turns.session_id and s.user_id = auth.uid()
    )
  );
"""


async def _migrate() -> None:
    async with connection() as handle:
        await handle.execute(SCHEMA)
