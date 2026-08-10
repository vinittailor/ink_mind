import 'package:fpdart/fpdart.dart';
import 'package:ink_mind/core/errors/failures.dart';
import 'package:ink_mind/features/chat/domain/repositories/chat_repository.dart';

class AskQuestion {
  const AskQuestion(this.repository);

  final ChatRepository repository;

  Stream<Either<Failure, String>> call(String params) {
    return repository.askQuestion(params);
  }
}
