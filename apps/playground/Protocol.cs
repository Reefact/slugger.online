#region Usings declarations

using System.Text;
using System.Text.Json;

#endregion

namespace Slugger.Playground;

/// <summary>One drawn slug the theme's own declarations do not allow, and why.</summary>
internal sealed record Fault(string Slug, string Problem);

/// <summary>What a run of the mechanical phase found.</summary>
internal sealed record Checked(int Drawn, IReadOnlyList<Fault> Faults);

/// <summary>
///     The one phase of the library's review protocol that is mechanical — and never the others.
/// </summary>
/// <remarks>
///     <para>
///         The protocol says it plainly: this check is a script you write, and the command has no
///         option for it. So this is that script, written once here, from the theme file's own
///         declarations: every drawn slug is taken apart into its terms, and each term must be in a
///         category its noun reaches, must not be in that noun's exclusions, and must not form a
///         pair the file refuses.
///     </para>
///     <para>
///         <b>A prefix is not a word.</b> Cutting a slug at its separators cannot tell a two-word
///         term from two terms, so the engine is asked to mark the boundaries instead: one
///         character between terms, a space between the words inside one. The slug then splits
///         without guessing.
///     </para>
///     <para>
///         What this is not: a reading. It holds for everything the file declares and says nothing
///         about what the words mean together. The phases of the protocol that find the most are
///         human readings, and none of them automates.
///     </para>
/// </remarks>
internal sealed class Protocol {

    #region Constants

    /// <summary>What marks a term boundary in a slug drawn for this check.</summary>
    internal const string TermSeparator = "|";

    /// <summary>What separates the words inside one term, so a two-word term stays one segment.</summary>
    internal const string WordSeparator = " ";

    /// <summary>Draws per noun, from the protocol's own count for a sample.</summary>
    private const int DrawsPerNoun = 30;

    #endregion

    #region Fields

    private readonly Dictionary<string, HashSet<string>> _adjectives;
    private readonly Dictionary<string, HashSet<string>> _participles;
    private readonly Dictionary<string, List<Entry>> _nouns;
    private readonly Dictionary<string, HashSet<string>> _refused;

    #endregion

    private Protocol(Dictionary<string, HashSet<string>>  adjectives,
                     Dictionary<string, HashSet<string>>  participles,
                     Dictionary<string, List<Entry>>      nouns,
                     Dictionary<string, HashSet<string>>  refused) {
        _adjectives  = adjectives;
        _participles = participles;
        _nouns       = nouns;
        _refused     = refused;
    }

    /// <summary>How many slugs a sample of this theme takes.</summary>
    internal int Sample => Math.Max(DrawsPerNoun, _nouns.Count * DrawsPerNoun);

    #region Static members

    /// <summary>Reads a theme file into the filter its own declarations describe.</summary>
    /// <param name="json">The theme, as its file holds it.</param>
    /// <returns>The filter, or null when the file is not shaped like a theme.</returns>
    internal static Protocol? For(string json) {
        try {
            using JsonDocument document = JsonDocument.Parse(json);
            JsonElement root = document.RootElement;

            if (root.ValueKind is not JsonValueKind.Object) { return null; }
            if (!root.TryGetProperty("nouns", out JsonElement nouns) || nouns.ValueKind is not JsonValueKind.Array) {
                return null;
            }

            Dictionary<string, List<Entry>> byValue = [];
            foreach (JsonElement noun in nouns.EnumerateArray()) {
                if (noun.ValueKind is not JsonValueKind.Object) { continue; }
                if (!noun.TryGetProperty("value", out JsonElement value) || value.ValueKind is not JsonValueKind.String) {
                    continue;
                }

                Entry entry = new(Words(noun, "categories"), Words(noun, "except"));
                if (!byValue.TryGetValue(Clean(value.GetString()!), out List<Entry>? entries)) {
                    byValue[Clean(value.GetString()!)] = entries = [];
                }

                entries.Add(entry);
            }

            if (byValue.Count == 0) { return null; }

            return new Protocol(Section(root, "adjectives"), Section(root, "participles"), byValue, Refusals(root));
        } catch (JsonException) {
            return null;
        }
    }

    /// <summary>
    ///     The library's own cleaning, so that a word in the file and the same word in a slug are
    ///     one word: lowercase, and anything that is not a letter or a digit becomes one space.
    /// </summary>
    private static string Clean(string value) {
        StringBuilder cleaned = new(value.Length);
        bool boundary = false;

        foreach (char character in value) {
            if (char.IsLetterOrDigit(character)) {
                cleaned.Append(char.ToLowerInvariant(character));
                boundary = false;
            } else if (!boundary) {
                cleaned.Append(' ');
                boundary = true;
            }
        }

        return cleaned.ToString().Trim();
    }

    private static Dictionary<string, HashSet<string>> Section(JsonElement root, string name) {
        Dictionary<string, HashSet<string>> section = [];

        if (!root.TryGetProperty(name, out JsonElement categories) || categories.ValueKind is not JsonValueKind.Object) {
            return section;
        }

        foreach (JsonProperty category in categories.EnumerateObject()) {
            if (category.Value.ValueKind is not JsonValueKind.Array) { continue; }

            section[category.Name] = [.. category.Value.EnumerateArray()
                                                 .Where(word => word.ValueKind is JsonValueKind.String)
                                                 .Select(word => Clean(word.GetString()!))];
        }

        return section;
    }

    private static Dictionary<string, HashSet<string>> Refusals(JsonElement root) {
        Dictionary<string, HashSet<string>> refused = [];

        if (!root.TryGetProperty("incompatible", out JsonElement pairs) || pairs.ValueKind is not JsonValueKind.Object) {
            return refused;
        }

        foreach (JsonProperty pair in pairs.EnumerateObject()) {
            if (pair.Value.ValueKind is not JsonValueKind.Array) { continue; }

            refused[Clean(pair.Name)] = [.. pair.Value.EnumerateArray()
                                                .Where(word => word.ValueKind is JsonValueKind.String)
                                                .Select(word => Clean(word.GetString()!))];
        }

        return refused;
    }

    private static List<string> Words(JsonElement noun, string name) {
        if (!noun.TryGetProperty(name, out JsonElement words) || words.ValueKind is not JsonValueKind.Array) {
            return [];
        }

        return [.. words.EnumerateArray().Where(word => word.ValueKind is JsonValueKind.String).Select(word => word.GetString()!)];
    }

    #endregion

    /// <summary>What the theme's declarations refuse in this slug, or null when they allow it.</summary>
    /// <param name="marked">A slug drawn with its term boundaries marked.</param>
    internal string? Fault(string marked) {
        string[] terms = [.. marked.Split(TermSeparator).Select(Clean)];
        string value = terms[^1];
        string[] before = terms[..^1];

        if (!_nouns.TryGetValue(value, out List<Entry>? entries)) {
            return $"\"{value}\" is not a noun of the theme";
        }

        foreach (Entry entry in entries) {
            HashSet<string> adjectives = Reach(_adjectives, entry);
            HashSet<string> participles = Reach(_participles, entry);

            switch (before.Length) {
                case 0:
                    return null;
                case 1 when adjectives.Contains(before[0]) || participles.Contains(before[0]):
                    return null;
                case 2 when adjectives.Contains(before[0])
                         && participles.Contains(before[1])
                         && !(_refused.TryGetValue(before[0], out HashSet<string>? refused) && refused.Contains(before[1])):
                    return null;
            }
        }

        return $"{string.Join(" + ", before)} cannot stand in front of \"{value}\"";
    }

    /// <summary>The pool a noun reaches in one section: its categories and the floor, less its own exclusions.</summary>
    private static HashSet<string> Reach(Dictionary<string, HashSet<string>> section, Entry noun) {
        HashSet<string> reached = [];

        foreach (string category in noun.Categories.Append("common")) {
            if (section.TryGetValue(category, out HashSet<string>? words)) { reached.UnionWith(words); }
        }

        reached.ExceptWith(noun.Except.Select(Clean));

        return reached;
    }

    private sealed record Entry(List<string> Categories, List<string> Except);

}
