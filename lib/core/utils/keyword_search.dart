import 'package:ink_mind/features/notes/domain/entities/note_chunk.dart';

const Set<String> _stopWords = {
  'a', 'an', 'and', 'are', 'as', 'at', 'be', 'by', 'for', 'from',
  'has', 'he', 'in', 'is', 'it', 'its', 'of', 'on', 'that', 'the',
  'to', 'was', 'were', 'will', 'with', 'what', 'where', 'who', 'how',
  'why', 'can', 'you', 'this', 'or', 'do', 'does', 'did',
};

/// Extracts significant words from [query], filtering out common stop words.
List<String> getSignificantWords(String query) {
  final rawWords = query
      .toLowerCase()
      .split(RegExp(r'[^\w]+'))
      .where((w) => w.isNotEmpty)
      .toList();
  final significant = rawWords.where((w) => !_stopWords.contains(w)).toList();
  return significant.isNotEmpty ? significant : rawWords;
}

/// Finds stored [chunks] whose text contains any of [query]'s significant words
/// (case-insensitive substring match) and returns them ranked by match count descending.
List<NoteChunk> performKeywordSearch(String query, List<NoteChunk> chunks) {
  final words = getSignificantWords(query);
  if (words.isEmpty) return [];

  final matches = <NoteChunk>[];
  for (final chunk in chunks) {
    final textLower = chunk.text.toLowerCase();
    var count = 0;
    for (final word in words) {
      if (textLower.contains(word)) {
        count++;
      }
    }
    if (count > 0) {
      matches.add(chunk.copyWith(score: count.toDouble()));
    }
  }

  matches.sort((a, b) => (b.score ?? 0.0).compareTo(a.score ?? 0.0));
  return matches;
}
