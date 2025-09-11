import 'package:flutter_test/flutter_test.dart';

import 'lofi_message_bubble_test.dart' as message_bubble_tests;
import 'lofi_input_composer_test.dart' as input_composer_tests;
import 'lofi_typing_indicator_test.dart' as typing_indicator_tests;
import 'lofi_error_state_test.dart' as error_state_tests;
import 'lofi_empty_state_test.dart' as empty_state_tests;

/// **Lo-Fi Design System Widget Test Runner**
/// 
/// This file runs all widget tests for the lo-fi design system components.
/// Tests cover functionality, accessibility, animations, and user interactions.
/// 
/// **Test Coverage:**
/// - LoFiMessageBubble: Message display, status indicators, animations
/// - LoFiInputComposer: Text input, voice recording, send actions
/// - LoFiTypingIndicator: Animation states, visibility changes
/// - LoFiErrorState: Error display, action buttons, severity handling
/// - LoFiEmptyState: Empty state display, action buttons, presets
/// 
/// **Running Tests:**
/// ```bash
/// flutter test test/widget/test_runner.dart
/// ```
/// 
/// **Individual Test Files:**
/// ```bash
/// flutter test test/widget/lofi_message_bubble_test.dart
/// flutter test test/widget/lofi_input_composer_test.dart
/// flutter test test/widget/lofi_typing_indicator_test.dart
/// flutter test test/widget/lofi_error_state_test.dart
/// flutter test test/widget/lofi_empty_state_test.dart
/// ```
void main() {
  group('Lo-Fi Design System Widget Tests', () {
    group('Message Bubble Tests', message_bubble_tests.main);
    group('Input Composer Tests', input_composer_tests.main);
    group('Typing Indicator Tests', typing_indicator_tests.main);
    group('Error State Tests', error_state_tests.main);
    group('Empty State Tests', empty_state_tests.main);
  });
}