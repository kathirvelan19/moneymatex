import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Multi-curve detailed Net Worth vs Assets & Debt line graph for Screen #19
class DetailedNetWorthChart extends StatelessWidget {
  final String period;
  final double height;

  const DetailedNetWorthChart({
    super.key,
    this.period = '1Y',
    this.height = 220,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: CustomPaint(
        size: Size.infinite,
        painter: _DetailedNetWorthChartPainter(period: period),
      ),
    );
  }
}

class _DetailedNetWorthChartPainter extends CustomPainter {
  final String period;

  _DetailedNetWorthChartPainter({required this.period});

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = AppColors.outlineVariant.withValues(alpha: 0.3)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // Draw horizontal gridlines
    const gridRows = 4;
    final rowHeight = size.height / gridRows;
    for (int i = 0; i <= gridRows; i++) {
      final y = i * rowHeight;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Normalized points for Net Worth (Curve 1 - Purple)
    final netWorthPoints = [
      const Offset(0.0, 0.75),
      const Offset(0.2, 0.68),
      const Offset(0.4, 0.55),
      const Offset(0.6, 0.48),
      const Offset(0.8, 0.32),
      const Offset(1.0, 0.18),
    ];

    // Normalized points for Total Assets (Curve 2 - Amber/Gold)
    final assetsPoints = [
      const Offset(0.0, 0.60),
      const Offset(0.2, 0.52),
      const Offset(0.4, 0.42),
      const Offset(0.6, 0.35),
      const Offset(0.8, 0.22),
      const Offset(1.0, 0.10),
    ];

    // Normalized points for Total Liabilities (Curve 3 - Red/Error)
    final debtPoints = [
      const Offset(0.0, 0.85),
      const Offset(0.2, 0.84),
      const Offset(0.4, 0.87),
      const Offset(0.6, 0.86),
      const Offset(0.8, 0.90),
      const Offset(1.0, 0.92),
    ];

    // 1. Draw Net Worth Gradient Fill
    final nwPathPoints = netWorthPoints.map((p) => Offset(p.dx * size.width, p.dy * size.height)).toList();
    final fillPath = Path()..moveTo(nwPathPoints.first.dx, size.height);
    for (var p in nwPathPoints) {
      fillPath.lineTo(p.dx, p.dy);
    }
    fillPath.lineTo(nwPathPoints.last.dx, size.height);
    fillPath.close();

    final fillGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        AppColors.primaryContainer.withValues(alpha: 0.3),
        AppColors.primaryContainer.withValues(alpha: 0.0),
      ],
    );

    canvas.drawPath(
      fillPath,
      Paint()
        ..shader = fillGradient.createShader(Rect.fromLTWH(0, 0, size.width, size.height))
        ..style = PaintingStyle.fill,
    );

    // 2. Draw Total Assets Curve (Amber)
    _drawCurve(canvas, size, assetsPoints, AppColors.tertiary, strokeWidth: 2.0);

    // 3. Draw Total Liabilities Curve (Error Red)
    _drawCurve(canvas, size, debtPoints, AppColors.error, strokeWidth: 2.0);

    // 4. Draw Main Net Worth Curve (Deep Purple)
    _drawCurve(canvas, size, netWorthPoints, AppColors.primary, strokeWidth: 3.0);

    // 5. Draw active marker point on Net Worth
    final lastP = nwPathPoints.last;
    canvas.drawCircle(lastP, 6, Paint()..color = AppColors.primary);
    canvas.drawCircle(lastP, 3, Paint()..color = AppColors.onPrimary);
  }

  void _drawCurve(Canvas canvas, Size size, List<Offset> normalizedPoints, Color color, {double strokeWidth = 2.0}) {
    final pathPoints = normalizedPoints.map((p) => Offset(p.dx * size.width, p.dy * size.height)).toList();
    final linePath = Path()..moveTo(pathPoints.first.dx, pathPoints.first.dy);

    for (int i = 0; i < pathPoints.length - 1; i++) {
      final p1 = pathPoints[i];
      final p2 = pathPoints[i + 1];
      final controlPoint1 = Offset(p1.dx + (p2.dx - p1.dx) / 2, p1.dy);
      final controlPoint2 = Offset(p1.dx + (p2.dx - p1.dx) / 2, p2.dy);
      linePath.cubicTo(controlPoint1.dx, controlPoint1.dy, controlPoint2.dx, controlPoint2.dy, p2.dx, p2.dy);
    }

    canvas.drawPath(
      linePath,
      Paint()
        ..color = color
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _DetailedNetWorthChartPainter oldDelegate) {
    return oldDelegate.period != period;
  }
}
