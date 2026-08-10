import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:ink_mind/features/notes/data/models/note_chunk_objectbox.dart';
import 'package:ink_mind/objectbox.g.dart';

/// Database helper managing the local ObjectBox store and vector index.
class ObjectBoxDatabase {
  late final Store store;
  late final Box<NoteChunkObjectBox> noteChunkBox;

  static ObjectBoxDatabase? _instance;

  ObjectBoxDatabase._(this.store) {
    noteChunkBox = Box<NoteChunkObjectBox>(store);
  }

  /// Returns the singleton [ObjectBoxDatabase] instance, initializing it if necessary.
  static Future<ObjectBoxDatabase> create() async {
    if (_instance != null) return _instance!;

    try {
      debugPrint('[ObjectBoxDatabase] Initializing ObjectBox store...');
      final docsDir = await getApplicationDocumentsDirectory();
      final storePath = p.join(docsDir.path, 'ink_mind_obx');
      final store = await openStore(directory: storePath);
      _instance = ObjectBoxDatabase._(store);
      debugPrint('[ObjectBoxDatabase] Store initialized at: $storePath');
      return _instance!;
    } catch (e) {
      debugPrint('[ObjectBoxDatabase] Failed to open ObjectBox store: $e');
      rethrow;
    }
  }
}
