# Deploying slugger.online

Every step has a check. Do not go on to the next one until the check passes: most of what
goes wrong here is silent, and the step that reveals it is rarely the step that caused it.

This guide is in English, like everything in this repository except the design documents
under `docs/design/`.

> **First run: 2026-11-21, tag `release/2026-11-21`.** These steps have been followed against
> a real account, and what they produced is recorded in them. One thing is still marked as
> unsettled, in step 3, and it is unsettled because it was never exercised rather than
> because it failed.

## 0. Before anything

```bash
pnpm install
pnpm build
pnpm test:browser
```

All three must pass locally first. `pnpm build` ends with `verify-output.sh`, which refuses
an artefact that breaks a rule of the specification; `pnpm test:browser` renders that
artefact under the runtime production uses.

On Windows, build under WSL2: the scripts are bash, which `cmd.exe` and PowerShell cannot
run.

## 1. The account

A Cloudflare account with Workers. The free plan is enough: the site is static assets, which
are unmetered, and the one script is confined to a single address (§12.3).

**Check.** `pnpm exec wrangler whoami` names your account.

## 2. The API token

Create a token with **Edit Cloudflare Workers** on the account that will hold the site.

Add two repository secrets, under Settings → Secrets and variables → Actions:

| Secret | What it is |
|---|---|
| `CLOUDFLARE_API_TOKEN` | The token you just made |
| `CLOUDFLARE_ACCOUNT_ID` | The account id, on the Workers overview page |

And two repository **variables**, which are not secret:

| Variable | Set it to |
|---|---|
| `SITE_ORIGIN` | `https://slugger.online` once step 6 is done; leave it unset before that |
| `PUBLIC_HSTS` | Leave unset until step 7. Read that step before setting it |

**Check.** The `release` workflow's manual dispatch runs green with *Build and verify
without publishing* left on. That rehearses everything up to the publish and stops.

## 3. The first deployment has no address

`wrangler.jsonc` sets `workers_dev: false`, so the Worker does **not** answer on
`slugger-online.<subdomain>.workers.dev`. That is deliberate: left on, the same bytes are
reachable under a second hostname that search engines index and visitors bookmark, and the
custom domain becomes one of the site's addresses rather than its address.

The cost lands here: **between the first publish and step 6, the site has no hostname at
all.** That is expected. Do not turn `workers_dev` on to get around it — turn it on, publish,
and you will be removing an indexed hostname later.

If you want to look at something before the domain is attached, use a preview instead:

```bash
pnpm build
pnpm preview       # uploads a version without promoting it
```

**Check.** `wrangler versions upload` prints a preview URL, and that URL serves the home
page.

> **§12.5 — still unsettled, and honestly so.** Whether a preview URL is unique per upload,
> whether it stays stable while that version exists, and how long it is retained: the first
> deployment went straight from the secrets to the tag, so `pnpm preview` was never run and
> none of it was observed. Nothing in the repository can answer it. The first person to need
> a preview settles it here.

## 4. Publishing

A branch never publishes. What publishes is a `release/*` tag on a commit that is on `main`,
and `scripts/check-release-tag.sh` refuses anything else before the build even starts.

```bash
git checkout main && git pull
git tag release/2026-11-16 && git push origin release/2026-11-16
```

**Check.** The `release` workflow goes green.

**Observed on the first run.** `wrangler` uploaded 77 files and reported:

```
Uploaded slugger-online (4.14 sec)
No targets deployed for slugger-online (0.35 sec)
Current Version ID: 0763c223-68e7-46c1-90fa-cc921996904b
```

`No targets deployed` is the expected answer here, not a warning: `workers_dev` is off and no
domain is attached yet, so the Worker exists and answers on nothing. Step 6 gives it an
address.

The run's last step is skipped at this point, and says why — the `SITE_ORIGIN` variable does
not exist yet. That is also expected; it is set in step 6.

GitHub masks the account id in the logs of its own accord, since it is a secret. It appears
as `***`.

## 5. What the deployment is checked for

```bash
./scripts/check-deployment.sh https://slugger.online release/2026-11-16
```

The workflow runs it for you; run it by hand whenever you want to know the live state. It
asks the live origin the things no build can answer (§12.5):

- the headers file actually taking effect, header by header, and the content policy carrying
  no broad allowance;
- which release is live, read from `version.json`, which is served `no-store` or it answers
  for the previous one;
- the compression actually applied to the WebAssembly resources — the heaviest bytes of the
  artefact;
- the playground's runtime being revalidated rather than held, because its names are stable
  and cannot be fingerprinted (§13.1).

It prints `not settled` rather than `ok` for anything it cannot exercise, and says what would
make the check real. Read those lines; they are the point of the script.

**Observed on the first run**, against the live site: every check above passed, and one came
back `not settled` — the order between serving an asset and applying a rewrite rule. The
playground declares no client-side route, so `_redirects` carries no rule and there is
nothing to exercise. A check that passed there would be reporting on an absence.

The browser suite was also pointed at the deployment, and all of it passed. Two results are
worth recording because they had only ever been reasoned about before: **the playground boots
in production, through to a slug, with no content-policy violation at all** — on the narrow
`'wasm-unsafe-eval'` allowance alone — and the negative control passes too, so the policy is
being enforced rather than merely sent.

You can also point the browser suite at the deployment:

```bash
PLAYWRIGHT_BASE_URL=https://slugger.online pnpm exec playwright test
```

## 6. The custom domain

Attach `slugger.online` to the Worker, in the dashboard under the Worker's Settings →
Domains & Routes. Cloudflare issues the certificate.

**Check.** `curl -sI https://slugger.online/ | head -1` answers `HTTP/2 200`, and
`./scripts/check-deployment.sh https://slugger.online` passes.

**Observed on the first run.** The zone already existed in the account — it had to, since the
API token's zone policy named it when it was created — so Cloudflare issued the certificate
without anything further being asked. The site answered 200 immediately afterwards.

**Observed from a browser, and worth knowing before you panic.** The site answered at once
from outside, while the machine that had tried `slugger.online` before the domain was
attached went on answering `DNS_PROBE_FINISHED_NXDOMAIN` for a good while after. Nothing was
wrong with the deployment. A resolver is allowed to remember that a name does not exist, and
for how long is the last field of the zone's `SOA` record — `1800` here, so thirty minutes
from whenever it asked. Two of those caches are yours to clear: `ipconfig /flushdns` on
Windows, and Chrome's own, at `chrome://net-internals/#dns`. The one at your ISP is not, so
the test that tells you where the stale answer lives is a phone with wifi off. Read the
records rather than guess — `curl -s 'https://dns.google/resolve?name=slugger.online&type=A'`
answers from the public side, and if the `A` and `NS` records are there, the deployment is
fine and the wait is the whole of the problem. Change nothing in Cloudflare during those
thirty minutes: there is nothing there to fix, and a change made blind is what turns a wait
into an outage.

Then set the `SITE_ORIGIN` repository variable, so the workflow checks the deployment from
the next release onward.

## 7. Strict transport, last and deliberately

Only once step 6's check has passed, set the `PUBLIC_HSTS` repository variable to `on` and
publish again.

**Read this before you do.** `Strict-Transport-Security` tells every browser that has seen
it to refuse plain HTTP to this host for the lifetime of the `max-age` — a year, here. Sent
from a deployment whose domain is not serving properly, it locks visitors out of a site you
cannot fix by redeploying, because their browser will not ask you again. That is why it is
opt-in, why it is step 7 rather than step 2, and why the only deployment that turns it on is
one that has checked.

**Check.** `curl -sI https://slugger.online/ | grep -i strict-transport` names it.

**Observed on the second release.** `release/2026-11-21.1` published with both variables set.
The workflow's `Check the deployment` step ran against the live site and passed — which is
the only proof that `SITE_ORIGIN` is set, since the step says nothing when it is missing — and
the header came back as `max-age=31536000; includeSubDomains`. From that release on, every
publish checks itself.

## 8. After the next release

One thing is only observable across two releases, and §12.5 carries it:

> a new version of the playground's runtime reaching a visitor who holds the old one.

Its files have stable names — the map from logical to fingerprinted name is written outside
the served directory, so a static host can never read it (§13.1) — so they are revalidated
rather than held. After the release following this one, load the playground in a browser that
visited the previous one and confirm it draws a slug with the new engine. If it does not,
revalidation is not reaching that path and the cache rule needs re-reading.
