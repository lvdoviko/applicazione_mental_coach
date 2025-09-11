import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:applicazione_mental_coach/design_system/components/lofi_input_composer.dart';

void main() {
  group('LoFiInputComposer Widget Tests', () {
    testWidgets('should render input field and send button', (WidgetTester tester) async {
      // Arrange
      String? sentMessage;
      
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LoFiInputComposer(
              onSendMessage: (message) {
                sentMessage = message;
              },
              hintText: 'Type your message...',
            ),
          ),
        ),
      );
      
      // Assert
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Type your message...'), findsOneWidget);
    });

    testWidgets('should show send button when text is entered', (WidgetTester tester) async {
      // Arrange
      String? sentMessage;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LoFiInputComposer(
              onSendMessage: (message) {
                sentMessage = message;
              },
            ),
          ),
        ),
      );
      
      // Initially should show voice button
      expect(find.byIcon(Icons.mic), findsOneWidget);
      expect(find.byIcon(Icons.send_rounded), findsNothing);
      
      // Act - Enter text
      await tester.enterText(find.byType(TextField), 'Hello');
      await tester.pumpAndSettle();
      
      // Assert - Should now show send button
      expect(find.byIcon(Icons.send_rounded), findsOneWidget);
      expect(find.byIcon(Icons.mic), findsNothing);
    });

    testWidgets('should send message when send button is tapped', (WidgetTester tester) async {
      // Arrange
      String? sentMessage;
      const testMessage = 'Test message';
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LoFiInputComposer(
              onSendMessage: (message) {
                sentMessage = message;
              },
            ),
          ),
        ),
      );
      
      // Act - Enter text and tap send
      await tester.enterText(find.byType(TextField), testMessage);
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.send_rounded));
      await tester.pumpAndSettle();
      
      // Assert
      expect(sentMessage, equals(testMessage));
      expect(find.text(testMessage), findsNothing); // Text field should be cleared
    });

    testWidgets('should show voice button when no text', (WidgetTester tester) async {
      // Arrange
      bool voiceStartCalled = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LoFiInputComposer(
              onSendMessage: (message) {},
              onVoiceStart: () {
                voiceStartCalled = true;
              },
            ),
          ),
        ),
      );
      
      // Assert - Voice button is visible
      expect(find.byIcon(Icons.mic), findsOneWidget);
      
      // Act - Tap voice button
      await tester.tap(find.byIcon(Icons.mic));
      await tester.pumpAndSettle();
      
      // Assert
      expect(voiceStartCalled, isTrue);
    });

    testWidgets('should show stop button when recording', (WidgetTester tester) async {
      // Arrange
      bool voiceStopCalled = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LoFiInputComposer(
              onSendMessage: (message) {},
              onVoiceStop: () {
                voiceStopCalled = true;
              },
              isRecording: true,
            ),
          ),
        ),
      );
      
      // Assert - Stop button is visible and has recording appearance
      expect(find.byIcon(Icons.stop), findsOneWidget);
      expect(find.byIcon(Icons.mic), findsNothing);
      
      // Act - Tap stop button
      await tester.tap(find.byIcon(Icons.stop));
      await tester.pumpAndSettle();
      
      // Assert
      expect(voiceStopCalled, isTrue);
    });

    testWidgets('should show attachment button when callback provided', (WidgetTester tester) async {
      // Arrange
      bool attachmentTapped = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LoFiInputComposer(
              onSendMessage: (message) {},
              onAttachmentTap: () {
                attachmentTapped = true;
              },
            ),
          ),
        ),
      );
      
      // Assert - Attachment button is visible
      expect(find.byIcon(Icons.attach_file), findsOneWidget);
      
      // Act - Tap attachment button
      await tester.tap(find.byIcon(Icons.attach_file));
      await tester.pumpAndSettle();
      
      // Assert
      expect(attachmentTapped, isTrue);
    });

    testWidgets('should not show attachment button when callback not provided', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LoFiInputComposer(
              onSendMessage: (message) {},
            ),
          ),
        ),
      );
      
      // Assert
      expect(find.byIcon(Icons.attach_file), findsNothing);
    });

    testWidgets('should disable input when isEnabled is false', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LoFiInputComposer(
              onSendMessage: (message) {},
              isEnabled: false,
            ),
          ),
        ),
      );
      
      // Assert
      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.enabled, isFalse);
    });

    testWidgets('should have correct semantic labels for accessibility', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LoFiInputComposer(
              onSendMessage: (message) {},
              onVoiceStart: () {},
              onAttachmentTap: () {},
            ),
          ),
        ),
      );
      
      // Assert text field semantics
      final textFieldSemantics = tester.getSemantics(find.byType(TextField));
      expect(textFieldSemantics.label, equals('Message input'));
      expect(textFieldSemantics.hint, contains('Type your message'));
      
      // Assert voice button semantics
      final voiceButtonSemantics = tester.getSemantics(find.byIcon(Icons.mic));
      expect(voiceButtonSemantics.label, contains('Start voice recording'));
      
      // Assert attachment button semantics
      final attachmentButtonSemantics = tester.getSemantics(find.byIcon(Icons.attach_file));
      expect(attachmentButtonSemantics.label, equals('Add attachment'));
    });

    testWidgets('should animate send button on press', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LoFiInputComposer(
              onSendMessage: (message) {},
            ),
          ),
        ),
      );
      
      // Enter text to show send button
      await tester.enterText(find.byType(TextField), 'Test');
      await tester.pumpAndSettle();
      
      // Assert ScaleTransition is present for send button
      expect(find.byType(ScaleTransition), findsOneWidget);
      
      // Act - Press and hold send button
      await tester.press(find.byIcon(Icons.send_rounded));
      await tester.pump(const Duration(milliseconds: 100));
      
      // The animation should be running
      await tester.pumpAndSettle();
    });

    testWidgets('should show pulsing animation when recording', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LoFiInputComposer(
              onSendMessage: (message) {},
              isRecording: true,
            ),
          ),
        ),
      );
      
      // Assert - AnimatedBuilder should be present for pulse animation
      expect(find.byType(AnimatedBuilder), findsOneWidget);
      
      // Pump a few frames to check animation
      for (int i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
    });

    testWidgets('should submit message on Enter key when text is present', (WidgetTester tester) async {
      // Arrange
      String? sentMessage;
      const testMessage = 'Enter key test';
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LoFiInputComposer(
              onSendMessage: (message) {
                sentMessage = message;
              },
            ),
          ),
        ),
      );
      
      // Act - Enter text and press Enter
      await tester.enterText(find.byType(TextField), testMessage);
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
      
      // Assert
      expect(sentMessage, equals(testMessage));
    });

    testWidgets('should handle long text input correctly', (WidgetTester tester) async {
      // Arrange
      const longMessage = 'This is a very long message that should be handled properly by the input composer component without any issues or truncation problems.';
      String? sentMessage;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LoFiInputComposer(
              onSendMessage: (message) {
                sentMessage = message;
              },
            ),
          ),
        ),
      );
      
      // Act
      await tester.enterText(find.byType(TextField), longMessage);
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.send_rounded));
      await tester.pumpAndSettle();
      
      // Assert
      expect(sentMessage, equals(longMessage));
    });
  });
}