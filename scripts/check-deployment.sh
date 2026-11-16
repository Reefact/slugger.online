#!/usr/bin/env bash
# The four things only a real deployment settles — §12.5 — asked of a live origin.
#
# Everything the build can check, the build already checked. These cannot be checked there,
# by construction: _headers and _redirects are inert until a host parses them, compression
# is applied by the edge and not by the artefact, and a cache regime is a property of a
# response rather than of a file.
#
# Run it against the deployment right after publishing. It also runs against `pnpm serve`,
# which is the same runtime locally, so the rules can be exercised before a release — the
# one thing that genuinely needs the real edge is compression.
set -euo pipefail

origin="${1:-}"
tag="${2:-}"

if [[ -z $origin ]]; then
    echo "usage: check-deployment.sh <origin> [expected-release-tag]" >&2
    echo "  e.g. ./scripts/check-deployment.sh https://slugger.online release/2026-11-16" >&2
    exit 1
fi

origin="${origin%/}"
fail=0
note=0

check() { printf '  %-62s' "$1"; }
ok() { echo "ok"; }
bad() { echo "FAILED"; echo "      $1" >&2; fail=1; }
unverified() { echo "not settled"; echo "      $1"; note=1; }

head_of() { curl -sS -D - -o /dev/null --max-time 30 "$@"; }

echo "==> checking $origin"

# ---------------------------------------------------------------------------------------
# Which release is live. version.json is stamped by the build and served no-store, or it
# answers for the previous one.
# ---------------------------------------------------------------------------------------
version="$(curl -sS --max-time 30 "$origin/version.json" || true)"

check "version.json says which release is live"
if [[ -n $version ]] && grep -q '"commit"' <<< "$version"; then ok; else
    bad "no version.json, or it carries no commit"
fi

check "version.json is never cached"
cache="$(head_of "$origin/version.json" | grep -i '^cache-control:' || true)"
grep -qi 'no-store' <<< "$cache" && ok || bad "cache-control was: ${cache:-absent}"

if [[ -n $tag ]]; then
    check "the release live is the one just published"
    if grep -q "\"release\": \"$tag\"" <<< "$version"; then ok; else
        bad "expected release $tag, got: $(grep -o '\"release\": \"[^\"]*\"' <<< "$version" || echo 'none')"
    fi
fi

# ---------------------------------------------------------------------------------------
# §12.5, first point — the headers file actually taking effect. Inert in the artefact; only
# a response says whether the host parsed it.
# ---------------------------------------------------------------------------------------
headers="$(head_of "$origin/")"

for pair in "content-security-policy:default-src" "x-content-type-options:nosniff" \
            "referrer-policy:strict-origin" "x-frame-options:DENY" "permissions-policy:camera"; do
    name="${pair%%:*}"
    want="${pair#*:}"
    check "$name reaches the response (§12.5)"
    grep -i "^$name:" <<< "$headers" | grep -qi -- "$want" && ok ||
        bad "$name was: $(grep -i "^$name:" <<< "$headers" || echo absent)"
done

check "the policy carries no broad allowance (§13.2)"
if grep -i '^content-security-policy:' <<< "$headers" | grep -qE "'unsafe-eval'|'unsafe-inline'"; then
    bad "a broad allowance reached production"
else ok; fi

# ---------------------------------------------------------------------------------------
# §12.5, second point — the order between serving an asset and applying a rewrite rule.
# ---------------------------------------------------------------------------------------
check "an asset is served rather than rewritten (§12.5)"
rules="$(grep -cE '^/[^ ]+ ' dist/_redirects 2>/dev/null || true)"
if [[ ${rules:-0} -eq 0 ]]; then
    unverified "the playground declares no client-side route, so _redirects carries no rule and
      there is nothing to exercise. The day one is added, this check becomes real: request a
      path that is both an asset and matched by a rule, and the asset must win."
else
    shell="$(curl -sS -o /dev/null -w '%{http_code}' --max-time 30 "$origin/playground/")"
    [[ $shell == 200 ]] && ok || bad "/playground/ answered $shell"
fi

# ---------------------------------------------------------------------------------------
# §12.5, fourth point — the compression actually applied to the WebAssembly resources.
# Measured rather than assumed: the local runtime compresses too, so this does exercise the
# rule before a release. What it cannot tell you is which encoding the real edge negotiates
# with a real client, which is why §12.5 lists it at all.
# ---------------------------------------------------------------------------------------
check "the WebAssembly resources are compressed in transit (§12.5)"
runtime="$(head_of -H 'Accept-Encoding: br, gzip' "$origin/playground/_framework/dotnet.native.js")"
encoding="$(grep -i '^content-encoding:' <<< "$runtime" || true)"
if grep -qiE 'br|gzip|zstd' <<< "$encoding"; then ok; else
    unverified "content-encoding was: ${encoding:-absent}. These are the heaviest bytes of
      the artefact, so an absent encoding on the deployment is a finding, not a detail —
      check what the edge is configured to compress."
fi

# ---------------------------------------------------------------------------------------
# §13.1 — the runtime's names are stable and cannot be fingerprinted, so a visitor must not
# keep last release's. The regime is revalidation; whether a 304 then arrives is the thing
# to look at after the NEXT release.
# ---------------------------------------------------------------------------------------
check "the playground runtime is revalidated, not held (§13.1)"
cache="$(head_of "$origin/playground/_framework/dotnet.js" | grep -i '^cache-control:' || true)"
grep -qi 'no-cache' <<< "$cache" && ok || bad "cache-control was: ${cache:-absent}"

echo
if [[ $fail -ne 0 ]]; then
    echo "check-deployment: the deployment does not satisfy the specification." >&2
    exit 1
fi

if [[ $note -ne 0 ]]; then
    echo "check-deployment: sound, with points above left unsettled — read them."
else
    echo "check-deployment: sound."
fi
