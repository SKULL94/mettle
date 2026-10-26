from functools import lru_cache
from pathlib import Path
from typing import Literal

from pydantic import field_validator
from pydantic_settings import BaseSettings, SettingsConfigDict

ProviderName = Literal["scripted", "anthropic"]
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
    llm_provider: ProviderName | None = None

    anthropic_api_key: str = ""
    anthropic_model: str = "claude-sonnet-5"
    grade_effort: str = "high"
    question_effort: str = "low"
    enable_fallbacks: bool = True

    database_url: str = "sqlite+aiosqlite:///./mettle.db"
    pg_pool_min: int = 1
    pg_pool_max: int = 10
    pg_disable_prepared_statements: bool = True

    cors_origins: str = "http://localhost:8080"
    log_level: str = "INFO"

    token_delay_ms: int = 24
    grade_delay_ms: int = 320

    @field_validator("llm_provider", mode="before")
    @classmethod
    def _blank_means_auto_detect(cls, value: object) -> object:
        if isinstance(value, str) and not value.strip():
            return None
        return value

    @property
    def has_api_key(self) -> bool:
        return bool(self.anthropic_api_key.strip())

    @property
    def resolved_provider(self) -> ProviderName:
        if self.llm_provider is None:
            return "anthropic" if self.has_api_key else "scripted"
        if self.llm_provider == "anthropic" and not self.has_api_key:
            return "scripted"
        return self.llm_provider

    @property
    def demo_mode(self) -> bool:
        return self.resolved_provider == "scripted"

    @property
    def reported_model(self) -> str:
        return "scripted" if self.demo_mode else self.anthropic_model

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
