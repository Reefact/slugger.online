import { expect, test } from '@playwright/test';

/**
 * THE RESPONSE HEADERS AND THE CONTENT POLICY — §13.1, §13.2.
 *
 * These run against `wrangler dev`, the runtime production uses, because `_headers` is
 * PARSED AND APPLIED by the host rather than served as an asset: under any other local
 * server the file is inert and every assertion here would pass against nothing (§12.5).
 */

const SECURITY_HEADERS: ReadonlyArray<readonly [string, RegExp]> = [
    ['x-content-type-options', /^nosniff$/],
    ['referrer-policy', /^strict-origin-when-cross-origin$/],
    ['x-frame-options', /^DENY$/i],
    ['permissions-policy', /camera=\(\)/],
    ['content-security-policy', /default-src 'self'/],
];

test('every page carries the security headers', async ({ request }) => {
    for (const path of ['/', '/why-slugger/', '/themes/', '/playground/']) {
        const response = await request.get(path);
        expect(response.status(), path).toBe(200);

        for (const [header, shape] of SECURITY_HEADERS) {
            expect(response.headers()[header] ?? '', `${path} → ${header}`).toMatch(shape);
        }
    }
});

test('the policy allows WebAssembly and nothing broader', async ({ request }) => {
    const policy = (await request.get('/')).headers()['content-security-policy'] ?? '';

    // §13.2 — the narrow allowance: it permits compiling a WebAssembly module and nothing
    // else. The playground cannot start without it.
    expect(policy).toContain("'wasm-unsafe-eval'");

    // And the broad one stays forbidden. 'unsafe-eval' would permit string evaluation and
    // Function construction besides; 'unsafe-inline' would disable the protection for every
    // script or style on the site to save one request.
    expect(policy, 'the broad allowance must never appear').not.toContain("'unsafe-eval'");
    expect(policy, "'unsafe-inline' must never appear").not.toContain("'unsafe-inline'");

    // Nothing may frame this site, and nothing may be loaded as a plugin.
    expect(policy).toContain("frame-ancestors 'none'");
    expect(policy).toContain("object-src 'none'");
});

test('the playground boots to a slug under the production policy, reporting no violation', async ({ page }) => {
    // §13.2's second rule, and the only one that settles anything: a policy that is correct
    // on review can be wrong in a browser. This watches for the violation event the browser
    // raises when it blocks something, so a passing boot cannot hide a policy the page
    // worked around.
    await page.addInitScript(() => {
        (window as unknown as { __violations: string[] }).__violations = [];
        document.addEventListener('securitypolicyviolation', (event) => {
            (window as unknown as { __violations: string[] }).__violations.push(
                `${event.violatedDirective} blocked ${event.blockedURI}`,
            );
        });
    });

    await page.goto('/playground/');
    await expect(page.locator('[data-slug]')).not.toBeEmpty({ timeout: 90_000 });

    const violations = await page.evaluate(
        () => (window as unknown as { __violations: string[] }).__violations,
    );

    expect(violations, 'the policy blocked something the playground needed').toEqual([]);
});

test('the policy is enforced, not merely sent', async ({ page }) => {
    // A negative control. Without it, every assertion above would still pass against a
    // browser that ignored the header entirely — and so would the boot.
    await page.addInitScript(() => {
        (window as unknown as { __blocked: number }).__blocked = 0;
        document.addEventListener('securitypolicyviolation', () => {
            (window as unknown as { __blocked: number }).__blocked += 1;
        });
    });

    await page.goto('/');

    // `script-src 'self'` with no 'unsafe-inline': injecting an inline script must be
    // refused by the browser.
    await page.evaluate(() => {
        const script = document.createElement('script');
        script.textContent = 'window.__itRan = true;';
        document.head.append(script);
    });

    expect(await page.evaluate(() => (window as unknown as { __itRan?: boolean }).__itRan)).toBeUndefined();
    expect(await page.evaluate(() => (window as unknown as { __blocked: number }).__blocked)).toBeGreaterThan(0);
});

test('the three cache regimes reach the response', async ({ request }) => {
    // §13.1. The playground's runtime is the one that cannot be fingerprinted, so it is
    // revalidated rather than held: a visitor must not keep last release's runtime.
    const page = await request.get('/');
    expect(page.headers()['cache-control']).toContain('no-cache');

    const version = await request.get('/version.json');
    expect(version.headers()['cache-control']).toContain('no-store');

    const runtime = await request.get('/playground/_framework/dotnet.js');
    expect(runtime.status()).toBe(200);
    expect(runtime.headers()['cache-control']).toContain('no-cache');
});
