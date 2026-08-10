import 'package:flutter/material.dart';
import 'package:ink_mind/core/theme/app_colors.dart';

/// A centered circular progress indicator using the app's primary color.
///
/// Drop this anywhere a full-screen or inline loading state is needed.
class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({super.key, this.size = 36.0});

  /// Diameter of the spinner. Defaults to 36 logical pixels.
  final double size;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox.square(
        dimension: size,
        child: CircularProgressIndicator(
          strokeWidth: 3,
          color: AppColors.primary,
        ),
      ),
    );
  }
}
