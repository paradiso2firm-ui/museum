import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// 에디토리얼 타이포그래피 시스템
/// - Newsreader: Display & Headlines (서적/매거진 느낌)
/// - Inter: Body, Labels, UI 요소 (기능적 대비)
abstract final class AppTypography {
  // Display - Newsreader
  static TextStyle displayLarge = GoogleFonts.newsreader(
    fontSize: 57,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.25,
    height: 1.12,
  );

  static TextStyle displayMedium = GoogleFonts.newsreader(
    fontSize: 45,
    fontWeight: FontWeight.w700,
    height: 1.16,
  );

  static TextStyle displaySmall = GoogleFonts.newsreader(
    fontSize: 36,
    fontWeight: FontWeight.w700,
    height: 1.22,
  );

  // Headline - Newsreader
  static TextStyle headlineLarge = GoogleFonts.newsreader(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 1.25,
  );

  static TextStyle headlineMedium = GoogleFonts.newsreader(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    height: 1.29,
  );

  static TextStyle headlineSmall = GoogleFonts.newsreader(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.33,
  );

  // Title - Inter
  static TextStyle titleLarge = GoogleFonts.inter(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    height: 1.27,
  );

  static TextStyle titleMedium = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.15,
    height: 1.5,
  );

  static TextStyle titleSmall = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    height: 1.43,
  );

  // Body - Inter
  static TextStyle bodyLarge = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.5,
    height: 1.5,
  );

  static TextStyle bodyMedium = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
    height: 1.43,
  );

  static TextStyle bodySmall = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
    height: 1.33,
  );

  // Label - Inter
  static TextStyle labelLarge = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    height: 1.43,
  );

  static TextStyle labelMedium = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    height: 1.33,
  );

  static TextStyle labelSmall = GoogleFonts.inter(
    fontSize: 10,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.5,
    height: 1.6,
  );
}
