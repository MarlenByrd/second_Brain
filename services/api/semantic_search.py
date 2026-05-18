"""Semantic search prototype over in-memory vectors."""
from __future__ import annotations

from dataclasses import dataclass
from typing import Iterable


@dataclass
class Item:
    id: str
    text: str
    vector: list[float]


def cosine(a: list[float], b: list[float]) -> float:
    dot = sum(x * y for x, y in zip(a, b))
    na = sum(x * x for x in a) ** 0.5
    nb = sum(x * x for x in b) ** 0.5
    if na == 0 or nb == 0:
        return 0.0
    return dot / (na * nb)


def search(query_vector: list[float], items: Iterable[Item], k: int = 5) -> list[tuple[Item, float]]:
    scored = [(item, cosine(query_vector, item.vector)) for item in items]
    return sorted(scored, key=lambda x: x[1], reverse=True)[:k]
