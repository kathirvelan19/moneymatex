import 'package:flutter/material.dart';
import '../theme/app_typography.dart';
import 'mm_card.dart';

class MMMetricTile extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;

  const MMMetricTile({
    super.key,
    required this.title,
    required this.value,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return MMCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTypography.tagline),
          const SizedBox(height: 4),
          Text(value, style: AppTypography.display.copyWith(fontSize: 28)),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(subtitle!, style: AppTypography.labelSmall),
          ],
        ],
      ),
    );
  }
}
