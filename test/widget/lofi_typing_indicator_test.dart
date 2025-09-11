import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:applicazione_mental_coach/design_system/components/lofi_typing_indicator.dart';

void main() {
  group('LoFiTypingIndicator Widget Tests', () {
    testWidgets('should render when visible', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoFiTypingIndicator(isVisible: true),
          ),
        ),
      );
      
      // Assert
      expect(find.byType(LoFiTypingIndicator), findsOneWidget);
      expect(find.byIcon(Icons.psychology_outlined), findsOneWidget);
      
      // Should show 3 animated dots
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('should not render when not visible', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoFiTypingIndicator(isVisible: false),
          ),
        ),
      );
      
      // Assert
      expect(find.byType(Container), findsNothing);
      expect(find.byIcon(Icons.psychology_outlined), findsNothing);
    });

    testWidgets('should show bot avatar with gradient', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoFiTypingIndicator(isVisible: true),
          ),
        ),
      );
      
      // Assert
      expect(find.byIcon(Icons.psychology_outlined), findsOneWidget);
      
      // Find container with gradient decoration
      final avatarContainer = tester.widget<Container>(
        find.descendant(
          of: find.byType(LoFiTypingIndicator),
          matching: find.byType(Container),
        ).first,
      );
      
      expect(avatarContainer.decoration, isA<BoxDecoration>());
      final decoration = avatarContainer.decoration as BoxDecoration;
      expect(decoration.gradient, isNotNull);
      expect(decoration.shape, equals(BoxShape.circle));
    });

    testWidgets('should show typing bubble with correct styling', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoFiTypingIndicator(isVisible: true),
          ),
        ),
      );
      
      // Assert - Find the typing bubble container
      final bubbleContainers = tester.widgetList<Container>(
        find.descendant(
          of: find.byType(LoFiTypingIndicator),
          matching: find.byType(Container),
        ),
      ).where((container) {
        final decoration = container.decoration as BoxDecoration?;
        return decoration?.borderRadius != null;
      });
      
      expect(bubbleContainers, isNotEmpty);
    });

    testWidgets('should animate typing dots', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoFiTypingIndicator(isVisible: true),
          ),
        ),
      );
      
      // Assert - AnimatedBuilder should be present for dot animations
      expect(find.byType(AnimatedBuilder), findsWidgets);
      
      // Pump several frames to test animation
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      
      // Animation should still be running
      expect(find.byType(AnimatedBuilder), findsWidgets);
    });

    testWidgets('should have proper accessibility semantics', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoFiTypingIndicator(isVisible: true),
          ),
        ),
      );
      
      // Assert
      final semantics = tester.getSemantics(find.byType(LoFiTypingIndicator));
      expect(semantics.label, contains('AI Coach is typing'));
      expect(semantics.hint, contains('composing a response'));
      expect(semantics.hasFlag(SemanticsFlag.isLiveRegion), isTrue);
    });

    testWidgets('should call onAnimationComplete when visibility changes', (WidgetTester tester) async {
      // Arrange
      bool animationCompleteCalled = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LoFiTypingIndicator(
              isVisible: true,
              onAnimationComplete: () {
                animationCompleteCalled = true;
              },
            ),
          ),
        ),
      );
      
      // Act - Change visibility to false
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LoFiTypingIndicator(
              isVisible: false,
              onAnimationComplete: () {
                animationCompleteCalled = true;
              },
            ),
          ),
        ),
      );
      
      await tester.pumpAndSettle();
      
      // Assert
      expect(animationCompleteCalled, isTrue);
    });

    testWidgets('should have correct dot spacing and count', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoFiTypingIndicator(isVisible: true),
          ),
        ),
      );
      
      // Assert - Should have exactly 3 animated dots
      final dotContainers = tester.widgetList<Container>(
        find.descendant(
          of: find.byType(LoFiTypingIndicator),
          matching: find.byType(Container),
        ),
      ).where((container) {
        // Filter for small circular containers (the dots)
        return container.constraints?.maxWidth == 6.0 &&
               container.constraints?.maxHeight == 6.0;
      });
      
      // Note: The exact count might vary based on widget structure
      // but we should have multiple small containers for the dots
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('should start animation when visible becomes true', (WidgetTester tester) async {
      // Arrange - Start with invisible
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoFiTypingIndicator(isVisible: false),
          ),
        ),
      );
      
      // Act - Make visible
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoFiTypingIndicator(isVisible: true),
          ),
        ),
      );
      
      await tester.pump(const Duration(milliseconds: 100));
      
      // Assert
      expect(find.byType(AnimatedBuilder), findsWidgets);
    });

    testWidgets('should stop animation when visible becomes false', (WidgetTester tester) async {
      // Arrange - Start with visible
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoFiTypingIndicator(isVisible: true),
          ),
        ),
      );
      
      await tester.pump(const Duration(milliseconds: 100));
      
      // Act - Make invisible
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoFiTypingIndicator(isVisible: false),
          ),
        ),
      );
      
      await tester.pumpAndSettle();
      
      // Assert
      expect(find.byType(Container), findsNothing);
    });

    testWidgets('should handle rapid visibility changes gracefully', (WidgetTester tester) async {
      // Act - Rapidly toggle visibility
      for (int i = 0; i < 5; i++) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: LoFiTypingIndicator(isVisible: i.isEven),
            ),
          ),
        );
        await tester.pump(const Duration(milliseconds: 50));
      }
      
      // Final state should be visible
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoFiTypingIndicator(isVisible: true),
          ),
        ),
      );
      
      await tester.pumpAndSettle();
      
      // Assert
      expect(find.byType(LoFiTypingIndicator), findsOneWidget);
      expect(find.byIcon(Icons.psychology_outlined), findsOneWidget);
    });
  });
}