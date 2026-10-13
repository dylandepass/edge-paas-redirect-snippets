#!/usr/bin/env bash
# Request each path a few times with debug headers and print one line per request.
#
# Usage:
#   scripts/check.sh <base-url> <path> [<path> ...]
#   RUNS=5 scripts/check.sh https://www.example.com /old-product.html "/rl-check-$(date +%s).html"
#
# The debug snippets must be installed to see X-RL-Trace.

set -uo pipefail

if [ $# -lt 2 ]; then
  echo "usage: $0 <base-url> <path> [<path> ...]" >&2
  exit 1
fi

BASE="${1%/}"
shift
RUNS="${RUNS:-3}"

for path in "$@"; do
  echo "== $path"
  for i in $(seq 1 "$RUNS"); do
    line=$(curl -sI -H 'Fastly-Debug: 1' "$BASE$path" \
      | tr -d '\r' \
      | grep -iE '^(HTTP/|location:|x-rl-trace:)' \
      | paste -sd ' ' -)
    echo "  [$i] $line"
  done
done
