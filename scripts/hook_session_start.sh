#!/bin/sh

# ================================================================
# SessionStart hook.
# Reset on clear/startup and preserve state on compact/resume.
# Inject static memories (user profile) as additionalContext at the start of every chat session.
# Stdin: VSCode hook JSON.
# Stdout: hookSpecificOutput JSON to inject context.
# ================================================================

set -e

cd "$(dirname "$0")/.."

for cmd in jq; do
    ! command -v "$cmd" > /dev/null || continue
    printf '\033[31m[ERROR] Missing required command "%s".\033[0m\n' "$cmd" >&2
    exit 1
done

input="$(jq -e '{source,session_id,hook_event_name,transcript_path}')"
sess_id="$(printf '%s' "$input" | jq -r 'select(.source == "clear" or .source == "startup") | .session_id')"
[ ! "$sess_id" ] || rm -rf "state/sessions/$sess_id"
sess_dir="state/sessions/$(printf '%s' "$input" | jq -er '.session_id')"
scripts/mem_init.sh "$sess_dir" >&2

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

printf ''                                                           \
| scripts/mem_find.sh "$sess_dir"                                   \
| jq -er --arg event "$(printf '%s' "$input" | jq -er '.hook_event_name')" '
    .memories
    | select(length > 0)
    | {
        hookSpecificOutput: {
            hookEventName: $event,
            additionalContext: "Memories from historian:\n" + tojson
        }
    }
'
