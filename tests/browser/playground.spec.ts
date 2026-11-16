import { expect, test } from '@playwright/test';

/**
 * The playground has to RUN. Everything else about it is readable from the artefact; this
 * is not. A trimmed WebAssembly build whose embedded theme resources were removed still
 * publishes, still loads, and draws nothing — and it fails nowhere but here (§10.8).
 */
test('the playground boots and draws a slug from the real engine', async ({ page }) => {
    await page.goto('/playground/');

    const slug = page.locator('[data-slug]');

    // The runtime download is the slow part of a cold start, so this waits for a value
    // rather than for a load event.
    await expect(slug).not.toBeEmpty({ timeout: 90_000 });

    const first = (await slug.textContent())?.trim() ?? '';

    // A slug is at least two words joined by a separator. Asserting the shape rather than a
    // value: the value is drawn, and pinning one would be writing a slug by hand (§14.3).
    expect(first).toMatch(/^[\p{L}\p{N}]+[-_][\p{L}\p{N}]/u);

    // Drawing again must be able to produce something else. Ten presses on a theme with
    // tens of thousands of combinations: a generator that returned a constant would fail,
    // and the odds of ten identical draws are not worth writing down.
    const seen = new Set<string>([first]);

    for (let i = 0; i < 10; i += 1) {
        await page.getByRole('button', { name: 'Draw another' }).click();
        seen.add(((await slug.textContent()) ?? '').trim());
    }

    expect(seen.size).toBeGreaterThan(1);
});

test('the engine offers the themes it ships, and the slug follows the casing asked for', async ({ page }) => {
    await page.goto('/playground/');
    await expect(page.locator('[data-slug]')).not.toBeEmpty({ timeout: 90_000 });

    // The list comes from the engine (SluggerTheme.EmbeddedNames), so this asserts that it
    // arrived rather than which names are in it — the names are the library's fact, not
    // this repository's (§2).
    const themes = page.getByLabel('Theme');
    await expect(themes.locator('option')).not.toHaveCount(0);

    await page.getByLabel('Casing').selectOption('Snake');
    await expect(page.locator('[data-slug]')).toContainText('_');

    await page.getByLabel('Casing').selectOption('Kebab');
    await expect(page.locator('[data-slug]')).toContainText('-');
});

test('the home page shows a slug without loading the .NET runtime', async ({ page }) => {
    // §12.1 and §9.8: a visitor who only reads the presentation never pays for the runtime.
    const framework: string[] = [];
    page.on('request', (request) => {
        if (request.url().includes('_framework/')) {
            framework.push(request.url());
        }
    });

    await page.goto('/');

    // The slug on the landing page was drawn at build time by the real engine (§14.3).
    await expect(page.locator('.slug')).not.toBeEmpty();

    expect(framework).toEqual([]);
});

test('nothing is wider than the viewport at phone width', async ({ page }) => {
    // §13.4. Checked on the rendered page, because no file says it.
    await page.setViewportSize({ width: 360, height: 800 });

    for (const path of ['/', '/playground/']) {
        await page.goto(path);
        const overflow = await page.evaluate(
            () => document.documentElement.scrollWidth - document.documentElement.clientWidth,
        );
        expect(overflow, `${path} scrolls horizontally`).toBeLessThanOrEqual(1);
    }
});
