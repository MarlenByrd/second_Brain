#!/usr/bin/env bash
set -euo pipefail

PORT="${1:-4173}"

echo "Starting local UI on http://localhost:${PORT}"
cd "$(dirname "$0")/../apps/web"
python3 -m http.server "${PORT}"
