#!/bin/sh

# ================================================================
# Seed mem store if missing.
# Args:
#   $1 = session dir (e.g. state/sessions/$sess_id)
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

printf '\033[36m[INFO] Use mem store[%s/%s] in "%s".\033[0m\n' "$HISTORIAN_STORE" "$HISTORIAN_SCOPE" "$HISTORIAN_URL" >&2

sess_dir="$1"
[ "$HISTORIAN_LOG_CURL" ] && log="$sess_dir/$HISTORIAN_LOG_CURL" || log='/dev/null'

mkdir -p "$sess_dir" "$(dirname "$log")"

curl -fsSLX POST                                    \
    -H "Authorization: Bearer $(
        az account get-access-token                 \
            --resource 'https://ai.azure.com/'      \
            --query accessToken                     \
            -o tsv
        )"                                          \
    -H 'Content-Type: application/json'             \
    -d '{
        "name": "'"$HISTORIAN_STORE"'",
        "description": "historian: GitHub Copilot coding-agent memory.",
        "definition": {
            "kind": "default",
            "chat_model": "'"$HISTORIAN_CHAT"'",
            "embedding_model": "'"$HISTORIAN_EMB"'",
            "options": {
                "chat_summary_enabled": true,
                "user_profile_enabled": true,
                "procedural_memory_enabled": true,
                "user_profile_details": "Coding preferences, recurring procedures, debugging lessons, repo conventions. Avoid PII, credentials, raw file contents, secrets."
            }
        }
    }'                                              \
    --trace-ascii '%'                               \
    "$HISTORIAN_URL/memory_stores?api-version=$HISTORIAN_API_VER"   \
2>>"$log"                                           \
|| curl -fsSL                                       \
    -H "Authorization: Bearer $(
        az account get-access-token                 \
            --resource 'https://ai.azure.com/'      \
            --query accessToken                     \
            -o tsv
    )"                                              \
    --trace-ascii '%'                               \
    "$HISTORIAN_URL/memory_stores/$HISTORIAN_STORE?api-version=$HISTORIAN_API_VER"  \
2>>"$log"
