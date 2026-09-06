import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';

/// Linear progress bar component with full rounding
class MMProgressBar extends StatelessWidget {
  final double progress; // 0.0 to 1.0
  final Color? color;
  final Color? backgroundColor;
  final double height;

  const MMProgressBar({
    super.key,
    required this.progress,
    this.color,
    this.backgroundColor,
    this.height = 4.0,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.full),
      child: LinearProgressIndicator(
        value: progress,
        minHeight: height,
        backgroundColor: backgroundColor ?? AppColors.surfaceContainerHigh,
        color: color ?? AppColors.primary,
      ),
    );
  }
}

/// Circular progress spinner component
class MMCircularProgress extends StatelessWidget {
  final double? value;
  final double size;
  final Color? color;

  const MMCircularProgress({
    super.key,
    this.value,
    this.size = 36.0,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        value: value,
        strokeWidth: 2.5,
        color: color ?? AppColors.primary,
      ),
    );
  }
}

/// Segmented linear progress bar component (e.g., 10 step survey)
class MMSegmentedProgressBar extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final double height;

  const MMSegmentedProgressBar({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    this.height = 4.0,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(totalSteps, (index) {
        final isCompletedOrActive = index < currentStep;
        return Expanded(
          child: Container(
            height: height,
            margin: EdgeInsets.only(right: index < totalSteps - 1 ? 4.0 : 0.0),
            decoration: BoxDecoration(
              color: isCompletedOrActive ? AppColors.primary : AppColors.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(AppRadius.full),
            ),
          ),
        );
      }),
    );
  }
}
