import 'package:ink_mind/features/notes/domain/entities/note_chunk.dart';

/// Merges two ranked lists using Reciprocal Rank Fusion (RRF).
///
/// For each item, its RRF score is `sum(1 / (k + rank))` across whichever
/// list(s) it appears in, where [k] defaults to 60 (standard constant).
/// Ranks are 1-indexed (1, 2, 3, ...).
///
/// Returns items sorted by combined score, highest first.
List<T> reciprocalRankFusion<T>({
  required List<T> semanticResults,
  required List<T> keywordResults,
  Object Function(T item)? getId,
  int k = 60,
}) {
  final keyExtractor = getId ?? (T item) {
    if (item is NoteChunk) {
      return item.id ?? item.text;
    }
    return item as Object;
  };

  final scores = <Object, double>{};
  final items = <Object, T>{};

  for (var i = 0; i < semanticResults.length; i++) {
    final item = semanticResults[i];
    final key = keyExtractor(item);
    final rank = i + 1;
    scores[key] = (scores[key] ?? 0.0) + (1.0 / (k + rank));
    items[key] = item;
  }

  for (var i = 0; i < keywordResults.length; i++) {
    final item = keywordResults[i];
    final key = keyExtractor(item);
    final rank = i + 1;
    scores[key] = (scores[key] ?? 0.0) + (1.0 / (k + rank));
    items.putIfAbsent(key, () => item);
  }

  final sortedKeys = items.keys.toList()
    ..sort((a, b) => scores[b]!.compareTo(scores[a]!));

  return sortedKeys.map((key) {
    final item = items[key];
    if (item is NoteChunk) {
      return item.copyWith(score: scores[key]) as T;
    }
    return item as T;
  }).toList();
}
