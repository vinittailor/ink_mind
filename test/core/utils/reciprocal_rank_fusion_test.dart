import 'package:flutter_test/flutter_test.dart';
import 'package:ink_mind/core/utils/reciprocal_rank_fusion.dart';
import 'package:ink_mind/features/notes/domain/entities/note_chunk.dart';

void main() {
  group('reciprocalRankFusion', () {
    test('correctly computes RRF scores for integer IDs', () {
      final semantic = [1, 2, 3];
      final keyword = [3, 1, 4];

      final merged = reciprocalRankFusion(
        semanticResults: semantic,
        keywordResults: keyword,
        k: 60,
      );

      // 1: rank 1 (semantic), rank 2 (keyword) -> 1/61 + 1/62 = 0.0163934 + 0.016129 = 0.032522
      // 3: rank 3 (semantic), rank 1 (keyword) -> 1/63 + 1/61 = 0.0158730 + 0.0163934 = 0.032266
      // 2: rank 2 (semantic) -> 1/62 = 0.016129
      // 4: rank 3 (keyword) -> 1/63 = 0.015873
      expect(merged, equals([1, 3, 2, 4]));
    });

    test('correctly merges NoteChunks and updates scores', () {
      const chunk1 = NoteChunk(id: 1, text: 'Alpha', embedding: []);
      const chunk2 = NoteChunk(id: 2, text: 'Beta', embedding: []);
      const chunk3 = NoteChunk(id: 3, text: 'Gamma', embedding: []);

      final semantic = [chunk1, chunk2];
      final keyword = [chunk3, chunk1];

      final merged = reciprocalRankFusion(
        semanticResults: semantic,
        keywordResults: keyword,
        k: 60,
      );

      expect(merged.length, equals(3));
      expect(merged.first.id, equals(1)); // chunk1 appears in both lists
      expect(merged.first.score, closeTo(1 / 61 + 1 / 62, 0.0001));
    });
  });
}
