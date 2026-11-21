#!/usr/bin/env bash
# Mirrors the library's mark, at the tag themes.pin declares — §8.5.
#
# The site does not draw its own icon. The library already has one: it is the NuGet icon of
# both packages and the command's own .ico. A reader who meets slugger on NuGet, in a
# terminal and here should meet the same glove, and drawing a second one would make the site
# the source of something it does not own (§2). So the mark is mirrored, at the same pin as
# the themes (§7.5).
#
# The library ships TWO drawings and says which size each is for. icon.svg carries grooves,
# highlights and stitches; icon-small.svg is the same glove with that detail taken out,
# because at 16 px — its own words — the full drawing is "a brown blot with a pink dot". The
# web has three slots, and the mapping below follows the library's rule rather than our
# taste:
#
#   icon-small.svg -> favicon.svg           the tab, which a browser draws at 16 to 32 px
#   slugger.ico    -> favicon.ico           seven sizes, already rendered, switching to the
#                                           detailed drawing above 32 px
#   icon.png       -> apple-touch-icon.png  256 px, detailed, never shown small
#
# Nothing is rasterised here. Each file is taken exactly as the library rendered it, so the
# mark cannot drift between the package and the site by way of a renderer of our own.
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$root"

tag="$(grep -vE '^\s*(#|$)' themes.pin | head -1 | tr -d '[:space:]')"
if [[ -z $tag ]]; then
    echo "fetch-icon: themes.pin declares no tag." >&2
    exit 1
fi

out="apps/site/public"
stamp="apps/site/.icon-tag"

mapping=(
    "assets/icon-small.svg:favicon.svg"
    "assets/slugger.ico:favicon.ico"
    "assets/icon.png:apple-touch-icon.png"
)

fresh=1
[[ -f $stamp && "$(cat "$stamp")" == "$tag" ]] || fresh=0
for pair in "${mapping[@]}"; do
    [[ -f "$out/${pair#*:}" ]] || fresh=0
done
if [[ $fresh -eq 1 ]]; then
    echo "==> mark already mirrored at $tag"
    exit 0
fi

# Same notice as fetch-themes.sh, and for the same reason: gh is authenticated by a login
# locally, by GH_TOKEN in Actions, and by nothing at all on a fresh machine.
if ! gh api "repos/Reefact/slugger" --jq '.full_name' > /dev/null 2>&1; then
    echo "fetch-icon: gh cannot reach the GitHub API." >&2
    echo "  In GitHub Actions, give the step: env: { GH_TOKEN: \${{ github.token }} }." >&2
    echo "  Locally, run: gh auth login" >&2
    exit 1
fi

echo "==> mirroring the mark at $tag"
mkdir -p "$out"
rm -f "$stamp"

for pair in "${mapping[@]}"; do
    src="${pair%%:*}"
    dst="${pair#*:}"
    gh api "repos/Reefact/slugger/contents/$src?ref=$tag" --jq '.content' | base64 -d > "$out/$dst"
    # A request that succeeds and returns nothing would publish an empty file, which no
    # browser reports: the tab simply shows the fallback and nobody notices for a release.
    [[ -s "$out/$dst" ]] || {
        echo "fetch-icon: $src came back empty at $tag." >&2
        exit 1
    }
    printf '    %-22s <- %s\n' "$dst" "$src"
done

echo "$tag" > "$stamp"
