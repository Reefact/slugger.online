#!/usr/bin/env bash
# Mirrors the draw options the command line offers, at the tag themes.pin declares — §10.5.
#
# §10.5 decided that the playground drives a FIXED SET OF OPTIONS, the command line's, and
# that the one drift it leaves open is an option added there and forgotten here. This script
# is half of the answer: it takes the list from the library instead of letting anyone type it
# twice. scripts/verify-output.sh is the other half, and §10.5 makes it a condition of
# publishing the route rather than a later improvement.
#
# WHAT COUNTS AS A DRAW OPTION, mechanically and with no list to maintain by hand: a
# SluggerSettings property whose name is also a GenerationOptions property. The command line
# has exactly one flag per option the engine declares, so the intersection is the list and
# nothing else is. Everything the command accepts beyond it is a command (--init,
# --register, --analyze), an output concern (--count, --oneshot, --clipboard) or asks for a
# filesystem the browser does not have (--theme-dir), which §10.3 refuses anyway.
#
# The wording travels with the list, and that is §10.4: the library names its options and
# says what they do, the site decides where that text sits. A label written here would be the
# site explaining the library in its own words, which is exactly what §10.4 forbids.
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$root"

tag="$(grep -vE '^\s*(#|$)' themes.pin | head -1 | tr -d '[:space:]')"
out="apps/site/src/generated/draw-options.json"

if [[ -f $out ]] && grep -q "\"pinnedTag\": \"$tag\"" "$out" 2>/dev/null; then
    echo "==> draw options already mirrored at $tag"
    exit 0
fi

if ! gh api "repos/Reefact/slugger" --jq '.full_name' > /dev/null 2>&1; then
    echo "fetch-options: gh cannot reach the GitHub API." >&2
    echo "  In GitHub Actions, give the step: env: { GH_TOKEN: \${{ github.token }} }." >&2
    echo "  Locally, run: gh auth login" >&2
    exit 1
fi

echo "==> mirroring the draw options at $tag"
mkdir -p "$(dirname "$out")"

work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT

for path in src/Slugger.Cli/CommandLine/SluggerSettings.cs src/Slugger/GenerationOptions.cs; do
    gh api "repos/Reefact/slugger/contents/$path?ref=$tag" --jq '.content' | base64 -d > "$work/$(basename "$path")"
done

TAG="$tag" OUT="$out" WORK="$work" python3 -I - <<'PYEOF'
import io, json, os, re, sys

tag, out, work = os.environ['TAG'], os.environ['OUT'], os.environ['WORK']

def read(name):
    with io.open(os.path.join(work, name), encoding='utf-8') as f:
        return f.read()

def unescape(text):
    return text.replace('\\"', '"').replace('\\\\', '\\')

# [CommandOption("--sep <CHARACTER>")] / [Description("...")] / public string? Separator
declaration = re.compile(
    r'\[CommandOption\("((?:[^"\\]|\\.)*)"\)\]\s*\n'
    r'\s*\[Description\("((?:[^"\\]|\\.)*)"\)\]\s*\n'
    r'\s*public\s+\S+\s+(\w+)\s*\{')

flags = {}
for template, description, prop in declaration.findall(read('SluggerSettings.cs')):
    flags[prop] = (unescape(template), unescape(description))

# A GenerationOptions property is public and settable at construction. Both shapes appear:
# `public bool Ascii { get; init; }` and a property with an init block of its own.
engine = []
source = read('GenerationOptions.cs')
for match in re.finditer(r'\n    public\s+(?!static)(\S+)\s+(\w+)\s*\{', source):
    kind, name = match.group(1), match.group(2)
    if 'init' in source[match.end():match.end() + 600]:
        engine.append((name, kind))

if len(engine) < 5:
    sys.exit('fetch-options: read %d options from GenerationOptions, which cannot be right.' % len(engine))

options, orphans = [], []
for name, kind in engine:
    if name not in flags:
        orphans.append(name)
        continue
    template, description = flags[name]
    options.append({
        'property': name,
        'type': kind,
        'flag': template.split(' ', 1)[0],
        'template': template,
        'description': description,
    })

# The engine declaring an option the command line cannot reach would break the premise §10.5
# rests on — that the playground and the command drive the same fixed set. Saying so here is
# cheaper than discovering it as a playground that silently offers less than it should.
if orphans:
    sys.exit('fetch-options: %s declared by GenerationOptions with no command-line flag at %s.'
             % (', '.join(orphans), tag))

with io.open(out, 'w', encoding='utf-8') as f:
    json.dump({'pinnedTag': tag, 'options': options}, f, indent=2, ensure_ascii=False)
    f.write('\n')

print('    %d draw options: %s' % (len(options), ' '.join(o['flag'] for o in options)))
PYEOF
