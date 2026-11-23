#!/usr/bin/env bash
# Mirrors the sentences the engine writes, at the tag themes.pin declares — §10.4, §16.
#
# §10.4 forbids the site a SECOND wording of a refusal or a measurement, and gives the
# reason: two wordings drift apart at the first correction, and they drift in silence,
# because both stay plausible and nothing compares them. A theme's author would then be told
# two different things by one product.
#
# A rule nothing checks is a wish (§16). This is what the check compares against: every
# sentence the engine's error model writes, cut at its interpolation holes so that what
# remains is the fixed text a copy would have carried with it. verify-output.sh then asserts
# that no component anywhere in this repository contains one of them.
#
# Short fragments are left out. "is empty" would match prose that owes the engine nothing,
# and a check that cries wolf is a check somebody turns off.
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$root"

tag="$(grep -vE '^\s*(#|$)' themes.pin | head -1 | tr -d '[:space:]')"
out="apps/site/src/generated/engine-sentences.txt"
stamp="apps/site/src/generated/.sentences-tag"

if [[ -f $out && -f $stamp && "$(cat "$stamp")" == "$tag" ]]; then
    echo "==> engine sentences already mirrored at $tag"
    exit 0
fi

if ! gh api "repos/Reefact/slugger" --jq '.full_name' > /dev/null 2>&1; then
    echo "fetch-sentences: gh cannot reach the GitHub API." >&2
    echo "  In GitHub Actions, give the step: env: { GH_TOKEN: \${{ github.token }} }." >&2
    exit 1
fi

echo "==> mirroring the engine's sentences at $tag"
mkdir -p "$(dirname "$out")"

work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT

gh api "repos/Reefact/slugger/contents/src/Slugger/SluggerThemeError.cs?ref=$tag" --jq '.content' |
    base64 -d > "$work/SluggerThemeError.cs"

OUT="$out" WORK="$work" python3 -I - <<'PYEOF'
import io, os, re, sys

out, work = os.environ['OUT'], os.environ['WORK']

with io.open(os.path.join(work, 'SluggerThemeError.cs'), encoding='utf-8') as f:
    source = f.read()

MINIMUM = 25

fragments = set()
for literal in re.findall(r'"((?:[^"\\\n]|\\.)*)"', source):
    text = literal.replace('\\"', '"').replace('\\\\', '\\')
    # An interpolation hole is where the sentence stops being fixed, so it is where a copy
    # would stop matching. What a copy WOULD carry is each run of text between the holes.
    for piece in re.split(r'\{[^}]*\}', text):
        piece = piece.strip()
        # Prose, not an identifier. A cref or a nameof target reaches the minimum length
        # easily and carries no space, and matching one would flag our own typed bridge for
        # naming the very property the engine names — which is the point of the bridge.
        if len(piece) >= MINIMUM and ' ' in piece:
            fragments.add(piece)

if len(fragments) < 5:
    sys.exit('fetch-sentences: read %d sentences, which cannot be right.' % len(fragments))

with io.open(out, 'w', encoding='utf-8') as f:
    for fragment in sorted(fragments):
        f.write(fragment + '\n')

print('    %d sentences of at least %d characters' % (len(fragments), MINIMUM))
PYEOF

echo "$tag" > "$stamp"
