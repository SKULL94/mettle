import asyncio
import contextlib
import uuid
from dataclasses import dataclass, field
from typing import Any

from langgraph.types import Command

from ..graph.state import initial_state
from . import bus
from .emitter import SessionEmitter


class SessionConflict(Exception):
    pass


class UnknownSession(Exception):
    pass


_graph: Any = None
_handles: dict[str, "SessionHandle"] = {}


def set_graph(graph: Any) -> None:
    global _graph
    _graph = graph


def graph() -> Any:
    if _graph is None:
        raise RuntimeError("graph is not configured")
    return _graph


@dataclass
class SessionHandle:
    session_id: str
    topic: str
    seniority: str
    question_total: int
    device_id: str
    emitter: SessionEmitter
    started: bool = False
    finished: bool = False
    lock: asyncio.Lock = field(default_factory=asyncio.Lock)
    inbox: asyncio.Queue[Any] = field(default_factory=asyncio.Queue)
    consumed: set[str] = field(default_factory=set)
    worker: asyncio.Task[None] | None = None

    @property
    def config(self) -> dict[str, Any]:
        return {"configurable": {"thread_id": self.session_id}}

    async def snapshot(self) -> dict[str, Any]:
        state = await graph().aget_state(self.config)
        return dict(state.values or {})

    async def attach(self) -> None:
        async with self.lock:
            if not self.started:
                self.started = True
                self.worker = asyncio.create_task(self._drain())
                await self.inbox.put(
                    initial_state(
                        session_id=self.session_id,
                        topic=self.topic,
                        seniority=self.seniority,
                        question_total=self.question_total,
                    )
                )
                return

            if self.worker is None or self.worker.done():
                self.worker = asyncio.create_task(self._drain())

            await self._replay_pending()

    async def _replay_pending(self) -> None:
        values = await self.snapshot()
        pending = values.get("pending")
        if pending is None:
            return

        await self.emitter.emit(
            "turn.started",
            {
                "index": pending["index"],
                "total": pending["total"],
                "kind": pending["kind"],
                "reason": pending["reason"],
                "topic": self.topic,
            },
        )
        await self.emitter.emit(
            "question.done",
            {
                "question_id": pending["question_id"],
                "text": pending["text"],
                "index": pending["index"],
                "total": pending["total"],
                "kind": pending["kind"],
                "reason": pending["reason"],
            },
        )

    async def submit(self, turn_id: str, answer: str) -> None:
        async with self.lock:
            if self.finished or turn_id in self.consumed:
                return

            values = await self.snapshot()
            pending = values.get("pending")

            if pending is None or pending["question_id"] != turn_id:
                history = values.get("history") or []
                if any(turn["question_id"] == turn_id for turn in history):
                    return
                raise SessionConflict("turn_id does not match the pending question")

            self.consumed.add(turn_id)
            await self.inbox.put(Command(resume=answer))

    async def _drain(self) -> None:
        while True:
            payload = await self.inbox.get()
            try:
                await graph().ainvoke(payload, self.config)
            except asyncio.CancelledError:
                raise
            except Exception as exc:
                await self.emitter.emit(
                    "error",
                    {
                        "code": "graph_failed",
                        "message": str(exc) or "the interview could not continue",
                        "retryable": True,
                    },
                )
                continue

            values = await self.snapshot()
            if values.get("scorecard") is not None:
                self.finished = True
                await self.emitter.close()
                return


async def create(
    topic: str,
    seniority: str,
    question_count: int,
    device_id: str,
) -> SessionHandle:
    session_id = f"sesn_{uuid.uuid4().hex[:16]}"
    handle = SessionHandle(
        session_id=session_id,
        topic=topic,
        seniority=seniority,
        question_total=question_count,
        device_id=device_id,
        emitter=bus.register(session_id),
    )
    _handles[session_id] = handle
    return handle


async def get(session_id: str) -> SessionHandle:
    handle = _handles.get(session_id)
    if handle is not None:
        return handle

    state = await graph().aget_state({"configurable": {"thread_id": session_id}})
    values = dict(state.values or {})
    if not values.get("topic"):
        raise UnknownSession(session_id)

    history = values.get("history") or []
    handle = SessionHandle(
        session_id=session_id,
        topic=str(values["topic"]),
        seniority=str(values.get("seniority") or "senior"),
        question_total=int(values.get("question_total") or 0),
        device_id="",
        emitter=bus.register(session_id),
        started=True,
        finished=values.get("scorecard") is not None,
        consumed={str(turn["question_id"]) for turn in history},
    )
    _handles[session_id] = handle
    return handle


async def remove(session_id: str) -> None:
    handle = _handles.pop(session_id, None)
    if handle is not None and handle.worker is not None:
        handle.worker.cancel()
        with contextlib.suppress(asyncio.CancelledError):
            await handle.worker
    await bus.drop(session_id)
