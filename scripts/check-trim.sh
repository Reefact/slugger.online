#!/usr/bin/env bash
# §10.8 — trim warnings, and the line between the ones that matter and the ones that cannot
# be fixed here.
#
# Trimming is on, and it must be: the engine loads its embedded themes as resources, exactly
# what a trimmer removes when nothing names them, and that failure appears only on the
# PUBLISHED artefact, never in development where trimming is off.
#
# Blazor WebAssembly's own framework resolves component parameters and JS interop through
# reflection, so it emits trim analysis warnings that NO change to this repository can fix.
# The .NET SDK's answer is SuppressTrimAnalysisWarnings, which hides all of them — including
# one from our own code, which is the only kind worth seeing.
#
# So the warnings stay visible and this script draws the line instead:
#
#   a trim warning originating in Microsoft.* or System.* is RECORDED and tolerated;
#   a trim warning originating anywhere else — this repository, or the engine — FAILS.
#
# Suppressing by warning id would have hidden the second kind along with the first, because
# the ids are shared. This is the no-blanket-NoWarn discipline the library keeps, applied
# to a boundary this repository does not own.
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$root"

log="$(mktemp)"
trap 'rm -f "$log"' EXIT

# A CLEAN publish, deliberately. An incremental one does not re-run the linker, so it
# reports no trim warnings at all — a pass that means nothing was linked rather than that
# nothing warned. That false pass was observed, not imagined.
rm -rf apps/playground/bin/Release apps/playground/obj/Release

echo "==> publishing the playground clean, reading its trim warnings"
dotnet publish apps/playground/Slugger.Playground.csproj -c Release > "$log" 2>&1 || {
    cat "$log" >&2
    exit 1
}

warnings="$(grep -oE 'Trim analysis warning IL[0-9]+: [^(]+' "$log" | sed 's/Trim analysis warning //' | sort -u || true)"

if [[ -z $warnings ]]; then
    echo "    none at all."
    exit 0
fi

ours="$(echo "$warnings" | grep -vE ': (Microsoft|System)\.' || true)"
theirs="$(echo "$warnings" | grep -cE ': (Microsoft|System)\.' || true)"

echo "    $theirs from the framework, recorded:"
echo "$warnings" | grep -E ': (Microsoft|System)\.' | sed 's/^/      /' || true

if [[ -n $ours ]]; then
    echo
    echo "check-trim: a trim warning originates outside the framework, which §10.8 does not tolerate:" >&2
    echo "$ours" | sed 's/^/  /' >&2
    exit 1
fi

echo
echo "check-trim: nothing outside the framework warns."
