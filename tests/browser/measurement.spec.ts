import { expect, test } from '@playwright/test';

/**
 * THE MEASUREMENT — §15.
 *
 * Two halves. What the collector refuses is asked of the collector, because §16 requires
 * those rules to be enforced there and not only avoided in a page: a page can be edited by
 * somebody who never read the rule. What the page sends is asked of a browser.
 */

const event = (body: unknown) => ({
    data: body,
    headers: { 'content-type': 'application/json' },
});

test('the collector refuses a placement indexed on a position (§15.2)', async ({ request }) => {
    // A narrative page gains and loses scenes. Keyed on position, two measurement periods
    // stop being comparable for the same moment — which is the only thing worth comparing.
    for (const placement of ['scene-3', 'exit-2', 'third-exit', 'last-act', 'step_1']) {
        const response = await request.post('/_event', event({ kind: 'install-copied', placement }));
        expect(response.status(), placement).toBe(422);
    }

    // And accepts one that names the moment instead.
    const good = await request.post(
        '/_event',
        event({ kind: 'install-copied', placement: 'after-the-refusal', variant: 'Slugger' }),
    );
    expect(good.status()).toBe(204);
});

test('the collector refuses anything of a theme (§15.3)', async ({ request }) => {
    // §10.6 promises a theme never leaves the browser. A measurement is exactly the detour
    // nobody thinks to check, so the shape of a theme event is fixed at the collector: a
    // kind, a placement, and a verdict that is one of two words.
    const carrying = await request.post(
        '/_event',
        event({ kind: 'theme-tried', placement: 'playground', themeName: 'mine' }),
    );
    expect(carrying.status(), 'a theme event must carry nothing of the theme').toBe(422);

    const sizes = await request.post(
        '/_event',
        event({ kind: 'theme-measured', placement: 'playground', bytes: 4096 }),
    );
    expect(sizes.status(), 'a size is a fingerprint when the files are few').toBe(422);

    // A free-form variant is the door a theme's name would walk through.
    const named = await request.post(
        '/_event',
        event({ kind: 'theme-measured', placement: 'playground', variant: 'iceland' }),
    );
    expect(named.status()).toBe(422);

    const verdict = await request.post(
        '/_event',
        event({ kind: 'theme-measured', placement: 'playground', variant: 'refused' }),
    );
    expect(verdict.status()).toBe(204);
});

test('the script stays off the path of everything the site serves (§12.3)', async ({ request }) => {
    // The whole basis of the decision to have a script at all. A page, an asset and a 404
    // must be answered without invoking it, so the quota it can exhaust is its own.
    for (const path of ['/', '/why-slugger/', '/playground/', '/themes/']) {
        expect((await request.get(path)).status(), path).toBe(200);
    }

    const missing = await request.get('/this-does-not-exist');
    expect(missing.status()).toBe(404);

    // And the one address it does answer refuses anything but a POST.
    expect((await request.get('/_event')).status()).toBe(405);
});

test('copying a command reports the moment and the half taken (§15.2)', async ({ page }) => {
    const sent: Array<Record<string, unknown>> = [];

    await page.route('**/_event', async (route) => {
        sent.push(JSON.parse(route.request().postData() ?? '{}'));
        await route.fulfill({ status: 204, body: '' });
    });

    await page.context().grantPermissions(['clipboard-read', 'clipboard-write']);
    await page.goto('/');

    // §15.1 — nothing is sent for merely arriving. These lanes ask nobody's consent precisely
    // because none of them can recognise a reader, and that stays true only while nothing
    // fires on its own.
    expect(sent, 'nothing is reported for arriving on a page').toEqual([]);

    const firstExit = page.locator('.exit').first();
    await firstExit.locator('.copy').first().click();

    await expect.poll(() => sent.length).toBe(1);

    const [first] = sent;
    expect(first.kind).toBe('install-copied');
    expect(first.placement, 'the placement names the moment').toBe('after-the-absurd-draw');
    expect(first.variant, 'the variant says which half was taken').toBe('Slugger.Core');

    // No identifier of any kind travels with it.
    expect(Object.keys(first).sort()).toEqual(['kind', 'placement', 'variant']);
});

test('nothing recognises a reader (§15.1, §15.4)', async ({ page }) => {
    await page.context().grantPermissions(['clipboard-read', 'clipboard-write']);
    await page.goto('/');
    await page.locator('.exit .copy').first().click();
    await page.waitForTimeout(200);

    // The first lanes do not ask for consent, and that is only defensible while they cannot
    // link two visits. No cookie, nothing in storage.
    expect(await page.context().cookies()).toEqual([]);
    expect(await page.evaluate(() => window.localStorage.length)).toBe(0);
    expect(await page.evaluate(() => window.sessionStorage.length)).toBe(0);
});

test('the command is readable without the script that copies it (§5.7)', async ({ browser }) => {
    const context = await browser.newContext({ javaScriptEnabled: false });
    const page = await context.newPage();

    await page.goto('/');

    // The command itself is content; the button is an enhancement added only where the
    // clipboard works. A copy button that cannot copy is a control that leads nowhere.
    const command = page.locator('.exit [data-command]').first();
    await expect(command).toBeVisible();
    await expect(command).toContainText('dotnet');
    await expect(page.locator('.copy')).toHaveCount(0);

    await context.close();
});
