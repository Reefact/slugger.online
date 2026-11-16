#!/usr/bin/env bash
# The whole pipeline, and the same script the continuous integration runs — §12.4. A
# pipeline that restates the local build drifts from it, and the drift is only discovered
# once one of the two is already wrong.
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$root"

./scripts/generate-content.sh

echo "==> site"
pnpm --filter @slugger/site build

# A clean publish of the playground, and the trim boundary of §10.8 read off it.
./scripts/check-trim.sh

./scripts/copy-playground.sh
./scripts/verify-output.sh

echo
echo "dist/ is the deployment, exactly as built."
