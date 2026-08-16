#!/usr/bin/env bash
set -euo pipefail

output="${1:-best100.csv}"
shift || true

if [[ $# -gt 0 ]]; then
  inputs=("$@")
else
  mapfile -t inputs < <(find . -maxdepth 1 -type f -name 'result_*.csv' | sort)
fi

if [[ ${#inputs[@]} -eq 0 ]]; then
  echo "No result CSV files found." >&2
  exit 1
fi

tmp="$(mktemp)"
trap 'rm -f "$tmp"' EXIT

{
  head -n 1 "${inputs[0]}"
  for file in "${inputs[@]}"; do
    tail -n +2 "$file"
  done | sort -t, -k1,1g | head -n 100
} > "$tmp"

mv "$tmp" "$output"
trap - EXIT

echo "Wrote top 100 candidates to $output"
