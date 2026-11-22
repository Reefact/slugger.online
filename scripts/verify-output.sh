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
check() { printf '  %-70s' "$1"; }
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
catalogue="apps/site/src/generated/catalogue.json"

check "the build-time catalogue exists and carries slugs (§14.3)"
if [[ -s $catalogue ]] && grep -q '"samples"' "$catalogue"; then ok; else
    bad "$catalogue carries no sample — the engine produced none"
fi

# §7.6 — ONE PAGE PER THEME, AND THE ROUTE IS KEYED ON THE FILE NAME. Keying on the display
# title would recreate the second source of truth the library dropped on purpose, and a
# theme renamed on one side would break links nothing checks. Read from the artefact: every
# name in the catalogue must have a directory, and the count must match.
check "every theme in the catalogue has a page, keyed on its file name (§7.6)"
if [[ -s $catalogue ]]; then
    missing=""
    count=0
    while IFS= read -r name; do
        count=$(( count + 1 ))
        [[ -f "dist/themes/${name}/index.html" ]] || missing="${missing}${name} "
    done < <(grep -oE '"name": "[^"]+"' "$catalogue" | sed 's/"name": "//; s/"$//')
    pages=$(find dist/themes -mindepth 1 -maxdepth 1 -type d 2>/dev/null | wc -l)
    if [[ -n $missing ]]; then
        bad "no page for: $missing"
    elif [[ $pages -ne $count ]]; then
        bad "$count themes in the catalogue, $pages pages in dist/themes"
    else ok; fi
else bad "no catalogue to check against"; fi

# §14.2 — NO FIGURE ABOUT A THEME IS EVER WRITTEN BY HAND. These change with every word an
# author adds, by somebody with no reason to think about a website; a copied one is wrong
# before it is reread. The catalogue pages must carry no numeric literal of their own.
check "no theme figure typed into a page (§14.2)"
typed="$(grep -nE '>[[:space:]]*[0-9][0-9,.]{2,}[[:space:]]*<' \
    apps/site/src/pages/themes apps/site/src/components/ThemeCard.astro -r 2>/dev/null || true)"
if [[ -z $typed ]]; then ok; else bad "$typed"; fi

# §9 — THE NARRATION. These read the home page rather than the components, because what
# matters is what shipped.

# §9.4 — the hinge of act three is MANDATORY, not decorative: without it a visitor reads a
# bad news where a guarantee is being offered.
check "act three opens on its hinge (§9.4)"
grep -q 'class="hinge"' dist/index.html && ok || bad "no hinge on the home page"

# §9.2 — one transformation in three acts, and in order.
check "the three acts are present, in order (§9.2)"
order="$(grep -oE 'id="act-(one|two|three)"' dist/index.html | sed 's/id="act-//; s/"//' | tr '\n' ' ')"
[[ $order == "one two three " ]] && ok || bad "acts came out as: $order"

# §9.3 — every act ends with an exit, so a visitor convinced early can leave with the
# command in hand.
check "every act ends with an exit (§9.3)"
exits="$(grep -o 'class="exit"' dist/index.html | wc -l || true)"
[[ $exits -ge 3 ]] && ok || bad "$exits exits for three acts"

# §13.5 — THE COMPARISON IS THE DOCUMENT, not something a script builds. Act one is never
# downgraded (§9.7), so its rounds must be in the markup: a reader without scripting gets
# the act, not an empty frame.
check "act one's comparison is in the markup, not built by script (§13.5)"
rounds="$(grep -o 'data-round' dist/index.html | wc -l || true)"
[[ $rounds -ge 10 ]] && ok || bad "only $rounds rounds in the markup"

# §14.4 — the one named exception to "no published theme is refused". The narrative tool
# fails if this file is ever ACCEPTED, so the exception is enforced from the other side
# rather than by lowering the rule.
check "the deliberately refused theme is still refused (§14.4)"
narrative="apps/site/src/generated/narrative.json"
if [[ -s $narrative ]] && grep -q '"refusals"' "$narrative"; then ok; else
    bad "$narrative carries no refusal — act three has nothing to read"
fi

# §15.2 — A MEASUREMENT PLACEMENT NAMES A MOMENT, NEVER A POSITION. The collector refuses
# one too, and both are wanted: the collector catches what a page sends, this catches what a
# page carries before anybody clicks it.
check "no measurement placement is indexed on a position (§15.2)"
positional="$(grep -rhoE 'data-placement="[^"]*(^|[-_])([0-9]+|first|second|third|fourth|fifth|last|next|previous)([-_]|")[^"]*"' \
    dist --include='*.html' 2>/dev/null || true)"
if [[ -z $positional ]]; then ok; else bad "$positional"; fi

# §12.3 — the script is acceptable only because it is OFF THE PATH. This is the line that
# makes that true, and widening it puts the whole site back in front of the request quota.
check "the worker answers on one address and no other (§12.3)"
confined="$(grep -o '"run_worker_first": \["/_event"\]' wrangler.jsonc | wc -l || true)"
[[ $confined -eq 1 ]] && ok || bad "run_worker_first must name exactly [\"/_event\"]"

# §13.1, §13.2 — THE RESPONSE HEADERS. The file is in the artefact; whether the host
# applies it is something only a served response can say, and tests/browser/headers.spec.ts
# asks that question against the runtime production uses.

check "the headers file was generated (§13.1)"
[[ -f dist/_headers ]] && ok || bad "dist/_headers missing — run generate-headers.mjs"

check "_headers and _redirects are kept out of the asset store"
if grep -q '^_headers$' dist/.assetsignore 2>/dev/null && grep -q '^_redirects$' dist/.assetsignore 2>/dev/null; then
    ok
else bad "dist/.assetsignore must list both, or the host serves them as files"; fi

# §13.2 — the narrow allowance is permitted and documented; the broad one is FORBIDDEN.
# Checked on the artefact as well as in a browser, because this is the line the policy
# exists to hold and widening it is a one-word change.
check "the policy allows WebAssembly and nothing broader (§13.2)"
if grep -q "wasm-unsafe-eval" dist/_headers 2>/dev/null &&
   ! grep -qE "'unsafe-eval'|'unsafe-inline'" dist/_headers; then
    ok
else bad "the policy is missing 'wasm-unsafe-eval', or carries a broad allowance"; fi

check "the policy's hashes and the artefact's inline content agree (§13.2)"
# The generator hashes whatever stayed inline, and the two checks further up refuse inline
# content outright. So the only consistent artefact is one with neither — and the day
# something genuinely has to be inlined, those checks and this one move together rather
# than 'unsafe-inline' being added quietly, which would disable the protection for every
# script and style on the site to save one request.
hashed="$(grep -o 'sha256-' dist/_headers | wc -l || true)"
inline_styles="$(grep -oE '<style[^>]*>[^<]' dist/index.html | wc -l || true)"
if [[ $hashed -eq 0 && $inline_styles -eq 0 ]]; then
    ok
else
    bad "$hashed policy hashes for $inline_styles inline blocks — they must match"
fi

# §11 — THE COMPARISON. Read off the page, because what matters is what shipped.

check "the comparison page is there (§11)"
[[ -f dist/why-slugger/index.html ]] && ok || bad "dist/why-slugger/index.html missing"

# §11.4 — no criterion is shown without being taught. Every axis must carry its question and
# its explanation IN THE PAGE, not only in the data: a template that forgot to render one
# would compile and publish a criterion nobody was taught.
check "every axis carries its question in the page (§11.4)"
if [[ -f dist/why-slugger/index.html ]]; then
    declared="$(grep -oE "question: '" apps/site/src/comparison.ts | wc -l || true)"
    rendered="$(grep -o 'class="axis-question"' dist/why-slugger/index.html | wc -l || true)"
    [[ $declared -gt 0 && $declared -eq $rendered ]] && ok ||
        bad "$declared axes declared, $rendered questions rendered"
else bad "no comparison page"; fi

check "every axis carries its explanation and its verdicts (§11.4)"
if [[ -f dist/why-slugger/index.html ]]; then
    axes="$(grep -o 'class="axis"' dist/why-slugger/index.html | wc -l || true)"
    verdicts="$(grep -o 'class="verdict verdict--' dist/why-slugger/index.html | wc -l || true)"
    # Read off the matrix's own header rather than guessed from the source: one column per
    # option, plus the one that names the question.
    columns="$(grep -o '<th scope="col">' dist/why-slugger/index.html | wc -l || true)"
    options=$(( columns - 1 ))
    [[ $axes -gt 0 && $verdicts -eq $(( axes * options )) ]] && ok ||
        bad "$axes axes x $options options should be $(( axes * options )) verdicts, found $verdicts"
else bad "no comparison page"; fi

# §11.4 — what deepens may fold, but through a NATIVE mechanism that opens from the
# keyboard. A div behind a script is neither.
check "the folded notes use a native disclosure (§11.4)"
grep -q '<details' dist/why-slugger/index.html 2>/dev/null && ok ||
    bad "no <details> on the comparison page"

# §11.7 — the right of reply is VISIBLE on the page, and the last-checked date with it.
check "the right of reply and the date are on the page (§11.7)"
if grep -q 'slugger.online/issues/1' dist/why-slugger/index.html 2>/dev/null &&
   grep -qE 'Last checked against its sources on [0-9]{4}-[0-9]{2}-[0-9]{2}' dist/why-slugger/index.html; then
    ok
else bad "the invitation to correct us, or the date, is missing"; fi

# §10.4 — the rule this document calls one of its most important: the site never carries a
# SECOND wording of a refusal or a measurement. Two wordings drift apart at the first
# correction and drift in silence, because both stay plausible and nothing compares them.
# This is what compares them: every fixed sentence the engine's error model writes, taken at
# the pin, against every component in this repository. A match is a copy.
check "no second wording of anything the engine says (§10.4)"
sentences="apps/site/src/generated/engine-sentences.txt"
if [[ ! -s $sentences ]]; then
    bad "$sentences is missing; run scripts/fetch-sentences.sh"
else
    copied="$(grep -rF -f "$sentences" apps/site/src apps/playground \
        --include='*.astro' --include='*.razor' --include='*.ts' --include='*.cs' \
        --exclude-dir=generated --exclude-dir=bin --exclude-dir=obj 2>/dev/null || true)"
    if [[ -z $copied ]]; then ok; else bad "$copied"; fi
fi

# §10.4 — a sentence that names a command-line option is advice, and advice belongs to
# neither side: a terminal may say which flag to correct because its reader has just typed
# one; a page may not, because its reader may have installed nothing at all, which is exactly
# what §10.2 promises them. Every refusal shown must therefore pass through the one place
# that drops those sentences.
check "every refusal shown is filtered of flag advice (§10.4)"
unfiltered="$(grep -n 'DiagnosticMessage' apps/playground/*.razor 2>/dev/null | grep -v 'Reasons.Said' || true)"
if [[ -z $unfiltered ]]; then ok; else bad "$unfiltered"; fi

# §10.2 — the playground does not validate the MEANING of a theme and never claims to. The
# phases of the protocol that find the most are human readings, and none of them automates. A
# word like "valid" on this page would tell an author their theme is good where it says only
# that the file holds together with what it declares.
check "no control is presented as validating a theme's meaning (§10.2)"
claims="$(grep -rniE '\b(valid|invalid|correct(ly)?|verified|approved|quality|score|rating)\b' \
    apps/playground/Playground.razor 2>/dev/null || true)"
if [[ -z $claims ]]; then ok; else bad "$claims"; fi

# §10.5 — THE CONDITION OF PUBLISHING THE ROUTE, in that section's own words, not a later
# improvement. The playground drives a fixed set of options: the command line's. A typed call
# makes a RENAMED option a compilation error, which is why the bridge is one; it cannot make
# an ADDED option anything at all. That is the drift this closes, and the only one left.
#
# The list it reads was taken from the library at the pin (scripts/fetch-options.sh), and the
# bridge names each option with nameof(GenerationOptions.X), so both sides are mechanical.
check "the playground offers every draw option the command does (§10.5)"
bridge="apps/playground/DrawOptions.cs"
# Only the arms of the switch, never the prose around them: this file explains itself with
# the same nameof() it dispatches on, and a comment must not be able to satisfy a check.
declared="$(grep -E '=>\s*options with' "$bridge" |
    grep -oE 'nameof\(GenerationOptions\.[A-Za-z]+\)' | sed -E 's/.*\.([A-Za-z]+)\)/\1/' | sort -u)"
offered="$(grep -oE '"property": "[A-Za-z]+"' dist/playground/options.json | sed -E 's/.*: "(.*)"/\1/' | sort -u)"
if [[ -z $offered ]]; then
    bad "dist/playground/options.json names no option"
elif [[ "$declared" != "$offered" ]]; then
    bad "$(printf 'the command offers:\n%s\nthe playground handles:\n%s' "$offered" "$declared")"
else
    ok
fi

# §10.2 — "the themes of the catalogue (§7.6)", which is seventeen, not the three the package
# embeds. An embedded theme needs no file; every other one does, or the visitor picks a name
# that cannot draw.
check "every catalogue theme can be drawn in the playground (§10.2)"
missing_theme=""
while IFS= read -r line; do
    name="${line%%|*}"
    origin="${line##*|}"
    [[ $origin == embedded ]] && continue
    [[ -f "dist/playground/themes/${name}.json" ]] || missing_theme="${missing_theme}${name} "
done < <(grep -oE '"name": "[^"]+"|"origin": "[^"]+"' dist/playground/themes/index.json |
    sed -E 's/.*: "(.*)"/\1/' | paste -d'|' - -)
catalogued="$(grep -c '"name"' apps/site/src/generated/catalogue.json || true)"
published="$(grep -c '"name"' dist/playground/themes/index.json || true)"
if [[ -n $missing_theme ]]; then
    bad "no theme file published for: $missing_theme"
elif [[ $catalogued -ne $published ]]; then
    bad "the catalogue holds $catalogued themes, the playground is offered $published"
else
    ok
fi

# §8.5 — the mark. The reference check above already proves the three files are in the
# artefact; this one proves every page still asks for them. The two failures it is for: a
# layout that loses a link in a refactor, and the playground drifting away from the site it
# claims to be part of (§8.6). Both look fine in a diff and wrong in a tab.
check "every page carries the library's mark (§8.5 and 8.6)"
unmarked=""
while IFS= read -r page; do
    for rel in 'href="/favicon.ico"' 'href="/favicon.svg"' 'href="/apple-touch-icon.png"'; do
        grep -qF "$rel" "$page" || unmarked="${unmarked}${page} -> ${rel}"$'\n'
    done
done < <(find dist -name '*.html' -type f)
if [[ -z $unmarked ]]; then ok; else bad "$unmarked"; fi

# The mark is mirrored, never drawn here (§8.5). A file that stopped being the library's
# would still be a valid icon and would still pass every check above it, so the one thing
# worth asserting is that nothing in the repository supplies it.
check "the mark is mirrored, not committed (§8.5)"
committed="$(git ls-files 'apps/site/public/favicon.*' 'apps/site/public/apple-touch-icon.*' 2>/dev/null || true)"
if [[ -z $committed ]]; then ok; else bad "committed instead of mirrored: $committed"; fi

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
