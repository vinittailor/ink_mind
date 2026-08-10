import 'package:fpdart/fpdart.dart';
import 'package:ink_mind/core/errors/failures.dart';
import 'package:ink_mind/core/usecases/usecase.dart';
import 'package:ink_mind/features/classifier/domain/entities/classification_result.dart';
import 'package:ink_mind/features/classifier/domain/repositories/classifier_repository.dart';

class ClassifyImage implements UseCase<ClassificationResult, String> {
  const ClassifyImage(this.repository);

  final ClassifierRepository repository;

  @override
  Future<Either<Failure, ClassificationResult>> call(String params) {
    return repository.classifyImage(params);
  }
}
