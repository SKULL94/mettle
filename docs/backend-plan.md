# Mettle — Backend Architecture

FastAPI + LangGraph service backing the Flutter app. Companion to
[`product-plan.md`](./product-plan.md); Flutter conventions in [`../CONVENTIONS.md`](../CONVENTIONS.md).

**Design goal:** the graph is the product. A reviewer should be able to read `graph/build.py` and see
the interview logic in twenty lines — and run the whole stack with no API key.

---

## 1. Stack

| Concern | Choice | Why |
|---|---|---|
| Web framework | FastAPI, async throughout | SSE streaming, Pydantic v2 validation, DI via `Depends` |
| Agent runtime | LangGraph `StateGraph` | Conditional edges + checkpointer + `interrupt()` are exactly this problem |
| Model | A frontier hosted LLM, reached through the provider adapter | Grading quality *is* the product; the effort dial is the cost lever, not a model downgrade |
| Checkpoints | `AsyncSqliteSaver` (dev) → `AsyncPostgresSaver` (prod) | Durable resume, swap by env var |
| Read models | SQLite / Postgres, 2 tables | Checkpoints are opaque blobs — you can't query "my last 10 sessions" from them |
| Deps / tooling | `uv`, `ruff`, `mypy --strict`, `pytest` | Fast, no Poetry ceremony |

---

## 2. The graph

An interview is a genuine state machine, which is the whole reason LangGraph earns its place here:
ask → listen → *either probe deeper or move on* → grade → summarize. That branch is a conditional
edge, the pause for an answer is an `interrupt()`, and the resume-after-days is a checkpointer.

```mermaid
stateDiagram-v2
    [*] --> plan_interview
    plan_interview --> ask_question
    ask_question --> await_answer
    await_answer --> grade_answer: answer submitted
    grade_answer --> ask_question: weak answer & depth < 2<br/>(follow-up)
    grade_answer --> ask_question: questions remaining<br/>(new topic)
    grade_answer --> summarize: budget exhausted
    summarize --> [*]
```

### State

```python
class InterviewState(TypedDict):
    session_id: str
    role: str                    # "flutter"
    seniority: str               # "senior"
    topic: str                   # "state-management"
    questions_remaining: int
    history: list[Turn]          # question + answer + score
    pending: Question | None     # awaiting an answer
    follow_up_depth: int         # 0..2 — hard cap on probing
    scorecard: Scorecard | None
```

### Nodes

| Node | Does |
|---|---|
| `plan_interview` | Chooses question areas from role + seniority + topic. Runs once. |
| `ask_question` | Generates the next question — or a follow-up conditioned on the weak dimension of the last answer. Streams tokens out. |
| `await_answer` | `interrupt()`. The graph parks here; the checkpointer persists everything. |
| `grade_answer` | Scores against the rubric via structured output → `TurnScore`. |
| `summarize` | Aggregates turns into a `Scorecard` with per-dimension totals and weak topics. |

### The conditional edge — the one piece of logic that matters

```python
def route_after_grade(state: InterviewState) -> str:
    last = state["history"][-1].score
    if last.weakest_dimension_score <= 2 and state["follow_up_depth"] < 2:
        return "ask_question"        # probe deeper, same topic
    if state["questions_remaining"] > 0:
        return "ask_question"        # advance
    return "summarize"
```

**This function is the project.** It's what makes the `↳ FOLLOW-UP` badge in the UI truthful, it's
what you point at when asked "why a graph and not one prompt?", and it's the thing a reviewer can
understand in ten seconds. Keep it this small.

`graph.get_graph().draw_mermaid()` renders the diagram above — generate it in CI and commit it so the
README's diagram can never drift from the code.

---

## 3. HTTP surface

```
POST   /v1/sessions                      create → {session_id, first_turn_url}
GET    /v1/sessions/{id}                 full state (cold reconnect, history)
GET    /v1/sessions/{id}/turns/stream    SSE: question tokens + grade events
POST   /v1/sessions/{id}/answer          submit answer → 202
POST   /v1/sessions/{id}/skip            skip current question → 202
GET    /v1/sessions/{id}/scorecard       final scorecard
GET    /v1/sessions?device_id=…          history list (read model)
GET    /v1/meta                          {version, model, demo_mode}
GET    /healthz                          liveness
```

### Why answer-submit and streaming are separate calls

`POST /answer` returns `202` immediately; the client then opens `GET /turns/stream` for the next
question's tokens. A single `POST` that returns `text/event-stream` would be more elegant and is
tempting — but `EventSource` on the web only does GET, so a POST stream forces a `fetch`-based HTTP
client on Flutter web. Two cheap round-trips beat a platform-specific transport on a primary target.

`POST /answer` takes a client-generated `turn_id` and is **idempotent** — a mobile retry after a
dropped connection can't double-submit an answer.

### SSE event protocol (versioned — the Flutter app depends on this)

```
event: turn.started     data: {"turn":3,"kind":"follow_up","reason":"depth","topic":"keys"}
event: question.delta   data: {"text":"What actually "}
event: question.done    data: {"question_id":"q_…","text":"…"}
event: grade.started    data: {}
event: grade.done       data: {"correctness":3,"depth":2,"clarity":4,"structure":3,"notes":"…"}
event: session.done     data: {"scorecard_url":"/v1/sessions/…/scorecard"}
event: error            data: {"code":"provider_unavailable","retryable":true}
```

Named events with typed payloads, not a bag of JSON on a single channel. **`turn.started` carrying
`kind: "follow_up"` and the `reason` is what drives the badge on the Interview screen** — the graph's
routing decision travels over the wire as a first-class event rather than being inferred client-side.

---

## 4. The provider abstraction — the highest-signal detail in the repo

```python
class LLMProvider(Protocol):
    def stream_question(self, req: QuestionRequest) -> AsyncIterator[str]: ...
    async def grade(self, req: GradeRequest) -> TurnScore: ...
```

| Implementation | Behavior |
|---|---|
| `AnthropicProvider` | Real hosted-model calls. |
| `ScriptedProvider` | Deterministic. Questions from `data/questions.yaml`, grading by rubric keyword coverage. Zero network. |

Selected by `settings.llm_provider`, **defaulting to `scripted` whenever no API key is present**. So:

- `docker compose up` works for a reviewer in 30 seconds with no credentials
- CI runs the full suite — graph routing included — with no secrets and no flake
- The Flutter app's demo mode is the same code path, not a mock

This is the detail that converts "interesting repo" into "this person has shipped things." Most
portfolio AI projects can't be run at all by the person evaluating them.

---

## 5. Working with the model

**Structured output for grading.** The provider's schema-validated parse path, handed a Pydantic
`TurnScore`, validates the response for you — no JSON coaxing, no retry-on-parse loop, no
assistant-prefill tricks.

```python
class TurnScore(BaseModel):
    correctness: int   # 1-5
    depth: int
    clarity: int
    structure: int
    missing: list[str]
    notes: str
```

**Reasoning is on by default — tune it with effort, not a token budget.** The target model tier
reasons adaptively without configuration; the `effort` dial is the quality/latency control. Start
`high` for grading (it's the product) and `medium` for question generation (latency is user-visible
there), then sweep against your own saved transcripts. The output-token cap covers reasoning *plus*
visible output, so leave headroom or answers truncate mid-sentence.

**No sampling parameters.** The target tier rejects `temperature`, `top_p`, and `top_k` outright.
Consistency in grading therefore comes from a fixed rubric with explicit per-level anchors — which is
the better mechanism regardless, since `temperature=0` never guaranteed determinism.

**Prompt caching is a large real win here.** The rubric plus system prompt is byte-identical across
every turn and every session, so put the cache breakpoint on the last system block. Guard it: keep
timestamps and session IDs *out* of the system prompt, or the prefix changes per request and nothing
caches.

**Mind the per-model cache floor — it is not uniform.** The minimum cacheable prefix is 512 tokens on
Opus 5 but **1024 on Sonnet 5**, and a prefix under the floor silently does not cache: no error, just
`cache_creation_input_tokens: 0` forever. The first rubric written here measured 483 tokens and
therefore never cached on Sonnet. Expanding it to explicit per-level anchors plus two calibration
examples brought it to 1324 tokens, which both clears the floor and is the mechanism the rubric was
supposed to provide in the first place. Measured on `claude-sonnet-5`: 1771 tokens written on the
first grade call, then read from cache on every subsequent one with ~102 uncached. Assert on
`usage.cache_read_input_tokens` in a provider test rather than trusting that it engaged.

**Handle refusals.** This matters more than it looks: a user practising for a **security** role asks
for security interview questions, which can legitimately trip a provider's safety classifiers. A
refusal arrives as a *successful* HTTP 200 with a refusal stop reason and no usable content — so
branch on the stop reason before reading the body, and configure a fallback model so a declined
request is re-served instead of dead-ending mid-interview.

---

## 6. Persistence

Two stores, each with a clear job:

- **Checkpoints** (`AsyncSqliteSaver` / `AsyncPostgresSaver`), `thread_id = session_id`. Owns live
  graph state and makes resume-after-days free.
- **Read models**, two tables — `sessions` and `turns`. Owns everything the API must *query*:
  history lists, score trends, weak-topic aggregation.

The read model exists because checkpoints are opaque blobs. Without it, rendering the Progress screen
would mean rehydrating N graphs. Two tables is the whole schema — don't let it grow into a second
source of truth for live state.

---

## 7. Identity

No auth, per the product decision. A `X-Device-Id` header carries a client-generated UUID, used only
to scope `thread_id` and the history list. **This is partitioning, not security** — say so in the
README rather than implying it authenticates anyone. No user table, no JWT, no session middleware.

---

## 8. Layout

```
api/
├── app/
│   ├── main.py              app factory, CORS, lifespan
│   ├── config.py            pydantic-settings
│   ├── api/v1/routes.py     thin — validate, call service, return
│   ├── schemas/             wire contract (request/response models)
│   ├── graph/
│   │   ├── state.py
│   │   ├── nodes.py
│   │   ├── rubric.py        the rubric text — one constant, cached
│   │   └── build.py         StateGraph assembly + compile
│   ├── providers/
│   │   ├── base.py          the Protocol
│   │   ├── anthropic.py
│   │   └── scripted.py
│   ├── store/               repositories + migrations
│   └── data/questions.yaml
├── tests/
├── Dockerfile
└── pyproject.toml
```

Same dependency discipline as the Flutter side: `routes` know nothing about the provider SDK,
`graph` knows only the `LLMProvider` Protocol, and `providers` know nothing about HTTP.

---

## 9. Testing

| Layer | Asserts |
|---|---|
| Graph routing | **A weak answer routes to a follow-up; a strong one advances.** The single most important test in the repo. |
| Graph resume | Interrupt mid-session, rebuild from the checkpointer, continue — state intact |
| Routes | `httpx.AsyncClient` against the app, `ScriptedProvider` injected |
| SSE contract | Event names and ordering match §3 — this is what the Flutter client parses |
| Providers | `ScriptedProvider` is deterministic; `AnthropicProvider` request-shaping tested against a recorded response |

CI makes **no network calls**. `ruff`, `mypy --strict`, `pytest` all green with zero secrets
configured — which is also what makes the badges meaningful rather than decorative.

---

## 10. Ops

- Multi-stage `Dockerfile` on `uv`; `docker compose up` brings up api + Postgres with seeded data
- `/healthz` liveness, `/v1/meta` exposing version + model + `demo_mode` so the app can show a
  `DEMO MODE` chip truthfully
- CORS restricted to the GitHub Pages origin; HTTPS both ends
- Structured JSON logs with a per-session correlation id; log the provider's `request_id` on failures
- Deploy to Fly.io free tier; GitHub Actions runs lint + types + tests, then builds the image

---

## 11. Build order

1. `ScriptedProvider` + `questions.yaml` — a working fake before anything real
2. State, nodes, and the conditional edge; routing tests passing with no network
3. SQLite checkpointer; resume test
4. FastAPI routes + the SSE event protocol; contract tests
5. `AnthropicProvider` with structured-output grading and prompt caching
6. Read models + history/trend endpoints
7. Docker, compose, CI, deploy

Steps 1–4 produce a fully testable backend with no API key and no model calls — which means the
Flutter app (building against fakes per the product plan) and the backend converge on a contract that
both sides have already tested independently.
