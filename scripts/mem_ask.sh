#!/bin/sh

set -e

cd "$(dirname "$0")/.."

for cmd in jq; do
    ! command -v "$cmd" > /dev/null || continue
    printf '\033[31m[ERROR] Missing required command "%s".\033[0m\n' "$cmd" >&2
    exit 1
done

jq -Rs '.' | jq -c '{type: "user.message", data: {content: .}}' | scripts/mem_find.sh state/ask