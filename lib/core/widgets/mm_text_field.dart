import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_typography.dart';

/// Centralized Input Field component (Height: 48dp baseline, #F8F2FA fill, 1px #CBC4D2 outline)
class MMTextField extends StatelessWidget {
  final String label;
  final String? hint;
  final TextEditingController? controller;
  final bool obscureText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;
  final String? errorText;

  const MMTextField({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.keyboardType,
    this.onChanged,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.labelSmall),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          onChanged: onChanged,
          style: AppTypography.bodyMedium.copyWith(color: AppColors.onBackground),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTypography.bodyMedium.copyWith(color: AppColors.outline),
            filled: true,
            fillColor: AppColors.surfaceContainerLow,
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
            errorText: errorText,
            errorStyle: AppTypography.labelSmall.copyWith(color: AppColors.error, fontSize: 12),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: const OutlineInputBorder(
              borderRadius: AppRadius.borderXs,
              borderSide: BorderSide(color: AppColors.outlineVariant, width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: AppRadius.borderXs,
              borderSide: BorderSide(
                color: errorText != null ? AppColors.error : AppColors.outlineVariant,
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: AppRadius.borderXs,
              borderSide: BorderSide(
                color: errorText != null ? AppColors.error : AppColors.primary,
                width: 1.5,
              ),
            ),
            errorBorder: const OutlineInputBorder(
              borderRadius: AppRadius.borderXs,
              borderSide: BorderSide(color: AppColors.error, width: 1),
            ),
            focusedErrorBorder: const OutlineInputBorder(
              borderRadius: AppRadius.borderXs,
              borderSide: BorderSide(color: AppColors.error, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}

/// Search input component with search prefix icon
class MMSearchField extends StatelessWidget {
  final String hint;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;

  const MMSearchField({
    super.key,
    this.hint = 'Search...',
    this.controller,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: AppTypography.bodyMedium.copyWith(color: AppColors.onBackground),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: AppTypography.bodyMedium.copyWith(color: AppColors.outline),
          filled: true,
          fillColor: AppColors.surfaceContainerLow,
          prefixIcon: const Icon(Icons.search, color: AppColors.outline, size: 20),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          border: const OutlineInputBorder(
            borderRadius: AppRadius.borderXs,
            borderSide: BorderSide(color: AppColors.outlineVariant, width: 1),
          ),
          enabledBorder: const OutlineInputBorder(
            borderRadius: AppRadius.borderXs,
            borderSide: BorderSide(color: AppColors.outlineVariant, width: 1),
          ),
          focusedBorder: const OutlineInputBorder(
            borderRadius: AppRadius.borderXs,
            borderSide: BorderSide(color: AppColors.primary, width: 1.5),
          ),
        ),
      ),
    );
  }
}

/// Dropdown selector field component
class MMDropdownField<T> extends StatelessWidget {
  final String label;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;

  const MMDropdownField({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.labelSmall),
        const SizedBox(height: 4),
        SizedBox(
          height: 48,
          child: DropdownButtonFormField<T>(
            initialValue: value,
            items: items,
            onChanged: onChanged,
            style: AppTypography.bodyMedium.copyWith(color: AppColors.onBackground),
            icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.outline),
            decoration: const InputDecoration(
              filled: true,
              fillColor: AppColors.surfaceContainerLow,
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: AppRadius.borderXs,
                borderSide: BorderSide(color: AppColors.outlineVariant, width: 1),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: AppRadius.borderXs,
                borderSide: BorderSide(color: AppColors.outlineVariant, width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: AppRadius.borderXs,
                borderSide: BorderSide(color: AppColors.primary, width: 1.5),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
