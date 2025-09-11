class AppSpacing {
  AppSpacing._();

  // Base spacing unit - Lo-fi uses 8pt grid system for cleaner spacing
  static const double unit = 4.0;

  // Lo-fi Minimal Spacing Scale
  static const double none = 0;
  static const double xs = unit; // 4
  static const double sm = unit * 2; // 8
  static const double md = unit * 3; // 12 (more refined than 16)
  static const double lg = unit * 4; // 16
  static const double xl = unit * 6; // 24
  static const double xxl = unit * 8; // 32
  static const double xxxl = unit * 10; // 40
  static const double huge = unit * 12; // 48
  static const double massive = unit * 16; // 64
  static const double gigantic = unit * 20; // 80
  static const double colossal = unit * 24; // 96

  // Lo-fi Semantic Spacing - More generous whitespace
  static const double messageBubblePadding = lg; // 16
  static const double screenPadding = xl; // 24
  static const double cardPadding = lg; // 16
  static const double buttonPadding = lg; // 16
  static const double iconPadding = sm; // 8

  // Lo-fi Component Spacing - Breathing room
  static const double sectionSpacing = massive; // 64
  static const double elementSpacing = xl; // 24
  static const double itemSpacing = lg; // 16
  static const double inlineSpacing = md; // 12

  // Chat Specific - Clean and spacious
  static const double messageBubbleMargin = sm; // 8
  static const double messageSpacing = xs; // 4
  static const double quickReplySpacing = sm; // 8
  static const double chatAvatarSize = 32;
  static const double chatAvatarMargin = sm; // 8

  // Quick reply chips
  static const double chipSpacing = sm; // 8
  static const double chipPaddingVertical = sm; // 8
  static const double chipPaddingHorizontal = lg; // 16

  // List spacing
  static const double listItemPadding = lg; // 16
  static const double listItemSpacing = xs; // 4

  // Onboarding - Generous lo-fi spacing
  static const double onboardingVertical = massive; // 64
  static const double onboardingHorizontal = xl; // 24

  // Composer
  static const double composerPadding = lg; // 16
  static const double composerMinHeight = 54;
}