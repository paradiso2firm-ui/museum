import 'package:flutter/material.dart';

/// Material 3 기반 커스텀 컬러 시스템
/// DESIGN.md의 "Surface Hierarchy & Nesting" 원칙을 따름
abstract final class AppColors {
  // Primary
  static const primary = Color(0xFFA43C12);
  static const onPrimary = Color(0xFFFFFFFF);
  static const primaryContainer = Color(0xFFFF7F50);
  static const onPrimaryContainer = Color(0xFF6C2000);
  static const primaryFixed = Color(0xFFFFDBCF);
  static const primaryFixedDim = Color(0xFFFFB59C);
  static const onPrimaryFixed = Color(0xFF380C00);
  static const onPrimaryFixedVariant = Color(0xFF822800);

  // Secondary
  static const secondary = Color(0xFF88503C);
  static const onSecondary = Color(0xFFFFFFFF);
  static const secondaryContainer = Color(0xFFFFB59C);
  static const onSecondaryContainer = Color(0xFF7A4431);
  static const secondaryFixed = Color(0xFFFFDBCF);
  static const secondaryFixedDim = Color(0xFFFFB59C);
  static const onSecondaryFixed = Color(0xFF360F02);
  static const onSecondaryFixedVariant = Color(0xFF6C3926);

  // Tertiary
  static const tertiary = Color(0xFF006970);
  static const onTertiary = Color(0xFFFFFFFF);
  static const tertiaryContainer = Color(0xFF00B5C0);
  static const onTertiaryContainer = Color(0xFF004145);
  static const tertiaryFixed = Color(0xFF7AF4FF);
  static const tertiaryFixedDim = Color(0xFF4DD9E4);
  static const onTertiaryFixed = Color(0xFF002022);
  static const onTertiaryFixedVariant = Color(0xFF004F54);

  // Error
  static const error = Color(0xFFBA1A1A);
  static const onError = Color(0xFFFFFFFF);
  static const errorContainer = Color(0xFFFFDAD6);
  static const onErrorContainer = Color(0xFF93000A);

  // Surface Hierarchy (Level 0 → Level 2)
  static const surface = Color(0xFFF9F9F9);
  static const surfaceBright = Color(0xFFF9F9F9);
  static const surfaceDim = Color(0xFFDADADA);
  static const surfaceContainerLowest = Color(0xFFFFFFFF);
  static const surfaceContainerLow = Color(0xFFF3F3F3);
  static const surfaceContainer = Color(0xFFEEEEEE);
  static const surfaceContainerHigh = Color(0xFFE8E8E8);
  static const surfaceContainerHighest = Color(0xFFE2E2E2);
  static const surfaceVariant = Color(0xFFE2E2E2);
  static const surfaceTint = Color(0xFFA43C12);

  // On Surface
  static const onSurface = Color(0xFF1A1C1C);
  static const onSurfaceVariant = Color(0xFF57423B);
  static const onBackground = Color(0xFF1A1C1C);
  static const background = Color(0xFFF9F9F9);

  // Outline
  static const outline = Color(0xFF8B7169);
  static const outlineVariant = Color(0xFFDEC0B6);

  // Inverse
  static const inverseSurface = Color(0xFF2F3131);
  static const inverseOnSurface = Color(0xFFF1F1F1);
  static const inversePrimary = Color(0xFFFFB59C);

  // Ambient Shadow (6% opacity of onSurface)
  static Color ambientShadow = onSurface.withValues(alpha: 0.06);
}
