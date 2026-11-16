# slugger.online

The official website of **[slugger](https://github.com/Reefact/slugger)** — a .NET command
and library that draw readable `adjective-noun` names from JSON themes their user writes,
and that refuse a vocabulary which does not hold up.

The site is one static deployment: an Astro application, with a Blazor WebAssembly
playground mounted under `/playground/`. There is no application server.

> **Status: the pipeline, the theme catalogue and the narrative are built.** The home page
> carries its three acts, every theme the library ships or carries has a page measured by the
> engine, and the playground boots in a browser and draws from the published package. The
> comparison page is specified and not yet built.

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
