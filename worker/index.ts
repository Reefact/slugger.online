/**
 * The collector, and the whole of the server side — §15.2, §15.3, and §12.3's one condition.
 *
 * §12.3 refuses a Worker script by default: requests served as static assets are free and
 * unmetered, requests that invoke a script count against a quota, and exhausting that quota
 * answers an error rather than falling back to the assets. The difference between a script
 * and no script is the difference between a site that degrades and a site that goes down.
 *
 * THIS SCRIPT IS ACCEPTABLE ONLY BECAUSE IT IS OFF THE PATH. wrangler.jsonc names exactly
 * one address under `run_worker_first`, so a request for a page, an asset or a 404 never
 * reaches this file. The quota it can exhaust is its own: exhausting it stops the
 * measurement, not a page. Widening that list is not a change to make without reopening the
 * decision.
 *
 * It stores nothing that could identify a visitor, and the two rules it enforces are the
 * ones §16 says the collector must refuse rather than merely the artefact avoid.
 */

interface Environment {
    /** Absent in a local run, which is why every write is guarded. */
    readonly MEASUREMENT?: {
        writeDataPoint(point: {
            indexes?: readonly string[];
            blobs?: readonly string[];
            doubles?: readonly number[];
        }): void;
    };
}

/** What may be reported. Anything else is refused, not silently dropped. */
const KINDS = new Set(['install-copied', 'theme-tried', 'theme-measured']);

/**
 * §15.2 — A PLACEMENT IS INDEXED ON A MOMENT, NEVER ON A POSITION.
 *
 * A narrative page gains and loses scenes. An event keyed on where something sat would make
 * two measurement periods incomparable for the same moment, which is precisely the thing
 * worth comparing. So a placement that carries an ordinal is refused here, by the collector,
 * and not only avoided in the page: a page can be edited by somebody who never read this.
 *
 * The ordinal may travel as a secondary field for a dashboard's readability. Never as a key.
 */
const POSITIONAL = /(^|[-_])(\d+|first|second|third|fourth|fifth|last|next|previous)([-_]|$)/i;

const MAX_FIELD = 64;

function refuse(reason: string): Response {
    // 422, not 400: the request is well-formed and its content is not allowed. The body says
    // why, because the only reader is a developer who just broke a rule.
    return new Response(reason, { status: 422, headers: { 'content-type': 'text/plain' } });
}

export default {
    async fetch(request: Request, env: Environment): Promise<Response> {
        if (request.method !== 'POST') {
            return new Response('POST only', { status: 405, headers: { allow: 'POST' } });
        }

        let payload: unknown;

        try {
            payload = await request.json();
        } catch {
            return refuse('not JSON');
        }

        if (typeof payload !== 'object' || payload === null) {
            return refuse('not an object');
        }

        const { kind, placement, variant, ordinal } = payload as Record<string, unknown>;

        if (typeof kind !== 'string' || !KINDS.has(kind)) {
            return refuse('unknown kind');
        }

        if (typeof placement !== 'string' || placement.length === 0 || placement.length > MAX_FIELD) {
            return refuse('placement missing');
        }

        if (POSITIONAL.test(placement)) {
            return refuse(`placement "${placement}" is indexed on a position; name the moment instead`);
        }

        if (variant !== undefined && (typeof variant !== 'string' || variant.length > MAX_FIELD)) {
            return refuse('variant must be a short string');
        }

        /**
         * §15.3 — THE PLAYGROUND REPORTS THAT A THEME WAS MEASURED, NEVER WHAT WAS MEASURED.
         *
         * Knowing that theme authors use the theme mode is what says whether the audience the
         * specification declares best served exists at all. Knowing anything about their
         * theme never is: not the words, not the categories, not the file name, and not its
         * size, which is a fingerprint when the files are few.
         *
         * §10.6 promises the file never leaves the browser. An event carrying something of it
         * would make that promise a lie by a detour, and a measurement is exactly the detour
         * nobody thinks to check. So the shape of a theme event is fixed here: a kind, a
         * placement, and a verdict that is one of two words.
         */
        if (kind !== 'install-copied') {
            const extra = Object.keys(payload as object).filter(
                (key) => !['kind', 'placement', 'variant', 'ordinal'].includes(key),
            );

            if (extra.length > 0) {
                return refuse(`a theme event carries nothing of the theme; drop ${extra.join(', ')}`);
            }

            if (variant !== undefined && variant !== 'accepted' && variant !== 'refused') {
                return refuse('a theme event reports accepted or refused, and nothing else');
            }
        }

        env.MEASUREMENT?.writeDataPoint({
            indexes: [kind],
            blobs: [placement, typeof variant === 'string' ? variant : ''],
            // The ordinal travels here, as a secondary field, never as a key (§15.2).
            doubles: [typeof ordinal === 'number' && Number.isFinite(ordinal) ? ordinal : 0],
        });

        // Nothing to say back. 204 keeps the response out of the way of a page that has
        // already moved on.
        return new Response(null, { status: 204 });
    },
};
