#!/bin/sh

# ================================================================
# Search memories using the full transcript as the query.
# Server takes the last message as the effective query.
# Args:
#   $1 = session dir (e.g. state/sessions/$sess_id)
# Stdin: transcript JSONL.
# Stdout: search_memories response JSON (empty when transcript missing/empty).
# ================================================================

set -e

cd "$(dirname "$0")/.."

for cmd in az curl jq; do
    ! command -v "$cmd" > /dev/null || continue
    printf '\033[31m[ERROR] Missing required command "%s".\033[0m\n' "$cmd" >&2
    exit 1
done

[ ! -f scripts/conf_usr.sh ] || . scripts/conf_usr.sh
. scripts/conf_def.sh

sess_dir="$1"
[ "$HISTORIAN_LOG_CURL" ] && log="$sess_dir/log/find-$HISTORIAN_LOG_CURL" || log='/dev/null'

mkdir -p "$sess_dir" "$(dirname "$log")"

jq -e '
    select(.type | endswith(".message"))
    | {
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
    }
'                                                   \
| scripts/redact.sh                                 \
| jq -es '.'                                        \
| jq -e '.[-10:]'                                   \
| jq -e 'reverse'                                   \
| jq -e '{
    scope: "'"$HISTORIAN_SCOPE"'",
    options: {
        max_memories: '"$HISTORIAN_MAX_MEM"'
    },
    items: .
}'                                                  \
| curl -fsSLX POST                                  \
    -H "Authorization: Bearer $(
        az account get-access-token                 \
            --resource 'https://ai.azure.com/'      \
            --query accessToken                     \
            -o tsv
    )"                                              \
    -H 'Content-Type: application/json'             \
    --data-binary '@-'                              \
    --trace-ascii '%'                               \
    "$HISTORIAN_URL/memory_stores/$HISTORIAN_STORE:search_memories?api-version=$HISTORIAN_API_VER"  \
2>>"$log"                                           \
| jq -e .  
