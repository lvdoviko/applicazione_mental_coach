import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:applicazione_mental_coach/design_system/tokens/app_colors.dart';
import 'package:applicazione_mental_coach/design_system/tokens/app_typography.dart';
import 'package:applicazione_mental_coach/design_system/tokens/app_spacing.dart';
import 'package:applicazione_mental_coach/design_system/tokens/app_animations.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: AppTypography.fontFamily,
      colorScheme: _lightColorScheme,
      textTheme: _textTheme,
      appBarTheme: _appBarTheme,
      elevatedButtonTheme: _elevatedButtonTheme,
      textButtonTheme: _textButtonTheme,
      outlinedButtonTheme: _outlinedButtonTheme,
      inputDecorationTheme: _inputDecorationTheme,
      cardTheme: _cardTheme,
      chipTheme: _chipTheme,
      floatingActionButtonTheme: _fabTheme,
      bottomNavigationBarTheme: _bottomNavTheme,
      dividerTheme: _dividerTheme,
      switchTheme: _switchTheme,
      scaffoldBackgroundColor: AppColors.background,
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: AppTypography.fontFamily,
      colorScheme: _darkColorScheme,
      textTheme: _darkTextTheme,
      appBarTheme: _darkAppBarTheme,
      elevatedButtonTheme: _darkElevatedButtonTheme,
      textButtonTheme: _darkTextButtonTheme,
      outlinedButtonTheme: _darkOutlinedButtonTheme,
      inputDecorationTheme: _darkInputDecorationTheme,
      cardTheme: _darkCardTheme,
      chipTheme: _darkChipTheme,
      floatingActionButtonTheme: _darkFabTheme,
      bottomNavigationBarTheme: _darkBottomNavTheme,
      dividerTheme: _darkDividerTheme,
      switchTheme: _darkSwitchTheme,
      scaffoldBackgroundColor: AppColors.darkBackground,
    );
  }

  // Lo-Fi Minimal Color Schemes
  static const ColorScheme _lightColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.primary,
    onPrimary: AppColors.white,
    secondary: AppColors.secondary,
    onSecondary: AppColors.textPrimary,
    tertiary: AppColors.accent,
    onTertiary: AppColors.textPrimary,
    error: AppColors.error,
    onError: AppColors.textPrimary,
    surface: AppColors.surface,
    onSurface: AppColors.textPrimary,
    surfaceContainerHighest: AppColors.surfaceVariant,
    onSurfaceVariant: AppColors.textSecondary,
    outline: AppColors.border,
    outlineVariant: AppColors.grey200,
  );

  static const ColorScheme _darkColorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: AppColors.primary,
    onPrimary: AppColors.white,
    secondary: AppColors.secondary,
    onSecondary: AppColors.darkTextPrimary,
    tertiary: AppColors.accent,
    onTertiary: AppColors.darkTextPrimary,
    error: AppColors.error,
    onError: AppColors.white,
    surface: AppColors.darkSurface,
    onSurface: AppColors.darkTextPrimary,
    surfaceContainerHighest: AppColors.darkSurfaceVariant,
    onSurfaceVariant: AppColors.darkTextSecondary,
    outline: AppColors.darkBorder,
    outlineVariant: AppColors.grey700,
  );

  // Text Themes - iOS Style
  static TextTheme get _textTheme => TextTheme(
        displayLarge: AppTypography.largeTitle,
        headlineLarge: AppTypography.h1,
        headlineMedium: AppTypography.h2,
        headlineSmall: AppTypography.h3,
        titleLarge: AppTypography.h4,
        titleMedium: AppTypography.callout,
        titleSmall: AppTypography.subheadline,
        bodyLarge: AppTypography.bodyLarge,
        bodyMedium: AppTypography.bodyMedium,
        bodySmall: AppTypography.footnote,
        labelLarge: AppTypography.buttonLarge,
        labelMedium: AppTypography.buttonMedium,
        labelSmall: AppTypography.caption1,
      );

  static TextTheme get _darkTextTheme => TextTheme(
        headlineLarge: AppTypography.h1Dark,
        headlineMedium: AppTypography.h2Dark,
        headlineSmall: AppTypography.h3Dark,
        titleLarge: AppTypography.h4Dark,
        bodyLarge: AppTypography.bodyLargeDark,
        bodyMedium: AppTypography.bodyMediumDark,
        bodySmall: AppTypography.bodySmallDark,
        labelLarge: AppTypography.buttonLarge,
        labelMedium: AppTypography.buttonMedium,
        labelSmall: AppTypography.captionDark,
      );

  // Component Themes
  static AppBarTheme get _appBarTheme => AppBarTheme(
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: AppTypography.h3,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      );

  static AppBarTheme get _darkAppBarTheme => AppBarTheme(
        backgroundColor: AppColors.darkSurface,
        foregroundColor: AppColors.darkTextPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: AppTypography.h3Dark,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      );

  static ElevatedButtonThemeData get _elevatedButtonTheme =>
      ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          textStyle: AppTypography.buttonLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppBorderRadius.button),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.buttonPadding * 2,
            vertical: AppSpacing.buttonPadding,
          ),
          elevation: 0,
          minimumSize: const Size(0, AppSpacing.composerMinHeight),
        ),
      );

  static ElevatedButtonThemeData get _darkElevatedButtonTheme =>
      ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          textStyle: AppTypography.buttonLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppBorderRadius.button),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.buttonPadding * 2,
            vertical: AppSpacing.buttonPadding,
          ),
          elevation: 0,
          minimumSize: const Size(0, AppSpacing.composerMinHeight),
        ),
      );

  static TextButtonThemeData get _textButtonTheme => TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: AppTypography.buttonMedium,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppBorderRadius.button),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.md,
          ),
          minimumSize: const Size(0, 44),
        ),
      );

  static TextButtonThemeData get _darkTextButtonTheme => TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: AppTypography.buttonMedium,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppBorderRadius.button),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.md,
          ),
          minimumSize: const Size(0, 44),
        ),
      );

  static OutlinedButtonThemeData get _outlinedButtonTheme =>
      OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: AppTypography.buttonMedium,
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppBorderRadius.button),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.buttonPadding * 2,
            vertical: AppSpacing.buttonPadding,
          ),
          minimumSize: const Size(0, AppSpacing.composerMinHeight),
        ),
      );

  static OutlinedButtonThemeData get _darkOutlinedButtonTheme =>
      OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: AppTypography.buttonMedium,
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppBorderRadius.button),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.buttonPadding * 2,
            vertical: AppSpacing.buttonPadding,
          ),
          minimumSize: const Size(0, AppSpacing.composerMinHeight),
        ),
      );

  static InputDecorationTheme get _inputDecorationTheme =>
      InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppBorderRadius.composer),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppBorderRadius.composer),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppBorderRadius.composer),
          borderSide: const BorderSide(color: AppColors.borderFocus, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppBorderRadius.composer),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.composerPadding,
          vertical: AppSpacing.composerPadding,
        ),
        hintStyle: AppTypography.composerPlaceholder,
      );

  static InputDecorationTheme get _darkInputDecorationTheme =>
      InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkSurfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppBorderRadius.composer),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppBorderRadius.composer),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppBorderRadius.composer),
          borderSide: const BorderSide(color: AppColors.borderFocus, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppBorderRadius.composer),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.composerPadding,
          vertical: AppSpacing.composerPadding,
        ),
        hintStyle: AppTypography.composerPlaceholder.copyWith(
          color: AppColors.darkTextSecondary,
        ),
      );

  static CardThemeData get _cardTheme => CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shadowColor: AppColors.textPrimary.withOpacity(0.08),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppBorderRadius.card),
        ),
        margin: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screenPadding,
          vertical: AppSpacing.md,
        ),
      );

  static CardThemeData get _darkCardTheme => CardThemeData(
        color: AppColors.darkSurface,
        elevation: 0,
        shadowColor: AppColors.darkTextPrimary.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppBorderRadius.card),
        ),
        margin: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screenPadding,
          vertical: AppSpacing.md,
        ),
      );

  static ChipThemeData get _chipTheme => ChipThemeData(
        backgroundColor: AppColors.surfaceVariant,
        selectedColor: AppColors.primary,
        labelStyle: AppTypography.bodySmall.copyWith(color: AppColors.textPrimary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppBorderRadius.chip),
        ),
        side: BorderSide.none,
        showCheckmark: false,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.chipPaddingHorizontal,
          vertical: AppSpacing.chipPaddingVertical,
        ),
      );

  static ChipThemeData get _darkChipTheme => ChipThemeData(
        backgroundColor: AppColors.darkSurfaceVariant,
        selectedColor: AppColors.primary,
        labelStyle: AppTypography.bodySmall.copyWith(color: AppColors.darkTextPrimary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppBorderRadius.chip),
        ),
        side: BorderSide.none,
        showCheckmark: false,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.chipPaddingHorizontal,
          vertical: AppSpacing.chipPaddingVertical,
        ),
      );

  static FloatingActionButtonThemeData get _fabTheme =>
      const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        elevation: 0,
      );

  static FloatingActionButtonThemeData get _darkFabTheme =>
      const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        elevation: 0,
      );

  static BottomNavigationBarThemeData get _bottomNavTheme =>
      BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: AppTypography.caption,
        unselectedLabelStyle: AppTypography.caption,
        elevation: 0,
      );

  static BottomNavigationBarThemeData get _darkBottomNavTheme =>
      BottomNavigationBarThemeData(
        backgroundColor: AppColors.darkSurface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.darkTextSecondary,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: AppTypography.captionDark,
        unselectedLabelStyle: AppTypography.captionDark,
        elevation: 0,
      );

  static DividerThemeData get _dividerTheme => const DividerThemeData(
        color: AppColors.border,
        thickness: 1,
        space: 1,
      );

  static DividerThemeData get _darkDividerTheme => const DividerThemeData(
        color: AppColors.darkBorder,
        thickness: 1,
        space: 1,
      );

  static SwitchThemeData get _switchTheme => SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary;
          }
          return AppColors.grey400;
        }),
      );

  static SwitchThemeData get _darkSwitchTheme => SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary;
          }
          return AppColors.grey400;
        }),
      );
}