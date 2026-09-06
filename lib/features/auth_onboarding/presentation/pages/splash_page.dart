import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../providers/auth_provider.dart';

/// Stitch Screen: MoneyMateX Splash Screen
/// Screen ID: 430bf5042514410ead8045a6c8f42019
/// Canvas Dimensions: 780 × 1768 px (Mobile 390 × 844 dp @2x scale)
class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  late AnimationController _dotController;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));

    _dotController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();

    _fadeController.forward();

    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    final startTime = DateTime.now();
    await ref.read(authStateProvider.notifier).checkSession();
    final elapsed = DateTime.now().difference(startTime);

    if (elapsed.inMilliseconds < 800) {
      await Future.delayed(Duration(milliseconds: 800 - elapsed.inMilliseconds));
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _dotController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLowest,
      body: Stack(
        alignment: Alignment.center,
        children: [
          // Main Content Canvas
          Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.marginMobile),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo (128x128 dp)
                      Image.asset(
                        'assets/logos/app_logo.png',
                        width: 128,
                        height: 128,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 128,
                          height: 128,
                          decoration: BoxDecoration(
                            color: AppColors.primaryContainer,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: const Icon(
                            Icons.account_balance_wallet,
                            size: 64,
                            color: AppColors.onPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.stackLg),

                      // Title & Tagline
                      Text(
                        'MoneyMateX',
                        textAlign: TextAlign.center,
                        style: AppTypography.display,
                      ),
                      const SizedBox(height: AppSpacing.stackSm),
                      Text(
                        'TRACK SMART. SAVE BETTER.',
                        textAlign: TextAlign.center,
                        style: AppTypography.tagline.copyWith(
                          color: AppColors.outline,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Bottom Loading Dots Indicator
          Positioned(
            bottom: 48,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (index) {
                return AnimatedBuilder(
                  animation: _dotController,
                  builder: (context, child) {
                    final delay = index * 0.2;
                    final value = (_dotController.value - delay) % 1.0;
                    final scale = (value < 0.4) ? 0.3 + (value / 0.4) * 0.7 : 1.0 - ((value - 0.4) / 0.6) * 0.7;
                    final opacity = 0.3 + (scale * 0.7);

                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: 8,
                      height: 8,
                      transform: Matrix4.diagonal3Values(scale.clamp(0.3, 1.0), scale.clamp(0.3, 1.0), 1.0),
                      decoration: BoxDecoration(
                        color: AppColors.outlineVariant.withValues(alpha: opacity.clamp(0.3, 1.0)),
                        shape: BoxShape.circle,
                      ),
                    );
                  },
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
