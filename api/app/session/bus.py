from .emitter import SessionEmitter

_emitters: dict[str, SessionEmitter] = {}


def register(session_id: str) -> SessionEmitter:
    emitter = _emitters.get(session_id)
    if emitter is None:
        emitter = SessionEmitter()
        _emitters[session_id] = emitter
    return emitter


def emitter_for(session_id: str) -> SessionEmitter | None:
    return _emitters.get(session_id)


async def drop(session_id: str) -> None:
    emitter = _emitters.pop(session_id, None)
    if emitter is not None:
        await emitter.close()
