#!/usr/bin/env bash
set -euo pipefail

PROFILE="${1:-balanced}"
ACTION="${2:-apply}"   # apply | status | prune

MODELS_MINIMAL=("qwen2.5:3b")
MODELS_BALANCED=("qwen2.5:7b")
MODELS_MULTIMODAL_LIGHT=("qwen2.5:7b" "qwen2.5vl:3b")

usage() {
  cat <<USAGE
Usage:
  ./scripts/setup_light_models.sh <profile> [action]

Profiles:
  minimal | balanced | multimodal_light

Actions:
  apply   - pull missing models for profile (default)
  status  - show which profile models are installed
  prune   - remove non-profile qwen models to free disk

Examples:
  ./scripts/setup_light_models.sh balanced
  ./scripts/setup_light_models.sh minimal status
  ./scripts/setup_light_models.sh multimodal_light prune
USAGE
}

if ! command -v ollama >/dev/null 2>&1; then
  echo "❌ ollama not found. Install Ollama first: https://ollama.com/download"
  exit 1
fi

if ! command -v python3 >/dev/null 2>&1; then
  echo "❌ python3 is required"
  exit 1
fi

get_profile_models() {
  case "${PROFILE}" in
    minimal) printf '%s\n' "${MODELS_MINIMAL[@]}" ;;
    balanced) printf '%s\n' "${MODELS_BALANCED[@]}" ;;
    multimodal_light) printf '%s\n' "${MODELS_MULTIMODAL_LIGHT[@]}" ;;
    -h|--help|help) usage; exit 0 ;;
    *)
      echo "❌ unknown profile: ${PROFILE}"
      usage
      exit 1
      ;;
  esac
}

installed_models() {
  ollama list | awk 'NR>1 {print $1}'
}

pull_if_needed() {
  local model="$1"
  if installed_models | grep -q "^${model}$"; then
    echo "✅ model already present: ${model}"
  else
    echo "⬇️ pulling model: ${model}"
    ollama pull "${model}"
  fi
}

show_status() {
  local missing=0
  echo "[Second Brain] Profile: ${PROFILE}"
  while IFS= read -r model; do
    if installed_models | grep -q "^${model}$"; then
      echo "✅ ${model}"
    else
      echo "⚠️  ${model} (missing)"
      missing=1
    fi
  done < <(get_profile_models)

  echo
  echo "Disk usage (Ollama):"
  du -sh "$HOME/.ollama" 2>/dev/null || echo "~/.ollama not found yet"

  return ${missing}
}

prune_non_profile_qwen() {
  mapfile -t keep < <(get_profile_models)
  echo "[Second Brain] Keeping models: ${keep[*]}"

  while IFS= read -r model; do
    [[ -z "$model" ]] && continue
    if [[ "$model" == qwen* ]]; then
      local keep_it=0
      for k in "${keep[@]}"; do
        if [[ "$k" == "$model" ]]; then keep_it=1; break; fi
      done
      if [[ $keep_it -eq 0 ]]; then
        echo "🧹 removing non-profile model: $model"
        ollama rm "$model" || true
      fi
    fi
  done < <(installed_models)
}

echo "[Second Brain] Profile=${PROFILE} Action=${ACTION}"
case "$ACTION" in
  apply)
    while IFS= read -r model; do
      pull_if_needed "$model"
    done < <(get_profile_models)
    ;;
  status)
    show_status || true
    ;;
  prune)
    prune_non_profile_qwen
    ;;
  *)
    echo "❌ unknown action: ${ACTION}"
    usage
    exit 1
    ;;
esac

echo "✅ done"
