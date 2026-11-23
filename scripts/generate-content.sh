#!/usr/bin/env bash
# Everything the site displays that descends from a source by a mechanism — §2.
#
# Nothing here is committed: it is regenerated before every build and before `dev`, so a
# stale copy cannot be served. The mirrored themes are pinned (§7.5) and cached by tag, so
# this is cheap after the first run.
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$root"

tag="$(grep -vE '^\s*(#|$)' themes.pin | head -1 | tr -d '[:space:]')"

./scripts/fetch-themes.sh

# §8.5 — the mark, mirrored rather than drawn, at the same pin.
./scripts/fetch-icon.sh

# §10.5 — the draw options the command line offers, taken from it rather than typed twice.
./scripts/fetch-options.sh

# §10.4 — what the engine says, so that a check can prove the site never says it a second time.
./scripts/fetch-sentences.sh

echo "==> catalogue: measurements and slugs, from the engine"
dotnet run --project tools/catalogue/Catalogue.csproj -c Release -- \
    tools/catalogue/mirrored "$tag" apps/site/src/generated/catalogue.json

echo "==> narrative: the contrast act one argues, and the refusal act three reads"
dotnet run --project tools/narrative/Narrative.csproj -c Release -- \
    tools/catalogue/mirrored/iceland.json apps/site/src/themes/hasty.json "$tag" \
    apps/site/src/generated/narrative.json

echo "==> version stamp"
mkdir -p apps/site/public
commit="$(git rev-parse HEAD 2>/dev/null || echo unknown)"
built="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
# RELEASE_TAG is set by the release workflow and empty everywhere else, so a local build
# says plainly that it is not a release rather than claiming to be one.
cat > apps/site/public/version.json <<JSON
{
  "release": "${RELEASE_TAG:-none}",
  "commit": "$commit",
  "built": "$built",
  "themes": "$tag"
}
JSON
echo "    $commit"
