import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ink_mind/features/classifier/domain/entities/classification_result.dart';
import 'package:ink_mind/features/classifier/domain/usecases/classify_image.dart';

sealed class ClassifierState extends Equatable {
  const ClassifierState();

  @override
  List<Object?> get props => [];
}

final class ClassifierIdle extends ClassifierState {
  const ClassifierIdle();
}

final class ClassifierLoading extends ClassifierState {
  const ClassifierLoading();
}

final class ClassifierResultState extends ClassifierState {
  const ClassifierResultState({
    required this.result,
    required this.imagePath,
  });

  final ClassificationResult result;
  final String imagePath;

  @override
  List<Object?> get props => [result, imagePath];
}

final class ClassifierError extends ClassifierState {
  const ClassifierError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

class ClassifierCubit extends Cubit<ClassifierState> {
  ClassifierCubit(this._classifyImage)
      : _picker = ImagePicker(),
        super(const ClassifierIdle());

  final ClassifyImage _classifyImage;
  final ImagePicker _picker;

  Future<void> pickAndClassifyImage(ImageSource source) async {
    try {
      final XFile? file = await _picker.pickImage(source: source);
      if (file == null) {
        debugPrint('[ClassifierCubit] Image selection cancelled by user.');
        return;
      }

      final imagePath = file.path;
      debugPrint('[ClassifierCubit] Selected image path: $imagePath');
      emit(const ClassifierLoading());

      final result = await _classifyImage(imagePath);

      result.fold(
        (failure) {
          debugPrint('[ClassifierCubit] Classification failure: ${failure.message}');
          emit(ClassifierError(failure.message));
        },
        (classificationResult) {
          debugPrint('[ClassifierCubit] Classification success: ${classificationResult.label}');
          emit(ClassifierResultState(
            result: classificationResult,
            imagePath: imagePath,
          ));
        },
      );
    } catch (e) {
      debugPrint('[ClassifierCubit] Error picking/classifying image: $e');
      emit(ClassifierError(e.toString()));
    }
  }
}
