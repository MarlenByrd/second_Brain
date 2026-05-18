#!/usr/bin/env bash
set -euo pipefail

if ! command -v docker >/dev/null 2>&1; then
  echo "Docker не найден в системе."
  echo "Запускаю локальный web-интерфейс без Docker..."
  echo "Если хотите полный стек (Postgres/Qdrant/Ollama), установите Docker Desktop."
  exec "$(dirname "$0")/run_ui.sh"
fi

echo "Starting local infra..."
docker compose -f infra/docker/docker-compose.yml up -d

echo "Done. Pull model (example):"
echo "  ollama pull qwen2.5:7b"
echo
echo "UI fallback available at any time: ./scripts/run_ui.sh"
