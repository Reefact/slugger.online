/**
 * Sending an event — §15.2, §15.3.
 *
 * FIRST-PARTY, and that is not incidental: the collector answers on this site's own origin,
 * so `connect-src 'self'` covers it and the content policy stays as narrow as §13.2 left it.
 * A third-party tag here would have to be allowed by the policy, and would be a third party
 * reached before anyone was asked (§15.4).
 *
 * Failing to report is never allowed to cost the visitor anything: the call is fire and
 * forget, and every error is swallowed. A measurement that broke a copy button would be
 * worse than no measurement.
 */
type Kind = 'install-copied' | 'theme-tried' | 'theme-measured';

export function report(kind: Kind, placement: string, variant?: string): void {
    const body = JSON.stringify(variant === undefined ? { kind, placement } : { kind, placement, variant });

    try {
        // Survives the page being left, which a copy often precedes.
        if (typeof navigator.sendBeacon === 'function') {
            navigator.sendBeacon('/_event', new Blob([body], { type: 'application/json' }));

            return;
        }

        void fetch('/_event', {
            method: 'POST',
            body,
            headers: { 'content-type': 'application/json' },
            keepalive: true,
        }).catch(() => undefined);
    } catch {
        // Nothing to do, and nothing worth telling the visitor.
    }
}
