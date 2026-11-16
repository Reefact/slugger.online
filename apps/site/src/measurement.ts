/**
 * What may be measured, and under what name — §15.2.
 *
 * A PLACEMENT NAMES A MOMENT, NEVER A POSITION. A copy event with no dimension only says
 * that people copy; the useful information is which moment convinced them, and that is
 * precisely what an identifier tied to where something sat would destroy. A narrative page
 * gains and loses scenes: keyed on position, two measurement periods stop being comparable
 * for the same moment.
 *
 * So these read as what the visitor had just understood. If act three moved before act two,
 * `after-the-refusal` would still mean the same thing — which is the test any new name has
 * to pass. The collector refuses a positional one besides, because a page can be edited by
 * somebody who never read this file.
 */
export const placements = {
    /** The compact command in the header, available from any page once the hero is passed. */
    header: 'header',
    /** They have seen that a flat list draws pairs nobody wants. */
    afterTheAbsurdDraw: 'after-the-absurd-draw',
    /** They have seen that the vocabulary is a file they write. */
    afterTheWordsAreYours: 'after-the-words-are-yours',
    /** They have seen what answers for a vocabulary they wrote. */
    afterTheRefusal: 'after-the-refusal',
    /** They came to compare, and decided. */
    afterTheComparison: 'after-the-comparison',
} as const;

export type Placement = (typeof placements)[keyof typeof placements];
