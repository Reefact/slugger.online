#!/usr/bin/env node
// The comparison's own rules, read off its data file — §11.7.
//
// It WARNS about staleness rather than failing: a page whose claims were last checked seven
// months ago is not a broken page, and refusing to publish one would mean refusing to
// publish anything on a quiet week. It FAILS on the two things that are defects rather than
// age.
import { readFile } from 'node:fs/promises';

const source = await readFile(new URL('../apps/site/src/comparison.ts', import.meta.url), 'utf8');

const read = (name) => {
    const found = source.match(new RegExp(`export const ${name} = '([^']+)'`))
        ?? source.match(new RegExp(`export const ${name} = (\\d+)`));

    if (found === null) {
        console.error(`check-comparison: comparison.ts declares no ${name}.`);
        process.exit(1);
    }

    return found[1];
};

const verifiedOn = read('verifiedOn');
const freshnessDays = Number(read('freshnessDays'));

const days = Math.floor((Date.now() - Date.parse(verifiedOn)) / 86_400_000);

if (Number.isNaN(days)) {
    console.error(`check-comparison: "${verifiedOn}" is not a date.`);
    process.exit(1);
}

let failed = false;

// §11.7 — NO REFERENCE ANOTHER RENDERING CAN BREAK. The same sentences are rendered three
// ways; the duel hides columns and the matrix drops the notes entirely, so "above", "below"
// and "the previous row" point at nothing in two of the three.
const notes = [...source.matchAll(/note:\s*\n?\s*'((?:[^'\\]|\\.)*)'/g)].map(([, note]) => note);

if (notes.length === 0) {
    console.error('check-comparison: no cell note found. The parse is wrong, not the data.');
    process.exit(1);
}

const positional = notes.filter((note) => /\b(above|below|the row before|previous row|next row)\b/i.test(note));

if (positional.length > 0) {
    console.error('check-comparison: a note refers to a position another rendering does not keep:');
    for (const note of positional) {
        console.error(`  ${note}`);
    }
    failed = true;
}

// §11.7 — no comparative superlative. A page that cannot be read as fair is not believed
// when it says good things about itself, and these words are how that slips in.
const boastful = notes.filter((note) => /\b(best|worst|superior|inferior|obviously|simply better|the only real)\b/i.test(note));

if (boastful.length > 0) {
    console.error('check-comparison: a note carries a comparative superlative:');
    for (const note of boastful) {
        console.error(`  ${note}`);
    }
    failed = true;
}

if (failed) {
    process.exit(1);
}

console.log(`check-comparison: ${notes.length} notes, last checked ${days} days ago.`);

if (days > freshnessDays) {
    console.warn(
        `\n  WARNING: the comparison was last checked on ${verifiedOn}, ${days} days ago, ` +
        `past the ${freshnessDays} days it declares.\n` +
        '  Re-read each source, correct what moved, and raise verifiedOn.\n',
    );
}
