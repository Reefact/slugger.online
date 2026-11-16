#!/usr/bin/env bash
# Mirrors the library's repository themes, at the tag themes.pin declares — §7.5.
#
# These are the themes the library carries WITHOUT embedding: ordinary files a reader
# registers. The embedded ones need none of this; they arrive inside the package and the
# catalogue tool reads them from there.
#
# The snapshot is atomic: a tag, never a branch. Mirroring main would publish a theme nobody
# can register yet, and would change under the site without a commit.
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$root"

tag="$(grep -vE '^\s*(#|$)' themes.pin | head -1 | tr -d '[:space:]')"
if [[ -z $tag ]]; then
    echo "fetch-themes: themes.pin declares no tag." >&2
    exit 1
fi

out="tools/catalogue/mirrored"
stamp="$out/.tag"

if [[ -f $stamp && "$(cat "$stamp")" == "$tag" && -n "$(find "$out" -name '*.json' -print -quit 2>/dev/null)" ]]; then
    echo "==> themes already mirrored at $tag"
    exit 0
fi

echo "==> mirroring themes at $tag"
rm -rf "$out"
mkdir -p "$out"

listing="$(gh api "repos/Reefact/slugger/contents/themes?ref=$tag" --jq '.[] | select(.name | endswith(".json")) | .name')"

if [[ -z $listing ]]; then
    echo "fetch-themes: no theme found at $tag." >&2
    exit 1
fi

while IFS= read -r name; do
    gh api "repos/Reefact/slugger/contents/themes/$name?ref=$tag" --jq '.content' | base64 -d > "$out/$name"
    printf '    %s\n' "$name"
done <<< "$listing"

echo "$tag" > "$stamp"
echo "==> $(find "$out" -name '*.json' | wc -l) themes at $tag"
