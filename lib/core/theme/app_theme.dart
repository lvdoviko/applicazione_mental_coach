import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:applicazione_mental_coach/design_system/tokens/app_colors.dart';
import 'package:applicazione_mental_coach/design_system/tokens/app_typography.dart';

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

  // Color Schemes
  static const ColorScheme _lightColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.deepTeal,
    onPrimary: AppColors.white,
    secondary: AppColors.softBlue,
    onSecondary: AppColors.white,
    tertiary: AppColors.lime,
    onTertiary: AppColors.textPrimary,
    error: AppColors.error,
    onError: AppColors.white,
    surface: AppColors.white,
    onSurface: AppColors.textPrimary,
    surfaceContainerHighest: AppColors.grey100,
    onSurfaceVariant: AppColors.grey600,
    outline: AppColors.grey300,
    outlineVariant: AppColors.grey200,
  );

  static const ColorScheme _darkColorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: AppColors.softBlue,
    onPrimary: AppColors.white,
    secondary: AppColors.lime,
    onSecondary: AppColors.textPrimary,
    tertiary: AppColors.orange,
    onTertiary: AppColors.white,
    error: AppColors.error,
    onError: AppColors.white,
    surface: AppColors.darkSurface,
    onSurface: AppColors.darkTextPrimary,
    surfaceContainerHighest: AppColors.grey800,
    onSurfaceVariant: AppColors.darkTextSecondary,
    outline: AppColors.grey600,
    outlineVariant: AppColors.grey700,
  );

  // Text Themes
  static TextTheme get _textTheme => TextTheme(
        headlineLarge: AppTypography.h1,
        headlineMedium: AppTypography.h2,
        headlineSmall: AppTypography.h3,
        titleLarge: AppTypography.h4,
        bodyLarge: AppTypography.bodyLarge,
        bodyMedium: AppTypography.bodyMedium,
        bodySmall: AppTypography.bodySmall,
        labelLarge: AppTypography.buttonLarge,
        labelMedium: AppTypography.buttonMedium,
        labelSmall: AppTypography.caption,
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
        scrolledUnderElevation: 1,
        titleTextStyle: AppTypography.h3,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      );

  static AppBarTheme get _darkAppBarTheme => AppBarTheme(
        backgroundColor: AppColors.darkSurface,
        foregroundColor: AppColors.darkTextPrimary,
        elevation: 0,
        scrolledUnderElevation: 1,
        titleTextStyle: AppTypography.h3Dark,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      );

  static ElevatedButtonThemeData get _elevatedButtonTheme =>
      ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.deepTeal,
          foregroundColor: AppColors.white,
          textStyle: AppTypography.buttonLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          elevation: 0,
        ),
      );

  static ElevatedButtonThemeData get _darkElevatedButtonTheme =>
      ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.softBlue,
          foregroundColor: AppColors.white,
          textStyle: AppTypography.buttonLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          elevation: 0,
        ),
      );

  static TextButtonThemeData get _textButtonTheme => TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.deepTeal,
          textStyle: AppTypography.buttonMedium,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );

  static TextButtonThemeData get _darkTextButtonTheme => TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.softBlue,
          textStyle: AppTypography.buttonMedium,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );

  static OutlinedButtonThemeData get _outlinedButtonTheme =>
      OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.deepTeal,
          textStyle: AppTypography.buttonMedium,
          side: const BorderSide(color: AppColors.deepTeal),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      );

  static OutlinedButtonThemeData get _darkOutlinedButtonTheme =>
      OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.softBlue,
          textStyle: AppTypography.buttonMedium,
          side: const BorderSide(color: AppColors.softBlue),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      );

  static InputDecorationTheme get _inputDecorationTheme =>
      InputDecorationTheme(
        filled: true,
        fillColor: AppColors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.grey300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.grey300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.deepTeal, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        hintStyle: AppTypography.bodyMedium.copyWith(color: AppColors.grey500),
      );

  static InputDecorationTheme get _darkInputDecorationTheme =>
      InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.grey600),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.grey600),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.softBlue, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        hintStyle:
            AppTypography.bodyMedium.copyWith(color: AppColors.darkTextSecondary),
      );

  static CardTheme get _cardTheme => CardTheme(
        color: AppColors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      );

  static CardTheme get _darkCardTheme => CardTheme(
        color: AppColors.darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      );

  static ChipThemeData get _chipTheme => ChipThemeData(
        backgroundColor: AppColors.grey100,
        selectedColor: AppColors.deepTeal,
        labelStyle: AppTypography.bodySmall,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      );

  static ChipThemeData get _darkChipTheme => ChipThemeData(
        backgroundColor: AppColors.grey700,
        selectedColor: AppColors.softBlue,
        labelStyle: AppTypography.bodySmall.copyWith(color: AppColors.darkTextPrimary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      );

  static FloatingActionButtonThemeData get _fabTheme =>
      const FloatingActionButtonThemeData(
        backgroundColor: AppColors.deepTeal,
        foregroundColor: AppColors.white,
      );

  static FloatingActionButtonThemeData get _darkFabTheme =>
      const FloatingActionButtonThemeData(
        backgroundColor: AppColors.softBlue,
        foregroundColor: AppColors.white,
      );

  static BottomNavigationBarThemeData get _bottomNavTheme =>
      BottomNavigationBarThemeData(
        backgroundColor: AppColors.white,
        selectedItemColor: AppColors.deepTeal,
        unselectedItemColor: AppColors.grey500,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: AppTypography.caption,
        unselectedLabelStyle: AppTypography.caption,
      );

  static BottomNavigationBarThemeData get _darkBottomNavTheme =>
      BottomNavigationBarThemeData(
        backgroundColor: AppColors.darkSurface,
        selectedItemColor: AppColors.softBlue,
        unselectedItemColor: AppColors.darkTextSecondary,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: AppTypography.captionDark,
        unselectedLabelStyle: AppTypography.captionDark,
      );

  static DividerThemeData get _dividerTheme => const DividerThemeData(
        color: AppColors.grey200,
        thickness: 1,
        space: 1,
      );

  static DividerThemeData get _darkDividerTheme => const DividerThemeData(
        color: AppColors.grey700,
        thickness: 1,
        space: 1,
      );

  static SwitchThemeData get _switchTheme => SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.deepTeal;
          }
          return AppColors.grey400;
        }),
      );

  static SwitchThemeData get _darkSwitchTheme => SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.softBlue;
          }
          return AppColors.grey400;
        }),
      );
}