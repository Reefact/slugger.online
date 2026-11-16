// Every slug the site displays is drawn HERE, at build time, by the real engine —
// specification §14.3. None is typed into a page.
//
// A slug written by hand in content is a lie on a delay: the day the produced format
// changes — a separator, a casing, a token — the page goes on showing the old one. And the
// mechanism is a standing end-to-end test of the engine besides: if a theme stops producing
// a slug, the site's build fails.
//
// The draw is DETERMINISTIC, from the seed below, so a build does not produce a gratuitous
// diff on every commit. `SlugGenerator.Next(IRandomSource)` is what makes that possible;
// `DefaultRandomSource(seed)` is the engine's own.

using System.Text.Json;
using Slugger;

const int Seed = 20_261_116;

if (args.Length != 1) {
    Console.Error.WriteLine("usage: sample-slugs <output.json>");

    return 1;
}

IRandomSource random = new DefaultRandomSource(Seed);

List<object> samples = [];

foreach (string name in SluggerTheme.EmbeddedNames) {
    SluggerTheme theme = SluggerTheme.LoadEmbeddedOrThrow(name);

    // The theme's own style, not this tool's: asking for a theme asks for its format as much
    // as its vocabulary, and overriding it here would publish a slug the tool never draws.
    SlugGenerator generator = SlugGenerator.ForOrThrow(theme);

    string slug = generator.Next(random);

    if (string.IsNullOrWhiteSpace(slug)) {
        Console.Error.WriteLine($"theme \"{name}\" produced no slug.");

        return 1;
    }

    samples.Add(new {
        theme = name,
        title = theme.Metadata.Title,
        description = theme.Metadata.Description,
        slug,
        combinations = generator.Combinations,
    });
}

string json = JsonSerializer.Serialize(
    new { seed = Seed, engine = typeof(SluggerTheme).Assembly.GetName().Version?.ToString(), samples },
    new JsonSerializerOptions { WriteIndented = true });

string path = args[0];
Directory.CreateDirectory(Path.GetDirectoryName(Path.GetFullPath(path))!);
File.WriteAllText(path, json + Environment.NewLine);

Console.WriteLine($"sample-slugs: {samples.Count} themes -> {path}");

return 0;
