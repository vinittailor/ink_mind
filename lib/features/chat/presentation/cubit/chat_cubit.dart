import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ink_mind/features/chat/domain/usecases/ask_question.dart';
import 'package:ink_mind/features/notes/domain/usecases/get_relevant_chunks.dart';

sealed class ChatState extends Equatable {
  const ChatState();

  @override
  List<Object?> get props => [];
}

final class ChatInitial extends ChatState {
  const ChatInitial();
}

final class ChatSearchingNotes extends ChatState {
  const ChatSearchingNotes();
}

final class ChatLoading extends ChatState {
  const ChatLoading();
}

final class ChatStreaming extends ChatState {
  const ChatStreaming(this.partialText, {this.sources = const []});

  final String partialText;
  final List<String> sources;

  @override
  List<Object?> get props => [partialText, sources];
}

final class ChatError extends ChatState {
  const ChatError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

class ChatCubit extends Cubit<ChatState> {
  ChatCubit({
    required AskQuestion askQuestion,
    required GetRelevantChunks getRelevantChunks,
  })  : _askQuestion = askQuestion,
        _getRelevantChunks = getRelevantChunks,
        super(const ChatInitial());

  final AskQuestion _askQuestion;
  final GetRelevantChunks _getRelevantChunks;
  StreamSubscription<dynamic>? _subscription;

  Future<void> ask(String question) async {
    final trimmed = question.trim();
    if (trimmed.isEmpty) return;

    await _subscription?.cancel();

    debugPrint('[ChatCubit] 🔍 Performing RAG retrieval for question: "$trimmed"');
    emit(const ChatSearchingNotes());

    // 1. Retrieve top relevant note chunks from storage backend
    final chunksResult = await _getRelevantChunks(trimmed);

    final List<String> sources = [];
    var promptToSend = trimmed;

    chunksResult.fold(
      (failure) => debugPrint('[ChatCubit] ⚠️ Note retrieval warning: ${failure.message}'),
      (chunks) {
        if (chunks.isNotEmpty) {
          for (final chunk in chunks) {
            sources.add(chunk.text);
          }
          final contextBlock = chunks.map((c) => '- ${c.text}').join('\n');
          promptToSend =
              'Using the following notes as context, answer the question.\n\nContext:\n$contextBlock\n\nQuestion: $trimmed';
          debugPrint('[ChatCubit] 🧠 Prompt augmented with ${chunks.length} retrieved note chunk(s)');
        } else {
          debugPrint('[ChatCubit] ℹ️ No relevant note chunks found. Querying Gemini directly.');
        }
      },
    );

    var accumulatedText = '';

    // 2. Query Gemini streaming endpoint with augmented RAG prompt
    emit(const ChatLoading());
    _subscription = _askQuestion(promptToSend).listen(
      (result) {
        result.fold(
          (failure) {
            debugPrint('[ChatCubit] Stream failure: ${failure.message}');
            emit(ChatError(failure.message));
          },
          (chunk) {
            accumulatedText += chunk;
            debugPrint('[ChatCubit] Stream success: $accumulatedText');
            emit(ChatStreaming(accumulatedText, sources: sources));
          },
        );
      },
      onError: (error) {
        debugPrint('[ChatCubit] Stream error: $error');
        emit(ChatError(error.toString()));
      },
    );
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
