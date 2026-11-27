import logging

import httpx

from ..config import get_settings
from . import pool

log = logging.getLogger("mettle.account")

IDENTITY_TIMEOUT = 15.0


class IdentityDeleteFailed(Exception):
    pass


async def purge_data(user_id: str) -> None:
    if not pool.enabled():
        return

    async with pool.connection() as handle, handle.transaction():
        await handle.execute(
            "delete from public.sessions where user_id = %s", (user_id,)
        )
        await handle.execute(
            "delete from public.user_quota where user_id = %s", (user_id,)
        )


async def delete_identity(user_id: str) -> None:
    settings = get_settings()

    if not settings.can_delete_accounts:
        log.warning(
            "SUPABASE_SECRET_KEY is not set, so %s keeps its sign-in after a "
            "delete request",
            user_id,
        )
        return

    url = f"{settings.supabase_admin_users_url}/{user_id}"
    headers = {
        "apikey": settings.supabase_secret_key,
        "Authorization": f"Bearer {settings.supabase_secret_key}",
    }

    async with httpx.AsyncClient(timeout=IDENTITY_TIMEOUT) as client:
        response = await client.delete(url, headers=headers)

    if response.status_code in (200, 204, 404):
        return

    log.error(
        "supabase refused to delete user: status=%s body=%s",
        response.status_code,
        response.text[:200],
    )
    raise IdentityDeleteFailed(str(response.status_code))


async def delete(user_id: str) -> None:
    await purge_data(user_id)
    await delete_identity(user_id)
