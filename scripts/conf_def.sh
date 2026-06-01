#!/bin/sh

[ "$HISTORIAN_API_VER"  ] || HISTORIAN_API_VER='2025-11-15-preview'
[ "$HISTORIAN_CHAT"     ] || HISTORIAN_CHAT='gpt-5.5'
[ "$HISTORIAN_EMB"      ] || HISTORIAN_EMB='text-embedding-3-small'
[ "$HISTORIAN_FOUNDRY"  ] || HISTORIAN_FOUNDRY='my-foundry/proj-default'
[ "$HISTORIAN_LOG_CURL" ] || HISTORIAN_LOG_CURL='curl.log'
[ "$HISTORIAN_MAX_MEM"  ] || HISTORIAN_MAX_MEM='10'
[ "$HISTORIAN_SCOPE"    ] || HISTORIAN_SCOPE='{{$userId}}'
[ "$HISTORIAN_STORE"    ] || HISTORIAN_STORE='historian'
[ "$HISTORIAN_URL"      ] || HISTORIAN_URL="https://$(printf '%s' "$HISTORIAN_FOUNDRY" | cut -d/ -f1).services.ai.azure.com/api/projects/$(printf '%s/' "$HISTORIAN_FOUNDRY" | cut -d/ -f2)"

for i in                \
    HISTORIAN_API_VER   \
    HISTORIAN_CHAT      \
    HISTORIAN_EMB       \
    HISTORIAN_FOUNDRY   \
    HISTORIAN_LOG_CURL  \
    HISTORIAN_MAX_MEM   \
    HISTORIAN_SCOPE     \
    HISTORIAN_STORE     \
    HISTORIAN_URL
do
    eval "[ ! \"\$$i\" ]" || continue
    printf '\033[36m[ERROR] Missing $%s.\033[0m\n' "$i" >&2
    exit 1
done
