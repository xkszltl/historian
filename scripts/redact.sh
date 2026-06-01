#!/bin/sh

# ================================================================
# Conservatively redact common secret patterns piped.
# Designed for memory and prefer false positive over false negative.
# ================================================================

set -e

for cmd in sed; do
    ! command -v "$cmd" > /dev/null || continue
    printf '\033[31m[ERROR] Missing required command "%s".\033[0m\n' "$cmd" >&2
    exit 1
done

sed 's/eyJ[[:alnum:]_-]\{10,\}\.[[:alnum:]_-]\{10,\}\.[[:alnum:]_-]\{10,\}/[REDACTED_JWT]/g' \
| sed 's/\(Bearer[[:space:]]\{1,\}\)[[:alnum:]._-]\{1,\}/\1[REDACTED_BEARER]/g' \
| sed 's/\(Authorization:[[:space:]]*\)[^[:space:]]\{1,\}/\1[REDACTED_AUTHZ]/g' \
| sed 's/gh[pousr]_[[:alnum:]]\{20,\}/[REDACTED_GH_TOKEN]/g' \
| sed 's/sk-[[:alnum:]]\{20,\}/[REDACTED_OAI_KEY]/g' \
| sed 's/AKIA[0-9A-Z]\{16\}/[REDACTED_AWS_KEY]/g' \
| sed 's/AIza[[:alnum:]_-]\{35\}/[REDACTED_GCP_KEY]/g' \
| sed 's/ya29\.[[:alnum:]_-]\{20,\}/[REDACTED_GCP_OAUTH]/g' \
| sed 's/\(AccountKey=\)[A-Za-z0-9+/=]\{40,\}/\1[REDACTED_AZURE_STORAGE_KEY]/g' \
| sed 's/\(SharedAccessKey=\)[A-Za-z0-9+/=]\{20,\}/\1[REDACTED_AZURE_SAS_KEY]/g' \
| sed 's/\([?&]sig=\)[A-Za-z0-9%]\{20,\}/\1[REDACTED_AZURE_SAS_SIG]/g' \
| sed 's/\([Pp][Aa][Ss][Ss][Ww][Oo][Rr][Dd][[:space:]]*[:=][[:space:]]*\)[^[:space:];]\{1,\}/\1[REDACTED_PASSWORD]/g' \
| sed 's/\([Pp][Aa][Ss][Ss][Ww][Dd][[:space:]]*[:=][[:space:]]*\)[^[:space:];]\{1,\}/\1[REDACTED_PASSWORD]/g' \
| sed 's/\([Pp][Ww][Dd][[:space:]]*[:=][[:space:]]*\)[^[:space:];]\{1,\}/\1[REDACTED_PASSWORD]/g' \
| sed 's/\([Ss][Ee][Cc][Rr][Ee][Tt][[:space:]]*[:=][[:space:]]*\)[^[:space:];]\{1,\}/\1[REDACTED_SECRET]/g' \
| sed 's/\([Aa][Pp][Ii][_-]\{0,1\}[Kk][Ee][Yy][[:space:]]*[:=][[:space:]]*\)[^[:space:];]\{1,\}/\1[REDACTED_API_KEY]/g'
