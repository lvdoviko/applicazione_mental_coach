import 'package:flutter/animation.dart';

class AppAnimations {
  AppAnimations._();

  // Lo-fi smooth animation durations (in milliseconds)
  static const Duration micro = Duration(milliseconds: 120);
  static const Duration small = Duration(milliseconds: 200);
  static const Duration medium = Duration(milliseconds: 350);
  static const Duration large = Duration(milliseconds: 600);

  // Smooth easing curves for lo-fi aesthetic
  static const Curve easeOut = Curves.easeOut;
  static const Curve easeIn = Curves.easeIn;
  static const Curve easeInOut = Curves.easeInOut;
  static const Curve easeOutCubic = Curves.easeOutCubic;
  static const Curve easeInOutCubic = Curves.easeInOutCubic;

  // Message-specific animations
  static const Duration messageFadeIn = medium;
  static const Duration messageSlideIn = small;
  static const Duration buttonPress = micro;
  static const Duration typingIndicator = Duration(milliseconds: 900);

  // Transition animations
  static const Duration pageTransition = medium;
  static const Duration modalSlide = medium;
  static const Duration chipAppear = small;
  
  // Skeleton loading
  static const Duration skeletonShimmer = Duration(milliseconds: 1500);
}

class AppBorderRadius {
  AppBorderRadius._();

  // Lo-fi rounded corners - soft but not too aggressive
  static const double none = 0;
  static const double sm = 6;
  static const double md = 12;
  static const double lg = 20;
  static const double xl = 24;
  static const double full = 9999;

  // Component-specific radius
  static const double messageBubble = 16;
  static const double composer = md;
  static const double chip = 20;
  static const double card = lg;
  static const double button = md;
  static const double avatar = full;
}