from functools import lru_cache
from pathlib import Path
from typing import Literal

from pydantic_settings import BaseSettings, SettingsConfigDict

CheckpointBackend = Literal["sqlite", "postgres"]

API_DIR = Path(__file__).resolve().parent.parent
REPO_ROOT = API_DIR.parent

POSTGRES_PREFIXES = ("postgres://", "postgresql://", "postgresql+")
SQLALCHEMY_DRIVERS = (
    "postgresql+asyncpg://",
    "postgresql+psycopg://",
    "postgresql+psycopg2://",
)


class Settings(BaseSettings):
    model_config = SettingsConfigDict(
        env_file=(REPO_ROOT / ".env", API_DIR / ".env"),
        env_file_encoding="utf-8",
        extra="ignore",
    )

    version: str = "0.1.0"

    anthropic_api_key: str = ""
    anthropic_model: str = "claude-sonnet-5"
    grade_effort: str = "high"
    question_effort: str = "low"
    enable_fallbacks: bool = True

    database_url: str = "sqlite+aiosqlite:///./mettle.db"
    pg_pool_min: int = 1
    pg_pool_max: int = 10
    pg_disable_prepared_statements: bool = True

    supabase_url: str = ""
    supabase_jwt_secret: str = ""

    free_sessions_per_user: int = 3
    monthly_spend_cap_cents: int = 2000

    cors_origins: str = "http://localhost:8080"
    log_level: str = "INFO"

    @property
    def has_api_key(self) -> bool:
        return bool(self.anthropic_api_key.strip())

    @property
    def auth_enforced(self) -> bool:
        return bool(self.supabase_url.strip())

    @property
    def supabase_issuer(self) -> str:
        return f"{self.supabase_url.rstrip('/')}/auth/v1"

    @property
    def supabase_jwks_url(self) -> str:
        return f"{self.supabase_issuer}/.well-known/jwks.json"

    @property
    def checkpoint_backend(self) -> CheckpointBackend:
        return (
            "postgres"
            if self.database_url.startswith(POSTGRES_PREFIXES)
            else "sqlite"
        )

    @property
    def postgres_dsn(self) -> str:
        url = self.database_url
        for prefix in SQLALCHEMY_DRIVERS:
            if url.startswith(prefix):
                url = f"postgresql://{url[len(prefix) :]}"
                break
        if url.startswith("postgres://"):
            url = f"postgresql://{url[len('postgres://') :]}"

        host_is_local = "@localhost" in url or "@127.0.0.1" in url
        if "sslmode=" not in url and not host_is_local:
            url = f"{url}{'&' if '?' in url else '?'}sslmode=require"
        return url

    @property
    def uses_transaction_pooler(self) -> bool:
        return ":6543" in self.database_url

    @property
    def sqlite_path(self) -> str:
        prefix = "sqlite+aiosqlite:///"
        if self.database_url.startswith(prefix):
            return self.database_url[len(prefix) :]
        if self.database_url.startswith("sqlite:///"):
            return self.database_url[len("sqlite:///") :]
        return "./mettle.db"

    @property
    def origins(self) -> list[str]:
        return [origin.strip() for origin in self.cors_origins.split(",") if origin.strip()]


@lru_cache
def get_settings() -> Settings:
    return Settings()
