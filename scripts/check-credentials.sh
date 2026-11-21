#!/usr/bin/env bash
# Are the Cloudflare credentials usable? — the check the deployment guide's step 2 needs.
#
# Without this, a rehearsal proves nothing about the secrets: it stops before the publish
# that would use them. So the first thing anybody learns about a wrong token is a failed
# deploy at the end of a five-minute build.
#
# It prints the account it can see and never the token.
set -euo pipefail

mode="${1:-rehearsing}"

token="${CLOUDFLARE_API_TOKEN:-}"
account="${CLOUDFLARE_ACCOUNT_ID:-}"

missing=""
count=0
if [[ -z $token ]]; then missing="CLOUDFLARE_API_TOKEN"; count=1; fi
if [[ -z $account ]]; then missing="${missing:+$missing and }CLOUDFLARE_ACCOUNT_ID"; count=$(( count + 1 )); fi
verb="is"
[[ $count -gt 1 ]] && verb="are"

if [[ -n $missing ]]; then
    if [[ $mode == publishing ]]; then
        echo "check-credentials: $missing $verb not set, and nothing can be published without it." >&2
        echo "  Repository Settings -> Secrets and variables -> Actions -> New repository secret." >&2
        exit 1
    fi

    echo "::warning::$missing $verb not set. This rehearsal cannot tell you whether the credentials work."
    exit 0
fi

echo "==> verifying the token"

verify="$(curl -sS --max-time 30 -H "Authorization: Bearer $token" \
    https://api.cloudflare.com/client/v4/user/tokens/verify || true)"

if ! grep -q '"success":true' <<< "$verify"; then
    echo "check-credentials: the token was refused by Cloudflare." >&2
    # The body names the reason and carries nothing secret.
    echo "  $verify" >&2
    exit 1
fi

echo "    the token is valid and active."

echo "==> verifying it can see the account"

seen="$(curl -sS --max-time 30 -H "Authorization: Bearer $token" \
    "https://api.cloudflare.com/client/v4/accounts/$account" || true)"

if ! grep -q '"success":true' <<< "$seen"; then
    echo "check-credentials: the token cannot read account $account." >&2
    echo "  Either the id is wrong, or the token was issued for a different account." >&2
    echo "  $seen" >&2
    exit 1
fi

name="$(sed -n 's/.*"name":"\([^"]*\)".*/\1/p' <<< "$seen" | head -1)"
echo "    account $account${name:+ — $name}"

# What publishing actually needs. A token that passes the two checks above can still lack
# the one permission that matters, and finding that out at `wrangler deploy` costs a whole
# build.
echo "==> verifying it may edit Workers"

scripts="$(curl -sS --max-time 30 -o /dev/null -w '%{http_code}' -H "Authorization: Bearer $token" \
    "https://api.cloudflare.com/client/v4/accounts/$account/workers/scripts" || true)"

case "$scripts" in
    200) echo "    Workers Scripts are readable." ;;
    403) echo "check-credentials: the token may not read Workers Scripts on this account." >&2
         echo "  Add Account -> Workers Scripts -> Edit to the token." >&2
         exit 1 ;;
    *)   echo "::warning::Workers Scripts answered $scripts; neither a pass nor a refusal. Continuing." ;;
esac

echo
echo "check-credentials: usable."
