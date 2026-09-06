import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/mm_chip.dart';

/// Premium Search & Category Filter Bar Component
class TransactionsSearchFilterBar extends StatelessWidget {
  final TextEditingController searchController;
  final String selectedCategory;
  final List<String> categories;
  final ValueChanged<String> onCategorySelected;
  final VoidCallback onClearSearch;

  const TransactionsSearchFilterBar({
    super.key,
    required this.searchController,
    required this.selectedCategory,
    required this.categories,
    required this.onCategorySelected,
    required this.onClearSearch,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasSearchText = searchController.text.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search TextField
        Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(AppRadius.l),
            border: Border.all(color: AppColors.outlineVariant, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: searchController,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.onSurface,
              fontSize: 14,
            ),
            decoration: InputDecoration(
              hintText: 'Search merchant, category, or amount...',
              hintStyle: AppTypography.bodyMedium.copyWith(
                color: AppColors.onSurfaceVariant.withValues(alpha: 0.7),
                fontSize: 13,
              ),
              prefixIcon: const Icon(
                Icons.search,
                color: AppColors.onSurfaceVariant,
                size: 20,
              ),
              suffixIcon: hasSearchText
                  ? IconButton(
                      icon: const Icon(Icons.close, size: 18),
                      color: AppColors.onSurfaceVariant,
                      onPressed: onClearSearch,
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.m,
                vertical: 14,
              ),
            ),
          ),
        ),

        const SizedBox(height: AppSpacing.m),

        // Horizontal Category Chips List
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: categories.map((c) {
              final isSelected = selectedCategory == c;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: MMCategoryChip(
                  label: c,
                  isSelected: isSelected,
                  onSelected: () => onCategorySelected(c),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
