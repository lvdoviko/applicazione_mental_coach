import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:applicazione_mental_coach/design_system/components/lofi_message_bubble.dart';
import 'package:applicazione_mental_coach/design_system/tokens/app_colors.dart';

void main() {
  group('LoFiMessageBubble Widget Tests', () {
    testWidgets('should render user message correctly', (WidgetTester tester) async {
      // Arrange
      const testMessage = 'Hello, this is a test message';
      final testTimestamp = DateTime.now();
      
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LoFiMessageBubble(
              message: testMessage,
              type: MessageType.user,
              timestamp: testTimestamp,
              status: MessageStatus.sent,
            ),
          ),
        ),
      );
      
      // Assert
      expect(find.text(testMessage), findsOneWidget);
      expect(find.byIcon(Icons.check), findsOneWidget);
    });

    testWidgets('should render bot message correctly', (WidgetTester tester) async {
      // Arrange
      const testMessage = 'Hello, I am your AI coach';
      final testTimestamp = DateTime.now();
      
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LoFiMessageBubble(
              message: testMessage,
              type: MessageType.bot,
              timestamp: testTimestamp,
            ),
          ),
        ),
      );
      
      // Assert
      expect(find.text(testMessage), findsOneWidget);
      expect(find.byIcon(Icons.psychology_outlined), findsOneWidget);
    });

    testWidgets('should show system message without avatar or status', (WidgetTester tester) async {
      // Arrange
      const testMessage = 'System notification';
      final testTimestamp = DateTime.now();
      
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LoFiMessageBubble(
              message: testMessage,
              type: MessageType.system,
              timestamp: testTimestamp,
            ),
          ),
        ),
      );
      
      // Assert
      expect(find.text(testMessage), findsOneWidget);
      expect(find.byIcon(Icons.psychology_outlined), findsNothing);
      expect(find.byIcon(Icons.check), findsNothing);
    });

    testWidgets('should show different status icons correctly', (WidgetTester tester) async {
      // Arrange
      const testMessage = 'Test message';
      final testTimestamp = DateTime.now();
      
      for (final status in MessageStatus.values) {
        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: LoFiMessageBubble(
                message: testMessage,
                type: MessageType.user,
                timestamp: testTimestamp,
                status: status,
              ),
            ),
          ),
        );
        
        // Assert
        switch (status) {
          case MessageStatus.sending:
            expect(find.byIcon(Icons.access_time), findsOneWidget);
            break;
          case MessageStatus.sent:
            expect(find.byIcon(Icons.check), findsOneWidget);
            break;
          case MessageStatus.delivered:
            expect(find.byIcon(Icons.done_all), findsOneWidget);
            break;
          case MessageStatus.read:
            expect(find.byIcon(Icons.done_all), findsOneWidget);
            break;
          case MessageStatus.error:
            expect(find.byIcon(Icons.error_outline), findsOneWidget);
            break;
        }
      }
    });

    testWidgets('should trigger retry callback on error status tap', (WidgetTester tester) async {
      // Arrange
      const testMessage = 'Failed message';
      final testTimestamp = DateTime.now();
      bool retryWasCalled = false;
      
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LoFiMessageBubble(
              message: testMessage,
              type: MessageType.user,
              timestamp: testTimestamp,
              status: MessageStatus.error,
              onRetry: () {
                retryWasCalled = true;
              },
            ),
          ),
        ),
      );
      
      await tester.tap(find.byIcon(Icons.error_outline));
      await tester.pumpAndSettle();
      
      // Assert
      expect(retryWasCalled, isTrue);
    });

    testWidgets('should display correct semantic labels', (WidgetTester tester) async {
      // Arrange
      const testMessage = 'Accessibility test message';
      final testTimestamp = DateTime.now();
      
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LoFiMessageBubble(
              message: testMessage,
              type: MessageType.user,
              timestamp: testTimestamp,
              status: MessageStatus.sent,
            ),
          ),
        ),
      );
      
      // Assert
      final semantics = tester.getSemantics(find.byType(LoFiMessageBubble));
      expect(semantics.label, contains('You said'));
      expect(semantics.label, contains(testMessage));
      expect(semantics.label, contains('Sent'));
    });

    testWidgets('should apply correct colors for user and bot messages', (WidgetTester tester) async {
      // Test user message colors
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LoFiMessageBubble(
              message: 'User message',
              type: MessageType.user,
              timestamp: DateTime.now(),
            ),
          ),
        ),
      );
      
      final userBubbleContainer = tester.widget<Container>(
        find.ancestor(
          of: find.text('User message'),
          matching: find.byType(Container),
        ).first,
      );
      expect((userBubbleContainer.decoration! as BoxDecoration).color, 
             equals(AppColors.userBubble));
      
      // Test bot message colors
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LoFiMessageBubble(
              message: 'Bot message',
              type: MessageType.bot,
              timestamp: DateTime.now(),
            ),
          ),
        ),
      );
      
      final botBubbleContainer = tester.widget<Container>(
        find.ancestor(
          of: find.text('Bot message'),
          matching: find.byType(Container),
        ).first,
      );
      expect((botBubbleContainer.decoration! as BoxDecoration).color, 
             equals(AppColors.botBubble));
    });

    testWidgets('should animate when isAnimated is true', (WidgetTester tester) async {
      // Arrange
      const testMessage = 'Animated message';
      final testTimestamp = DateTime.now();
      
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LoFiMessageBubble(
              message: testMessage,
              type: MessageType.bot,
              timestamp: testTimestamp,
              isAnimated: true,
            ),
          ),
        ),
      );
      
      // Check that FadeTransition and SlideTransition are present
      expect(find.byType(FadeTransition), findsOneWidget);
      expect(find.byType(SlideTransition), findsOneWidget);
      expect(find.byType(ScaleTransition), findsOneWidget);
      
      // Pump a frame to start animations
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpAndSettle();
      
      // Assert
      expect(find.text(testMessage), findsOneWidget);
    });

    testWidgets('should format timestamps correctly', (WidgetTester tester) async {
      // Test recent message (now)
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LoFiMessageBubble(
              message: 'Recent message',
              type: MessageType.system,
              timestamp: DateTime.now(),
            ),
          ),
        ),
      );
      
      expect(find.text('now'), findsOneWidget);
      
      // Test older message (minutes ago)
      final fiveMinutesAgo = DateTime.now().subtract(const Duration(minutes: 5));
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LoFiMessageBubble(
              message: 'Older message',
              type: MessageType.system,
              timestamp: fiveMinutesAgo,
            ),
          ),
        ),
      );
      
      expect(find.textContaining('5m ago'), findsOneWidget);
    });
  });
}