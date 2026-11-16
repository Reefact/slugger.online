// The catalogue the site renders — specification §7.6, §14.2, §14.3.
//
// Everything a theme page shows about a theme is produced HERE, by the engine, at build
// time. Not one number and not one slug is typed into a page, and the reason is sharper for
// this product than the general one: these figures change with every word an author adds, by
// somebody who has no reason to think about a website while adding a word. A copied number
// would be wrong before it was reread.
//
// Two sources, and the catalogue does not sort them by where they live but by what they ask
// of a reader: the EMBEDDED themes arrive inside the package and work with nothing done; the
// MIRRORED ones are ordinary files, pinned to a release tag (§7.5), that a reader registers.
//
// WHAT IS DELIBERATELY ABSENT: how a theme classes its words. §7.6 asks for its categories
// and what each permits, and the engine publishes neither — only the categories nothing
// reaches. The rule for that case is §10.4's: the site asks for a measure it does not have,
// it never computes one. Parsing the theme file here would be a second reading of a document
// the engine already reads, and the first number the two disagreed about would be published
// as fact. So the page says what the engine says, and the gap is an issue on the library.

using System.Text.Json;
using System.Text.Json.Serialization;
using Slugger;

const int Seed = 20_261_116;
const int SamplesPerTheme = 6;

if (args.Length != 3) {
    Console.Error.WriteLine("usage: catalogue <mirrored-themes-dir> <pinned-tag> <output.json>");

    return 1;
}

string mirroredDirectory = args[0];
string pinnedTag = args[1];
string output = args[2];

List<ThemeEntry> entries = [];

foreach (string name in SluggerTheme.EmbeddedNames.OrderBy(static n => n, StringComparer.Ordinal)) {
    entries.Add(Describe(name, SluggerTheme.LoadEmbeddedOrThrow(name), SluggerTheme.AnalyzeEmbedded(name), "embedded"));
}

foreach (string path in Directory.EnumerateFiles(mirroredDirectory, "*.json").OrderBy(static p => p, StringComparer.Ordinal)) {
    // The file name IS the theme's identity — never the display title it may declare (§7.6).
    // Keying a route on the title would recreate the second source of truth the library
    // dropped on purpose, and a theme renamed on one side would break links nothing checks.
    string name = Path.GetFileNameWithoutExtension(path);

    entries.Add(Describe(name, SluggerTheme.LoadFromFileOrThrow(path), SluggerTheme.AnalyzeFromFile(path), "mirrored"));
}

if (entries.Count == 0) {
    Console.Error.WriteLine("catalogue: no theme at all. Something is wrong rather than empty.");

    return 1;
}

JsonSerializerOptions options = new() {
    WriteIndented = true,
    // camelCase, because the reader is TypeScript. A key absent rather than null is what
    // lets a page distinguish "the theme says nothing here" from "the theme says nothing" -
    // the distinction §5.7 turns into words rather than a blank.
    PropertyNamingPolicy = JsonNamingPolicy.CamelCase,
    DefaultIgnoreCondition = JsonIgnoreCondition.WhenWritingNull,
};

Directory.CreateDirectory(Path.GetDirectoryName(Path.GetFullPath(output))!);
File.WriteAllText(
    output,
    JsonSerializer.Serialize(
        new {
            seed = Seed,
            pinnedTag,
            engine = typeof(SluggerTheme).Assembly.GetName().Version?.ToString(),
            themes = entries,
        },
        options) + Environment.NewLine);

Console.WriteLine($"catalogue: {entries.Count} themes -> {output}");

return 0;

static ThemeEntry Describe(string name, SluggerTheme theme, ThemeAnalysis analysis, string origin) {
    // A seed per theme, derived from its name, so that adding a theme does not reshuffle
    // every other theme's samples in the diff. Deterministic either way (§14.3).
    IRandomSource random = new DefaultRandomSource(Seed + name.GetHashCode(StringComparison.Ordinal));

    // The theme's OWN style, never this tool's: asking for a theme asks for its format as
    // much as its vocabulary, and overriding it here would publish a slug the command does
    // not draw.
    SlugGenerator generator = SlugGenerator.ForOrThrow(theme);

    List<string> samples = [];

    for (int i = 0; i < SamplesPerTheme; i += 1) {
        samples.Add(generator.Next(random));
    }

    if (samples.Any(string.IsNullOrWhiteSpace)) {
        throw new InvalidOperationException($"theme \"{name}\" produced an empty slug.");
    }

    ThemeMeasurements measured = analysis.Measurements;

    return new ThemeEntry(
        name,
        origin,
        // Every key below is optional, the block itself included. A theme that says nothing
        // about itself gets a page that says nothing about it — never an invented
        // description, and never a blank that reads as a display fault (§7.6, §5.7).
        new Meta(
            NullIfBlank(theme.Metadata.Title),
            NullIfBlank(theme.Metadata.Description),
            NullIfBlank(theme.Metadata.Author),
            NullIfBlank(theme.Metadata.Version),
            NullIfBlank(theme.Metadata.Source),
            NullIfBlank(theme.Metadata.CreatedAt),
            NullIfBlank(theme.Metadata.PublishedAt)),
        samples,
        new Measurements(
            analysis.IsAccepted,
            analysis.FloorsWaived,
            measured.Combinations,
            measured.LongestSlug,
            [.. measured.Margins.Select(static m => new Margin(m.Rule.ToString(), m.WorstCase, NullIfBlank(m.Beside), m.Limit, m.Margin))],
            [.. measured.DuplicatedNouns],
            [.. measured.UnreachableCategories],
            new Exposure(measured.LeastExposed.Word, measured.LeastExposed.Nouns),
            new Exposure(measured.MostExposed.Word, measured.MostExposed.Nouns),
            // The engine's own sentences, carried word for word, each with its stable code.
            // The site lays them out - order, grouping, folding - and never writes a second
            // wording for one (§10.4). The code is what a page groups by; the sentence is
            // what it shows.
            [.. analysis.Refusals.Select(static r => new Reason(r.Code.ToString(), r.DiagnosticMessage))],
            [.. analysis.Remarks]));
}

static string? NullIfBlank(string? value) => string.IsNullOrWhiteSpace(value) ? null : value;

internal sealed record ThemeEntry(string Name, string Origin, Meta Meta, IReadOnlyList<string> Samples, Measurements Measurements);

internal sealed record Meta(string? Title, string? Description, string? Author, string? Version, string? Source, string? CreatedAt, string? PublishedAt);

internal sealed record Margin(string Rule, long WorstCase, string? Beside, long Limit, long MarginValue);

internal sealed record Exposure(string Word, int Nouns);

internal sealed record Reason(string Code, string Sentence);

internal sealed record Measurements(
    bool IsAccepted,
    bool FloorsWaived,
    long Combinations,
    string LongestSlug,
    IReadOnlyList<Margin> Margins,
    IReadOnlyList<string> DuplicatedNouns,
    IReadOnlyList<string> UnreachableCategories,
    Exposure LeastExposed,
    Exposure MostExposed,
    IReadOnlyList<Reason> Refusals,
    IReadOnlyList<string> Remarks);
