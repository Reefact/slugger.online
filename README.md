# slugger.online

The official website of **[slugger](https://github.com/Reefact/slugger)** — a .NET command
and library that draw readable `adjective-noun` names from JSON themes their user writes,
and that refuse a vocabulary which does not hold up.

The site is one static deployment: an Astro application, with a Blazor WebAssembly
playground mounted under `/playground/`. There is no application server.

> **Status: skeleton.** The build pipeline is real and verified end to end — the playground
> boots in a browser and draws slugs from the published engine. The landing page's narrative,
> the theme catalogue and the comparison page are specified and not yet built.

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
  sample-slugs/  Draws, at build time, every slug the site displays (§14.3)
scripts/         Build the two halves, assemble them, and refuse a bad artefact
docs/design/     The specification
```

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
