import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary Brand Colors (warm palette)
  static const Color warmRed = Color(0xFFD73527);
  static const Color warmOrange = Color(0xFFFF8C42);
  static const Color warmYellow = Color(0xFFFFC947);
  static const Color warmCoral = Color(0xFFFF6B6B);
  static const Color warmTerracotta = Color(0xFFE07A5F);
  static const Color warmPeach = Color(0xFFFFB4A2);
  static const Color warmGold = Color(0xFFF2CC8F);
  static const Color warmBrown = Color(0xFF8B4513);
  
  // Main brand colors
  static const Color primary = warmTerracotta;
  static const Color secondary = warmGold;
  
  // Background and surface colors
  static const Color background = Color(0xFFFFFBF7);
  static const Color surface = Color(0xFFF9F7F4);
  static const Color textPrimary = Color(0xFF2D1B14);
  static const Color textSecondary = Color(0xFF8B7355);
  static const Color border = Color(0xFFE5DDD5);

  // Semantic Colors
  static const Color success = Color(0xFFE9C46A);
  static const Color warning = warmOrange;
  static const Color error = Color(0xFFE76F51);
  static const Color info = warmGold;

  // Neutral Palette
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color grey50 = Color(0xFFF9FAFB);
  static const Color grey100 = Color(0xFFF3F4F6);
  static const Color grey200 = Color(0xFFE5E7EB);
  static const Color grey300 = Color(0xFFD1D5DB);
  static const Color grey400 = Color(0xFF9CA3AF);
  static const Color grey500 = Color(0xFF6B7280);
  static const Color grey600 = Color(0xFF4B5563);
  static const Color grey700 = Color(0xFF374151);
  static const Color grey800 = Color(0xFF1F2937);
  static const Color grey900 = Color(0xFF111827);

  // Chat Bubble Colors
  static const Color userBubble = warmTerracotta;
  static const Color aiBubble = grey100;
  static const Color userBubbleText = white;
  static const Color aiBubbleText = textPrimary;

  // Avatar Colors
  static const List<Color> avatarColors = [
    warmTerracotta,
    warmGold,
    warmYellow,
    warmOrange,
    warmCoral,
    warmPeach,
    warmRed,
    warmBrown,
  ];

  // Dark Mode Colors
  static const Color darkBackground = Color(0xFF0D1117);
  static const Color darkSurface = Color(0xFF161B22);
  static const Color darkTextPrimary = Color(0xFFE6EDF3);
  static const Color darkTextSecondary = Color(0xFF7D8590);
}