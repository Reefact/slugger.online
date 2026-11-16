/**
 * What the narrative shows — produced at build time by `tools/narrative`, from the engine
 * (§9, §14.3).
 *
 * Act I's two columns are the same vocabulary drawn twice: once through a theme that says
 * which words go together, once through the same theme with that classification
 * mechanically removed. No word on this page was invented (§5.6).
 */
import narrative from './generated/narrative.json';

export interface Round {
    readonly withCategories: string;
    readonly withoutCategories: string;
}

export interface Reason {
    readonly code: string;
    readonly sentence: string;
}

export interface Margin {
    readonly rule: string;
    readonly worstCase: number;
    readonly limit: number;
    readonly marginValue: number;
}

export interface ActOne {
    readonly theme: string;
    readonly title: string;
    readonly rounds: readonly Round[];
    readonly combinationsWithCategories: number;
    readonly combinationsWithout: number;
}

export interface ActThree {
    readonly theme: string;
    readonly title: string;
    readonly refusals: readonly Reason[];
    readonly margins: readonly Margin[];
}

export interface Narrative {
    readonly seed: number;
    readonly pinnedTag: string;
    readonly engine: string;
    readonly actOne: ActOne;
    readonly actThree: ActThree;
}

export const narration = narrative as unknown as Narrative;
