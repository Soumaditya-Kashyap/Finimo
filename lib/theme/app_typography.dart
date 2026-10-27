import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTypography {
  AppTypography._();

  // Space Grotesk - Expressive Numerals & Headers
  static TextStyle displayLg({Color color = AppColors.textPrimary}) =>
      GoogleFonts.spaceGrotesk(
        fontSize: 36,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.03 * 36,
        color: color,
        height: 1.2,
      );

  static TextStyle headlineMd({Color color = AppColors.textPrimary}) =>
      GoogleFonts.spaceGrotesk(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.01 * 22,
        color: color,
      );

  static TextStyle headlineSm({
    Color color = AppColors.textPrimary,
    FontWeight fontWeight = FontWeight.w600,
  }) =>
      GoogleFonts.spaceGrotesk(
        fontSize: 18,
        fontWeight: fontWeight,
        letterSpacing: 0,
        color: color,
      );

  // Manrope - Functional Body & Labels
  static TextStyle bodyLg({Color color = AppColors.textPrimary}) =>
      GoogleFonts.manrope(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        letterSpacing: -0.01 * 16,
        color: color,
      );

  static TextStyle bodyMd({
    Color color = AppColors.textPrimary,
    FontWeight fontWeight = FontWeight.w400,
  }) =>
      GoogleFonts.manrope(
        fontSize: 14,
        fontWeight: fontWeight,
        letterSpacing: 0,
        color: color,
      );

  static TextStyle bodySm({Color color = AppColors.textMuted}) =>
      GoogleFonts.manrope(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.01 * 12,
        color: color,
      );

  static TextStyle labelLg({Color color = AppColors.textPrimary}) =>
      GoogleFonts.manrope(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.02 * 14,
        color: color,
      );

  static TextStyle labelMd({
    Color color = AppColors.textPrimary,
    FontWeight fontWeight = FontWeight.w500,
  }) =>
      GoogleFonts.manrope(
        fontSize: 12,
        fontWeight: fontWeight,
        letterSpacing: 0.04 * 12,
        color: color,
      );

  static TextStyle labelSm({
    Color color = AppColors.textMuted,
    FontWeight fontWeight = FontWeight.w700,
  }) =>
      GoogleFonts.manrope(
        fontSize: 10,
        fontWeight: fontWeight,
        letterSpacing: 0.08 * 10,
        color: color,
      );

  static TextStyle caption({
    Color color = AppColors.textMuted,
    FontWeight fontWeight = FontWeight.w400,
  }) =>
      GoogleFonts.manrope(
        fontSize: 11,
        fontWeight: fontWeight,
        letterSpacing: 0.02 * 11,
        color: color,
      );
}
