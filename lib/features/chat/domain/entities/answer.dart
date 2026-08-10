import 'package:equatable/equatable.dart';

class Answer extends Equatable {
  const Answer(this.text);

  final String text;

  @override
  List<Object?> get props => [text];
}
