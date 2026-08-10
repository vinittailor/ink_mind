import 'package:fpdart/fpdart.dart';
import 'package:ink_mind/core/errors/failures.dart';

abstract interface class ChatRepository {
  Stream<Either<Failure, String>> askQuestion(String question);
}
