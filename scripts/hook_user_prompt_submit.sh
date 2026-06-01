#!/bin/sh

# ================================================================
# UserPromptSubmit hook.
# Send transcript delta to update and search memories with the transcript to inject as additionalContext.
# Stdin: VSCode hook JSON (.session_id, .transcript_path, .prompt).
# Stdout: hookSpecificOutput JSON (or empty when no memories).
# ================================================================

set -e

cd "$(dirname "$0")/.."

for cmd in jq; do
    ! command -v "$cmd" > /dev/null || continue
    printf '\033[31m[ERROR] Missing required command "%s".\033[0m\n' "$cmd" >&2
    exit 1
done

input="$(jq -e '{hook_event_name,session_id,transcript_path}')"
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
scripts/mem_add.sh "$sess_dir" 0 < "$conv" >&2 &
bg=$!
trap 'trap - EXIT HUP INT TERM; /bin/kill -TERM "$bg" || true; wait "$bg" || true; exit 1' EXIT HUP INT TERM

prompt='Historian links AI agents to memory store to provide info beyond LLM context.
We evaluate its quality while using.
List out historian memory particularly useful for the current round at the end of response, titled "Helpful Historian Memories".
Usefulness measured by but not limited to:
- Providing info not available in non-memory context.
- Sifting your assumption/decision.
- Providing high-level insight that you need extra effort to derive.
- Reliably reducing effort of research and experiment.

Only include high quality historian memories and omit the section if none of them is necessary.
Each entry contains memory `.kind` and a brief 1-sentence summary of `.content`, in the form of "- **[chat_summary]** Alice likes red car."

Memories from historian:
'

scripts/mem_find.sh "$sess_dir" < "$conv"   \
| jq -er --arg event "$(printf '%s' "$input" | jq -er '.hook_event_name')" --arg prompt "$prompt" '
    .memories
    | select(length > 0)
    | {
        hookSpecificOutput: {
            hookEventName: $event,
            additionalContext: $prompt + tojson
        }
    }
'

wait "$bg"
trap - EXIT HUP INT TERM
