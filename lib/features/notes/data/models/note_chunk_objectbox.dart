import 'package:objectbox/objectbox.dart';

/// ObjectBox entity for storing note chunks and HNSW vector index for embeddings.
@Entity()
class NoteChunkObjectBox {
  @Id()
  int id;

  String text;

  @HnswIndex(dimensions: 768)
  @Property(type: PropertyType.floatVector)
  List<double>? embedding;

  String? sourceTitle;
  int? chunkIndex;
  String? createdAt;

  NoteChunkObjectBox({
    this.id = 0,
    required this.text,
    this.embedding,
    this.sourceTitle,
    this.chunkIndex,
    this.createdAt,
  });
}
