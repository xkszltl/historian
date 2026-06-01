#!/bin/sh

# ================================================================
# Send transcript delta to mem_update with given delay.
# Delta is messages strictly after $sess_dir/msg_id.txt;
# if that id is missing from the transcript (clear/rebase), resend all.
# Args:
#   $1 = session dir (e.g. state/sessions/$sess_id)
#   $2 = update_delay seconds (0 = immediate flush)
# Stdin: transcript JSONL.
# Reads $sess_dir/{msg,upd}_id.txt.
# Writes $sess_dir/{msg,upd}_id.txt on success.
# Noop when transcript missing/empty or no new messages.
# ================================================================

set -e

cd "$(dirname "$0")/.."

for cmd in az curl grep jq; do
    ! command -v "$cmd" > /dev/null || continue
    printf '\033[31m[ERROR] Missing required command "%s".\033[0m\n' "$cmd" >&2
    exit 1
done

[ ! -f scripts/conf_usr.sh ] || . scripts/conf_usr.sh
. scripts/conf_def.sh

sess_dir="$1"
delay="$2"
[ "$HISTORIAN_LOG_CURL" ] && log="$sess_dir/log/add-$HISTORIAN_LOG_CURL" || log='/dev/null'

mkdir -p "$sess_dir/upd_id.staging.d" "$(dirname "$log")"

msg_id="$(grep . "$sess_dir/msg_id.txt" 2>/dev/null | head -n1 | grep -v '"' || true)"
upd_id="$(grep . "$sess_dir/upd_id.txt" 2>/dev/null | head -n1 | grep -v '"' || true)"
tmp_upd_id="$sess_dir/upd_id.staging.d/pid-$$.txt"

jq -e 'select(.type | endswith(".message"))'    \
| jq -es '.'                                    \
| jq -e '.[((map(.id) | rindex("'"$msg_id"'")) // -1) + 1 :]'   \
| scripts/redact.sh                             \
| jq -cer '.[], .[-1].id // "'"$msg_id"'"'      \
| sed -n '$!p;$w '"$sess_dir/msg_id.txt"        \
| jq -e '{
    type: "message",
    role: (.type | rtrimstr(".message")),
    content: [
        {
            type: "input_text",
            text: (.data.reasoningText // "")
        },
        {
            type: "input_text",
            text: (.data.content // "")
        }
    ]
}'                                              \
| jq -es '.'                                    \
| jq -e 'reverse'                               \
| jq -e '{
    items: .,
    scope: "'"$HISTORIAN_SCOPE"'",
    previous_update_id: "'"$upd_id"'",
    update_delay: '"$delay"'
}'                                              \
| curl -sSLX POST                               \
    -H "Authorization: Bearer $(
        az account get-access-token             \
            --resource 'https://ai.azure.com/'  \
            --query accessToken                 \
            -o tsv
    )"                                          \
    -H 'Content-Type: application/json'         \
    --data-binary '@-'                          \
    --trace-ascii '%'                           \
    "$HISTORIAN_URL/memory_stores/$HISTORIAN_STORE:update_memories?api-version=$HISTORIAN_API_VER"  \
2>>"$log"                                       \
| jq -er '.update_id // empty'                  \
| grep '[^[:space:]]'                           \
> "$tmp_upd_id"                                 \
|| printf '\033[31m[ERROR] No update_id returned when adding mem with conversation to store.\033[0m\n' >&2

if grep -q '[^[:space:]]' "$tmp_upd_id"; then
    mv -f "$tmp_upd_id" "$sess_dir/upd_id.txt"
else
    mv -f "$tmp_upd_id" "$sess_dir/upd_id.txt"
    exit 1
fi
