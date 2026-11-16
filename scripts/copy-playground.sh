#!/usr/bin/env bash
# Assembles the published playground into dist/playground/ — §12.2, one artefact built in
# one place.
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$root"

# NOTE THE TRAILING SEGMENT. Because the project file sets StaticWebAssetBasePath to
# `playground`, publish already nests the application one directory down — the output is
# publish/wwwroot/playground/, not publish/wwwroot/. Copying from the parent produces a
# dist/playground/playground/ and a blank page, with no error anywhere; verify-output.sh is
# what caught it.
published="apps/playground/bin/Release/net10.0/publish/wwwroot/playground"

if [[ ! -d $published ]]; then
    echo "copy-playground: $published does not exist. Publish the playground first." >&2
    exit 1
fi

rm -rf dist/playground
mkdir -p dist/playground

# The .gz and .br siblings Blazor emits are left behind. They exist for a server that
# serves precompressed files from disk; the host here compresses from its own asset store,
# so shipping them would roughly triple the artefact's file count for nothing, against the
# budget of §13.3. What compression actually reaches a visitor is one of the things §12.5
# says only a real deployment can settle — check it there, not here.
cd "$published"
find . -type f ! -name '*.gz' ! -name '*.br' -exec cp --parents {} "$root/dist/playground/" \;
cd "$root"

echo "==> playground assembled into dist/playground/ ($(find dist/playground -type f | wc -l) files)"
