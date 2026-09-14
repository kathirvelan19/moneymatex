import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// MoneyMateX Typography System
/// Powered everywhere by GoogleFonts.poppins
abstract class AppTypography {
  // Display (Hero Splash, Main Net Worth Totals)
  static TextStyle display = GoogleFonts.poppins(
    fontSize: 48,
    fontWeight: FontWeight.w700,
    height: 1.1,
    letterSpacing: -0.96,
    color: AppColors.onBackground,
  );

  // Headline Large (Section Headers)
  static TextStyle headlineLarge = GoogleFonts.poppins(
    fontSize: 32,
    fontWeight: FontWeight.w600,
    height: 1.2,
    letterSpacing: -0.32,
    color: AppColors.onBackground,
  );

  // Headline Mobile (Screen Titles)
  static TextStyle headlineMobile = GoogleFonts.poppins(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.2,
    letterSpacing: 0,
    color: AppColors.onBackground,
  );

  // Headline Medium (Card Titles)
  static TextStyle headlineMedium = GoogleFonts.poppins(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: 0,
    color: AppColors.onBackground,
  );

  // Body Large (Primary Readability Text)
  static TextStyle bodyLarge = GoogleFonts.poppins(
    fontSize: 18,
    fontWeight: FontWeight.w400,
    height: 1.6,
    letterSpacing: 0,
    color: AppColors.onBackground,
  );

  // Body Medium (Standard Descriptions)
  static TextStyle bodyMedium = GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.6,
    letterSpacing: 0,
    color: AppColors.onSurfaceVariant,
  );

  // Label Small (Currencies, Data Points, Percentages, Timestamps)
  static TextStyle labelSmall = GoogleFonts.poppins(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    height: 1.2,
    letterSpacing: 0.26,
    color: AppColors.onSurfaceVariant,
  );

  // Tagline (Understated Editorial Quotes)
  static TextStyle tagline = GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.w300,
    height: 1.4,
    letterSpacing: 0.7,
    color: AppColors.secondary,
  );
}

