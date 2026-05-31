import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../utils/app_colors.dart';

/// CitiGuide theme — Plus Jakarta Sans, deep-navy primary, light surfaces.
class AppTheme {
  AppTheme._();

  static ThemeData get light {
    final base = ThemeData.light(useMaterial3: true);
    final textTheme = GoogleFonts.plusJakartaSansTextTheme(base.textTheme)
        .apply(bodyColor: AppColors.ink, displayColor: AppColors.ink);

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.bg,
      primaryColor: AppColors.primary,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.coral,
        surface: AppColors.bg,
        error: AppColors.danger,
        onPrimary: Colors.white,
        onSurface: AppColors.ink,
      ),
      textTheme: textTheme,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: AppColors.ink,
        surfaceTintColor: Colors.transparent,
      ),
      dividerColor: AppColors.line,
    );
  }

  /// Display / title text styles used throughout (letter-spacing tuned).
  static TextStyle display(double size, {Color? color, double? height}) =>
      GoogleFonts.plusJakartaSans(
        fontSize: size,
        fontWeight: FontWeight.w800,
        letterSpacing: -size * 0.02,
        height: height,
        color: color ?? AppColors.ink,
      );

  static TextStyle title(double size, {Color? color, double? height}) =>
      GoogleFonts.plusJakartaSans(
        fontSize: size,
        fontWeight: FontWeight.w700,
        letterSpacing: -size * 0.01,
        height: height,
        color: color ?? AppColors.ink,
      );

  static TextStyle body(
    double size, {
    Color? color,
    FontWeight weight = FontWeight.w500,
    double? height,
  }) =>
      GoogleFonts.plusJakartaSans(
        fontSize: size,
        fontWeight: weight,
        height: height,
        color: color ?? AppColors.ink,
      );
}
