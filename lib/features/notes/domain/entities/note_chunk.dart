import 'package:equatable/equatable.dart';

class NoteChunk extends Equatable {
  const NoteChunk({
    this.id,
    required this.text,
    required this.embedding,
    this.score,
    this.sourceTitle,
    this.chunkIndex,
    this.createdAt,
  });

  final int? id;
  final String text;
  final List<double> embedding;
  final double? score;
  final String? sourceTitle;
  final int? chunkIndex;
  final String? createdAt;

  NoteChunk copyWith({
    int? id,
    double? score,
    String? sourceTitle,
    int? chunkIndex,
    String? createdAt,
  }) {
    return NoteChunk(
      id: id ?? this.id,
      text: text,
      embedding: embedding,
      score: score ?? this.score,
      sourceTitle: sourceTitle ?? this.sourceTitle,
      chunkIndex: chunkIndex ?? this.chunkIndex,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        text,
        embedding,
        score,
        sourceTitle,
        chunkIndex,
        createdAt,
      ];
}
