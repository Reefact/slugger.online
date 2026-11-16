import { defineConfig, devices } from '@playwright/test';

/**
 * The published artefact, rendered.
 *
 * These checks run against `dist/` — never a development build — because that is the only
 * thing that catches the class of defect which exists only after trimming (§10.8), and the
 * only thing that can answer what a rendered page says rather than what a file contains.
 *
 * It is served by `wrangler dev`, the runtime production uses, and NOT by a plain static
 * server: _redirects and _headers are parsed and applied by the host rather than served as
 * assets, so anything that depends on them is only true under this runtime (§12.5).
 */
export default defineConfig({
    testDir: './tests/browser',
    fullyParallel: true,
    // The WebAssembly runtime's cold start is the slow part, and the default 30s cut the
    // per-expect timeouts below off at the knees.
    timeout: 120_000,
    forbidOnly: Boolean(process.env.CI),
    retries: 0,
    reporter: process.env.CI ? 'github' : 'list',

    use: {
        baseURL: 'http://127.0.0.1:8788',
        trace: 'retain-on-failure',

        /**
         * Normally empty: Playwright uses the browser it downloaded for its own version.
         *
         * Set CHROMIUM_PATH when a browser is already on the machine and is not the build
         * this Playwright version expects - a prepared container, or an offline one. It is
         * read from the environment rather than written here, so no machine's layout is
         * baked into the repository.
         */
        launchOptions: process.env.CHROMIUM_PATH ? { executablePath: process.env.CHROMIUM_PATH } : {},
    },

    projects: [{ name: 'chromium', use: { ...devices['Desktop Chrome'] } }],

    webServer: {
        command: 'pnpm exec wrangler dev --port 8788',
        url: 'http://127.0.0.1:8788/',
        reuseExistingServer: !process.env.CI,
        // The WebAssembly runtime is the slow part of a cold start, not the server.
        timeout: 120_000,
    },
});
