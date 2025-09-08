import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary Brand Colors (as requested)
  static const Color deepTeal = Color(0xFF0F5860);
  static const Color softBlue = Color(0xFF2B9ED9);
  static const Color lime = Color(0xFFA7D129);
  static const Color orange = Color(0xFFFF9A42);
  static const Color background = Color(0xFFF6F8FA);
  static const Color textPrimary = Color(0xFF0B1A1F);

  // Semantic Colors
  static const Color success = lime;
  static const Color warning = orange;
  static const Color error = Color(0xFFE53E3E);
  static const Color info = softBlue;

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
  static const Color userBubble = deepTeal;
  static const Color aiBubble = grey100;
  static const Color userBubbleText = white;
  static const Color aiBubbleText = textPrimary;

  // Avatar Colors
  static const List<Color> avatarColors = [
    deepTeal,
    softBlue,
    lime,
    orange,
    Color(0xFF8B5CF6), // Purple
    Color(0xFFEC4899), // Pink
    Color(0xFFF59E0B), // Amber
    Color(0xFF10B981), // Emerald
  ];

  // Dark Mode Colors
  static const Color darkBackground = Color(0xFF0D1117);
  static const Color darkSurface = Color(0xFF161B22);
  static const Color darkTextPrimary = Color(0xFFE6EDF3);
  static const Color darkTextSecondary = Color(0xFF7D8590);
}