import 'package:flutter/material.dart';
import 'package:applicazione_mental_coach/design_system/tokens/app_colors.dart';

class AppTypography {
  AppTypography._();

  // Font Family - Using system default for iOS-style look
  static const String fontFamily = '.AppleSystemUIFont'; // iOS system font

  // Font Weights - iOS style
  static const FontWeight ultraLight = FontWeight.w100;
  static const FontWeight thin = FontWeight.w200;
  static const FontWeight light = FontWeight.w300;
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;
  static const FontWeight heavy = FontWeight.w800;
  static const FontWeight black = FontWeight.w900;

  // Text Styles - Light Theme - iOS Style
  static TextStyle get headingLarge => const TextStyle(
        fontFamily: fontFamily,
        fontSize: 34,
        fontWeight: bold,
        color: AppColors.textPrimary,
        height: 1.24,
        letterSpacing: -0.5,
      );

  static TextStyle get headingMedium => const TextStyle(
        fontFamily: fontFamily,
        fontSize: 22,
        fontWeight: semiBold,
        color: AppColors.textPrimary,
        height: 1.27,
        letterSpacing: -0.2,
      );

  static TextStyle get largeTitle => const TextStyle(
        fontFamily: fontFamily,
        fontSize: 34,
        fontWeight: bold,
        color: AppColors.textPrimary,
        height: 1.24,
        letterSpacing: -0.5,
      );

  static TextStyle get h1 => const TextStyle(
        fontFamily: fontFamily,
        fontSize: 28,
        fontWeight: bold,
        color: AppColors.textPrimary,
        height: 1.24,
        letterSpacing: -0.3,
      );

  static TextStyle get h2 => const TextStyle(
        fontFamily: fontFamily,
        fontSize: 22,
        fontWeight: bold,
        color: AppColors.textPrimary,
        height: 1.27,
        letterSpacing: -0.2,
      );

  static TextStyle get h3 => const TextStyle(
        fontFamily: fontFamily,
        fontSize: 20,
        fontWeight: semiBold,
        color: AppColors.textPrimary,
        height: 1.3,
        letterSpacing: -0.1,
      );

  static TextStyle get h4 => const TextStyle(
        fontFamily: fontFamily,
        fontSize: 17,
        fontWeight: semiBold,
        color: AppColors.textPrimary,
        height: 1.35,
        letterSpacing: -0.05,
      );

  static TextStyle get bodyLarge => const TextStyle(
        fontFamily: fontFamily,
        fontSize: 17,
        fontWeight: regular,
        color: AppColors.textPrimary,
        height: 1.44,
        letterSpacing: -0.02,
      );

  static TextStyle get body => const TextStyle(
        fontFamily: fontFamily,
        fontSize: 15,
        fontWeight: regular,
        color: AppColors.textPrimary,
        height: 1.47,
        letterSpacing: -0.01,
      );

  static TextStyle get bodyMedium => const TextStyle(
        fontFamily: fontFamily,
        fontSize: 15,
        fontWeight: regular,
        color: AppColors.textPrimary,
        height: 1.47,
        letterSpacing: -0.01,
      );

  static TextStyle get bodySmall => const TextStyle(
        fontFamily: fontFamily,
        fontSize: 13,
        fontWeight: regular,
        color: AppColors.grey600,
        height: 1.38,
      );

  static TextStyle get buttonLarge => const TextStyle(
        fontFamily: fontFamily,
        fontSize: 17,
        fontWeight: semiBold,
        color: AppColors.white,
        height: 1.29,
        letterSpacing: -0.02,
      );

  static TextStyle get buttonMedium => const TextStyle(
        fontFamily: fontFamily,
        fontSize: 15,
        fontWeight: semiBold,
        color: AppColors.white,
        height: 1.33,
        letterSpacing: -0.01,
      );

  static TextStyle get callout => const TextStyle(
        fontFamily: fontFamily,
        fontSize: 16,
        fontWeight: regular,
        color: AppColors.textPrimary,
        height: 1.31,
        letterSpacing: -0.02,
      );

  static TextStyle get subheadline => const TextStyle(
        fontFamily: fontFamily,
        fontSize: 15,
        fontWeight: regular,
        color: AppColors.textPrimary,
        height: 1.33,
        letterSpacing: -0.01,
      );

  static TextStyle get footnote => const TextStyle(
        fontFamily: fontFamily,
        fontSize: 13,
        fontWeight: regular,
        color: AppColors.grey600,
        height: 1.38,
      );

  static TextStyle get caption1 => const TextStyle(
        fontFamily: fontFamily,
        fontSize: 12,
        fontWeight: regular,
        color: AppColors.grey600,
        height: 1.33,
      );

  static TextStyle get caption => const TextStyle(
        fontFamily: fontFamily,
        fontSize: 12,
        fontWeight: regular,
        color: AppColors.grey500,
        height: 1.33,
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