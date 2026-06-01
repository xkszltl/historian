#!/bin/sh

# ================================================================
# Force an immediate (debounce=0) flush of transcript delta to mem_update.
# Stdin: VSCode hook JSON (.session_id, .transcript_path).
# Stdout: empty.
# ================================================================

set -e

cd "$(dirname "$0")/.."

for cmd in jq; do
    ! command -v "$cmd" > /dev/null || continue
    printf '\033[31m[ERROR] Missing required command "%s".\033[0m\n' "$cmd" >&2
    exit 1
done

input="$(jq -e '{session_id,transcript_path}')"
sess_dir="state/sessions/$(printf '%s' "$input" | jq -er '.session_id')"
conv="$(printf '%s' "$input" | jq -er '.transcript_path // empty' || cat "$sess_dir/transcript_path.txt" 2>/dev/null || true)"
if [ ! "$conv" ]; then
    printf '\033[31m[ERROR] Missing transcript_path in hook input.\033[0m\n' >&2
    exit 1
elif [ "$conv" != "$(cat "$sess_dir/transcript_path.txt" 2>/dev/null || true)" ]; then
    mkdir -p "$sess_dir/transcript_path.staging.d"
    printf '%s\n' "$conv" > "$sess_dir/transcript_path.staging.d/pid-$$.txt"
    mv -f "$sess_dir/transcript_path.staging.d/pid-$$.txt" "$sess_dir/transcript_path.txt"
    printf '\033[36m[INFO] Set transcript_path "%s".\033[0m\n' "$conv" >&2
fi
scripts/mem_add.sh "$sess_dir" 0 < "$conv" >&2
