import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTypography {
  const AppTypography._();

  static const String displayFamily = 'Sora';
  static const String bodyFamily = 'Inter';

  static TextTheme textTheme(MomentumPalette palette) {
    final display = displayFamily;
    final body = bodyFamily;
    return TextTheme(
      displayLarge: TextStyle(
        fontFamily: display,
        fontSize: 40,
        fontWeight: FontWeight.w700,
        letterSpacing: -1.2,
        color: palette.textPrimary,
        height: 1.1,
      ),
      displayMedium: TextStyle(
        fontFamily: display,
        fontSize: 34,
        fontWeight: FontWeight.w700,
        letterSpacing: -1,
        color: palette.textPrimary,
        height: 1.12,
      ),
      displaySmall: TextStyle(
        fontFamily: display,
        fontSize: 28,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.8,
        color: palette.textPrimary,
        height: 1.15,
      ),
      headlineLarge: TextStyle(
        fontFamily: display,
        fontSize: 26,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.6,
        color: palette.textPrimary,
        height: 1.2,
      ),
      headlineMedium: TextStyle(
        fontFamily: display,
        fontSize: 22,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.4,
        color: palette.textPrimary,
        height: 1.25,
      ),
      headlineSmall: TextStyle(
        fontFamily: display,
        fontSize: 19,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.3,
        color: palette.textPrimary,
        height: 1.3,
      ),
      titleLarge: TextStyle(
        fontFamily: display,
        fontSize: 17,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
        color: palette.textPrimary,
        height: 1.35,
      ),
      titleMedium: TextStyle(
        fontFamily: display,
        fontSize: 15,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.1,
        color: palette.textPrimary,
        height: 1.4,
      ),
      titleSmall: TextStyle(
        fontFamily: body,
        fontSize: 13.5,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.1,
        color: palette.textPrimary,
        height: 1.4,
      ),
      bodyLarge: TextStyle(
        fontFamily: body,
        fontSize: 15.5,
        fontWeight: FontWeight.w400,
        color: palette.textPrimary,
        height: 1.5,
      ),
      bodyMedium: TextStyle(
        fontFamily: body,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: palette.textPrimary,
        height: 1.5,
      ),
      bodySmall: TextStyle(
        fontFamily: body,
        fontSize: 12.5,
        fontWeight: FontWeight.w400,
        color: palette.textSecondary,
        height: 1.45,
      ),
      labelLarge: TextStyle(
        fontFamily: body,
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: palette.textPrimary,
        height: 1.4,
      ),
      labelMedium: TextStyle(
        fontFamily: body,
        fontSize: 11.5,
        fontWeight: FontWeight.w500,
        color: palette.textSecondary,
        height: 1.4,
      ),
      labelSmall: TextStyle(
        fontFamily: body,
        fontSize: 10.5,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.4,
        color: palette.textTertiary,
        height: 1.35,
      ),
    );
  }
}
