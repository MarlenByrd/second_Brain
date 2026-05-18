"""Telegram ingestion prototype (local-only).

Reads exported JSON and converts messages into canonical memory events.
"""
from __future__ import annotations

import hashlib
import json
from dataclasses import dataclass
from datetime import datetime, timezone
from pathlib import Path
from typing import Any


@dataclass
class CanonicalEvent:
    external_id: str
    event_type: str
    ts: datetime
    text: str
    source_type: str = "telegram"

    def to_dict(self) -> dict[str, Any]:
        return {
            "external_id": self.external_id,
            "event_type": self.event_type,
            "ts": self.ts.isoformat(),
            "text": self.text,
            "source_type": self.source_type,
            "hash": hashlib.sha256(self.text.encode("utf-8")).hexdigest(),
        }


def parse_export(path: Path) -> list[CanonicalEvent]:
    data = json.loads(path.read_text(encoding="utf-8"))
    out: list[CanonicalEvent] = []
    for msg in data.get("messages", []):
        text = msg.get("text")
        if isinstance(text, list):
            text = " ".join(str(x) for x in text)
        if not text:
            continue
        out.append(
            CanonicalEvent(
                external_id=str(msg.get("id")),
                event_type="message",
                ts=datetime.fromisoformat(msg["date"]).astimezone(timezone.utc),
                text=str(text).strip(),
            )
        )
    return out


if __name__ == "__main__":
    sample = Path("sample_telegram_export.json")
    if sample.exists():
        events = parse_export(sample)
        print(json.dumps([e.to_dict() for e in events[:5]], indent=2, ensure_ascii=False))
    else:
        print("Provide sample_telegram_export.json in this directory.")
