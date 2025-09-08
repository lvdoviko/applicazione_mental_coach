class AppSpacing {
  AppSpacing._();

  // Base spacing unit (4dp)
  static const double unit = 4.0;

  // Spacing Scale
  static const double xs = unit; // 4
  static const double sm = unit * 2; // 8
  static const double md = unit * 3; // 12
  static const double lg = unit * 4; // 16
  static const double xl = unit * 5; // 20
  static const double xxl = unit * 6; // 24
  static const double xxxl = unit * 8; // 32
  static const double huge = unit * 10; // 40
  static const double massive = unit * 12; // 48

  // Semantic Spacing
  static const double chatBubblePadding = lg; // 16
  static const double screenPadding = xl; // 20
  static const double cardPadding = lg; // 16
  static const double buttonPadding = md; // 12
  static const double iconPadding = sm; // 8

  // Component Spacing
  static const double betweenSections = xxxl; // 32
  static const double betweenElements = lg; // 16
  static const double betweenItems = md; // 12
  static const double withinComponents = sm; // 8

  // Chat Specific
  static const double chatBubbleMargin = sm; // 8
  static const double messageSeparation = xs; // 4
  static const double quickReplySpacing = sm; // 8

  // Onboarding
  static const double onboardingVertical = huge; // 40
  static const double onboardingHorizontal = xl; // 20
}