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

# The themes the playground draws from — §10.2, which says "those of the catalogue (§7.6)",
# not the three the package happens to embed.
#
# They are PUBLISHED AS FILES rather than embedded in the assembly, for three reasons. The
# payload of §13.3 stays as it is. The mirror of §7.5 stays the one copy. And the path a
# repository theme takes through the engine — JSON text into SluggerTheme.LoadFromJson —
# becomes the same path the visitor's own file will take, so the second use of §10.2 is
# built on something already exercised rather than on a branch of its own.
#
# The manifest is derived from the catalogue, never listed here: a theme the library adds
# appears without this script changing (§2). It carries each theme's origin, because the
# three embedded ones need no file — the engine already holds them.
# §10.5 — the option list, published beside the application it drives.
cp apps/site/src/generated/draw-options.json dist/playground/options.json

echo "==> playground themes"
mkdir -p dist/playground/themes
python3 -I -c '
import io, json, os, shutil, sys

with io.open("apps/site/src/generated/catalogue.json", encoding="utf-8") as f:
    themes = json.load(f)["themes"]

manifest = []
for theme in themes:
    name, origin = theme["name"], theme["origin"]
    manifest.append({"name": name, "origin": origin})
    if origin == "embedded":
        continue
    source = os.path.join("tools/catalogue/mirrored", name + ".json")
    if not os.path.isfile(source):
        sys.exit("copy-playground: the catalogue names %s, which the mirror does not hold." % name)
    shutil.copyfile(source, os.path.join("dist/playground/themes", name + ".json"))

manifest.sort(key=lambda t: t["name"])
with io.open("dist/playground/themes/index.json", "w", encoding="utf-8") as f:
    json.dump(manifest, f, indent=1)
    f.write("\n")

embedded = sum(1 for t in manifest if t["origin"] == "embedded")
print("    %d themes, %d of them embedded in the engine" % (len(manifest), embedded))
'

echo "==> playground assembled into dist/playground/ ($(find dist/playground -type f | wc -l) files)"
