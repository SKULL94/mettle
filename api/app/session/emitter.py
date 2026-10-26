import asyncio
from collections.abc import AsyncIterator
from typing import Any

Event = tuple[str, dict[str, Any]]


class SessionEmitter:
    def __init__(self) -> None:
        self._queue: asyncio.Queue[Event | None] = asyncio.Queue()
        self._closed = False

    @property
    def closed(self) -> bool:
        return self._closed

    async def emit(self, event: str, data: dict[str, Any]) -> None:
        if self._closed:
            return
        await self._queue.put((event, data))

    async def close(self) -> None:
        if self._closed:
            return
        self._closed = True
        await self._queue.put(None)

    async def stream(self) -> AsyncIterator[Event]:
        while True:
            item = await self._queue.get()
            if item is None:
                return
            yield item
