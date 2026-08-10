import 'package:flutter_test/flutter_test.dart';
import 'package:ink_mind/core/utils/keyword_search.dart';
import 'package:ink_mind/features/notes/domain/entities/note_chunk.dart';

void main() {
  group('performKeywordSearch', () {
    const chunk1 = NoteChunk(id: 1, text: 'Project Blue Falcon launch details', embedding: []);
    const chunk2 = NoteChunk(id: 2, text: 'Blue ocean strategy notes', embedding: []);
    const chunk3 = NoteChunk(id: 3, text: 'Unrelated grocery list', embedding: []);

    test('extracts significant words filtering out stop words', () {
      final words = getSignificantWords('What is the Blue Falcon project?');
      expect(words, equals(['blue', 'falcon', 'project']));
    });

    test('ranks chunks by count of matching query words', () {
      final results = performKeywordSearch(
        'What is the Blue Falcon project?',
        [chunk1, chunk2, chunk3],
      );

      expect(results.length, equals(2));
      expect(results[0].id, equals(1)); // matches blue, falcon, project -> score 3.0
      expect(results[0].score, equals(3.0));
      expect(results[1].id, equals(2)); // matches blue -> score 1.0
      expect(results[1].score, equals(1.0));
    });

    test('handles queries with exact codes or numbers', () {
      const codeChunk = NoteChunk(id: 4, text: 'Error code 404-XYZ in module socket', embedding: []);
      final results = performKeywordSearch(
        'code 404-XYZ',
        [chunk1, codeChunk],
      );

      expect(results.length, equals(1));
      expect(results.first.id, equals(4));
    });
  });
}
