from functools import lru_cache

from ..config import get_settings
from .base import LLMProvider
from .scripted import ScriptedProvider


@lru_cache
def get_provider() -> LLMProvider:
    settings = get_settings()

    if settings.resolved_provider == "anthropic":
        from .anthropic import AnthropicProvider

        return AnthropicProvider(
            api_key=settings.anthropic_api_key,
            model=settings.anthropic_model,
            grade_effort=settings.grade_effort,
            question_effort=settings.question_effort,
            enable_fallbacks=settings.enable_fallbacks,
        )

    return ScriptedProvider(
        token_delay_ms=settings.token_delay_ms,
        grade_delay_ms=settings.grade_delay_ms,
    )
