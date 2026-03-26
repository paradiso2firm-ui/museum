import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

void showDevSnackBar(BuildContext context, [String feature = '이 기능']) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(
          '$feature은(는) 개발중입니다',
          style: AppTypography.labelMedium.copyWith(
            color: AppColors.surfaceContainerLowest,
          ),
        ),
        backgroundColor: AppColors.inverseSurface,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 100),
        duration: const Duration(seconds: 2),
      ),
    );
}
