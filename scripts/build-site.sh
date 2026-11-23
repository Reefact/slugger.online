#!/usr/bin/env bash
# The whole pipeline, and the same script the continuous integration runs — §12.4. A
# pipeline that restates the local build drifts from it, and the drift is only discovered
# once one of the two is already wrong.
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$root"

./scripts/generate-content.sh

# §11.7 — the comparison's editorial rules, and its freshness warning.
node ./scripts/check-comparison.mjs

# §3.7, §10.2 — the mechanical phase, on every published theme, and the negative control that
# makes its silence mean something: a filter that never speaks proves nothing.
echo "==> protocol: the mechanical phase, against the themes it will be offered"
dotnet run --project tools/protocol/Protocol.Tool.csproj -c Release -- tools/catalogue/mirrored

echo "==> site"
pnpm --filter @slugger/site build

# A clean publish of the playground, and the trim boundary of §10.8 read off it.
./scripts/check-trim.sh

./scripts/copy-playground.sh

# §13.2 — the policy names the hash of anything left inline, so it is written after the
# artefact exists and recomputed every time.
node ./scripts/generate-headers.mjs

./scripts/verify-output.sh

echo
echo "dist/ is the deployment, exactly as built."
