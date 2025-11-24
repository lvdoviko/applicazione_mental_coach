import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Performance Dark Mode Palette - Primary
  static const Color background = Color(0xFF121212); // Deep Grey for OLED
  static const Color surface = Color(0xFF1F1F1F); // Slightly lighter for cards
  static const Color surfaceVariant = Color(0xFF2C2C2C);
  
  // Action Colors
  static const Color primary = Color(0xFF2962FF); // Electric Blue / Indigo (Focus)
  static const Color primaryVariant = Color(0xFF0039CB);
  static const Color secondary = Color(0xFF00BFA5); // Teal (Energy/Growth)
  static const Color secondaryVariant = Color(0xFF008E76);
  static const Color accent = Color(0xFF64FFDA); // Neon Green/Teal accent

  // Text Colors (High Contrast for Dark Mode)
  static const Color textPrimary = Color(0xFFE6EDF3); // Off-white
  static const Color textSecondary = Color(0xFFA3A3A3); // Light Grey
  static const Color textTertiary = Color(0xFF6E7681); // Darker Grey
  
  // Borders & Dividers
  static const Color border = Color(0xFF30363D);
  static const Color borderFocus = primary;

  // Message Bubble Colors
  static const Color userBubble = Color(0xFF1A237E); // Deep Indigo
  static const Color userBubbleText = textPrimary;
  static const Color botBubble = Color(0xFF21262D); // Dark Surface
  static const Color botBubbleText = textPrimary;

  // Semantic Colors - Psychological Safety
  static const Color success = Color(0xFF00C853); // Vibrant Green
  static const Color warning = Color(0xFFFFAB00); // Amber
  static const Color error = Color(0xFFFF6D00); // Orange (instead of harsh Red)
  static const Color info = Color(0xFF2979FF); // Blue

  // Gradients
  static const LinearGradient readinessBatteryGradient = LinearGradient(
    colors: [Color(0xFFFF3D00), Color(0xFFFFC400), Color(0xFF00E676)],
    stops: [0.0, 0.5, 1.0],
  );

  static const LinearGradient flowStateGradient = LinearGradient(
    colors: [Color(0xFF2962FF), Color(0xFF00BFA5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Skeleton Loading
  static const Color skeleton = Color(0xFF2C2C2C);
  static const Color skeletonHighlight = Color(0xFF3E3E3E);

  // Legacy/Compatibility (Mapping old names to new palette where possible)
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color grey50 = Color(0xFFFAFAFA);
  static const Color grey100 = Color(0xFFF5F5F5);
  static const Color grey200 = Color(0xFFEEEEEE);
  static const Color grey300 = Color(0xFFE0E0E0);
  static const Color grey400 = Color(0xFFBDBDBD);
  static const Color grey500 = Color(0xFF9E9E9E);
  static const Color grey600 = Color(0xFF757575);
  static const Color grey700 = Color(0xFF616161);
  static const Color grey800 = Color(0xFF424242);
  static const Color grey900 = Color(0xFF212121);

  // Avatar Colors - Abstract/Neon
  static const List<Color> avatarColors = [
    primary,
    secondary,
    accent,
    Color(0xFF6200EA), // Deep Purple
    Color(0xFFC51162), // Pink
    Color(0xFFFFAB00), // Amber
    Color(0xFF00C853), // Green
    Color(0xFF2962FF), // Blue
  ];

  // Warm colors (Deprecating but keeping for safety, mapped to dark equivalents or neutrals)
  static const Color warmTerracotta = Color(0xFFD84315); // Darker orange
  static const Color warmGold = Color(0xFFFF8F00); // Darker amber
  static const Color warmOrange = Color(0xFFEF6C00);
  static const Color warmPeach = Color(0xFF4E342E); // Brownish
  static const Color warmYellow = Color(0xFFF9A825);
  static const Color warmCoral = Color(0xFFBF360C);

  static const Color aiBubble = botBubble;
  static const Color aiBubbleText = botBubbleText;
}