#!/bin/sh

# ================================================================
# Force an immediate (debounce=0) flush of transcript delta to mem_update.
# Stdin: VSCode hook JSON (.session_id, .transcript_path).
# Stdout: updatedInput JSON for historian-attn delegation, otherwise empty.
# ================================================================

set -e

cd "$(dirname "$0")/.."

for cmd in jq; do
    ! command -v "$cmd" > /dev/null || continue
    printf '\033[31m[ERROR] Missing required command "%s".\033[0m\n' "$cmd" >&2
    exit 1
done

input="$(jq -e '{hook_event_name,session_id,tool_input,tool_name,transcript_path}')"
if printf '%s\n' "$input" | jq -e '.tool_name == "mcp_historian_historian_ask"' > /dev/null; then
    exit 0
fi

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

printf '%s\n' "$input" | jq -r '
    select(.hook_event_name == "PreToolUse" and .tool_name == "runSubagent" and .tool_input.agentName == "historian-attn")
    | .tool_input
    | .prompt |= ((if startswith("[historian-attn:no-auto-memory]\n") then "" else "[historian-attn:no-auto-memory]\n" end) + .)
    | {hookSpecificOutput: {hookEventName: "PreToolUse", updatedInput: .}}
'
