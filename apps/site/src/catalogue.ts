/**
 * The catalogue the theme pages render — produced at build time by `tools/catalogue`, from
 * the engine (§7.6, §14.2, §14.3).
 *
 * These types describe that file. Nothing here computes anything about a theme: every
 * number already came from the engine, and a page that derived one would be the second
 * source of truth §2 exists to prevent.
 */
import catalogue from './generated/catalogue.json';

/** How a theme reaches its reader — never where its file happens to live (§7.6). */
export type Origin = 'embedded' | 'mirrored';

export interface Meta {
    /** A display name. NEVER an identity: the file name is (§7.6). Absent when undeclared. */
    readonly title?: string;
    readonly description?: string;
    readonly author?: string;
    readonly version?: string;
    readonly source?: string;
    readonly createdAt?: string;
    readonly publishedAt?: string;
}

export interface Margin {
    /** The engine's own rule identifier, e.g. `AdjectivesPerNoun`. */
    readonly rule: string;
    readonly worstCase: number;
    /** The noun or word the worst case belongs to, when the rule has one. */
    readonly beside?: string;
    readonly limit: number;
    readonly marginValue: number;
}

export interface Exposure {
    readonly word: string;
    readonly nouns: number;
}

/** A refusal: the engine's sentence, word for word, and the code a page groups by (§10.4). */
export interface Reason {
    readonly code: string;
    readonly sentence: string;
}

export interface Measurements {
    readonly isAccepted: boolean;
    readonly floorsWaived: boolean;
    readonly combinations: number;
    readonly longestSlug: string;
    readonly margins: readonly Margin[];
    readonly duplicatedNouns: readonly string[];
    readonly unreachableCategories: readonly string[];
    readonly leastExposed: Exposure;
    readonly mostExposed: Exposure;
    readonly refusals: readonly Reason[];
    readonly remarks: readonly string[];
}

export interface Theme {
    /** The file name, and the key of this theme's route (§7.6). */
    readonly name: string;
    readonly origin: Origin;
    readonly meta: Meta;
    readonly samples: readonly string[];
    readonly measurements: Measurements;
}

export interface Catalogue {
    readonly seed: number;
    /** The library release the mirrored themes were taken from (§7.5). */
    readonly pinnedTag: string;
    readonly engine: string;
    readonly themes: readonly Theme[];
}

export const themes = catalogue as unknown as Catalogue;

export const byOrigin = (origin: Origin): readonly Theme[] =>
    themes.themes.filter((theme) => theme.origin === origin);

/**
 * `AdjectivesPerNoun` read as a human reads it.
 *
 * This is LAYOUT, not wording (§10.4): it splits an identifier mechanically rather than
 * restating a sentence the engine owns. A table of hand-written labels would drift the day
 * a rule is added, and the split cannot.
 */
export const ruleLabel = (rule: string): string => {
    const words = rule.replace(/([a-z])([A-Z])/g, '$1 $2').toLowerCase();

    return words.charAt(0).toUpperCase() + words.slice(1);
};
