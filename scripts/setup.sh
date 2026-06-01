#!/bin/sh

# Generate scripts/conf_usr.sh from HISTORIAN_* env vars, then verify against Foundry.
# Usage: HISTORIAN_FOUNDRY=my-foundry/proj-default scripts/setup.sh

set -e

cd "$(dirname "$0")/.."

for cmd in az curl grep jq; do
    ! command -v "$cmd" > /dev/null || continue
    printf '\033[31m[ERROR] Missing required command "%s".\033[0m\n' "$cmd" >&2
    exit 1
done

printf '#!/bin/sh\n\n' > 'scripts/conf_usr.sh.staging'
set | grep '^HISTORIAN_[[:alnum:]_]*=' | sort >> 'scripts/conf_usr.sh.staging'
chmod +x 'scripts/conf_usr.sh.staging'
mv -f 'scripts/conf_usr.sh.staging' 'scripts/conf_usr.sh'

. scripts/conf_usr.sh
. scripts/conf_def.sh

az account get-access-token             \
    --resource 'https://ai.azure.com/'  \
| jq -er '.accessToken'                 \
> /dev/null                             \
&& printf '\033[36m[INFO] Connected to Azure via CLI login session.\033[0m\n' >&2   \
|| printf '\033[33m[WARNING] Cannot get access token from Azure CLI. Run "az login".\033[0m\n' >&2

printf '\033[36m[INFO] Verify Azure Foundry "%s".\033[0m\n' "$(printf '%s' "$HISTORIAN_FOUNDRY" | cut -d/ -f1)" >&2
curl -fsSL                                          \
    -H "Authorization: Bearer $(
        az account get-access-token                 \
            --resource 'https://ai.azure.com/'      \
            --query accessToken                     \
            -o tsv
    )"                                              \
    "$HISTORIAN_URL/memory_stores?api-version=$HISTORIAN_API_VER"   \
> /dev/null                                         \
&& printf '\033[36m[INFO] Connected to Foundry project "%s".\033[0m\n' "$HISTORIAN_FOUNDRY" >&2 \
|| printf '\033[33m[WARNING] Cannot reach Foundry project "%s".\033[0m\n' "$HISTORIAN_FOUNDRY" >&2

for model in "$HISTORIAN_CHAT" "$HISTORIAN_EMB"; do
    curl -fsSL                                      \
        -H "Authorization: Bearer $(
            az account get-access-token             \
                --resource 'https://ai.azure.com/'  \
                --query accessToken                 \
                -o tsv
        )"                                          \
        "$HISTORIAN_URL/deployments/$model?api-version=$HISTORIAN_API_VER"  \
    > /dev/null                                     \
    && printf '\033[36m[INFO] Connected to model deployment "%s".\033[0m\n' "$model" >&2    \
    || printf '\033[33m[WARNING] Cannot find model deployment "%s".\033[0m\n' "$model" >&2
done

printf '\033[32m[INFO] Historian setup complete. You can make future edits by calling setup script again or directly in "scripts/conf_usr.sh".\033[0m\n' >&2
