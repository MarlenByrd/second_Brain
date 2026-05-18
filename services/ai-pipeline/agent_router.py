"""Lightweight agent router for local multi-agent pipeline.

Each task is routed to a small specialized model profile to reduce RAM/SSD usage.
"""
from __future__ import annotations

from dataclasses import dataclass
from enum import Enum


class AgentTask(str, Enum):
    INGESTION_CLEANER = "ingestion_cleaner"
    ENTITY_EXTRACTOR = "entity_extractor"
    MEMORY_SUMMARIZER = "memory_summarizer"
    RETRIEVAL_RANKER = "retrieval_ranker"
    GRAPH_LINKER = "graph_linker"
    VISION_OCR = "vision_ocr"


@dataclass(frozen=True)
class Route:
    agent_name: str
    provider: str
    model: str
    max_context_tokens: int


def route_task(task: AgentTask, profile: str = "balanced") -> Route:
    """Map task -> lightweight model route.

    This is an orchestration stub that can be consumed by the future daemon/API layer.
    """
    if profile == "minimal":
        base = Route("text-mini", "ollama", "qwen2.5:3b", 4096)
        if task == AgentTask.VISION_OCR:
            raise ValueError("Vision is disabled in minimal profile")
        return base

    if profile == "balanced":
        base = Route("text-balanced", "ollama", "qwen2.5:7b", 8192)
        if task == AgentTask.VISION_OCR:
            raise ValueError("Vision is disabled in balanced profile")
        return base

    if profile == "multimodal_light":
        if task == AgentTask.VISION_OCR:
            return Route("vision-light", "ollama", "qwen2.5vl:3b", 4096)
        return Route("text-balanced", "ollama", "qwen2.5:7b", 8192)

    raise ValueError(f"Unknown profile: {profile}")
