#region Usings declarations

using System.Text.Json.Serialization;

#endregion

namespace Slugger.Playground;

/// <summary>
///     One theme of the catalogue (§7.6), as scripts/copy-playground.sh publishes it beside the
///     application.
/// </summary>
/// <param name="Name">The theme's file name, which is what the catalogue keys on (§7.6).</param>
/// <param name="Origin">
///     <c>embedded</c> when the package already carries the theme, so nothing is fetched for it:
///     the engine opens it itself. Anything else is a repository theme, mirrored at the pin and
///     published as a file beside this application.
/// </param>
internal sealed record CatalogueTheme(string Name, string Origin);

/// <summary>
///     One option of a draw, as the command line declares it — §10.5. Everything here is the
///     library's own text, mirrored at the pin by scripts/fetch-options.sh; §10.4 leaves the site
///     the layout and nothing else.
/// </summary>
/// <param name="Property">The <see cref="GenerationOptions" /> property it sets.</param>
/// <param name="Type">That property's type, which decides the shape of the control.</param>
/// <param name="Flag">The option as it is typed on a command line.</param>
/// <param name="Template">The option as <c>--help</c> prints it, its value in capitals.</param>
/// <param name="Description">What <c>--help</c> says of it.</param>
internal sealed record DrawOption(string Property, string Type, string Flag, string Template, string Description);

/// <param name="PinnedTag">The library tag this list was read at (§7.5).</param>
internal sealed record DrawOptionsFile(string PinnedTag, DrawOption[] Options);

/// <summary>
///     Source-generated serialisation. The reflection-based one would be trimmed away and warn
///     about it, and §10.8 makes a trim warning from our own code an error.
/// </summary>
[JsonSourceGenerationOptions(PropertyNamingPolicy = JsonKnownNamingPolicy.CamelCase)]
[JsonSerializable(typeof(CatalogueTheme[]))]
[JsonSerializable(typeof(DrawOptionsFile))]
internal sealed partial class PlaygroundJson : JsonSerializerContext;
