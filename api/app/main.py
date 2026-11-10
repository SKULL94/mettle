import logging
from collections.abc import AsyncIterator
from contextlib import asynccontextmanager

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from .api.v1.routes import router as v1_router
from .config import get_settings
from .graph.build import build_graph
from .session import registry
from .store.checkpointer import open_checkpointer

LOCAL_ORIGINS = r"http://(localhost|127\.0\.0\.1|10\.0\.2\.2)(:\d+)?"

log = logging.getLogger("mettle")


@asynccontextmanager
async def lifespan(app: FastAPI) -> AsyncIterator[None]:
    settings = get_settings()
    logging.basicConfig(
        level=getattr(logging, settings.log_level.upper(), logging.INFO),
        format="%(asctime)s %(levelname)s %(name)s %(message)s",
    )

    log.info(
        "starting version=%s model=%s configured=%s",
        settings.version,
        settings.anthropic_model,
        settings.has_api_key,
    )

    if not settings.has_api_key:
        log.warning("ANTHROPIC_API_KEY is not set; POST /v1/sessions will return 503")

    async with open_checkpointer(settings) as checkpointer:
        registry.set_graph(build_graph(checkpointer))
        yield

    log.info("shutdown complete")


def create_app() -> FastAPI:
    settings = get_settings()

    app = FastAPI(
        title="Mettle API",
        version=settings.version,
        lifespan=lifespan,
    )

    app.add_middleware(
        CORSMiddleware,
        allow_origins=settings.origins,
        allow_origin_regex=LOCAL_ORIGINS,
        allow_credentials=False,
        allow_methods=["*"],
        allow_headers=["*"],
    )

    app.include_router(v1_router, prefix="/v1")

    @app.get("/healthz")
    async def healthz() -> dict[str, str | bool]:
        return {
            "status": "ok",
            "model": settings.anthropic_model,
            "checkpointer": settings.checkpoint_backend,
            "configured": settings.has_api_key,
        }

    return app


app = create_app()
