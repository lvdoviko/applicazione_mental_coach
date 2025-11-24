import 'package:flutter/material.dart';
import 'package:applicazione_mental_coach/design_system/tokens/app_colors.dart';

class AppTypography {
  AppTypography._();

  // Font Family - Inter for cross-platform consistency, with system fallbacks
  static const String fontFamily = 'Inter';
  static const List<String> fontFallbacks = ['-apple-system', 'BlinkMacSystemFont', 'Roboto', 'sans-serif'];

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

  // Text Styles - Performance Design
  static TextStyle get headingLarge => const TextStyle(
        fontFamily: fontFamily,
        fontSize: 34,
        fontWeight: bold,
        color: AppColors.textPrimary,
        height: 1.3,
        letterSpacing: -0.025,
      );

  static TextStyle get headingMedium => const TextStyle(
        fontFamily: fontFamily,
        fontSize: 24,
        fontWeight: semiBold,
        color: AppColors.textPrimary,
        height: 1.4,
        letterSpacing: 0,
      );

  static TextStyle get largeTitle => const TextStyle(
        fontFamily: fontFamily,
        fontSize: 34,
        fontWeight: bold,
        color: AppColors.textPrimary,
        height: 1.3,
        letterSpacing: -0.5,
      );

  static TextStyle get h1 => const TextStyle(
        fontFamily: fontFamily,
        fontSize: 28,
        fontWeight: bold,
        color: AppColors.textPrimary,
        height: 1.3,
        letterSpacing: -0.3,
      );

  static TextStyle get h2 => const TextStyle(
        fontFamily: fontFamily,
        fontSize: 22,
        fontWeight: bold,
        color: AppColors.textPrimary,
        height: 1.35,
        letterSpacing: -0.2,
      );

  static TextStyle get h3 => const TextStyle(
        fontFamily: fontFamily,
        fontSize: 20,
        fontWeight: semiBold,
        color: AppColors.textPrimary,
        height: 1.4,
        letterSpacing: -0.1,
      );

  static TextStyle get h4 => const TextStyle(
        fontFamily: fontFamily,
        fontSize: 17,
        fontWeight: semiBold,
        color: AppColors.textPrimary,
        height: 1.4,
        letterSpacing: -0.05,
      );

  static TextStyle get bodyLarge => const TextStyle(
        fontFamily: fontFamily,
        fontSize: 18,
        fontWeight: regular,
        color: AppColors.textPrimary,
        height: 1.6, // Optimized for readability
        letterSpacing: 0,
      );

  static TextStyle get body => const TextStyle(
        fontFamily: fontFamily,
        fontSize: 16,
        fontWeight: regular,
        color: AppColors.textPrimary,
        height: 1.5, // Increased from 1.4
        letterSpacing: 0,
      );

  static TextStyle get bodyMedium => const TextStyle(
        fontFamily: fontFamily,
        fontSize: 16,
        fontWeight: regular,
        color: AppColors.textPrimary,
        height: 1.5, // Increased from 1.4
        letterSpacing: 0,
      );

  static TextStyle get bodySmall => const TextStyle(
        fontFamily: fontFamily,
        fontSize: 14,
        fontWeight: regular,
        color: AppColors.textSecondary,
        height: 1.5,
      );

  static TextStyle get buttonLarge => const TextStyle(
        fontFamily: fontFamily,
        fontSize: 17,
        fontWeight: semiBold,
        color: AppColors.white,
        height: 1.3,
        letterSpacing: -0.02,
      );

  static TextStyle get buttonMedium => const TextStyle(
        fontFamily: fontFamily,
        fontSize: 15,
        fontWeight: semiBold,
        color: AppColors.white,
        height: 1.35,
        letterSpacing: -0.01,
      );

  static TextStyle get callout => const TextStyle(
        fontFamily: fontFamily,
        fontSize: 16,
        fontWeight: regular,
        color: AppColors.textPrimary,
        height: 1.4,
        letterSpacing: -0.02,
      );

  static TextStyle get subheadline => const TextStyle(
        fontFamily: fontFamily,
        fontSize: 15,
        fontWeight: regular,
        color: AppColors.textPrimary,
        height: 1.4,
        letterSpacing: -0.01,
      );

  static TextStyle get footnote => const TextStyle(
        fontFamily: fontFamily,
        fontSize: 13,
        fontWeight: regular,
        color: AppColors.textTertiary,
        height: 1.4,
      );

  static TextStyle get caption1 => const TextStyle(
        fontFamily: fontFamily,
        fontSize: 12,
        fontWeight: regular,
        color: AppColors.textTertiary,
        height: 1.4,
      );

  static TextStyle get caption => const TextStyle(
        fontFamily: fontFamily,
        fontSize: 12,
        fontWeight: regular,
        color: AppColors.textTertiary,
        height: 1.4,
      );

  static TextStyle get overline => const TextStyle(
        fontFamily: fontFamily,
        fontSize: 10,
        fontWeight: medium,
        color: AppColors.textTertiary,
        height: 1.2,
        letterSpacing: 1.5,
      );

  // Chat Specific Styles - Optimized for reading bubbles
  static TextStyle get chatBubbleUser => const TextStyle(
        fontFamily: fontFamily,
        fontSize: 16,
        fontWeight: regular,
        color: AppColors.userBubbleText,
        height: 1.5,
        letterSpacing: 0,
      );

  static TextStyle get chatBubbleBot => const TextStyle(
        fontFamily: fontFamily,
        fontSize: 16,
        fontWeight: regular,
        color: AppColors.botBubbleText,
        height: 1.5,
        letterSpacing: 0,
      );

  static TextStyle get chatTimestamp => const TextStyle(
        fontFamily: fontFamily,
        fontSize: 12,
        fontWeight: regular,
        color: AppColors.textTertiary,
        height: 1.3,
      );

  static TextStyle get composerPlaceholder => const TextStyle(
        fontFamily: fontFamily,
        fontSize: 16,
        fontWeight: regular,
        color: AppColors.textTertiary,
        height: 1.5,
      );

  // Legacy alias
  static TextStyle get chatBubbleAI => chatBubbleBot;

  // Dark Theme Variants (Now default, but keeping for compatibility if needed)
  static TextStyle get h1Dark => h1;
  static TextStyle get h2Dark => h2;
  static TextStyle get h3Dark => h3;
  static TextStyle get h4Dark => h4;
  static TextStyle get bodyLargeDark => bodyLarge;
  static TextStyle get bodyMediumDark => bodyMedium;
  static TextStyle get bodySmallDark => bodySmall;
  static TextStyle get captionDark => caption;
}