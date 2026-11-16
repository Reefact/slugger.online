#!/usr/bin/env bash
# Renders dist/ and checks what only a rendered page can say — §10.8, §12.5.
#
# It needs a full `pnpm build` first, because one of the checks is that the playground runs.
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$root"

if [[ ! -f dist/playground/index.html ]]; then
    echo "check-in-browser: dist/ is not built. Run pnpm build first." >&2
    exit 1
fi

exec pnpm exec playwright test "$@"
