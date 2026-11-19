import logging
from dataclasses import dataclass
from typing import Annotated

from fastapi import Depends, Header, HTTPException, status

from ..config import get_settings
from .tokens import TokenError, decode, first_name_of, verify

log = logging.getLogger("mettle.auth")

LOCAL_USER = "local-dev-user"

_UNAUTHORIZED = HTTPException(
    status.HTTP_401_UNAUTHORIZED,
    "a valid bearer token is required",
    headers={"WWW-Authenticate": "Bearer"},
)


def _bearer(authorization: str | None) -> str:
    if not authorization:
        raise _UNAUTHORIZED

    scheme, _, token = authorization.partition(" ")
    if scheme.lower() != "bearer" or not token.strip():
        raise _UNAUTHORIZED

    return token.strip()


@dataclass(frozen=True)
class Principal:
    id: str
    first_name: str


async def require_principal(
    authorization: Annotated[str | None, Header()] = None,
) -> Principal:
    settings = get_settings()

    if not settings.auth_enforced:
        return Principal(id=LOCAL_USER, first_name="")

    try:
        claims = await decode(_bearer(authorization), settings)
    except TokenError as exc:
        log.info("rejected a token: %s", exc)
        raise _UNAUTHORIZED from None

    return Principal(id=str(claims["sub"]), first_name=first_name_of(claims))


async def require_user(
    authorization: Annotated[str | None, Header()] = None,
) -> str:
    settings = get_settings()

    if not settings.auth_enforced:
        return LOCAL_USER

    try:
        return await verify(_bearer(authorization), settings)
    except TokenError as exc:
        log.info("rejected a token: %s", exc)
        raise _UNAUTHORIZED from None


CurrentUser = Annotated[str, Depends(require_user)]
CurrentPrincipal = Annotated[Principal, Depends(require_principal)]
