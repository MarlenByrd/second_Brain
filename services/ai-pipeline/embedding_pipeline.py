"""Local embedding pipeline prototype."""
from __future__ import annotations

from dataclasses import dataclass

from sentence_transformers import SentenceTransformer


@dataclass
class EmbeddingRecord:
    memory_id: str
    vector: list[float]


class LocalEmbedder:
    def __init__(self, model_name: str = "sentence-transformers/all-MiniLM-L6-v2") -> None:
        self.model = SentenceTransformer(model_name)

    def embed(self, memory_id: str, text: str) -> EmbeddingRecord:
        vector = self.model.encode([text], normalize_embeddings=True)[0]
        return EmbeddingRecord(memory_id=memory_id, vector=vector.tolist())
