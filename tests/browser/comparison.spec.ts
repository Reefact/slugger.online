import { expect, test } from '@playwright/test';

/**
 * THE COMPARISON — §11.
 *
 * Most of its rules are readable from the artefact and live in verify-output.sh. What only a
 * rendered page can say is the ORDER a reader meets things in, and whether the folding
 * actually opens.
 */

test('the page concludes before it proves', async ({ page }) => {
    await page.goto('/why-slugger/');

    // §11.3 — a matrix of ten axes does not read in a minute: it asks a reader to learn ten
    // criteria and apply them themselves. So the three questions §4 gives an already-equipped
    // reader are answered BEFORE the first criterion, and the apparatus comes last.
    const positionOf = async (selector: string) =>
        page.locator(selector).first().evaluate((node) => node.getBoundingClientRect().top + window.scrollY);

    const answers = await positionOf('.answers');
    const firstAxis = await positionOf('.axis');
    const matrix = await positionOf('.matrix');

    expect(answers, 'the three answers come before the first criterion').toBeLessThan(firstAxis);
    expect(firstAxis, 'the criteria come before the matrix').toBeLessThan(matrix);

    // §11.6 — coexistence is said early, but not first: an objection without desire does not
    // exist yet.
    const coexistence = await positionOf('text=Nothing here has to be removed');
    expect(coexistence).toBeGreaterThan(answers);
    expect(coexistence).toBeLessThan(firstAxis);
});

test('a criterion is taught before it is applied, and its verdicts are visible folded', async ({ page }) => {
    await page.goto('/why-slugger/');

    const axis = page.locator('.axis').first();

    // §11.4 — the label, the question and the explanation are visible. What deepens may fold;
    // what the axis means may not.
    await expect(axis.locator('h3')).not.toBeEmpty();
    await expect(axis.locator('.axis-question')).toBeVisible();
    await expect(axis.locator('.prose').first()).toBeVisible();

    // The verdict stays visible whether the note is open or shut: what folds is the sentence
    // behind the answer, never the answer.
    const firstVerdict = axis.locator('.verdict').first();
    await expect(firstVerdict).toBeVisible();
    await expect(firstVerdict).not.toBeEmpty();

    // And the fold opens from the keyboard, with no hover anywhere — there is no hover on a
    // phone, and information in a tooltip is information absent.
    const summary = axis.locator('summary').first();
    const note = axis.locator('details').first().locator('p');

    await expect(note).toBeHidden();
    await summary.focus();
    await page.keyboard.press('Enter');
    await expect(note).toBeVisible();
    await expect(note).not.toBeEmpty();
});

test('the page says good things about the others, and the matrix leads back to each criterion', async ({ page }) => {
    await page.goto('/why-slugger/');

    // §11.1 — a comparison only convinces if it is manifestly able to say the other tool is
    // the right one. On uniqueness it is, and the page has to show it rather than claim it.
    const uniqueness = page.locator('#axis-uniqueness');
    const theirs = uniqueness.locator('summary', { hasText: 'An opaque identifier' });
    await expect(theirs.locator('.verdict--designed-for-it')).toBeVisible();

    const ours = uniqueness.locator('summary', { hasText: 'slugger' });
    await expect(ours.locator('.verdict--not-offered')).toBeVisible();

    // The matrix is a second rendering of the same data, and every row returns to the
    // criterion it summarises.
    const rows = page.locator('.matrix tbody tr');
    const count = await rows.count();
    expect(count).toBeGreaterThan(0);

    for (let i = 0; i < count; i += 1) {
        const href = await rows.nth(i).locator('th a').getAttribute('href');
        expect(href).toMatch(/^#axis-/);
        await expect(page.locator(href!)).toHaveCount(1);
    }
});
