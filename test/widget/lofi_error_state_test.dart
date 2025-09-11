import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:applicazione_mental_coach/design_system/components/lofi_error_state.dart';

void main() {
  group('LoFiErrorState Widget Tests', () {
    testWidgets('should render basic error state', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoFiErrorState(
              title: 'Test Error',
              message: 'This is a test error message',
            ),
          ),
        ),
      );
      
      // Assert
      expect(find.text('Test Error'), findsOneWidget);
      expect(find.text('This is a test error message'), findsOneWidget);
    });

    testWidgets('should show correct icons for different severities', (WidgetTester tester) async {
      // Test error severity
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoFiErrorState(
              title: 'Error',
              message: 'Error message',
              severity: ErrorSeverity.error,
            ),
          ),
        ),
      );
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      
      // Test warning severity
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoFiErrorState(
              title: 'Warning',
              message: 'Warning message',
              severity: ErrorSeverity.warning,
            ),
          ),
        ),
      );
      expect(find.byIcon(Icons.warning_amber_outlined), findsOneWidget);
      
      // Test info severity
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoFiErrorState(
              title: 'Info',
              message: 'Info message',
              severity: ErrorSeverity.info,
            ),
          ),
        ),
      );
      expect(find.byIcon(Icons.info_outline), findsOneWidget);
      
      // Test critical severity
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoFiErrorState(
              title: 'Critical',
              message: 'Critical message',
              severity: ErrorSeverity.critical,
            ),
          ),
        ),
      );
      expect(find.byIcon(Icons.dangerous_outlined), findsOneWidget);
    });

    testWidgets('should show primary action button when provided', (WidgetTester tester) async {
      // Arrange
      bool primaryActionCalled = false;
      
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LoFiErrorState(
              title: 'Error with Action',
              message: 'Error message',
              primaryActionText: 'Retry',
              onPrimaryAction: () {
                primaryActionCalled = true;
              },
            ),
          ),
        ),
      );
      
      // Assert
      expect(find.text('Retry'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
      
      // Act - Tap button
      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();
      
      // Assert
      expect(primaryActionCalled, isTrue);
    });

    testWidgets('should show secondary action button when provided', (WidgetTester tester) async {
      // Arrange
      bool secondaryActionCalled = false;
      
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LoFiErrorState(
              title: 'Error with Secondary Action',
              message: 'Error message',
              secondaryActionText: 'Cancel',
              onSecondaryAction: () {
                secondaryActionCalled = true;
              },
            ),
          ),
        ),
      );
      
      // Assert
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.byType(TextButton), findsOneWidget);
      
      // Act - Tap button
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      
      // Assert
      expect(secondaryActionCalled, isTrue);
    });

    testWidgets('should show dismiss button when canDismiss is true', (WidgetTester tester) async {
      // Arrange
      bool dismissCalled = false;
      
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LoFiErrorState(
              title: 'Dismissible Error',
              message: 'Error message',
              canDismiss: true,
              onDismiss: () {
                dismissCalled = true;
              },
            ),
          ),
        ),
      );
      
      // Assert
      expect(find.byIcon(Icons.close), findsOneWidget);
      
      // Act - Tap dismiss button
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();
      
      // Assert
      expect(dismissCalled, isTrue);
    });

    testWidgets('should show details when provided', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoFiErrorState(
              title: 'Error with Details',
              message: 'Error message',
              details: 'Technical error details here',
            ),
          ),
        ),
      );
      
      // Assert
      expect(find.text('Technical Details'), findsOneWidget);
      expect(find.byType(ExpansionTile), findsOneWidget);
      
      // Act - Expand details
      await tester.tap(find.text('Technical Details'));
      await tester.pumpAndSettle();
      
      // Assert
      expect(find.text('Technical error details here'), findsOneWidget);
    });

    testWidgets('should have correct semantic labels', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoFiErrorState(
              title: 'Accessible Error',
              message: 'Error message for accessibility',
              severity: ErrorSeverity.warning,
            ),
          ),
        ),
      );
      
      // Assert
      final semantics = tester.getSemantics(find.byType(LoFiErrorState));
      expect(semantics.label, contains('Warning: Accessible Error'));
      expect(semantics.hint, contains('Error message for accessibility'));
    });

    testWidgets('should show live region for critical errors', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoFiErrorState(
              title: 'Critical Error',
              message: 'This is critical',
              severity: ErrorSeverity.critical,
            ),
          ),
        ),
      );
      
      // Assert
      final semantics = tester.getSemantics(find.byType(LoFiErrorState));
      expect(semantics.hasFlag(SemanticsFlag.isLiveRegion), isTrue);
    });

    testWidgets('should animate when isAnimated is true', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoFiErrorState(
              title: 'Animated Error',
              message: 'Error with animation',
              isAnimated: true,
            ),
          ),
        ),
      );
      
      // Assert
      expect(find.byType(FadeTransition), findsOneWidget);
      expect(find.byType(SlideTransition), findsOneWidget);
    });

    testWidgets('should not animate when isAnimated is false', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoFiErrorState(
              title: 'Static Error',
              message: 'Error without animation',
              isAnimated: false,
            ),
          ),
        ),
      );
      
      // Assert
      expect(find.byType(FadeTransition), findsNothing);
      expect(find.byType(SlideTransition), findsNothing);
    });

    testWidgets('should show both primary and secondary actions', (WidgetTester tester) async {
      // Arrange
      bool primaryCalled = false;
      bool secondaryCalled = false;
      
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LoFiErrorState(
              title: 'Error with Both Actions',
              message: 'Error message',
              primaryActionText: 'Primary',
              onPrimaryAction: () {
                primaryCalled = true;
              },
              secondaryActionText: 'Secondary',
              onSecondaryAction: () {
                secondaryCalled = true;
              },
            ),
          ),
        ),
      );
      
      // Assert
      expect(find.text('Primary'), findsOneWidget);
      expect(find.text('Secondary'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
      expect(find.byType(TextButton), findsOneWidget);
      
      // Act - Tap both buttons
      await tester.tap(find.text('Primary'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Secondary'));
      await tester.pumpAndSettle();
      
      // Assert
      expect(primaryCalled, isTrue);
      expect(secondaryCalled, isTrue);
    });

    testWidgets('should use custom icon when provided', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoFiErrorState(
              title: 'Custom Icon Error',
              message: 'Error with custom icon',
              icon: Icons.star,
            ),
          ),
        ),
      );
      
      // Assert
      expect(find.byIcon(Icons.star), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsNothing);
    });

    testWidgets('should handle shake animation for critical errors', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoFiErrorState(
              title: 'Critical Shake Error',
              message: 'This should shake',
              severity: ErrorSeverity.critical,
              isAnimated: true,
            ),
          ),
        ),
      );
      
      // Assert - Should have animations for critical errors
      expect(find.byType(FadeTransition), findsOneWidget);
      expect(find.byType(SlideTransition), findsOneWidget);
      expect(find.byType(AnimatedBuilder), findsOneWidget);
    });
  });

  group('ErrorStatePresets Tests', () {
    testWidgets('should create network error preset correctly', (WidgetTester tester) async {
      // Arrange
      bool retryCalled = false;
      
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ErrorStatePresets.networkError(
              onRetry: () {
                retryCalled = true;
              },
            ),
          ),
        ),
      );
      
      // Assert
      expect(find.text('Connection Error'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
      expect(find.byIcon(Icons.wifi_off_outlined), findsOneWidget);
      
      // Act - Tap retry
      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();
      
      // Assert
      expect(retryCalled, isTrue);
    });

    testWidgets('should create server error preset correctly', (WidgetTester tester) async {
      // Arrange
      bool retryCalled = false;
      bool supportCalled = false;
      
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ErrorStatePresets.serverError(
              onRetry: () {
                retryCalled = true;
              },
              onContactSupport: () {
                supportCalled = true;
              },
            ),
          ),
        ),
      );
      
      // Assert
      expect(find.text('Server Error'), findsOneWidget);
      expect(find.text('Try Again'), findsOneWidget);
      expect(find.text('Contact Support'), findsOneWidget);
      expect(find.byIcon(Icons.cloud_off_outlined), findsOneWidget);
    });

    testWidgets('should create maintenance mode preset correctly', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ErrorStatePresets.maintenanceMode(),
          ),
        ),
      );
      
      // Assert
      expect(find.text('Under Maintenance'), findsOneWidget);
      expect(find.text('Check Again'), findsOneWidget);
      expect(find.byIcon(Icons.build_outlined), findsOneWidget);
    });
  });
}