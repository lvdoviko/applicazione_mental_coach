import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Lo-Fi Minimal Palette - Light Mode
  static const Color background = Color(0xFFFBF9F8);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF8F6F5);
  static const Color primary = Color(0xFF7DAEA9);
  static const Color secondary = Color(0xFFE6D9F2);
  static const Color accent = Color(0xFFD4C4E8);
  static const Color textPrimary = Color(0xFF0F1724);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textTertiary = Color(0xFF9CA3AF);
  static const Color border = Color(0xFFE5E7EB);
  static const Color borderFocus = primary;

  // Message Bubble Colors
  static const Color userBubble = Color(0xFFDCEEF9);
  static const Color userBubbleText = textPrimary;
  static const Color botBubble = Color(0xFFFFF7EA);
  static const Color botBubbleText = textPrimary;

  // Semantic Colors - Muted for lo-fi aesthetic
  static const Color success = Color(0xFF86EFAC);
  static const Color warning = Color(0xFFFDE68A);
  static const Color error = Color(0xFFFCA5A5);
  static const Color info = Color(0xFFBAE6FD);

  // Skeleton Loading
  static const Color skeleton = Color(0xFFF3F4F6);
  static const Color skeletonHighlight = Color(0xFFFFFFFF);

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

  // Avatar Colors - Lo-fi pastels
  static const List<Color> avatarColors = [
    primary,
    secondary,
    accent,
    Color(0xFFC7D2FE), // soft blue
    Color(0xFFF8BBD0), // soft pink
    Color(0xFFE1F5FE), // soft cyan
    Color(0xFFE8F5E8), // soft green
    Color(0xFFFFF3E0), // soft amber
  ];

  // Dark Mode Colors
  static const Color darkBackground = Color(0xFF0F1117);
  static const Color darkSurface = Color(0xFF161B22);
  static const Color darkSurfaceVariant = Color(0xFF21262D);
  static const Color darkTextPrimary = Color(0xFFE6EDF3);
  static const Color darkTextSecondary = Color(0xFF7D8590);
  static const Color darkTextTertiary = Color(0xFF656D76);
  static const Color darkBorder = Color(0xFF30363D);
  static const Color darkUserBubble = Color(0xFF1C2128);
  static const Color darkBotBubble = Color(0xFF21262D);
  static const Color darkSkeleton = Color(0xFF21262D);
  static const Color darkSkeletonHighlight = Color(0xFF30363D);

  // Legacy aliases for backward compatibility
  static const Color aiBubble = botBubble;
  static const Color aiBubbleText = botBubbleText;
}