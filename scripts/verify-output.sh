#!/usr/bin/env bash
# Reads the artefact and refuses it when a rule of the specification is broken. Every check
# below names the section it enforces; §16 is the register.
#
# These are the rules whose breach does NOT produce an error on its own — that is the whole
# reason the script exists.
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$root"

fail=0
check() { printf '  %-58s' "$1"; }
ok() { echo "ok"; }
bad() { echo "FAILED"; echo "      $1" >&2; fail=1; }

echo "==> verifying dist/"

check "dist/ exists"
[[ -d dist ]] && ok || bad "run pnpm build first"

check "the home page is there"
[[ -f dist/index.html ]] && ok || bad "dist/index.html missing"

check "a 404 page is there"
[[ -f dist/404.html ]] && ok || bad "dist/404.html missing — the host serves the nearest one"

check "version.json is there"
[[ -f dist/version.json ]] && ok || bad "dist/version.json missing"

# §12.2 — THE PREFIX AGREEMENT. A mismatch produces no error: the document loads, every
# relative URL resolves one directory too high, and the visitor sees a blank page. So both
# halves are read from the artefact itself rather than from the files that set them.
check "the playground was assembled under /playground/"
[[ -f dist/playground/index.html ]] && ok || bad "dist/playground/index.html missing"

check "the playground's base href is /playground/ (§12.2)"
if grep -q '<base href="/playground/"' dist/playground/index.html 2>/dev/null; then ok; else
    bad "wwwroot/index.html must carry <base href=\"/playground/\" />"
fi

check "the framework was rooted at /playground/ (§12.2)"
if [[ -d dist/playground/_framework ]]; then ok; else
    bad "no dist/playground/_framework — StaticWebAssetBasePath is not 'playground'"
fi

# §10.8 — the engine's embedded themes are resources, exactly what a trimmer removes when
# nothing names it, and the failure only appears on the published artefact.
check "the engine shipped into the playground (§10.8)"
if ls dist/playground/_framework/Slugger.* >/dev/null 2>&1; then ok; else
    bad "no Slugger assembly under _framework — the trimmer or the reference is wrong"
fi

# EVERY LOCAL ASSET A PAGE REFERENCES MUST EXIST. Nothing upstream enforces this: a
# dangling reference publishes, loads, and 404s in the visitor's browser. The playground's
# boot script is the one that will dangle, because .NET fingerprints it and index.html has
# to carry a placeholder for the rewrite to happen (§12.2).
check "every asset a page references exists (§12.2)"
missing=""
while IFS= read -r page; do
    dir="$(dirname "$page")"
    refs="$(grep -oE '(src|href)="[^"#:]+\.(js|css|wasm|json|png|svg|webp|ico)"' "$page" 2>/dev/null |
        sed -E 's/^(src|href)="//; s/"$//' || true)"
    while IFS= read -r ref; do
        [[ -z $ref ]] && continue
        case $ref in
            /*) target="dist${ref}" ;;
            *) target="${dir}/${ref}" ;;
        esac
        [[ -f $target ]] || missing="${missing}${page} -> ${ref}"$'
'
    done <<< "$refs"
done < <(find dist -name '*.html' -type f)
if [[ -z $missing ]]; then ok; else bad "$missing"; fi

# §13.2 — no inline script or style. An inline <style> forces 'unsafe-inline' for styles,
# which disables the protection for every stylesheet on the site to save one request.
check "no inline <style> in any page (§13.2)"
if grep -rlE '<style[^>]*>[^<]' dist --include='*.html' 2>/dev/null | grep -q .; then
    bad "inline <style> found in: $(grep -rlE '<style[^>]*>[^<]' dist --include='*.html' | tr '\n' ' ')"
else ok; fi

check "no inline <script> body in any page (§13.2)"
if grep -rlE '<script(?![^>]*\ssrc=)[^>]*>[^<]' dist --include='*.html' -P 2>/dev/null | grep -q .; then
    bad "inline <script> found — it would need its own hash in the policy"
else ok; fi

# §14.3 — every slug on the site was drawn by the engine at build time. An empty sample set
# means the generator ran and produced nothing, which must not ship.
check "the build-time slugs exist and are not empty (§14.3)"
samples="apps/site/src/generated/slugs.json"
if [[ -s $samples ]] && grep -q '"slug"' "$samples"; then ok; else
    bad "$samples carries no slug — the engine produced none"
fi

# §8.6 — one visual source. The playground is the side that will break this, so the check
# looks there first: the token file must have crossed, and no component may carry a literal.
check "the shared tokens crossed into the playground (§8.6)"
[[ -f dist/playground/css/tokens.css ]] && ok || bad "dist/playground/css/tokens.css missing"

check "no colour literal outside the token file (§8.6)"
# bin/ and obj/ hold the COPY the project file makes of the token file itself, so they are
# excluded: the rule is about what a component declares, not about where the one source
# lands. tokens.css is the source and is excluded by name for the same reason.
literals="$(grep -rnE '#[0-9a-fA-F]{3}([0-9a-fA-F]{3})?\b|\brgb\(|\bhsl\(' \
    apps/site/src apps/playground \
    --include='*.css' --include='*.razor' --include='*.astro' \
    --exclude='tokens.css' --exclude-dir=bin --exclude-dir=obj 2>/dev/null || true)"
if [[ -z $literals ]]; then ok; else bad "$literals"; fi

echo
if [[ $fail -ne 0 ]]; then
    echo "verify-output: the artefact does not satisfy the specification." >&2
    exit 1
fi
echo "verify-output: the artefact is sound."
