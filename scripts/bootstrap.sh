#!/usr/bin/env bash
set -euo pipefail

echo "Starting local infra..."
docker compose -f infra/docker/docker-compose.yml up -d

echo "Done. Pull model (example):"
echo "  ollama pull qwen2.5:7b"
