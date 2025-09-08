import 'package:flutter/material.dart';
import 'package:applicazione_mental_coach/design_system/tokens/app_colors.dart';

class AppTypography {
  AppTypography._();

  // Font Family - Using system default for now
  static const String fontFamily = 'Roboto'; // Will fallback to system font

  // Font Weights
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;

  // Text Styles - Light Theme
  static TextStyle get h1 => const TextStyle(
        fontFamily: fontFamily,
        fontSize: 28,
        fontWeight: semiBold,
        color: AppColors.textPrimary,
        height: 1.2,
      );

  static TextStyle get h2 => const TextStyle(
        fontFamily: fontFamily,
        fontSize: 24,
        fontWeight: semiBold,
        color: AppColors.textPrimary,
        height: 1.25,
      );

  static TextStyle get h3 => const TextStyle(
        fontFamily: fontFamily,
        fontSize: 20,
        fontWeight: medium,
        color: AppColors.textPrimary,
        height: 1.3,
      );

  static TextStyle get h4 => const TextStyle(
        fontFamily: fontFamily,
        fontSize: 18,
        fontWeight: medium,
        color: AppColors.textPrimary,
        height: 1.35,
      );

  static TextStyle get bodyLarge => const TextStyle(
        fontFamily: fontFamily,
        fontSize: 16,
        fontWeight: regular,
        color: AppColors.textPrimary,
        height: 1.5,
      );

  static TextStyle get bodyMedium => const TextStyle(
        fontFamily: fontFamily,
        fontSize: 14,
        fontWeight: regular,
        color: AppColors.textPrimary,
        height: 1.4,
      );

  static TextStyle get bodySmall => const TextStyle(
        fontFamily: fontFamily,
        fontSize: 12,
        fontWeight: regular,
        color: AppColors.grey600,
        height: 1.35,
      );

  static TextStyle get buttonLarge => const TextStyle(
        fontFamily: fontFamily,
        fontSize: 16,
        fontWeight: medium,
        color: AppColors.white,
        height: 1.25,
      );

  static TextStyle get buttonMedium => const TextStyle(
        fontFamily: fontFamily,
        fontSize: 14,
        fontWeight: medium,
        color: AppColors.white,
        height: 1.25,
      );

  static TextStyle get caption => const TextStyle(
        fontFamily: fontFamily,
        fontSize: 12,
        fontWeight: regular,
        color: AppColors.grey500,
        height: 1.3,
      );

  static TextStyle get overline => const TextStyle(
        fontFamily: fontFamily,
        fontSize: 10,
        fontWeight: medium,
        color: AppColors.grey500,
        height: 1.2,
        letterSpacing: 1.5,
      );

  // Chat Specific Styles
  static TextStyle get chatBubbleUser => const TextStyle(
        fontFamily: fontFamily,
        fontSize: 16,
        fontWeight: regular,
        color: AppColors.userBubbleText,
        height: 1.4,
      );

  static TextStyle get chatBubbleAI => const TextStyle(
        fontFamily: fontFamily,
        fontSize: 16,
        fontWeight: regular,
        color: AppColors.aiBubbleText,
        height: 1.4,
      );

  static TextStyle get chatTimestamp => const TextStyle(
        fontFamily: fontFamily,
        fontSize: 10,
        fontWeight: regular,
        color: AppColors.grey500,
        height: 1.2,
      );

  // Dark Theme Variants
  static TextStyle get h1Dark => h1.copyWith(color: AppColors.darkTextPrimary);
  static TextStyle get h2Dark => h2.copyWith(color: AppColors.darkTextPrimary);
  static TextStyle get h3Dark => h3.copyWith(color: AppColors.darkTextPrimary);
  static TextStyle get h4Dark => h4.copyWith(color: AppColors.darkTextPrimary);
  static TextStyle get bodyLargeDark => bodyLarge.copyWith(color: AppColors.darkTextPrimary);
  static TextStyle get bodyMediumDark => bodyMedium.copyWith(color: AppColors.darkTextPrimary);
  static TextStyle get bodySmallDark => bodySmall.copyWith(color: AppColors.darkTextSecondary);
  static TextStyle get captionDark => caption.copyWith(color: AppColors.darkTextSecondary);
}