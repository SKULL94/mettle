import asyncio
from functools import lru_cache
from typing import Any

import jwt
from jwt import PyJWKClient

from ..config import Settings

ASYMMETRIC_ALGORITHMS = ("RS256", "ES256")
SYMMETRIC_ALGORITHMS = ("HS256",)
AUDIENCE = "authenticated"
JWKS_LIFESPAN_SECONDS = 3600


class TokenError(Exception):
    pass


@lru_cache
def _jwk_client(jwks_url: str) -> PyJWKClient:
    return PyJWKClient(jwks_url, cache_keys=True, lifespan=JWKS_LIFESPAN_SECONDS)


def _algorithm_of(token: str) -> str:
    try:
        header = jwt.get_unverified_header(token)
    except jwt.PyJWTError as exc:
        raise TokenError("the token header could not be read") from exc

    algorithm = header.get("alg")
    if not isinstance(algorithm, str):
        raise TokenError("the token does not declare a signing algorithm")
    return algorithm


async def _signing_key(token: str, jwks_url: str) -> Any:
    client = _jwk_client(jwks_url)
    try:
        key = await asyncio.to_thread(client.get_signing_key_from_jwt, token)
    except Exception as exc:
        raise TokenError("the signing key could not be resolved") from exc
    return key.key


async def verify(token: str, settings: Settings) -> str:
    algorithm = _algorithm_of(token)

    if algorithm in SYMMETRIC_ALGORITHMS:
        secret = settings.supabase_jwt_secret.strip()
        if not secret:
            raise TokenError("the token is HS256 but no SUPABASE_JWT_SECRET is configured")
        key: Any = secret
        algorithms = list(SYMMETRIC_ALGORITHMS)
    elif algorithm in ASYMMETRIC_ALGORITHMS:
        key = await _signing_key(token, settings.supabase_jwks_url)
        algorithms = list(ASYMMETRIC_ALGORITHMS)
    else:
        raise TokenError(f"unsupported signing algorithm: {algorithm}")

    try:
        claims = jwt.decode(
            token,
            key,
            algorithms=algorithms,
            audience=AUDIENCE,
            issuer=settings.supabase_issuer,
            options={"require": ["exp", "sub", "aud", "iss"]},
        )
    except jwt.PyJWTError as exc:
        raise TokenError(str(exc) or "the token is not valid") from exc

    subject = claims.get("sub")
    if not isinstance(subject, str) or not subject:
        raise TokenError("the token carries no subject")
    return subject
