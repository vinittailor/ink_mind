import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ink_mind/core/widgets/loading_indicator.dart';
import 'package:ink_mind/features/classifier/presentation/cubit/classifier_cubit.dart';

class ClassifierPage extends StatelessWidget {
  const ClassifierPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('On-Device Photo Classifier'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Gallery'),
                    onPressed: () => context
                        .read<ClassifierCubit>()
                        .pickAndClassifyImage(ImageSource.gallery),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Camera'),
                    onPressed: () => context
                        .read<ClassifierCubit>()
                        .pickAndClassifyImage(ImageSource.camera),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Expanded(
              child: BlocBuilder<ClassifierCubit, ClassifierState>(
                builder: (context, state) {
                  return switch (state) {
                    ClassifierIdle() => const Center(
                        child: Text(
                          'Pick or take a photo to classify it offline.',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ClassifierLoading() => const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          LoadingIndicator(),
                          SizedBox(height: 12),
                          Text('Running on-device TFLite inference...'),
                        ],
                      ),
                    ClassifierResultState(:final result, :final imagePath) =>
                      SingleChildScrollView(
                        child: Column(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(
                                File(imagePath),
                                height: 250,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Card(
                              color: Theme.of(context).colorScheme.surfaceContainerHighest,
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  children: [
                                    const Text(
                                      'Predicted Label',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      result.label.toUpperCase(),
                                      style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.lightGreenAccent,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Confidence: ${(result.confidence * 100).toStringAsFixed(1)}%',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ClassifierError(:final message) => Text(
                        message,
                        style: const TextStyle(color: Colors.red),
                      ),
                  };
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
