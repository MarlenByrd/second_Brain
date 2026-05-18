#!/usr/bin/env bash
set -euo pipefail

PROFILE="${1:-balanced}"

echo "[Second Brain] Selected profile: ${PROFILE}"

if ! command -v ollama >/dev/null 2>&1; then
  echo "❌ ollama not found. Install Ollama first: https://ollama.com/download"
  exit 1
fi

pull_if_needed() {
  local model="$1"
  if ollama list | awk '{print $1}' | grep -q "^${model}$"; then
    echo "✅ model already present: ${model}"
  else
    echo "⬇️ pulling model: ${model}"
    ollama pull "${model}"
  fi
}

case "${PROFILE}" in
  minimal)
    pull_if_needed "qwen2.5:3b"
    ;;
  balanced)
    pull_if_needed "qwen2.5:7b"
    ;;
  multimodal_light)
    pull_if_needed "qwen2.5:7b"
    pull_if_needed "qwen2.5vl:3b"
    ;;
  *)
    echo "❌ unknown profile: ${PROFILE}"
    echo "Available: minimal | balanced | multimodal_light"
    exit 1
    ;;
esac

echo "✅ done"
