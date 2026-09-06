import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Custom Trend & Cash Flow Line Chart for Financial Command Center
class CommandCenterChart extends StatelessWidget {
  final String period;
  final double height;

  const CommandCenterChart({
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
        painter: _CommandCenterChartPainter(period: period),
      ),
    );
  }
}

class _CommandCenterChartPainter extends CustomPainter {
  final String period;

  _CommandCenterChartPainter({required this.period});

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = AppColors.outlineVariant.withValues(alpha: 0.4)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // 1. Draw horizontal background gridlines
    const gridRows = 4;
    final rowHeight = size.height / gridRows;
    for (int i = 0; i <= gridRows; i++) {
      final y = i * rowHeight;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Data points for Net Worth Curve (normalized 0.0 - 1.0)
    final points = [
      const Offset(0.0, 0.75),
      const Offset(0.15, 0.65),
      const Offset(0.3, 0.70),
      const Offset(0.45, 0.45),
      const Offset(0.6, 0.50),
      const Offset(0.75, 0.30),
      const Offset(0.9, 0.25),
      const Offset(1.0, 0.15),
    ];

    // Convert normalized offsets to canvas coordinates
    final pathPoints = points.map((p) {
      return Offset(p.dx * size.width, p.dy * size.height);
    }).toList();

    // 2. Gradient area fill under curve
    final fillPath = Path()..moveTo(pathPoints.first.dx, size.height);
    for (var p in pathPoints) {
      fillPath.lineTo(p.dx, p.dy);
    }
    fillPath.lineTo(pathPoints.last.dx, size.height);
    fillPath.close();

    final fillGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        AppColors.primaryContainer.withValues(alpha: 0.35),
        AppColors.primaryContainer.withValues(alpha: 0.0),
      ],
    );

    final fillPaint = Paint()
      ..shader = fillGradient.createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;
    canvas.drawPath(fillPath, fillPaint);

    // 3. Smooth curve line
    final linePath = Path()..moveTo(pathPoints.first.dx, pathPoints.first.dy);
    for (int i = 0; i < pathPoints.length - 1; i++) {
      final p1 = pathPoints[i];
      final p2 = pathPoints[i + 1];
      final controlPoint1 = Offset(p1.dx + (p2.dx - p1.dx) / 2, p1.dy);
      final controlPoint2 = Offset(p1.dx + (p2.dx - p1.dx) / 2, p2.dy);
      linePath.cubicTo(controlPoint1.dx, controlPoint1.dy, controlPoint2.dx, controlPoint2.dy, p2.dx, p2.dy);
    }

    final linePaint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(linePath, linePaint);

    // 4. Highlight active current data point at the end
    final lastP = pathPoints.last;
    canvas.drawCircle(
      lastP,
      6,
      Paint()..color = AppColors.primary,
    );
    canvas.drawCircle(
      lastP,
      3,
      Paint()..color = AppColors.onPrimary,
    );
  }

  @override
  bool shouldRepaint(covariant _CommandCenterChartPainter oldDelegate) {
    return oldDelegate.period != period;
  }
}
