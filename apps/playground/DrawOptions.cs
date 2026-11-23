namespace Slugger.Playground;

/// <summary>
///     The bridge of §10.5: an ordinary typed call into the published package, never a generated
///     catalogue of its surface.
/// </summary>
/// <remarks>
///     <para>
///         Every arm names its target with <c>nameof(GenerationOptions.X)</c>, so a property the
///         library renames stops compiling here. That is the half of the drift §10.5 says a typed
///         bridge closes by itself.
///     </para>
///     <para>
///         The other half it cannot close: an option ADDED to the command line is not a compilation
///         error, it is a playground silently offering less than the command. scripts/verify-output.sh
///         carries that check, and §10.5 makes it a condition of publishing the route.
///     </para>
/// </remarks>
internal static class DrawOptions {

    #region Static members

    /// <summary>Sets one option, given as the text its control holds.</summary>
    /// <param name="options">What has been set so far.</param>
    /// <param name="property">The <see cref="GenerationOptions" /> property to set.</param>
    /// <param name="value">The control's text. A switch passes an empty one: its presence is the value.</param>
    /// <returns>The options with that one set.</returns>
    /// <exception cref="ArgumentOutOfRangeException">The engine refuses the value; its message says why.</exception>
    /// <exception cref="FormatException">The text is not of the option's type.</exception>
    internal static GenerationOptions Apply(GenerationOptions options, string property, string value) {
        return property switch {
            nameof(GenerationOptions.Separator)       => options with { Separator = value },
            nameof(GenerationOptions.WordSeparator)   => options with { WordSeparator = value },
            nameof(GenerationOptions.FoldAccents)     => options with { FoldAccents = true },
            nameof(GenerationOptions.Ascii)           => options with { Ascii = true },
            nameof(GenerationOptions.Casing)          => options with { Casing = Enum.Parse<Casing>(value, ignoreCase: true) },
            nameof(GenerationOptions.MaxLength)       => options with { MaxLength = Number(value) },
            nameof(GenerationOptions.MaxSegmentWords) => options with { MaxSegmentWords = Number(value) },
            nameof(GenerationOptions.SegmentMode)     => options with { SegmentMode = Enum.Parse<SegmentMode>(value, ignoreCase: true) },
            nameof(GenerationOptions.TokenLength)     => options with { TokenLength = Number(value) },
            nameof(GenerationOptions.TokenHex)        => options with { TokenHex = true },
            nameof(GenerationOptions.TokenGlued)      => options with { TokenGlued = true },
            nameof(GenerationOptions.TokenChance)     => options with { TokenChance = Number(value) },
            // Unreachable while the check above passes, and the check is what keeps it so. Leaving
            // the options untouched rather than throwing means a list that somehow drifted in
            // production costs one missing option, never a blank page.
            _ => options
        };
    }

    /// <summary>The values an enumerated option offers, or none when it is not one.</summary>
    internal static IReadOnlyList<string> ValuesOf(string type) {
        return type switch {
            nameof(Casing)      => Enum.GetNames<Casing>(),
            nameof(SegmentMode) => Enum.GetNames<SegmentMode>(),
            _                   => []
        };
    }

    private static int Number(string value) {
        return int.TryParse(value, out int parsed)
            ? parsed
            : throw new FormatException($"\"{value}\" is not a whole number.");
    }

    #endregion

}
