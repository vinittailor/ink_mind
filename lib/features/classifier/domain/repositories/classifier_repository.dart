import 'package:fpdart/fpdart.dart';
import 'package:ink_mind/core/errors/failures.dart';
import 'package:ink_mind/features/classifier/domain/entities/classification_result.dart';

abstract interface class ClassifierRepository {
  /// Classifies the photo at [imagePath] entirely on-device using TFLite.
  Future<Either<Failure, ClassificationResult>> classifyImage(String imagePath);
}
