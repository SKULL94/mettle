import json
from collections.abc import AsyncIterator

from anthropic import AsyncAnthropic

from ..graph.rubric import RUBRIC
from .base import GradeRequest, QuestionRequest, TurnScore

FALLBACK_BETA = "server-side-fallback-2026-07-01"

NO_TUNING_PREFIXES = ("claude-haiku-4-5", "claude-sonnet-4-5")

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
You are conducting a mock technical interview for a **Flutter** engineer
working in Dart. Every question must be about Flutter and Dart specifically -
widgets, elements, BuildContext, the widget lifecycle, bloc or other Flutter
state management, Dart isolates and the event loop, Flutter rendering and
raster performance, go_router, flutter_test.

Never ask about React Native, Jetpack Compose, SwiftUI, RecyclerView,
FlatList, UIKit, or any other framework. The topic name you are given refers to
the Flutter concept of that name - "keys" means Flutter's Key, ValueKey and
GlobalKey, not map keys or database keys.

Ask one question at a time and nothing else: no preamble, no restatement of the
topic, no commentary on the previous answer, no markdown. Output only the
question text.

Keep it to two sentences at most. Ground it in a concrete situation a Flutter
developer would actually hit rather than asking for a definition.

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
        self._supports_tuning = not model.startswith(NO_TUNING_PREFIXES)

    def _question_tuning(self) -> dict[str, object]:
        if not self._supports_tuning:
            return {"thinking": {"type": "disabled"}}
        return {
            "thinking": {"type": "disabled"},
            "output_config": {"effort": self._question_effort},
        }

    def _grade_tuning(self) -> dict[str, object]:
        schema = {"type": "json_schema", "schema": SCORE_SCHEMA}
        if not self._supports_tuning:
            return {"output_config": {"format": schema}}
        return {
            "thinking": {"type": "adaptive"},
            "output_config": {"effort": self._grade_effort, "format": schema},
        }

    async def stream_question(self, req: QuestionRequest) -> AsyncIterator[str]:
        async with self._client.beta.messages.stream(
            model=self._model,
            max_tokens=1024,
            **self._fallbacks,
            **self._question_tuning(),
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
            **self._grade_tuning(),
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
            f"Level: {req.difficulty} ({req.seniority})",
            req.difficulty_brief,
            "",
            f"Topic: {req.topic_label}",
            f"This topic covers: {req.topic_covers}",
            "",
            f"Question {req.index} of {req.total}.",
            "Stay inside this topic and pitch it at the level above.",
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
        return "\n".join(
            [
                f"Topic: {req.topic_label}",
                f"Level: {req.difficulty} - asked of a {req.seniority} developer.",
                "Judge the answer against the anchors exactly as written. Do not"
                " soften them for a junior or raise them for a senior; the question"
                " already carries the level.",
                "",
                f"Question: {req.question}",
                "",
                f"Candidate answer:\n{req.answer or '(no answer given)'}",
            ]
        )
