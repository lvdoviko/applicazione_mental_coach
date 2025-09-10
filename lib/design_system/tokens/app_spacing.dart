class AppSpacing {
  AppSpacing._();

  // Base spacing unit - iOS uses 8pt grid system
  static const double unit = 4.0;

  // iOS-style Spacing Scale
  static const double xs = unit; // 4
  static const double sm = unit * 2; // 8
  static const double md = unit * 4; // 16 (iOS default)
  static const double lg = unit * 6; // 24
  static const double xl = unit * 8; // 32
  static const double xxl = unit * 10; // 40
  static const double xxxl = unit * 12; // 48
  static const double huge = unit * 16; // 64
  static const double massive = unit * 20; // 80

  // iOS-style Semantic Spacing
  static const double chatBubblePadding = md; // 16
  static const double screenPadding = lg; // 24 (iOS standard edge margins)
  static const double cardPadding = md; // 16
  static const double buttonPadding = md; // 16
  static const double iconPadding = sm; // 8

  // iOS-style Component Spacing
  static const double betweenSections = huge; // 64
  static const double betweenElements = xl; // 32
  static const double betweenItems = lg; // 24
  static const double withinComponents = md; // 16

  // Chat Specific - iOS Messages style
  static const double chatBubbleMargin = sm; // 8
  static const double messageSeparation = xs; // 4
  static const double quickReplySpacing = sm; // 8

  // Onboarding - More generous iOS spacing
  static const double onboardingVertical = huge; // 64
  static const double onboardingHorizontal = lg; // 24
}