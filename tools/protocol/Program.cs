#region Usings declarations

using Slugger;
using Slugger.Errors;
using Slugger.Playground;

#endregion

// The negative control for the mechanical phase of §3.7.
//
// Run against every published theme, the filter says nothing — which is right: they went through
// the protocol. But a filter that never speaks proves nothing at all, and the two sides here read
// the SAME FILE, so they can only ever disagree through a bug. Silence is therefore evidence only
// once we know the filter can speak.
//
// So this asserts both halves: that every slug the engine draws passes, and that slugs the theme
// plainly refuses do not. The refused ones are built from a word no theme carries rather than from
// an invented theme — what is probed is the filter, not a vocabulary.

const int Draws = 2_000;
const string Absent = "zzzzqq";

string directory = args.Length > 0 ? args[0] : "tools/catalogue/mirrored";
string[] files = Directory.GetFiles(directory, "*.json");

if (files.Length == 0) {
    Console.Error.WriteLine($"protocol-check: no theme in {directory}.");

    return 1;
}

int failures = 0;

foreach (string file in files.OrderBy(path => path)) {
    string name = Path.GetFileNameWithoutExtension(file);
    string json = File.ReadAllText(file);

    if (Protocol.For(json) is not { } protocol) {
        Console.Error.WriteLine($"  {name}: the filter could not read the theme.");
        failures += 1;

        continue;
    }

    Outcome<SluggerTheme> loaded = SluggerTheme.LoadFromJson(json, name);
    if (loaded.Error is not null) {
        Console.Error.WriteLine($"  {name}: the engine refuses a published theme.");
        failures += 1;

        continue;
    }

    SlugGenerator generator = SlugGenerator.ForOrThrow(loaded.GetResultOrThrow(), defaults => defaults with {
        Separator = Protocol.TermSeparator,
        WordSeparator = Protocol.WordSeparator,
        Casing = Casing.Kebab,
        TokenLength = 0,
        FoldAccents = false,
        Ascii = false
    });

    // Every slug the engine draws stands where the file allows it.
    string? unexpected = null;
    for (int draw = 0; draw < Draws && unexpected is null; draw += 1) {
        string slug = generator.Next();
        if (protocol.Fault(slug) is { } problem) { unexpected = $"{slug}: {problem}"; }
    }

    if (unexpected is not null) {
        Console.Error.WriteLine($"  {name}: the filter refuses a slug the engine drew — {unexpected}");
        failures += 1;

        continue;
    }

    // And it speaks when it should: a noun the theme does not carry, and a term that stands in
    // front of a noun it never reaches.
    string noun = generator.Next().Split(Protocol.TermSeparator)[^1];

    if (protocol.Fault(Absent) is null) {
        Console.Error.WriteLine($"  {name}: the filter allows a noun the theme does not carry.");
        failures += 1;
    } else if (protocol.Fault($"{Absent}{Protocol.TermSeparator}{noun}") is null) {
        Console.Error.WriteLine($"  {name}: the filter allows a term that reaches no noun.");
        failures += 1;
    }
}

if (failures > 0) {
    Console.Error.WriteLine($"protocol-check: {failures} theme(s) failed.");

    return 1;
}

Console.WriteLine($"protocol-check: {files.Length} themes, {Draws} draws each, and the filter speaks when it should.");

return 0;
