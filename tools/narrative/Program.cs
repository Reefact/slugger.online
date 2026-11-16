// What the narrative shows, produced at build time by the engine — §9, §14.3, §14.4.
//
// ACT I IS A CONTRAST, AND IT USES NO INVENTED WORD. §5.6 forbids a theme written for the
// vitrine, so the flat list the act argues against is not written here: it is DERIVED,
// mechanically, from a theme the library carries. Every adjective and participle category
// collapses into `common`, every noun's own classification goes, and nothing else changes.
// Same words, same nouns, same counts — only the thing the act is about is removed.
//
// Both halves are then loaded under the ordinary rules, with no waiver (§14.4). If the
// derivation ever produced a theme the engine refuses, this build fails rather than
// publishing a comparison against something that could not exist.
//
// ONE PROMISE CANNOT SURVIVE THE DERIVATION, and dropping it is part of it: a theme's
// maxLength is a promise about its SORTED pools, and flattening grows every pool, so the
// flat variant can draw longer than the sorted one ever could. Keeping the promise would
// have the engine refuse the derivation for a reason that says nothing about the act.
//
// ACT III reads a theme that is refused, and that is the one exception §14.4 names: its
// property of being refused is its subject. It lives in this repository, and the check that
// no published theme is refused excludes it by name rather than being lowered for it.

using System.Text.Json;
using System.Text.Json.Nodes;
using System.Text.Json.Serialization;
using Slugger;

const int Seed = 20_261_116;
const int Rounds = 14;

if (args.Length != 4) {
    Console.Error.WriteLine("usage: narrative <sorted-theme.json> <hasty-theme.json> <pinned-tag> <output.json>");

    return 1;
}

string sortedPath = args[0];
string hastyPath = args[1];
string pinnedTag = args[2];
string output = args[3];

string sortedJson = File.ReadAllText(sortedPath);
string flatJson = Flatten(sortedJson);
string themeName = Path.GetFileNameWithoutExtension(sortedPath);

// Both halves, under the ordinary rules. A waiver here would publish a comparison against a
// theme the tool would refuse (§14.4).
SluggerTheme sorted = SluggerTheme.LoadFromJsonOrThrow(sortedJson, themeName);
SluggerTheme flat = SluggerTheme.LoadFromJsonOrThrow(flatJson, themeName + "-flat");

SlugGenerator sortedGenerator = SlugGenerator.ForOrThrow(sorted);
SlugGenerator flatGenerator = SlugGenerator.ForOrThrow(flat);

// The SAME seed on both sides, so the two columns are the same draw made twice — once
// through a vocabulary that says which words go together, once through one that does not.
IRandomSource sortedRandom = new DefaultRandomSource(Seed);
IRandomSource flatRandom = new DefaultRandomSource(Seed);

List<Round> rounds = [];

for (int i = 0; i < Rounds; i += 1) {
    string withCategories = sortedGenerator.Next(sortedRandom);
    string withoutCategories = flatGenerator.Next(flatRandom);

    if (string.IsNullOrWhiteSpace(withCategories) || string.IsNullOrWhiteSpace(withoutCategories)) {
        Console.Error.WriteLine("narrative: a generator produced an empty slug.");

        return 1;
    }

    rounds.Add(new Round(withCategories, withoutCategories));
}

// The seed is the catalogue's own constant, and the rounds are the FIRST ones it gives.
// Choosing a seed because its draws flattered the argument would be the one dishonesty this
// page cannot afford — the demonstration has to defend itself (§9.9).
ThemeAnalysis sortedAnalysis = SluggerTheme.AnalyzeFromJson(sortedJson, themeName);
ThemeAnalysis flatAnalysis = SluggerTheme.AnalyzeFromJson(flatJson, themeName + "-flat");

// Act III. Refused on purpose, and read through the engine's own sentences (§10.4).
string hastyJson = File.ReadAllText(hastyPath);
string hastyName = Path.GetFileNameWithoutExtension(hastyPath);
ThemeAnalysis hastyAnalysis = SluggerTheme.AnalyzeFromJson(hastyJson, hastyName);

if (hastyAnalysis.IsAccepted) {
    Console.Error.WriteLine($"narrative: \"{hastyName}\" is accepted, and act III needs a refusal to read.");

    return 1;
}

JsonSerializerOptions options = new() {
    WriteIndented = true,
    PropertyNamingPolicy = JsonNamingPolicy.CamelCase,
    DefaultIgnoreCondition = JsonIgnoreCondition.WhenWritingNull,
};

// A theme can be refused EARLIER than it can be measured: when a section the rules
// themselves read is malformed, the rules are skipped for it, and the analysis carries no
// measurement at all. Act III needs both beats - the refusal that says everything at once,
// and the measurement that says by how much - so a file that cannot be measured is a build
// failure here rather than an act published with half of it missing.
if (hastyAnalysis.Measurements is null) {
    Console.Error.WriteLine(
        $"narrative: \"{hastyName}\" is refused too early to be measured. Act III reads a " +
        "refusal AND a measurement; give the file a well-formed shape and let the rules do " +
        "the refusing.");

    return 1;
}

Directory.CreateDirectory(Path.GetDirectoryName(Path.GetFullPath(output))!);
File.WriteAllText(
    output,
    JsonSerializer.Serialize(
        new {
            seed = Seed,
            pinnedTag,
            engine = typeof(SluggerTheme).Assembly.GetName().Version?.ToString(),
            actOne = new {
                theme = themeName,
                title = sorted.Metadata.Title ?? themeName,
                rounds,
                combinationsWithCategories = sortedAnalysis.Measurements.Combinations,
                combinationsWithout = flatAnalysis.Measurements.Combinations,
            },
            actThree = new {
                theme = hastyName,
                title = hastyAnalysis.Name,
                // The engine's sentences, word for word, each with the code a page groups by.
                // The site lays them out and never writes a second wording (§10.4).
                refusals = hastyAnalysis.Refusals
                    .Select(static r => new Reason(r.Code.ToString(), r.DiagnosticMessage))
                    .ToList(),
                margins = hastyAnalysis.Measurements.Margins
                    .Select(static m => new Margin(m.Rule.ToString(), m.WorstCase, m.Limit, m.Margin))
                    .ToList(),
            },
        },
        options) + Environment.NewLine);

Console.WriteLine($"narrative: {rounds.Count} rounds on {themeName}, {hastyAnalysis.Refusals.Count} refusals on {hastyName} -> {output}");

return 0;

// The derivation, and all of it. It removes classification and nothing else: no word is
// added, removed or changed, so the two columns a reader compares are the same vocabulary.
static string Flatten(string json) {
    JsonObject document = JsonNode.Parse(json)!.AsObject();

    foreach (string section in new[] { "adjectives", "participles" }) {
        if (document[section] is not JsonObject categories) {
            continue;
        }

        List<JsonNode?> every = [];

        foreach (KeyValuePair<string, JsonNode?> category in categories) {
            if (category.Value is JsonArray words) {
                every.AddRange(words.Select(static word => JsonNode.Parse(word!.ToJsonString())));
            }
        }

        document[section] = new JsonObject { ["common"] = new JsonArray([.. every]) };
    }

    if (document["nouns"] is JsonArray nouns) {
        foreach (JsonNode? noun in nouns) {
            if (noun is JsonObject entry) {
                entry.Remove("categories");
                entry.Remove("except");
                entry.Remove("incompatible");
            }
        }
    }

    // Its own description would describe a theme that no longer exists.
    document.Remove("meta");

    // See the note at the top: a length promise is a promise about the sorted pools.
    document.Remove("maxLength");

    if (document["defaults"] is JsonObject defaults) {
        defaults.Remove("maxSegmentWords");
    }

    return document.ToJsonString();
}

internal sealed record Round(string WithCategories, string WithoutCategories);

internal sealed record Reason(string Code, string Sentence);

internal sealed record Margin(string Rule, long WorstCase, long Limit, long MarginValue);
