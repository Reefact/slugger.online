/**
 * The comparison — specification §11.
 *
 * DATA, NOT MARKUP, and the teaching of each axis is part of the data (§11.7). Three
 * renderings read this one file: criterion by criterion, a duel, and the matrix. A fact that
 * lived in a template could not be rendered three ways, and could not be checked.
 *
 * §11.4 IS ENFORCED BY THESE TYPES. An axis that carried no plain-language label, no concrete
 * question and no explanation would not compile. That is the rule's whole point: "business
 * invariant" has a precise meaning, and having a precise meaning is not being
 * understandable.
 *
 * §11.7 governs what may be written below: a factual tone, no comparative superlative, one
 * idea per sentence, and EVERY claim about a third-party tool verifiable in its own
 * repository or registry — which is why each option carries its sources and the page shows
 * them rather than keeping them in a code comment.
 */

/** The date every claim below was last checked against its source (§11.7). */
export const verifiedOn = '2026-11-16';

/** Past this many days, the build warns. It does not fail: a stale page is not a broken one. */
export const freshnessDays = 180;

/** Where the authors of anything named here are invited to correct us (§11.7). */
export const rightOfReply = 'https://github.com/Reefact/slugger.online/issues/1';

export type OptionId = 'hand-written' | 'opaque-id' | 'docker' | 'haikunator' | 'slugger';

export interface Source {
    readonly label: string;
    readonly href: string;
}

export interface Option {
    readonly id: OptionId;
    /** The author's own name and casing, respected (§11.7). */
    readonly name: string;
    /** The situation a reader recognises themselves in — concrete before abstract. */
    readonly situation: string;
    /** What it is, in one sentence. */
    readonly what: string;
    readonly sources: readonly Source[];
}

/**
 * What a cell says. Four values and no more, because a scale invites a score and this page
 * does not keep one.
 */
export type Verdict = 'designed-for-it' | 'possible' | 'not-offered' | 'beside-the-point';

export interface Cell {
    readonly verdict: Verdict;
    /** One sentence, factual. Never "see above": the duel hides columns (§11.7). */
    readonly note: string;
}

export interface Axis {
    readonly id: string;
    /** Plain language, readable with no prior expertise (§11.4). */
    readonly label: string;
    /** The concrete question it settles, put as a reader would put it (§11.4). */
    readonly question: string;
    /** Short, one idea per sentence (§11.4). */
    readonly explanation: string;
    /** The technical term, when one exists — after the idea, never in its place (§11.4). */
    readonly term?: string;
    /** Only when it teaches more than another sentence would (§11.4). */
    readonly example?: string;
    readonly cells: Readonly<Record<OptionId, Cell>>;
}

export const verdictWording: Record<Verdict, string> = {
    'designed-for-it': 'Designed for it',
    possible: 'Possible',
    'not-offered': 'Not offered',
    'beside-the-point': 'Beside the point',
};

/**
 * §11.2 — the competitors not to forget. Most teams are not choosing between libraries: they
 * have an array in a helper class, or they reached for an opaque identifier and were right
 * to. A comparison that ignores those two is talking past its reader.
 */
export const options: readonly Option[] = [
    {
        id: 'hand-written',
        name: 'A list you wrote yourself',
        situation: 'You needed names last month and wrote twenty adjectives into a helper class.',
        what: 'An array in your own source, drawn from with your own code.',
        sources: [],
    },
    {
        id: 'opaque-id',
        name: 'An opaque identifier',
        situation: 'Nobody reads the name. It only has to be unique.',
        what: 'A GUID, a ULID, a random string. No vocabulary at all.',
        sources: [],
    },
    {
        id: 'docker',
        name: "Docker's names generator",
        situation: 'You liked how Docker names containers and want the same thing.',
        what: 'An adjective and a surname, drawn from two flat lists, joined by an underscore.',
        sources: [
            {
                label: 'moby/moby — internal/namesgenerator/legacy/names-generator.go',
                href: 'https://github.com/moby/moby/blob/master/internal/namesgenerator/legacy/names-generator.go',
            },
        ],
    },
    {
        id: 'haikunator',
        name: 'Haikunator',
        situation: 'You want Heroku-style names from .NET, and you want them now.',
        what: 'An adjective, a noun and a numeric token, drawn from two flat lists.',
        sources: [
            { label: 'Atrox/haikunator.net', href: 'https://github.com/Atrox/haikunator.net' },
            { label: 'Haikunator on nuget.org', href: 'https://www.nuget.org/packages/Haikunator' },
            { label: 'usmanbashir/haikunator — the Ruby original', href: 'https://github.com/usmanbashir/haikunator' },
        ],
    },
    {
        id: 'slugger',
        name: 'slugger',
        situation: 'The names are read by people, and a wrong pair would be noticed.',
        what: 'A vocabulary you write, where a noun declares what it is and only fitting words reach it.',
        sources: [{ label: 'Reefact/slugger', href: 'https://github.com/Reefact/slugger' }],
    },
];

/**
 * §11.5 — ten axes. Each one teaches before it compares, and the order is the order a reader
 * meets the questions in, not the order that flatters anybody.
 */
export const axes: readonly Axis[] = [
    {
        id: 'fit',
        label: 'The adjective has to suit the noun',
        question: 'Can the generator pair words that make no sense together?',
        explanation:
            'On a flat list, every adjective can meet every noun. Most draws come out fine. The bad one is rare, and you cannot tell which draw it will be.',
        term: 'Restriction by shared category',
        example: 'thundering-moon reads wrong; weeping-willow does not. A flat list cannot tell them apart.',
        cells: {
            'hand-written': {
                verdict: 'not-offered',
                note: 'You can curate the pairs by hand, but nothing in an array carries the rule.',
            },
            'opaque-id': { verdict: 'beside-the-point', note: 'There are no words to pair.' },
            docker: {
                verdict: 'not-offered',
                note: 'Two flat lists. The one pair it refuses, boring_wozniak, is a hard-coded exception in the program.',
            },
            haikunator: { verdict: 'not-offered', note: 'Two flat lists, drawn independently.' },
            slugger: {
                verdict: 'designed-for-it',
                note: 'An adjective reaches a noun only when the two share a category. It is the reason the tool exists.',
            },
        },
    },
    {
        id: 'ownership',
        label: 'Whose words are they',
        question: 'If the vocabulary is wrong for you, can you change it?',
        explanation:
            'A generator with a built-in list decides how your names sound. Replacing that list is the difference between a tool and a fixed output.',
        cells: {
            'hand-written': { verdict: 'designed-for-it', note: 'They are literally yours; you typed them.' },
            'opaque-id': { verdict: 'beside-the-point', note: 'There is no vocabulary.' },
            docker: {
                verdict: 'not-offered',
                note: 'The lists live in the program. The package is under internal/, so other Go programs cannot import it at all.',
            },
            haikunator: {
                verdict: 'possible',
                note: 'Adjectives and Nouns are public fields on the Haikunator type, so a caller can replace either.',
            },
            slugger: {
                verdict: 'designed-for-it',
                note: 'A theme is a JSON file you write. The ones it ships are starting points, not the product.',
            },
        },
    },
    {
        id: 'adding-words',
        label: 'Adding a word',
        question: 'Does adding one word mean rebuilding something?',
        explanation:
            'A vocabulary grows. Where it lives decides whether growing it is an edit or a release.',
        cells: {
            'hand-written': { verdict: 'not-offered', note: 'The list is source code, so a word is a rebuild.' },
            'opaque-id': { verdict: 'beside-the-point', note: 'Nothing to add.' },
            docker: { verdict: 'not-offered', note: 'The list is compiled into the daemon.' },
            haikunator: { verdict: 'possible', note: 'Assigning the public arrays is code, so it rebuilds with your project.' },
            slugger: {
                verdict: 'designed-for-it',
                note: 'Drop a JSON file in the theme directory and ask for it by file name. Nothing is recompiled.',
            },
        },
    },
    {
        id: 'bad-vocabulary',
        label: 'A vocabulary that does not hold up',
        question: 'If your word list has a mistake in it, when do you find out?',
        explanation:
            'A list too small, a category nothing carries, a word declared twice: none of this stops a program from running. It shows up in the names, later, in front of somebody.',
        cells: {
            'hand-written': { verdict: 'not-offered', note: 'An array is valid as long as it compiles.' },
            'opaque-id': { verdict: 'beside-the-point', note: 'There is nothing to validate.' },
            docker: { verdict: 'not-offered', note: 'The lists are literals; nothing checks them.' },
            haikunator: { verdict: 'not-offered', note: 'Replacement arrays are accepted as given.' },
            slugger: {
                verdict: 'designed-for-it',
                note: 'A theme is refused at load, and one run reports every reason at once rather than the first.',
            },
        },
    },
    {
        id: 'by-how-much',
        label: 'By how much you missed',
        question: 'When something is refused, does the tool say how far off you are?',
        explanation:
            'Yes or no tells an author to go back to the file. A number tells them what to write. A theme two words above a floor reads as healthy and breaks on the next edit.',
        cells: {
            'hand-written': { verdict: 'beside-the-point', note: 'Nothing refuses, so nothing measures.' },
            'opaque-id': { verdict: 'beside-the-point', note: 'Nothing refuses, so nothing measures.' },
            docker: { verdict: 'beside-the-point', note: 'Nothing refuses, so nothing measures.' },
            haikunator: { verdict: 'beside-the-point', note: 'Nothing refuses, so nothing measures.' },
            slugger: {
                verdict: 'designed-for-it',
                note: 'Measuring reports the margin on every rule, and it works on a file that was just refused.',
            },
        },
    },
    {
        id: 'several-vocabularies',
        label: 'More than one vocabulary at a time',
        question: 'Can one run draw from several word lists without mixing them?',
        explanation:
            'Mixing two lists is not the same as choosing between them. Concatenating vocabularies produces pairs neither list intended.',
        cells: {
            'hand-written': { verdict: 'possible', note: 'Your code can pick a list first; nothing helps you.' },
            'opaque-id': { verdict: 'beside-the-point', note: 'There is no vocabulary.' },
            docker: { verdict: 'not-offered', note: 'One pair of lists.' },
            haikunator: { verdict: 'possible', note: 'One instance holds one vocabulary; a caller can hold several.' },
            slugger: {
                verdict: 'designed-for-it',
                note: 'Name several themes and the draw is weighted across them, each staying a sealed vocabulary.',
            },
        },
    },
    {
        id: 'uniqueness',
        label: 'Two runs giving the same name',
        question: 'Is the result guaranteed to be unique?',
        explanation:
            'A vocabulary is finite, so a name drawn from one can repeat. A suffix makes a collision rarer; it does not abolish it.',
        term: 'Collision',
        cells: {
            'hand-written': { verdict: 'not-offered', note: 'A short list collides quickly.' },
            'opaque-id': {
                verdict: 'designed-for-it',
                note: 'This is what an opaque identifier is for, and no word generator competes with it here.',
            },
            docker: { verdict: 'not-offered', note: 'Callers add their own suffix when they need one.' },
            haikunator: { verdict: 'not-offered', note: 'A numeric token makes a repeat less likely.' },
            slugger: {
                verdict: 'not-offered',
                note: 'A token is offered and reduces collisions. If a name must be unique, use something that guarantees it.',
            },
        },
    },
    {
        id: 'replay',
        label: 'Drawing the same thing twice',
        question: 'Can you replay a run and get the names you got before?',
        explanation:
            'A test, a fixture or a build that shows a generated name needs the same one next time, or its output changes for no reason.',
        term: 'Seeded draw',
        cells: {
            'hand-written': { verdict: 'possible', note: 'Your own code decides, so you can seed it.' },
            'opaque-id': { verdict: 'not-offered', note: 'Unpredictability is the point.' },
            docker: { verdict: 'not-offered', note: 'The package draws from the global source and exposes no seed.' },
            haikunator: { verdict: 'designed-for-it', note: 'A constructor takes a seed.' },
            slugger: { verdict: 'designed-for-it', note: 'A draw accepts a random source, and a seeded one replays exactly.' },
        },
    },
    {
        id: 'read-by-people',
        label: 'A name a person reads',
        question: 'Is the result meant to be read, said out loud, typed from memory?',
        explanation:
            'This is the question that separates the whole family from an identifier. If nobody reads the name, none of the rows above matter.',
        cells: {
            'hand-written': { verdict: 'designed-for-it', note: 'That is why you wrote the list.' },
            'opaque-id': { verdict: 'not-offered', note: 'Deliberately so, and that is a reason to choose one.' },
            docker: { verdict: 'designed-for-it', note: 'Container names are read all day.' },
            haikunator: { verdict: 'designed-for-it', note: 'Heroku-style names are made to be said.' },
            slugger: { verdict: 'designed-for-it', note: 'It is the premise of the tool.' },
        },
    },
    {
        id: 'getting-it',
        label: 'What you install',
        question: 'What has to arrive in your project, and does it exist for .NET?',
        explanation:
            'A generator you cannot reference is a generator you reimplement. Where a tool is published decides whether you can try it this afternoon.',
        cells: {
            'hand-written': { verdict: 'designed-for-it', note: 'Nothing: it is already in your source.' },
            'opaque-id': { verdict: 'designed-for-it', note: 'Nothing: the platform has one.' },
            docker: {
                verdict: 'not-offered',
                note: 'Go, and under internal/, so it is not importable. Ports exist; they are other projects.',
            },
            haikunator: {
                verdict: 'designed-for-it',
                note: 'A NuGet package. Its most recent release on nuget.org is dated 2018-11-14.',
            },
            slugger: { verdict: 'designed-for-it', note: 'A NuGet package for the engine, and a dotnet tool for the command.' },
        },
    },
];
