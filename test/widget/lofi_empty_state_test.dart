import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:applicazione_mental_coach/design_system/components/lofi_empty_state.dart';

void main() {
  group('LoFiEmptyState Widget Tests', () {
    testWidgets('should render basic empty state', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoFiEmptyState(
              icon: Icons.inbox,
              title: 'Empty State',
              message: 'Nothing to show here',
            ),
          ),
        ),
      );
      
      // Assert
      expect(find.text('Empty State'), findsOneWidget);
      expect(find.text('Nothing to show here'), findsOneWidget);
      expect(find.byIcon(Icons.inbox), findsOneWidget);
    });

    testWidgets('should show button when provided', (WidgetTester tester) async {
      // Arrange
      bool buttonTapped = false;
      
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LoFiEmptyState(
              icon: Icons.add,
              title: 'Empty with Button',
              message: 'Tap button to add',
              buttonText: 'Add Item',
              onButtonTap: () {
                buttonTapped = true;
              },
            ),
          ),
        ),
      );
      
      // Assert
      expect(find.text('Add Item'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
      
      // Act - Tap button
      await tester.tap(find.text('Add Item'));
      await tester.pumpAndSettle();
      
      // Assert
      expect(buttonTapped, isTrue);
    });

    testWidgets('should not show button when not provided', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoFiEmptyState(
              icon: Icons.search,
              title: 'No Button',
              message: 'This has no button',
            ),
          ),
        ),
      );
      
      // Assert
      expect(find.byType(ElevatedButton), findsNothing);
    });

    testWidgets('should use custom icon color when provided', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoFiEmptyState(
              icon: Icons.star,
              title: 'Custom Color',
              message: 'Custom icon color',
              iconColor: Colors.red,
            ),
          ),
        ),
      );
      
      // Assert
      final iconWidget = tester.widget<Icon>(find.byIcon(Icons.star));
      expect(iconWidget.color, equals(Colors.red));
    });

    testWidgets('should animate when isAnimated is true', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoFiEmptyState(
              icon: Icons.animation,
              title: 'Animated State',
              message: 'This should animate',
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
            body: LoFiEmptyState(
              icon: Icons.stop,
              title: 'Static State',
              message: 'This should not animate',
              isAnimated: false,
            ),
          ),
        ),
      );
      
      // Assert
      expect(find.byType(FadeTransition), findsNothing);
      expect(find.byType(SlideTransition), findsNothing);
    });

    testWidgets('should have correct layout and centering', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoFiEmptyState(
              icon: Icons.center_focus_strong,
              title: 'Centered',
              message: 'This should be centered',
            ),
          ),
        ),
      );
      
      // Assert - Should have Center widget
      expect(find.byType(Center), findsOneWidget);
      
      // Assert - Should have Column for vertical layout
      expect(find.byType(Column), findsOneWidget);
      
      final column = tester.widget<Column>(find.byType(Column));
      expect(column.mainAxisAlignment, equals(MainAxisAlignment.center));
      expect(column.mainAxisSize, equals(MainAxisSize.min));
    });

    testWidgets('should show circular icon background', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoFiEmptyState(
              icon: Icons.circle,
              title: 'Circle Background',
              message: 'Icon with circular background',
            ),
          ),
        ),
      );
      
      // Assert - Find container with circular background
      final containers = tester.widgetList<Container>(find.byType(Container));
      final iconContainer = containers.firstWhere(
        (container) {
          final decoration = container.decoration as BoxDecoration?;
          return decoration?.shape == BoxShape.circle;
        },
      );
      
      expect(iconContainer.constraints?.maxWidth, equals(120));
      expect(iconContainer.constraints?.maxHeight, equals(120));
    });

    testWidgets('should truncate long messages appropriately', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoFiEmptyState(
              icon: Icons.text_fields,
              title: 'Long Message',
              message: 'This is a very long message that should be truncated properly to avoid layout issues and maintain good user experience across different screen sizes and devices.',
            ),
          ),
        ),
      );
      
      // Assert - Text widget should have maxLines and overflow properties
      final messageText = tester.widget<Text>(
        find.text('This is a very long message that should be truncated properly to avoid layout issues and maintain good user experience across different screen sizes and devices.'),
      );
      
      expect(messageText.maxLines, equals(3));
      expect(messageText.overflow, equals(TextOverflow.ellipsis));
    });

    testWidgets('should handle button tap correctly with callback', (WidgetTester tester) async {
      // Arrange
      int tapCount = 0;
      
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LoFiEmptyState(
              icon: Icons.touch_app,
              title: 'Tap Counter',
              message: 'Tap the button',
              buttonText: 'Tap Me',
              onButtonTap: () {
                tapCount++;
              },
            ),
          ),
        ),
      );
      
      // Act - Tap button multiple times
      await tester.tap(find.text('Tap Me'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Tap Me'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Tap Me'));
      await tester.pumpAndSettle();
      
      // Assert
      expect(tapCount, equals(3));
    });

    testWidgets('should have proper spacing between elements', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoFiEmptyState(
              icon: Icons.space_bar,
              title: 'Spacing Test',
              message: 'Check spacing',
              buttonText: 'Button',
              onButtonTap: () {},
            ),
          ),
        ),
      );
      
      // Assert - Should have SizedBox widgets for spacing
      expect(find.byType(SizedBox), findsWidgets);
    });
  });

  group('EmptyStatePresets Tests', () {
    testWidgets('should create noConversations preset correctly', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyStatePresets.noConversations,
          ),
        ),
      );
      
      // Assert
      expect(find.text('No conversations yet'), findsOneWidget);
      expect(find.text('Start a conversation with your AI coach to begin your wellness journey.'), findsOneWidget);
      expect(find.text('Start Chat'), findsOneWidget);
      expect(find.byIcon(Icons.chat_bubble_outline), findsOneWidget);
    });

    testWidgets('should create noSearchResults preset correctly', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyStatePresets.noSearchResults,
          ),
        ),
      );
      
      // Assert
      expect(find.text('No results found'), findsOneWidget);
      expect(find.text('Try adjusting your search terms or browse all conversations.'), findsOneWidget);
      expect(find.text('Clear Search'), findsOneWidget);
      expect(find.byIcon(Icons.search_off_outlined), findsOneWidget);
    });

    testWidgets('should create noNotifications preset correctly', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyStatePresets.noNotifications,
          ),
        ),
      );
      
      // Assert
      expect(find.text('All caught up'), findsOneWidget);
      expect(find.text('You have no new notifications. Check back later for updates.'), findsOneWidget);
      expect(find.byIcon(Icons.notifications_none_outlined), findsOneWidget);
      
      // Should not be animated
      expect(find.byType(FadeTransition), findsNothing);
      expect(find.byType(SlideTransition), findsNothing);
    });

    testWidgets('should create connectionError preset correctly', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyStatePresets.connectionError,
          ),
        ),
      );
      
      // Assert
      expect(find.text('Connection lost'), findsOneWidget);
      expect(find.text('Check your internet connection and try again.'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
      expect(find.byIcon(Icons.wifi_off_outlined), findsOneWidget);
    });

    testWidgets('should create noData preset correctly', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyStatePresets.noData,
          ),
        ),
      );
      
      // Assert
      expect(find.text('Nothing here'), findsOneWidget);
      expect(find.text('This section will populate with content as you use the app.'), findsOneWidget);
      expect(find.byIcon(Icons.inbox_outlined), findsOneWidget);
      
      // Should not be animated
      expect(find.byType(FadeTransition), findsNothing);
      expect(find.byType(SlideTransition), findsNothing);
    });
  });
}