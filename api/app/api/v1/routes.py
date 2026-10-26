import json
from collections.abc import AsyncIterator
from typing import Annotated, Any

from fastapi import APIRouter, Header, HTTPException, Response, status
from sse_starlette.sse import EventSourceResponse

from ...config import get_settings
from ...data.catalog import UnknownTopic, catalog, resolve
from ...providers.factory import ProviderNotConfigured, get_provider
from ...schemas.wire import (
    AnswerRequest,
    CatalogResponse,
    CreateSessionRequest,
    CreateSessionResponse,
    DifficultyOut,
    MetaResponse,
    ScorecardResponse,
    SessionStateResponse,
    SkipRequest,
    TopicOut,
)
from ...session import registry

router = APIRouter()

DeviceId = Annotated[str, Header(alias="X-Device-Id")]


async def _handle(session_id: str) -> registry.SessionHandle:
    try:
        return await registry.get(session_id)
    except registry.UnknownSession:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "unknown session") from None


@router.get("/meta", response_model=MetaResponse)
async def meta() -> MetaResponse:
    settings = get_settings()
    return MetaResponse(
        version=settings.version,
        model=settings.reported_model,
        demo_mode=settings.demo_mode,
        configured=settings.has_api_key,
    )


@router.get("/topics", response_model=CatalogResponse)
async def topics() -> CatalogResponse:
    return CatalogResponse(
        difficulties=[
            DifficultyOut(
                id=level.id,
                label=level.label,
                seniority=level.seniority,
                topics=[
                    TopicOut(id=t.id, label=t.label, covers=t.covers)
                    for t in level.topics
                ],
            )
            for level in catalog()
        ]
    )


@router.post(
    "/sessions",
    response_model=CreateSessionResponse,
    status_code=status.HTTP_201_CREATED,
)
async def create_session(
    body: CreateSessionRequest,
    x_device_id: DeviceId = "anonymous",
) -> CreateSessionResponse:
    try:
        get_provider()
    except ProviderNotConfigured as exc:
        raise HTTPException(
            status.HTTP_503_SERVICE_UNAVAILABLE, str(exc)
        ) from None

    try:
        level, _ = resolve(body.topic)
    except UnknownTopic:
        raise HTTPException(
            status.HTTP_400_BAD_REQUEST, f"unknown topic: {body.topic}"
        ) from None

    handle = await registry.create(
        topic=body.topic,
        difficulty=level.id,
        question_count=body.question_count,
        device_id=x_device_id,
    )
    return CreateSessionResponse(
        session_id=handle.session_id,
        first_turn_url=f"/v1/sessions/{handle.session_id}/turns/stream",
    )


@router.get("/sessions/{session_id}", response_model=SessionStateResponse)
async def get_session(session_id: str) -> SessionStateResponse:
    handle = await _handle(session_id)
    values = await handle.snapshot()
    return SessionStateResponse(
        session_id=session_id,
        topic=handle.topic,
        question_total=handle.question_total,
        asked_count=int(values.get("asked_count") or 0),
        questions_remaining=int(values.get("questions_remaining") or handle.question_total),
        pending=values.get("pending"),
        history=list(values.get("history") or []),
        finished=handle.finished,
    )


@router.get("/sessions/{session_id}/turns/stream")
async def stream_turns(session_id: str) -> EventSourceResponse:
    handle = await _handle(session_id)
    await handle.attach()

    async def publisher() -> AsyncIterator[dict[str, Any]]:
        async for event, data in handle.emitter.stream():
            yield {"event": event, "data": json.dumps(data, separators=(",", ":"))}

    return EventSourceResponse(publisher())


@router.post("/sessions/{session_id}/answer", status_code=status.HTTP_202_ACCEPTED)
async def submit_answer(session_id: str, body: AnswerRequest) -> Response:
    handle = await _handle(session_id)
    try:
        await handle.submit(body.turn_id, body.answer)
    except registry.SessionConflict as exc:
        raise HTTPException(status.HTTP_409_CONFLICT, str(exc)) from None
    return Response(status_code=status.HTTP_202_ACCEPTED)


@router.post("/sessions/{session_id}/skip", status_code=status.HTTP_202_ACCEPTED)
async def skip_question(session_id: str, body: SkipRequest) -> Response:
    handle = await _handle(session_id)
    try:
        await handle.submit(body.turn_id, "")
    except registry.SessionConflict as exc:
        raise HTTPException(status.HTTP_409_CONFLICT, str(exc)) from None
    return Response(status_code=status.HTTP_202_ACCEPTED)


@router.get("/sessions/{session_id}/scorecard", response_model=ScorecardResponse)
async def get_scorecard(session_id: str) -> ScorecardResponse:
    handle = await _handle(session_id)
    values = await handle.snapshot()
    scorecard = values.get("scorecard")
    if scorecard is None:
        raise HTTPException(status.HTTP_409_CONFLICT, "the interview is not finished")
    return ScorecardResponse.model_validate(scorecard)


@router.delete("/sessions/{session_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_session(session_id: str) -> Response:
    await registry.remove(session_id)
    return Response(status_code=status.HTTP_204_NO_CONTENT)
