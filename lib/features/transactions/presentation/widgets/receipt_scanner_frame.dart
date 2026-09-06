import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_typography.dart';

/// Scanner Frame Overlay for Receipt Scanner Screen (#26 & #27)
class ReceiptScannerFrame extends StatelessWidget {
  final bool isScanning;
  final String tipText;

  const ReceiptScannerFrame({
    super.key,
    this.isScanning = true,
    this.tipText = 'Position receipt inside the frame',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 380,
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(
          color: AppColors.primaryContainer.withValues(alpha: 0.8),
          width: 2,
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Corner brackets
          Positioned(
            top: 12,
            left: 12,
            child: _buildCornerBracket(top: true, left: true),
          ),
          Positioned(
            top: 12,
            right: 12,
            child: _buildCornerBracket(top: true, left: false),
          ),
          Positioned(
            bottom: 12,
            left: 12,
            child: _buildCornerBracket(top: false, left: true),
          ),
          Positioned(
            bottom: 12,
            right: 12,
            child: _buildCornerBracket(top: false, left: false),
          ),

          // Center guidance text
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.document_scanner_outlined,
                size: 48,
                color: Colors.white.withValues(alpha: 0.7),
              ),
              const SizedBox(height: 12),
              Text(
                tipText,
                textAlign: TextAlign.center,
                style: AppTypography.bodyMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  shadows: const [Shadow(blurRadius: 4, color: Colors.black)],
                ),
              ),
            ],
          ),

          // Laser scanning animation line
          if (isScanning)
            Positioned(
              top: 80,
              left: 20,
              right: 20,
              child: Container(
                height: 2,
                decoration: BoxDecoration(
                  color: AppColors.secondary,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.secondary.withValues(alpha: 0.8),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCornerBracket({required bool top, required bool left}) {
    return SizedBox(
      width: 24,
      height: 24,
      child: CustomPaint(
        painter: _CornerBracketPainter(top: top, left: left),
      ),
    );
  }
}

class _CornerBracketPainter extends CustomPainter {
  final bool top;
  final bool left;

  _CornerBracketPainter({required this.top, required this.left});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.secondary
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final path = Path();
    if (top && left) {
      path.moveTo(0, size.height);
      path.lineTo(0, 0);
      path.lineTo(size.width, 0);
    } else if (top && !left) {
      path.moveTo(0, 0);
      path.lineTo(size.width, 0);
      path.lineTo(size.width, size.height);
    } else if (!top && left) {
      path.moveTo(0, 0);
      path.lineTo(0, size.height);
      path.lineTo(size.width, size.height);
    } else {
      path.moveTo(0, size.height);
      path.lineTo(size.width, size.height);
      path.lineTo(size.width, 0);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
