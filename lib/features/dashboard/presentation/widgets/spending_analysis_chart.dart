import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Custom Donut & Category Bar Spending Chart for Screen #21
class SpendingAnalysisChart extends StatelessWidget {
  final String period;
  final double height;

  const SpendingAnalysisChart({
    super.key,
    this.period = '1M',
    this.height = 200,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: CustomPaint(
        size: Size.infinite,
        painter: _SpendingAnalysisChartPainter(period: period),
      ),
    );
  }
}

class _SpendingAnalysisChartPainter extends CustomPainter {
  final String period;

  _SpendingAnalysisChartPainter({required this.period});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 12;
    final innerRadius = radius * 0.65;

    // Categories: [Share 0..1, Color]
    final categorySlices = [
      [0.334, AppColors.tertiary], // Housing & Utilities (33.4%)
      [0.258, AppColors.primary], // Food & Dining (25.8%)
      [0.170, AppColors.secondary], // Shopping (17.0%)
      [0.122, AppColors.aiAccent], // Subscriptions (12.2%)
      [0.116, const Color(0xFFE57373)], // Travel (11.6%)
    ];

    double startAngle = -math.pi / 2;

    for (var slice in categorySlices) {
      final sweepAngle = (slice[0] as double) * 2 * math.pi;
      final paint = Paint()
        ..color = slice[1] as Color
        ..style = PaintingStyle.stroke
        ..strokeWidth = radius - innerRadius
        ..strokeCap = StrokeCap.butt;

      final sliceRadius = (radius + innerRadius) / 2;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: sliceRadius),
        startAngle,
        sweepAngle - 0.04, // slight segment gap
        false,
        paint,
      );

      startAngle += sweepAngle;
    }

    // Inner circle background
    canvas.drawCircle(
      center,
      innerRadius,
      Paint()..color = AppColors.surfaceContainerLowest,
    );
  }

  @override
  bool shouldRepaint(covariant _SpendingAnalysisChartPainter oldDelegate) {
    return oldDelegate.period != period;
  }
}
