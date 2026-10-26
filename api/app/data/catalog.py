from functools import lru_cache
from pathlib import Path

import yaml
from pydantic import BaseModel, Field

TOPICS_PATH = Path(__file__).resolve().parent / "topics.yaml"

DIFFICULTY_ORDER = ("easy", "medium", "hard")


class Topic(BaseModel):
    id: str
    label: str
    covers: str
    difficulty: str = ""


class Difficulty(BaseModel):
    id: str
    label: str
    seniority: str
    brief: str
    topics: list[Topic] = Field(default_factory=list)


class UnknownTopic(Exception):
    pass


@lru_cache
def catalog() -> list[Difficulty]:
    raw = yaml.safe_load(TOPICS_PATH.read_text(encoding="utf-8"))

    levels: list[Difficulty] = []
    for key in DIFFICULTY_ORDER:
        entry = raw[key]
        topics = [
            Topic(
                id=item["id"],
                label=item["label"],
                covers=" ".join(item["covers"].split()),
                difficulty=key,
            )
            for item in entry["topics"]
        ]
        levels.append(
            Difficulty(
                id=key,
                label=entry["label"],
                seniority=entry["seniority"],
                brief=" ".join(entry["brief"].split()),
                topics=topics,
            )
        )
    return levels


@lru_cache
def _by_topic_id() -> dict[str, tuple[Difficulty, Topic]]:
    return {
        topic.id: (level, topic) for level in catalog() for topic in level.topics
    }


def resolve(topic_id: str) -> tuple[Difficulty, Topic]:
    found = _by_topic_id().get(topic_id)
    if found is None:
        raise UnknownTopic(topic_id)
    return found


def topic_ids() -> list[str]:
    return list(_by_topic_id())
