/// Pure utility function to split a raw block of text into sentence-grouped chunks.
///
/// Groups every [sentencesPerChunk] sentences (default 2) together into one chunk.
List<String> chunkText(String rawText, {int sentencesPerChunk = 2}) {
  final trimmed = rawText.trim();
  if (trimmed.isEmpty) return [];

  // Regex splits on sentence endings (. ! ?) followed by whitespace or end of string.
  final sentenceRegExp = RegExp(r'[^.!?]+[.!?]+(?:\s+|$)');
  final allMatches = sentenceRegExp.allMatches(trimmed).toList();

  final sentences = <String>[];
  var lastMatchEnd = 0;
  for (final match in allMatches) {
    sentences.add(match.group(0)!.trim());
    lastMatchEnd = match.end;
  }

  // Include any trailing unpunctuated text (e.g. missing terminal period)
  if (lastMatchEnd < trimmed.length) {
    final leftover = trimmed.substring(lastMatchEnd).trim();
    if (leftover.isNotEmpty) {
      sentences.add(leftover);
    }
  }

  // If no sentences were found, fallback to splitting on double newlines or single string
  if (sentences.isEmpty) {
    final paragraphSplits = trimmed
        .split(RegExp(r'\n\s*\n'))
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    return paragraphSplits.isNotEmpty ? paragraphSplits : [trimmed];
  }

  final chunks = <String>[];
  for (var i = 0; i < sentences.length; i += sentencesPerChunk) {
    final end = (i + sentencesPerChunk < sentences.length) ? i + sentencesPerChunk : sentences.length;
    final chunkGroup = sentences.sublist(i, end).join(' ');
    if (chunkGroup.trim().isNotEmpty) {
      chunks.add(chunkGroup.trim());
    }
  }

  return chunks;
}
