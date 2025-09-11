import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// **Lo-Fi Accessibility Helpers**
/// 
/// **Functional Description:**
/// Utility functions and widgets to enhance accessibility across the app.
/// Provides semantic wrappers, focus management, and screen reader support.
/// 
/// **Features:**
/// - Semantic labels and hints
/// - Live region announcements
/// - Focus management utilities
/// - High contrast support detection
/// - Reduced motion preferences
/// 
/// **Usage:**
/// ```dart
/// AccessibilityHelpers.announceMessage(context, 'Message sent');
/// AccessibilityHelpers.wrapButton(child, 'Send message', onTap: callback);
/// ```
class AccessibilityHelpers {
  AccessibilityHelpers._();

  /// Announce a message to screen readers
  static void announceMessage(BuildContext context, String message, {
    AssertionsAriaLive ariaLive = AssertionsAriaLive.polite,
  }) {
    SemanticsService.announce(message, TextDirection.ltr);
  }

  /// Create a semantic button wrapper
  static Widget wrapButton({
    required Widget child,
    required String label,
    String? hint,
    VoidCallback? onTap,
    bool enabled = true,
  }) {
    return Semantics(
      label: label,
      hint: hint,
      button: true,
      enabled: enabled,
      excludeSemantics: false,
      child: GestureDetector(
        onTap: enabled ? onTap : null,
        child: child,
      ),
    );
  }

  /// Create a semantic text field wrapper
  static Widget wrapTextField({
    required Widget child,
    required String label,
    String? hint,
    bool obscureText = false,
    bool multiline = false,
  }) {
    return Semantics(
      label: label,
      hint: hint,
      textField: true,
      obscured: obscureText,
      multiline: multiline,
      child: child,
    );
  }

  /// Create a semantic list item wrapper
  static Widget wrapListItem({
    required Widget child,
    required String label,
    String? hint,
    int? index,
    int? total,
  }) {
    String fullHint = hint ?? '';
    if (index != null && total != null) {
      fullHint += fullHint.isNotEmpty ? '. ' : '';
      fullHint += 'Item ${index + 1} of $total';
    }

    return Semantics(
      label: label,
      hint: fullHint,
      container: true,
      child: child,
    );
  }

  /// Create a semantic live region for dynamic content
  static Widget wrapLiveRegion({
    required Widget child,
    required String label,
    String? hint,
    bool assertive = false,
  }) {
    return Semantics(
      label: label,
      hint: hint,
      liveRegion: true,
      container: true,
      child: child,
    );
  }

  /// Create a semantic navigation wrapper
  static Widget wrapNavigation({
    required Widget child,
    required String label,
  }) {
    return Semantics(
      label: label,
      container: true,
      explicitChildNodes: true,
      child: child,
    );
  }

  /// Create a semantic header wrapper
  static Widget wrapHeader({
    required Widget child,
    required String text,
    int level = 1,
  }) {
    return Semantics(
      label: text,
      header: true,
      child: child,
    );
  }

  /// Create a semantic progress indicator wrapper
  static Widget wrapProgress({
    required Widget child,
    required double value,
    String? label,
  }) {
    final percentage = (value * 100).round();
    return Semantics(
      label: label ?? 'Progress',
      value: '$percentage percent',
      child: child,
    );
  }

  /// Focus management utilities
  static void requestFocus(BuildContext context, FocusNode focusNode) {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (context.mounted) {
        focusNode.requestFocus();
      }
    });
  }

  /// Move focus to next focusable element
  static void focusNext(BuildContext context) {
    FocusScope.of(context).nextFocus();
  }

  /// Move focus to previous focusable element
  static void focusPrevious(BuildContext context) {
    FocusScope.of(context).previousFocus();
  }

  /// Check if user prefers reduced motion
  static bool prefersReducedMotion(BuildContext context) {
    return MediaQuery.of(context).disableAnimations;
  }

  /// Check if high contrast is enabled
  static bool isHighContrastEnabled(BuildContext context) {
    return MediaQuery.of(context).highContrast;
  }

  /// Get text scale factor for accessibility
  static double getTextScaleFactor(BuildContext context) {
    return MediaQuery.of(context).textScaler.scale(1.0);
  }

  /// Create accessible dialog
  static Future<T?> showAccessibleDialog<T>({
    required BuildContext context,
    required Widget child,
    required String title,
    String? description,
    bool barrierDismissible = true,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) => Semantics(
        label: title,
        hint: description,
        scopesRoute: true,
        explicitChildNodes: true,
        child: child,
      ),
    );
  }

  /// Create accessible bottom sheet
  static Future<T?> showAccessibleBottomSheet<T>({
    required BuildContext context,
    required Widget child,
    required String title,
    String? description,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      builder: (context) => Semantics(
        label: title,
        hint: description,
        container: true,
        child: child,
      ),
    );
  }
}

/// Widget that excludes child from semantics tree when needed
class ConditionalSemantics extends StatelessWidget {
  final Widget child;
  final bool exclude;
  final String? label;
  final String? hint;
  final bool? button;
  final bool? header;
  final bool? textField;

  const ConditionalSemantics({
    super.key,
    required this.child,
    this.exclude = false,
    this.label,
    this.hint,
    this.button,
    this.header,
    this.textField,
  });

  @override
  Widget build(BuildContext context) {
    if (exclude) {
      return ExcludeSemantics(child: child);
    }

    return Semantics(
      label: label,
      hint: hint,
      button: button,
      header: header,
      textField: textField,
      child: child,
    );
  }
}

/// Semantic labels for common UI elements
class SemanticLabels {
  static const String send = 'Send message';
  static const String voiceRecord = 'Record voice message';
  static const String voiceStop = 'Stop recording';
  static const String attach = 'Add attachment';
  static const String search = 'Search';
  static const String close = 'Close';
  static const String back = 'Go back';
  static const String menu = 'Open menu';
  static const String settings = 'Open settings';
  static const String refresh = 'Refresh';
  static const String retry = 'Retry';
  static const String dismiss = 'Dismiss';
  static const String expand = 'Expand';
  static const String collapse = 'Collapse';
  static const String loading = 'Loading';
  static const String error = 'Error occurred';
  static const String success = 'Success';
  static const String warning = 'Warning';
  static const String info = 'Information';
}

/// Semantic hints for common interactions
class SemanticHints {
  static const String doubleTap = 'Double tap to activate';
  static const String swipeLeft = 'Swipe left for more options';
  static const String swipeRight = 'Swipe right for more options';
  static const String longPress = 'Long press for additional options';
  static const String scrollable = 'Swipe up or down to scroll';
  static const String editable = 'Text field, double tap to edit';
  static const String required = 'Required field';
  static const String optional = 'Optional field';
}