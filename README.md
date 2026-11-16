# slugger.online

The official website of **[slugger](https://github.com/Reefact/slugger)** — a .NET command
and library that draw readable `adjective-noun` names from JSON themes their user writes,
and that refuse a vocabulary which does not hold up.

The site is one static deployment: an Astro application, with a Blazor WebAssembly
playground mounted under `/playground/`. There is no application server.

> **Status: every route the specification names is built.** The home page carries its three
> acts, the comparison answers in a minute and proves afterwards, every theme has a page
> measured by the engine, and the playground boots in a browser and draws from the published
> package.

## The specification

[`docs/design/specification.md`](docs/design/specification.md) — what is decided, and why.
It is in French, by decision; everything else here is in English, and so is the site itself.

It carries no state, no schedule and no fact it is not the source of: §1.2 says why, and §2
says where those facts live instead. Two sections decide more than the others — §3, the
product vision, and §10, the playground, which runs the real engine in the browser and
serves theme authors as much as anyone drawing a name.

## Layout

```
apps/
  site/          Astro — landing page and content pages
  playground/    Blazor WebAssembly — runs the real engine in the browser
packages/
  design-tokens/ Colour, space, type and motion, shared by both applications (§8.6)
tools/
  catalogue/     Measures every theme and draws every slug the site shows (§7.6, §14.3)
  narrative/     Derives the flat theme act one argues against, and reads act three's refusal
scripts/         Build the two halves, assemble them, and refuse a bad artefact
docs/design/     The specification
```

## The narrative

The home page is one transformation in three acts, and act one is the only one that has to
convince: on a flat list the bad pair is rare and unpredictable, which is why proofreading
cannot catch it.

**That act uses no invented word.** It shows one vocabulary drawn twice, with the same seed —
once through a theme that says which words may meet, once through the same theme with that
classification mechanically removed. The derivation lives in `tools/narrative`, removes
classification and nothing else, and both halves are loaded under the ordinary rules: if the
derived theme were ever refused, the build fails rather than comparing against something that
could not exist.

One promise cannot survive the derivation and is dropped with the categories: a theme's
length promise is a promise about its *sorted* pools, and flattening grows every pool.

Acts two and three are static blocks. That is the order the specification fixes for giving
back the cost of an animated scene — merge two scenes, merge the hinge with what follows,
then downgrade a whole act — applied deliberately. Act one is never downgraded.

Act three reads a theme that is refused on purpose, which is the one exception the
specification names. The generator fails if that file is ever *accepted*, so the exception is
enforced from the other side rather than by lowering the rule.

## The headers and the content policy

`scripts/generate-headers.mjs` writes `dist/_headers` after the artefact exists, because the
policy has to name the hash of anything that stayed inline and a hash changes whenever its
content does. A hand-written policy is one that is right until the next build.

**The playground runs under a policy with no `'unsafe-eval'` and no `'unsafe-inline'.** A
WebAssembly runtime cannot start without permission to instantiate a module, and
`'wasm-unsafe-eval'` is exactly that permission and nothing else — no string evaluation, no
`Function` construction, no inline script. The runtime does carry a `new Function` call, in
the path serving the debugging proxy; it never runs on a published site, and the browser
check is what settles that rather than a comment.

Those checks do three things no file can say: they watch for the violation event a browser
raises when it blocks something and require none while the playground boots to a slug; they
inject an inline script and require the browser to refuse it, so a passing boot cannot hide
a policy that was never enforced; and they read the cache regimes off real responses.

Strict transport is **opt-in** — `PUBLIC_HSTS=on` — because sending it from a deployment
whose custom domain is not yet serving locks visitors out for the lifetime of the max-age.
The deployment that turns it on is the one that has checked.

`_headers` and `_redirects` are never served: the host parses them and applies their rules,
and `public/.assetsignore` keeps them out of the asset store. Verified by asking for
`/_headers` and getting a 404.

## The comparison

`/why-slugger` compares slugger with a list you wrote yourself, an opaque identifier,
Docker's names generator and Haikunator — the first two because most teams are choosing
between those rather than between libraries.

**It concludes, then proves.** A matrix of ten axes does not read in a minute: it asks a
reader to learn ten criteria and apply them themselves. So the three questions an
already-equipped reader has are answered before the first criterion, and the apparatus comes
last.

The data is a structured file, and **the teaching of each axis is part of it**: the types
refuse an axis without a plain-language label, the concrete question it settles and a short
explanation, so a criterion nobody was taught does not compile. Three renderings read that
one file.

Every claim about a third-party tool was read in its own repository or registry entry, and
the page shows those links. On uniqueness the page says an opaque identifier is the right
answer and slugger is not — a comparison that cannot say that is not believed when it says
anything else.

`scripts/check-comparison.mjs` runs in the build: it fails on a note that points at a
position another rendering does not keep, or on a comparative superlative, and warns once
the last-checked date is older than the page declares.

## The theme catalogue

`/themes` carries one page per theme — the three the engine embeds, and the ones the library
carries as ordinary files. Grouped by what a theme asks of its reader rather than by where
its file lives: the first work with nothing done, the second are registered.

**Not one figure on those pages was typed.** Margins on each floor, combinations, the
exposure gap, duplicated nouns, unreachable categories: all of it is counted at build time by
the engine, through the model `DEC0038` published. So are the slugs, drawn from a fixed seed
in each theme's own style. A theme that stopped producing one would fail the build.

The mirrored themes are pinned to a released tag, declared once in [`themes.pin`](themes.pin)
and fetched by `scripts/fetch-themes.sh`. A tag, never a branch: mirroring `main` would
publish a theme nobody can register yet.

One thing the specification asks for is absent, deliberately — how a theme classes its words.
The engine publishes the categories nothing reaches and no more, and the site asks for a
measure it lacks rather than computing one
([Reefact/slugger#122](https://github.com/Reefact/slugger/issues/122)). Parsing the theme here
would be a second reading of a document the engine already reads.

## Requirements

| | |
|---|---|
| Node | ≥ 22, with pnpm (`packageManager` pins the version) |
| .NET SDK | pinned by `global.json` |

## Building

```bash
pnpm install
pnpm build
```

That runs the whole pipeline: it draws the build-time slugs with the real engine, builds the
site into `dist/`, publishes the playground, reads its trim warnings, copies it to
`dist/playground/` and verifies the artefact's shape. The halves can also be built
separately with `pnpm build:site` and `pnpm build:playground`.

`dist/` is the deployment — the directory uploaded to Cloudflare Workers, exactly as built.

## Checking it in a browser

```bash
pnpm build          # required: one of the checks is that the playground runs
pnpm test:browser
```

The scripts the build runs read the artefact. This one renders it, against `dist/` served by
the runtime production uses, and checks what only a rendered page can say: the playground
starts and draws a slug, the home page never loads the .NET runtime, nothing is wider than
the viewport.

**It has already earned its place twice.** The playground's boot script is published under a
fingerprinted name, and an `index.html` that references it plainly builds green, loads, and
404s. And the runtime's own files cannot be fingerprinted at all on a static host, because
the map from logical to fingerprinted name is written outside the served directory — the
application then dies at startup with nothing in any build log. Both were found here.

If a browser is already on the machine and is not the build this Playwright version expects,
point at it rather than downloading: `CHROMIUM_PATH=/path/to/chromium pnpm test:browser`.

## How the two halves meet

The playground's project file sets `StaticWebAssetBasePath` to `playground`, and its
`index.html` carries the matching `<base href="/playground/" />`. Both are asserted by
`scripts/verify-output.sh`, because a mismatch produces a blank page rather than an error:
the document loads, and every asset URL resolves one directory too high.

Note that publish already nests the application one directory down because of that same
setting — the output is `publish/wwwroot/playground/`, not `publish/wwwroot/`.

## The engine version

The playground references a **published** package, never a source build: a playground
running the library's `main` would offer options that exist in no package a visitor can
install. The version is declared once, in `Directory.Packages.props`.

The package is `Slugger.Core`; the assembly inside it is `Slugger`. The command ships
separately as `Slugger`.

## Deploying

```bash
pnpm serve      # serve dist/ the way Workers will, parsing _headers and _redirects
pnpm run deploy # publish dist/ as built — it does not rebuild, so build first
```

`pnpm serve` is not a static file server: it is the Workers runtime locally, so the response
headers and the redirect rules are the real ones. Prefer it over any other local server when
checking anything that depends on them.

## Licence

[Apache 2.0](LICENSE).
