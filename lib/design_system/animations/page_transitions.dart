import 'package:flutter/material.dart';
import 'package:applicazione_mental_coach/design_system/tokens/app_animations.dart';

/// **Lo-Fi Page Transitions**
/// 
/// **Functional Description:**
/// Smooth page transitions with lo-fi aesthetic animations.
/// Features gentle slides, fades, and scale effects for navigation.
/// 
/// **Visual Specifications:**
/// - Slide transitions: 20px offset with ease-out-cubic
/// - Fade transitions: 0.8 to 1.0 opacity range
/// - Scale transitions: 0.95 to 1.0 scale range
/// - Duration: 350ms for all transitions
/// - Curves: easeOutCubic for natural feel
/// 
/// **Performance:**
/// - Hardware-accelerated transforms
/// - Optimized animation curves
/// - Minimal overdraw during transitions
class LoFiPageTransitions {
  static const Duration _duration = Duration(milliseconds: 350);
  
  /// Gentle slide from right with fade
  static PageRouteBuilder slideFromRight(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: _duration,
      reverseTransitionDuration: _duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        
        final slideAnimation = Tween<Offset>(
          begin: begin,
          end: end,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: AppAnimations.easeOutCubic,
        ));

        final fadeAnimation = Tween<double>(
          begin: 0.8,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: AppAnimations.easeOut,
        ));

        return FadeTransition(
          opacity: fadeAnimation,
          child: SlideTransition(
            position: slideAnimation,
            child: child,
          ),
        );
      },
    );
  }

  /// Gentle slide from bottom for modals
  static PageRouteBuilder slideFromBottom(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: _duration,
      reverseTransitionDuration: _duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 1.0);
        const end = Offset.zero;
        
        final slideAnimation = Tween<Offset>(
          begin: begin,
          end: end,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: AppAnimations.easeOutCubic,
        ));

        final fadeAnimation = Tween<double>(
          begin: 0.9,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: AppAnimations.easeOut,
        ));

        return FadeTransition(
          opacity: fadeAnimation,
          child: SlideTransition(
            position: slideAnimation,
            child: child,
          ),
        );
      },
    );
  }

  /// Subtle scale and fade for dialogs
  static PageRouteBuilder scaleAndFade(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: _duration,
      reverseTransitionDuration: _duration,
      opaque: false,
      barrierColor: Colors.black54,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final scaleAnimation = Tween<double>(
          begin: 0.95,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: AppAnimations.easeOutBack,
        ));

        final fadeAnimation = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: AppAnimations.easeOut,
        ));

        return FadeTransition(
          opacity: fadeAnimation,
          child: ScaleTransition(
            scale: scaleAnimation,
            child: child,
          ),
        );
      },
    );
  }

  /// Simple fade for subtle transitions
  static PageRouteBuilder fadeIn(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: _duration,
      reverseTransitionDuration: _duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final fadeAnimation = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: AppAnimations.easeOut,
        ));

        return FadeTransition(
          opacity: fadeAnimation,
          child: child,
        );
      },
    );
  }

  /// Shared axis transition for related screens
  static PageRouteBuilder sharedAxis(Widget page, {bool isVertical = false}) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: _duration,
      reverseTransitionDuration: _duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final primaryOffset = isVertical 
          ? const Offset(0.0, 0.1) 
          : const Offset(0.1, 0.0);
        final secondaryOffset = isVertical 
          ? const Offset(0.0, -0.1) 
          : const Offset(-0.1, 0.0);

        final primarySlide = Tween<Offset>(
          begin: primaryOffset,
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: AppAnimations.easeOutCubic,
        ));

        final secondarySlide = Tween<Offset>(
          begin: Offset.zero,
          end: secondaryOffset,
        ).animate(CurvedAnimation(
          parent: secondaryAnimation,
          curve: AppAnimations.easeOutCubic,
        ));

        final fadeIn = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: AppAnimations.easeOut,
        ));

        final fadeOut = Tween<double>(
          begin: 1.0,
          end: 0.0,
        ).animate(CurvedAnimation(
          parent: secondaryAnimation,
          curve: AppAnimations.easeOut,
        ));

        return Stack(
          children: [
            if (secondaryAnimation.status != AnimationStatus.dismissed)
              SlideTransition(
                position: secondarySlide,
                child: FadeTransition(
                  opacity: fadeOut,
                  child: Container(),
                ),
              ),
            SlideTransition(
              position: primarySlide,
              child: FadeTransition(
                opacity: fadeIn,
                child: child,
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Extension to simplify navigation with lo-fi transitions
extension NavigationExtensions on NavigatorState {
  Future<T?> pushWithSlide<T>(Widget page) {
    return push<T>(LoFiPageTransitions.slideFromRight(page));
  }

  Future<T?> pushWithFade<T>(Widget page) {
    return push<T>(LoFiPageTransitions.fadeIn(page));
  }

  Future<T?> pushModalWithSlide<T>(Widget page) {
    return push<T>(LoFiPageTransitions.slideFromBottom(page));
  }

  Future<T?> pushWithScale<T>(Widget page) {
    return push<T>(LoFiPageTransitions.scaleAndFade(page));
  }
}