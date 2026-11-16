// @ts-check
import { defineConfig } from 'astro/config';

export default defineConfig({
    site: 'https://slugger.online',

    // English only, no locale prefix — specification §6.1. The root serves English, which
    // is exactly the shape a default locale would have, so §6.2's "do not make a second
    // locale impossible" costs nothing here.

    // The whole deployment is one static directory at the repository root, and the
    // published playground is copied into it under /playground/ afterwards
    // (scripts/build-site.sh). Building straight into it keeps the two halves from ever
    // being assembled in two different places — §12.2.
    outDir: '../../dist',

    build: {
        // Directory format writes /themes/index.html rather than /themes.html, so a reader
        // given either spelling lands on the page. It also matches the /playground/ form
        // the published Blazor application already has.
        format: 'directory',

        // Astro inlines small stylesheets into the document by default. Every one it inlines
        // is an inline <style>, and an inline <style> forces the Content Security Policy to
        // allow 'unsafe-inline' for styles — which disables the protection for every
        // stylesheet on the site, to save one request (§13.2). verify-output.sh asserts the
        // result rather than trusting this setting.
        inlineStylesheets: 'never',
    },

    vite: {
        build: {
            // Same reasoning, applied to everything else Astro would fold into the document.
            // An inlined script needs its own hash in the policy, recomputed whenever its
            // content changes; an emitted file is covered by `script-src 'self'`.
            assetsInlineLimit: 0,
        },
    },
});
