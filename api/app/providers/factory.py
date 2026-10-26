from functools import lru_cache

from ..config import get_settings
from .anthropic import AnthropicProvider


class ProviderNotConfigured(Exception):
    pass


@lru_cache
def get_provider() -> AnthropicProvider:
    settings = get_settings()

    if not settings.has_api_key:
        raise ProviderNotConfigured(
            "ANTHROPIC_API_KEY is not set, so no questions can be generated"
        )

    return AnthropicProvider(
        api_key=settings.anthropic_api_key,
        model=settings.anthropic_model,
        grade_effort=settings.grade_effort,
        question_effort=settings.question_effort,
        enable_fallbacks=settings.enable_fallbacks,
    )
