import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Custom Compact Net Worth Curve Chart for Screen #18 Net Worth Tracker (Compact)
class CompactNetWorthChart extends StatelessWidget {
  final String period;
  final double height;

  const CompactNetWorthChart({
    super.key,
    this.period = '1M',
    this.height = 180,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: CustomPaint(
        size: Size.infinite,
        painter: _CompactNetWorthChartPainter(period: period),
      ),
    );
  }
}

class _CompactNetWorthChartPainter extends CustomPainter {
  final String period;

  _CompactNetWorthChartPainter({required this.period});

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = AppColors.outlineVariant.withValues(alpha: 0.3)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // Horizontal dashed lines
    const gridRows = 3;
    final rowHeight = size.height / gridRows;
    for (int i = 1; i < gridRows; i++) {
      final y = i * rowHeight;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Points normalized (x: 0..1, y: 0..1)
    final points = [
      const Offset(0.0, 0.8),
      const Offset(0.2, 0.7),
      const Offset(0.4, 0.55),
      const Offset(0.6, 0.60),
      const Offset(0.8, 0.35),
      const Offset(1.0, 0.2),
    ];

    final pathPoints = points.map((p) => Offset(p.dx * size.width, p.dy * size.height)).toList();

    // Area fill
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
        AppColors.primaryContainer.withValues(alpha: 0.25),
        AppColors.primaryContainer.withValues(alpha: 0.0),
      ],
    );

    canvas.drawPath(
      fillPath,
      Paint()
        ..shader = fillGradient.createShader(Rect.fromLTWH(0, 0, size.width, size.height))
        ..style = PaintingStyle.fill,
    );

    // Smooth Line
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
        ..color = AppColors.primary
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke,
    );

    // Current point dot
    final lastP = pathPoints.last;
    canvas.drawCircle(lastP, 5, Paint()..color = AppColors.primary);
    canvas.drawCircle(lastP, 2.5, Paint()..color = AppColors.onPrimary);
  }

  @override
  bool shouldRepaint(covariant _CompactNetWorthChartPainter oldDelegate) {
    return oldDelegate.period != period;
  }
}
