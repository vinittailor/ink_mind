import 'package:equatable/equatable.dart';

class ClassificationResult extends Equatable {
  const ClassificationResult({
    required this.label,
    required this.confidence,
  });

  final String label;
  final double confidence;

  @override
  List<Object?> get props => [label, confidence];
}
