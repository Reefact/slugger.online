#!/usr/bin/env bash
# Everything the site displays that descends from a source by a mechanism — §2.
#
# Two outputs, neither committed: the build-time slugs drawn by the real engine (§14.3),
# and the version stamp that says which build is live. Both are regenerated before every
# build and before `dev`, so a stale one cannot be served.
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$root"

echo "==> slugs, drawn by the engine"
dotnet run --project tools/sample-slugs/SampleSlugs.csproj -c Release -- \
    apps/site/src/generated/slugs.json

echo "==> version stamp"
mkdir -p apps/site/public
commit="$(git rev-parse HEAD 2>/dev/null || echo unknown)"
built="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
cat > apps/site/public/version.json <<JSON
{
  "commit": "$commit",
  "built": "$built"
}
JSON
echo "    $commit"
