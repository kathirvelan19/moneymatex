import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// MoneyMateX Typography System
/// Headings & Body: Hanken Grotesk
/// Technical Data, Currency, Timestamps & Labels: Geist
abstract class AppTypography {
  // Display (Hero Splash, Main Net Worth Totals)
  static TextStyle display = GoogleFonts.hankenGrotesk(
    fontSize: 48,
    fontWeight: FontWeight.w700,
    height: 1.1,
    letterSpacing: -0.96,
    color: AppColors.onBackground,
  );

  // Headline Large (Section Headers)
  static TextStyle headlineLarge = GoogleFonts.hankenGrotesk(
    fontSize: 32,
    fontWeight: FontWeight.w600,
    height: 1.2,
    letterSpacing: -0.32,
    color: AppColors.onBackground,
  );

  // Headline Mobile (Screen Titles)
  static TextStyle headlineMobile = GoogleFonts.hankenGrotesk(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.2,
    letterSpacing: 0,
    color: AppColors.onBackground,
  );

  // Headline Medium (Card Titles)
  static TextStyle headlineMedium = GoogleFonts.hankenGrotesk(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: 0,
    color: AppColors.onBackground,
  );

  // Body Large (Primary Readability Text)
  static TextStyle bodyLarge = GoogleFonts.hankenGrotesk(
    fontSize: 18,
    fontWeight: FontWeight.w400,
    height: 1.6,
    letterSpacing: 0,
    color: AppColors.onBackground,
  );

  // Body Medium (Standard Descriptions)
  static TextStyle bodyMedium = GoogleFonts.hankenGrotesk(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.6,
    letterSpacing: 0,
    color: AppColors.onSurfaceVariant,
  );

  // Label Small (Geist - Currencies, Data Points, Percentages, Timestamps)
  static TextStyle labelSmall = const TextStyle(
    fontFamily: 'Geist',
    fontSize: 13,
    fontWeight: FontWeight.w500,
    height: 1.2,
    letterSpacing: 0.26,
    color: AppColors.onSurfaceVariant,
  );


  // Tagline (Understated Editorial Quotes)
  static TextStyle tagline = GoogleFonts.hankenGrotesk(
    fontSize: 14,
    fontWeight: FontWeight.w300,
    height: 1.4,
    letterSpacing: 0.7,
    color: AppColors.secondary,
  );
}
