import 'package:flutter/foundation.dart';
import 'package:fpdart/fpdart.dart';
import 'package:ink_mind/core/errors/exceptions.dart';
import 'package:ink_mind/core/errors/failures.dart';
import 'package:ink_mind/features/chat/data/datasources/chat_remote_data_source.dart';
import 'package:ink_mind/features/chat/domain/repositories/chat_repository.dart';

class ChatRepositoryImpl implements ChatRepository {
  const ChatRepositoryImpl(this._remoteDataSource);

  final ChatRemoteDataSource _remoteDataSource;

  @override
  Stream<Either<Failure, String>> askQuestion(String question) async* {
    debugPrint('[ChatRepositoryImpl] Initiating stream for: "$question"');
    try {
      await for (final chunk in _remoteDataSource.askQuestion(question)) {
        yield Right(chunk);
      }
    } on ServerException catch (e) {
      debugPrint('[ChatRepositoryImpl] Caught ServerException: ${e.message}');
      yield Left(ServerFailure(e.message));
    } catch (e, stackTrace) {
      debugPrint('[ChatRepositoryImpl] Caught Unexpected Exception: $e');
      debugPrint('$stackTrace');
      yield Left(UnexpectedFailure(e.toString()));
    }
  }
}
