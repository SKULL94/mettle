import json
from collections.abc import AsyncIterator

from anthropic import AsyncAnthropic

from ..graph.rubric import RUBRIC
from .base import GradeRequest, QuestionRequest, TurnScore

FALLBACK_BETA = "server-side-fallback-2026-07-01"

SCORE_SCHEMA = {
    "type": "object",
    "properties": {
        "correctness": {"type": "integer", "enum": [1, 2, 3, 4, 5]},
        "depth": {"type": "integer", "enum": [1, 2, 3, 4, 5]},
        "clarity": {"type": "integer", "enum": [1, 2, 3, 4, 5]},
        "structure": {"type": "integer", "enum": [1, 2, 3, 4, 5]},
        "missing": {"type": "array", "items": {"type": "string"}},
        "notes": {"type": "string"},
    },
    "required": ["correctness", "depth", "clarity", "structure", "missing", "notes"],
    "additionalProperties": False,
}

INTERVIEWER = """\
You are conducting a mock technical interview for a mobile engineer. Ask one
question at a time and nothing else: no preamble, no restatement of the topic,
no commentary on the previous answer, no markdown. Output only the question
text.

Keep it to two sentences at most. Ground it in a concrete situation the
candidate would actually hit rather than asking for a definition.

Do not include internal or system XML tags in your response.
"""


class ProviderRefused(Exception):
    def __init__(self, category: str | None) -> None:
        super().__init__(f"the model declined this request ({category or 'unspecified'})")
        self.category = category


class AnthropicProvider:
    def __init__(
        self,
        api_key: str,
        model: str,
        grade_effort: str = "high",
        question_effort: str = "low",
        enable_fallbacks: bool = True,
    ) -> None:
        self._client = AsyncAnthropic(api_key=api_key)
        self._model = model
        self._grade_effort = grade_effort
        self._question_effort = question_effort
        self._fallbacks: dict[str, object] = (
            {"betas": [FALLBACK_BETA], "fallbacks": "default"} if enable_fallbacks else {}
        )

    def keywords_for(self, topic: str, bank_index: int) -> list[str]:
        return []

    async def stream_question(self, req: QuestionRequest) -> AsyncIterator[str]:
        async with self._client.beta.messages.stream(
            model=self._model,
            max_tokens=1024,
            **self._fallbacks,
            thinking={"type": "disabled"},
            output_config={"effort": self._question_effort},
            system=[
                {
                    "type": "text",
                    "text": INTERVIEWER,
                    "cache_control": {"type": "ephemeral"},
                }
            ],
            messages=[{"role": "user", "content": self._question_prompt(req)}],
        ) as stream:
            async for chunk in stream.text_stream:
                yield chunk

            final = await stream.get_final_message()
            if final.stop_reason == "refusal":
                raise ProviderRefused(self._category(final))

    async def grade(self, req: GradeRequest) -> TurnScore:
        response = await self._client.beta.messages.create(
            model=self._model,
            max_tokens=4096,
            **self._fallbacks,
            thinking={"type": "adaptive"},
            output_config={
                "effort": self._grade_effort,
                "format": {"type": "json_schema", "schema": SCORE_SCHEMA},
            },
            system=[
                {
                    "type": "text",
                    "text": RUBRIC,
                    "cache_control": {"type": "ephemeral"},
                }
            ],
            messages=[{"role": "user", "content": self._grade_prompt(req)}],
        )

        if response.stop_reason == "refusal":
            raise ProviderRefused(self._category(response))

        text = next(
            (block.text for block in response.content if block.type == "text"),
            "",
        )
        return TurnScore.model_validate(json.loads(text))

    @staticmethod
    def _category(message: object) -> str | None:
        details = getattr(message, "stop_details", None)
        return getattr(details, "category", None)

    @staticmethod
    def _question_prompt(req: QuestionRequest) -> str:
        lines = [
            f"Topic: {req.topic}",
            f"Seniority: {req.seniority}",
            f"Question {req.index} of {req.total}.",
        ]

        if req.is_follow_up:
            lines += [
                "",
                "This is a follow-up on the previous answer, which was weakest on "
                f"{req.weak_dimension}. Probe that specific weakness rather than "
                "moving to a new area.",
                f"Previous question: {req.previous_question}",
                f"Their answer: {req.previous_answer}",
            ]
        elif req.asked:
            lines += ["", "Already asked, do not repeat:"]
            lines += [f"- {question}" for question in req.asked]

        return "\n".join(lines)

    @staticmethod
    def _grade_prompt(req: GradeRequest) -> str:
        lines = [f"Topic: {req.topic}", f"Question: {req.question}"]

        if req.keywords:
            lines.append(
                f"Concepts a complete answer would touch: {', '.join(req.keywords)}"
            )

        lines += ["", f"Candidate answer:\n{req.answer or '(no answer given)'}"]
        return "\n".join(lines)
