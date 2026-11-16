/**
 * The copy buttons, and the only place an install event is raised — §7.1, §15.2.
 *
 * Progressive enhancement: the command is readable and selectable without this script, and
 * the button is only ADDED when it can work. §5.7 asks that nothing visible lead nowhere,
 * and a copy button that does nothing because the clipboard is unavailable is exactly that.
 */
import { report } from './measure';

const canCopy = typeof navigator !== 'undefined' && typeof navigator.clipboard?.writeText === 'function';

if (canCopy) {
    for (const slot of document.querySelectorAll<HTMLElement>('[data-command]')) {
        const command = slot.textContent?.trim() ?? '';
        const placement = slot.dataset.placement ?? '';
        const variant = slot.dataset.variant ?? '';

        if (command === '' || placement === '') {
            continue;
        }

        const button = document.createElement('button');
        button.type = 'button';
        button.className = 'copy';
        button.textContent = 'Copy';
        // Named for a screen reader, which hears "Copy" with no idea what of.
        button.setAttribute('aria-label', `Copy the command: ${command}`);

        button.addEventListener('click', () => {
            void navigator.clipboard.writeText(command).then(
                () => {
                    button.textContent = 'Copied';
                    // The live region announces it; the word changing is for everyone else.
                    window.setTimeout(() => {
                        button.textContent = 'Copy';
                    }, 2000);

                    // The variant says WHICH half was taken: the engine and the command do
                    // not say the same thing about the reader who took them (§15.2).
                    report('install-copied', placement, variant);
                },
                () => undefined,
            );
        });

        slot.after(button);
    }
}
