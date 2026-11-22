namespace Slugger.Playground;

/// <summary>
///     What a page may show of a reason the engine gave — §10.4.
/// </summary>
/// <remarks>
///     <para>
///         The sentence of a refusal belongs to the library and is shown word for word, so that a
///         refusal read here and the same refusal read in a terminal say the same thing. The site
///         never writes a second one: two wordings drift apart at the first correction, and they
///         drift in silence, because both stay plausible and nothing compares them.
///     </para>
///     <para>
///         One kind of sentence belongs to neither side, and that is all this class removes:
///         <b>advice naming a command-line option</b>. A terminal has the right to say which flag
///         to correct, because its reader has just typed one. A page does not: its reader may have
///         installed nothing at all, which is exactly what §10.2 promises them. So the sentence is
///         dropped rather than translated into a gesture of this interface — and the code of the
///         reason, which is the library's too, is shown beside what remains.
///     </para>
/// </remarks>
internal static class Reasons {

    #region Static members

    /// <summary>The reason as this page may say it: the library's own sentences, less any advice.</summary>
    /// <param name="diagnostic">The engine's diagnostic message, exactly as it wrote it.</param>
    /// <returns>What remains, which is empty when the whole message was advice.</returns>
    internal static string Said(string? diagnostic) {
        if (string.IsNullOrWhiteSpace(diagnostic)) { return string.Empty; }

        return string.Join(' ', Sentences(diagnostic).Where(sentence => !NamesAnOption(sentence))).Trim();
    }

    /// <summary>Whether a sentence names a command-line option, which is what makes it advice.</summary>
    private static bool NamesAnOption(string sentence) {
        for (int at = sentence.IndexOf("--", StringComparison.Ordinal);
             at >= 0 && at + 2 < sentence.Length;
             at = sentence.IndexOf("--", at + 2, StringComparison.Ordinal)) {
            // "--" before a lowercase letter is a flag; before anything else it is punctuation,
            // and an em dash the library wrote must not cost the reader a sentence.
            if (char.IsAsciiLetterLower(sentence[at + 2])) { return true; }
        }

        return false;
    }

    /// <summary>
    ///     The message cut into sentences, each keeping its full stop. A full stop counts only
    ///     where a space or the end of the message follows it, so a decimal or an abbreviation does
    ///     not split a sentence in two.
    /// </summary>
    private static IEnumerable<string> Sentences(string message) {
        int start = 0;

        for (int at = 0; at < message.Length; at += 1) {
            if (message[at] is not '.') { continue; }
            if (at + 1 < message.Length && message[at + 1] is not ' ') { continue; }

            yield return message[start..(at + 1)].Trim();

            start = at + 1;
        }

        if (start < message.Length) { yield return message[start..].Trim(); }
    }

    #endregion

}
