/**
 * Package names, versions, install commands and publication state live in ONE place —
 * specification §14.1. No page writes them.
 *
 * Nothing here is a fact this repository owns: the registry is the source (§2). Raising a
 * version is a one-line change, and `state` is what §5.7 renders in plain words. A slot
 * whose state is not `published` must not offer a copyable command, and §16 fails the
 * build if one does.
 *
 * `scripts/check-packages.mjs` confronts every version below with nuget.org, so a version
 * that has gone missing or a `published` that is not true fails rather than ships.
 */

export type PublicationState = 'published' | 'prerelease' | 'unpublished';

export interface Package {
    /** The registry identifier. */
    readonly id: string;
    /** What this half is, in the reader's terms — never the package id. */
    readonly label: string;
    /** Who it is for, in one line. */
    readonly audience: string;
    readonly version: string;
    readonly state: PublicationState;
    /** The command a reader runs. Rendered, never typed into a page. */
    readonly command: string;
}

/**
 * Two slots, because the product ships as two packages that do not install the same way
 * nor for the same reader (§7.4). The command is the tool; the library is referenced.
 */
export const packages: readonly Package[] = [
    {
        id: 'Slugger',
        label: 'The command',
        audience: 'Draw names from a terminal, and write themes of your own.',
        version: '1.2.1',
        state: 'published',
        command: 'dotnet tool install --global Slugger',
    },
    {
        id: 'Slugger.Core',
        label: 'The engine',
        audience: 'Generate names from C#, with no command line involved.',
        version: '1.0.0',
        state: 'published',
        command: 'dotnet add package Slugger.Core',
    },
];

/** Where the reader goes for what this site does not write (§7.5). */
export const repository = 'https://github.com/Reefact/slugger';

/** The words §5.7 renders for each state. Never a colour alone (§13.4). */
export const stateWording: Record<PublicationState, string | null> = {
    published: null,
    prerelease: 'Pre-release — the command needs a prerelease flag.',
    unpublished: 'Not published yet — nothing to install.',
};
