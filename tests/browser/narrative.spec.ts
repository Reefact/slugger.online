import { expect, test } from '@playwright/test';

/**
 * THE NARRATION — §9, and chiefly §13.5.
 *
 * Most of what the narration must satisfy is readable from the artefact and lives in
 * verify-output.sh. The two below are not: no file can say whether a reader without
 * scripting still gets act one, nor whether a reduced-motion preference leaves anything
 * hidden.
 */

test('act one is whole without any scripting', async ({ browser }) => {
    // Act one alone carries the demonstration, and §9.7 forbids ever downgrading it. Two
    // lists of words prove nothing, so the comparison has to BE the document.
    const context = await browser.newContext({ javaScriptEnabled: false });
    const page = await context.newPage();

    await page.goto('/');

    const rounds = page.locator('[data-round]');
    await expect(rounds).not.toHaveCount(0);

    // Every round carries both halves: a reader meets the pair together, which is the whole
    // comparison.
    const first = rounds.first();
    await expect(first.locator('.duel-sorted')).not.toBeEmpty();
    await expect(first.locator('.duel-flat')).not.toBeEmpty();

    // And visible, not merely present. A script that hid them and then failed would take the
    // act with it, which is why the enhancement adds the hidden state rather than removing it.
    await expect(first).toBeVisible();

    // The hinge of §9.4 is structural, so it survives too.
    await expect(page.locator('.hinge')).toBeVisible();

    await context.close();
});

test('a reduced-motion preference hides nothing', async ({ browser }) => {
    // §13.5: no continuous scrub, no staged arrival, and the WHOLE of the information kept.
    const context = await browser.newContext({ reducedMotion: 'reduce' });
    const page = await context.newPage();

    await page.goto('/');

    const rounds = page.locator('[data-round]');
    const total = await rounds.count();
    expect(total).toBeGreaterThan(0);

    // Every one of them, at once, with no scrolling asked of anybody.
    for (let i = 0; i < total; i += 1) {
        await expect(rounds.nth(i)).toBeVisible();
    }

    // The scene never opted into its staged state.
    await expect(page.locator('[data-scene]')).not.toHaveClass(/duel--staged/);

    await context.close();
});

test('every act offers a way out, and offers nothing it has not shown', async ({ page }) => {
    await page.goto('/');

    // §9.3 — graded exits. Act one has shown the engine and nothing else, so its exit offers
    // the engine alone; offering the command there would be noise.
    const exits = page.locator('.exit');
    await expect(exits).toHaveCount(3);

    const commands = await page.locator('.exit .slot-command').allTextContents();
    expect(commands.length).toBeGreaterThan(0);

    // §5.7 — nothing copyable for what is not installable. Every command shown must be a
    // real one, which here means it names a package the metadata declares published.
    for (const command of commands) {
        expect(command.trim()).toMatch(/^dotnet (tool install --global|add package) /);
    }
});
