#!/usr/bin/env bash
set -euo pipefail

# Static analysis helper for AUTHORIZED lab samples only.
# Runs oletools and YARA inside the isolated docker analyzer container.

usage() {
  cat <<'USAGE'
Usage: ./scripts/analysis/analyze_sample.sh --file samples/<file> [--out reports/<name>]
USAGE
}

FILE=""
OUT=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --file) FILE="${2:-}"; shift 2 ;;
    --out) OUT="${2:-}"; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown arg: $1" >&2; usage; exit 1 ;;
  esac
done

[[ -z "$FILE" ]] && { echo "Missing --file" >&2; usage; exit 1; }
[[ -f "$FILE" ]] || { echo "File not found: $FILE" >&2; exit 1; }

base=$(basename "$FILE")
OUT=${OUT:-reports/${base%.*}}
mkdir -p "$OUT" samples reports

# copy into samples if outside
if [[ "$FILE" != samples/* ]]; then
  cp "$FILE" "samples/$base"
  FILE="samples/$base"
fi

docker compose -f docker/docker-compose.yml up -d --build >/dev/null
container_file="/workspace/$FILE"
container_out="/workspace/$OUT"

docker compose -f docker/docker-compose.yml exec -T analyzer "mkdir -p '$container_out'"
docker compose -f docker/docker-compose.yml exec -T analyzer "oleid '$container_file' > '$container_out/oleid.txt' 2>&1 || true"
docker compose -f docker/docker-compose.yml exec -T analyzer "olevba --decode '$container_file' > '$container_out/olevba.txt' 2>&1 || true"
docker compose -f docker/docker-compose.yml exec -T analyzer "mraptor '$container_file' > '$container_out/mraptor.txt' 2>&1 || true"
docker compose -f docker/docker-compose.yml exec -T analyzer "yara -r /workspace/detection/yara '$container_file' > '$container_out/yara.txt' 2>&1 || true"

echo "Reports written to $OUT"
