import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Dual Bar & Trend Curve Cash Flow Chart for Screen #20
class CashFlowChart extends StatelessWidget {
  final String period;
  final double height;

  const CashFlowChart({
    super.key,
    this.period = '1M',
    this.height = 220,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: CustomPaint(
        size: Size.infinite,
        painter: _CashFlowChartPainter(period: period),
      ),
    );
  }
}

class _CashFlowChartPainter extends CustomPainter {
  final String period;

  _CashFlowChartPainter({required this.period});

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = AppColors.outlineVariant.withValues(alpha: 0.3)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // 1. Draw horizontal grid lines
    const gridRows = 4;
    final rowHeight = size.height / gridRows;
    for (int i = 0; i <= gridRows; i++) {
      final y = i * rowHeight;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Bar Data for 6 Periods (Normalized 0..1)
    // Each item has: [incomeHeight, expenseHeight]
    final barData = [
      [0.70, 0.45], // P1
      [0.75, 0.50], // P2
      [0.65, 0.40], // P3
      [0.85, 0.55], // P4
      [0.80, 0.48], // P5
      [0.90, 0.52], // P6
    ];

    final numGroups = barData.length;
    final groupWidth = size.width / numGroups;
    final barWidth = groupWidth * 0.28;

    final incomeBarPaint = Paint()
      ..color = const Color(0xFF10B981) // Green for Inflow
      ..style = PaintingStyle.fill;

    final expenseBarPaint = Paint()
      ..color = AppColors.secondary.withValues(alpha: 0.7) // Slate purple for Outflow
      ..style = PaintingStyle.fill;

    final netPoints = <Offset>[];

    for (int i = 0; i < numGroups; i++) {
      final groupLeft = i * groupWidth;
      final incomeH = barData[i][0] * (size.height * 0.8);
      final expenseH = barData[i][1] * (size.height * 0.8);

      final incomeRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(
          groupLeft + groupWidth * 0.15,
          size.height - incomeH,
          barWidth,
          incomeH,
        ),
        const Radius.circular(4),
      );

      final expenseRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(
          groupLeft + groupWidth * 0.15 + barWidth + 4,
          size.height - expenseH,
          barWidth,
          expenseH,
        ),
        const Radius.circular(4),
      );

      canvas.drawRRect(incomeRect, incomeBarPaint);
      canvas.drawRRect(expenseRect, expenseBarPaint);

      // Calculate Net Cash Flow Point (Income - Expense)
      final netVal = barData[i][0] - barData[i][1];
      final netY = size.height - (netVal * (size.height * 0.8) + size.height * 0.15);
      final centerX = groupLeft + groupWidth / 2;
      netPoints.add(Offset(centerX, netY));
    }

    // 2. Draw Net Cash Flow Trend Curve
    if (netPoints.length > 1) {
      final linePath = Path()..moveTo(netPoints.first.dx, netPoints.first.dy);
      for (int i = 0; i < netPoints.length - 1; i++) {
        final p1 = netPoints[i];
        final p2 = netPoints[i + 1];
        final control1 = Offset(p1.dx + (p2.dx - p1.dx) / 2, p1.dy);
        final control2 = Offset(p1.dx + (p2.dx - p1.dx) / 2, p2.dy);
        linePath.cubicTo(control1.dx, control1.dy, control2.dx, control2.dy, p2.dx, p2.dy);
      }

      final linePaint = Paint()
        ..color = AppColors.primary
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke;

      canvas.drawPath(linePath, linePaint);

      for (var p in netPoints) {
        canvas.drawCircle(p, 4, Paint()..color = AppColors.primary);
        canvas.drawCircle(p, 2, Paint()..color = AppColors.onPrimary);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _CashFlowChartPainter oldDelegate) {
    return oldDelegate.period != period;
  }
}
