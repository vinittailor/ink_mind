import 'package:flutter/foundation.dart';
import 'package:fpdart/fpdart.dart';
import 'package:ink_mind/core/errors/exceptions.dart';
import 'package:ink_mind/core/errors/failures.dart';
import 'package:ink_mind/features/classifier/data/datasources/classifier_local_data_source.dart';
import 'package:ink_mind/features/classifier/domain/entities/classification_result.dart';
import 'package:ink_mind/features/classifier/domain/repositories/classifier_repository.dart';

class ClassifierRepositoryImpl implements ClassifierRepository {
  const ClassifierRepositoryImpl(this._localDataSource);

  final ClassifierLocalDataSource _localDataSource;

  @override
  Future<Either<Failure, ClassificationResult>> classifyImage(String imagePath) async {
    debugPrint('[ClassifierRepositoryImpl] Classifying image at path: $imagePath');
    try {
      final result = await _localDataSource.classifyImage(imagePath);
      return Right(result);
    } on ModelException catch (e) {
      debugPrint('[ClassifierRepositoryImpl] ModelException: ${e.message}');
      return Left(ModelFailure(e.message));
    } catch (e, stackTrace) {
      debugPrint('[ClassifierRepositoryImpl] Unexpected exception: $e');
      debugPrint('$stackTrace');
      return Left(UnexpectedFailure(e.toString()));
    }
  }
}
