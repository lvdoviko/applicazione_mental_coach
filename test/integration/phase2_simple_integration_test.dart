import 'package:flutter_test/flutter_test.dart';

// Import the models and services we want to test (without platform dependencies)
import 'package:applicazione_mental_coach/features/privacy/models/consent_model.dart';
import 'package:applicazione_mental_coach/features/chat/models/chat_message.dart';

void main() {
  group('Phase 2 Simple Integration Tests', () {
    
    group('Consent Model Integration', () {
      test('should handle complete consent workflow', () {
        // Start with empty consent
        final initialConsent = ConsentData(
          dataProcessingConsent: false,
          healthDataConsent: false,
          marketingConsent: false,
          analyticsConsent: false,
          healthPermissionsGranted: false,
          consentVersion: '1.0',
          timestamp: DateTime.now(),
        );
        
        expect(initialConsent.hasRequiredConsents, isFalse);
        expect(initialConsent.summary.grantedCount, equals(0));
        
        // Add required consent
        final withDataConsent = initialConsent.copyWith(
          dataProcessingConsent: true,
        );
        
        expect(withDataConsent.hasRequiredConsents, isTrue);
        expect(withDataConsent.summary.grantedCount, equals(1));
        expect(withDataConsent.summary.hasMinimum, isTrue);
        
        // Add health consent
        final withHealthConsent = withDataConsent.copyWith(
          healthDataConsent: true,
          healthPermissionsGranted: true,
        );
        
        expect(withHealthConsent.hasHealthConsents, isTrue);
        expect(withHealthConsent.summary.grantedCount, equals(3));
        
        // Add all optional consents
        final fullConsent = withHealthConsent.copyWith(
          marketingConsent: true,
          analyticsConsent: true,
        );
        
        expect(fullConsent.summary.grantedCount, equals(5));
        expect(fullConsent.summary.isComplete, isTrue);
        expect(fullConsent.summary.percentageComplete, equals(100));
        
        // Test GDPR export
        final gdprExport = fullConsent.toGdprExport();
        expect(gdprExport, contains('consent_data'));
        expect(gdprExport, contains('legal_basis'));
        expect(gdprExport['legal_basis']['data_processing'], equals('consent'));
        expect(gdprExport['legal_basis']['health_data'], equals('consent'));
        expect(gdprExport['legal_basis']['marketing'], equals('consent'));
        expect(gdprExport['legal_basis']['analytics'], equals('legitimate_interest'));
      });

      test('should handle consent withdrawal scenarios', () {
        // Start with full consent
        final fullConsent = ConsentData(
          dataProcessingConsent: true,
          healthDataConsent: true,
          marketingConsent: true,
          analyticsConsent: true,
          healthPermissionsGranted: true,
          consentVersion: '1.0',
          timestamp: DateTime.now(),
        );
        
        expect(fullConsent.summary.isComplete, isTrue);
        
        // Withdraw health consent (should disable health permissions too)
        final healthWithdrawn = fullConsent.copyWith(
          healthDataConsent: false,
          healthPermissionsGranted: false,
        );
        
        expect(healthWithdrawn.hasHealthConsents, isFalse);
        expect(healthWithdrawn.summary.grantedCount, equals(3)); // data + marketing + analytics
        
        // Withdraw optional consents
        final minimalConsent = healthWithdrawn.copyWith(
          marketingConsent: false,
          analyticsConsent: false,
        );
        
        expect(minimalConsent.hasRequiredConsents, isTrue);
        expect(minimalConsent.summary.grantedCount, equals(1)); // Only data processing
        expect(minimalConsent.summary.hasMinimum, isTrue);
        expect(minimalConsent.summary.isComplete, isFalse);
      });

      test('should validate consent type requirements correctly', () {
        final dataOnlyConsent = ConsentData(
          dataProcessingConsent: true,
          healthDataConsent: false,
          marketingConsent: false,
          analyticsConsent: false,
          healthPermissionsGranted: false,
          consentVersion: '1.0',
          timestamp: DateTime.now(),
        );
        
        // Should pass minimum requirements
        expect(dataOnlyConsent.hasRequiredConsents, isTrue);
        expect(dataOnlyConsent.hasHealthConsents, isFalse);
        expect(dataOnlyConsent.hasAllOptionalConsents, isFalse);
        
        // Test each consent type
        expect(ConsentType.dataProcessing.isRequired, isTrue);
        expect(ConsentType.healthData.isRequired, isFalse);
        expect(ConsentType.marketing.isRequired, isFalse);
        expect(ConsentType.analytics.isRequired, isFalse);
        
        // Test display names
        expect(ConsentType.dataProcessing.displayName, equals('Data Processing'));
        expect(ConsentType.healthData.displayName, equals('Health Data'));
        expect(ConsentType.marketing.displayName, equals('Marketing'));
        expect(ConsentType.analytics.displayName, equals('Analytics'));
      });
    });
    
    group('Chat Message Integration', () {
      test('should handle message lifecycle from creation to delivery', () {
        final sessionId = 'test_session_${DateTime.now().millisecondsSinceEpoch}';
        
        // Create user message
        final userMessage = ChatMessage.user(
          'How can I improve my sleep quality before the competition?',
          sessionId: sessionId,
        );
        
        expect(userMessage.isSending, isTrue);
        expect(userMessage.status, equals(ChatMessageStatus.sending));
        expect(userMessage.text, contains('sleep quality'));
        expect(userMessage.sessionId, equals(sessionId));
        
        // Mark as sent
        final sentMessage = userMessage.copyWithStatus(ChatMessageStatus.sent);
        expect(sentMessage.isSending, isFalse);
        expect(sentMessage.status, equals(ChatMessageStatus.sent));
        expect(sentMessage.id, equals(userMessage.id)); // Same ID
        
        // Create AI response
        final aiMessage = ChatMessage.ai(
          'For better sleep before competition, try establishing a consistent bedtime routine...',
          sessionId: sessionId,
          confidenceScore: 0.94,
          modelUsed: 'kaix-mental-coach-v1',
          processingTimeMs: 750,
        );
        
        expect(aiMessage.isAI, isTrue);
        expect(aiMessage.isUser, isFalse);
        expect(aiMessage.status, equals(ChatMessageStatus.delivered));
        expect(aiMessage.confidenceScore, equals(0.94));
        expect(aiMessage.modelUsed, equals('kaix-mental-coach-v1'));
        expect(aiMessage.processingTimeMs, equals(750));
        expect(aiMessage.sessionId, equals(sessionId));
        
        // Test typing indicator
        final typingMessage = ChatMessage.typing(sessionId: sessionId);
        expect(typingMessage.isTyping, isTrue);
        expect(typingMessage.displayText, equals('AI is typing...'));
        expect(typingMessage.text, isEmpty);
        expect(typingMessage.sessionId, equals(sessionId));
        
        // Test system message
        final systemMessage = ChatMessage.system(
          'Session started with enhanced mental health support',
          sessionId: sessionId,
          metadata: const {'type': 'session_start', 'version': '2.0'},
        );
        
        expect(systemMessage.isSystem, isTrue);
        expect(systemMessage.isUser, isFalse);
        expect(systemMessage.isAI, isFalse);
        expect(systemMessage.getMetadata<String>('type'), equals('session_start'));
        expect(systemMessage.getMetadata<String>('version'), equals('2.0'));
      });
      
      test('should serialize and deserialize WebSocket data correctly', () {
        const sessionId = 'websocket_test_session';
        
        // Test user message serialization
        final userMessage = ChatMessage.user(
          'I feel anxious about tomorrow\'s performance',
          sessionId: sessionId,
        );
        
        final userWebSocketData = userMessage.toWebSocketMap();
        expect(userWebSocketData['type'], equals('user'));
        expect(userWebSocketData['text'], contains('anxious'));
        expect(userWebSocketData['session_id'], equals(sessionId));
        expect(userWebSocketData, contains('timestamp'));
        expect(userWebSocketData, contains('timestamp'));
        
        // Test AI message deserialization
        final aiWebSocketData = <String, dynamic>{
          'id': 'ai_msg_567',
          'type': 'ai',
          'text': 'It\'s natural to feel some pre-performance anxiety. Here are some strategies...',
          'session_id': sessionId,
          'timestamp': DateTime.now().toIso8601String(),
          'confidence_score': 0.96,
          'model_used': 'kaix-v2',
          'processing_time_ms': 1100,
          'escalation_needed': false,
          'metadata': {
            'response_category': 'anxiety_support',
            'techniques_suggested': ['breathing', 'visualization']
          }
        };
        
        final parsedAiMessage = ChatMessage.fromWebSocket(aiWebSocketData);
        expect(parsedAiMessage.id, equals('ai_msg_567'));
        expect(parsedAiMessage.isAI, isTrue);
        expect(parsedAiMessage.text, contains('pre-performance anxiety'));
        expect(parsedAiMessage.confidenceScore, equals(0.96));
        expect(parsedAiMessage.modelUsed, equals('kaix-v2'));
        expect(parsedAiMessage.processingTimeMs, equals(1100));
        expect(parsedAiMessage.escalationNeeded, isFalse);
        expect(parsedAiMessage.sessionId, equals(sessionId));
      });

      test('should handle error scenarios gracefully', () {
        // Test message with error status
        final userMessage = ChatMessage.user('Test message');
        final errorMessage = userMessage.copyWithStatus(ChatMessageStatus.error);
        
        expect(errorMessage.isError, isTrue);
        expect(errorMessage.status, equals(ChatMessageStatus.error));
        
        // Test WebSocket data with missing fields
        final incompleteWebSocketData = <String, dynamic>{
          'type': 'ai',
          'text': 'Response text',
          // Missing session_id, timestamp, etc.
        };
        
        expect(() {
          ChatMessage.fromWebSocket(incompleteWebSocketData);
        }, returnsNormally); // Should not throw
        
        // Test empty message handling
        final emptyMessage = ChatMessage.user('');
        expect(emptyMessage.text, isEmpty);
        expect(emptyMessage.displayText, isEmpty);
      });
    });
    
    group('Performance Integration', () {
      test('should handle high-frequency consent operations efficiently', () {
        final stopwatch = Stopwatch()..start();
        
        // Simulate rapid consent updates
        for (int i = 0; i < 100; i++) {
          final consent = ConsentData(
            dataProcessingConsent: i % 2 == 0,
            healthDataConsent: i % 3 == 0,
            marketingConsent: i % 4 == 0,
            analyticsConsent: i % 5 == 0,
            healthPermissionsGranted: i % 6 == 0,
            consentVersion: '1.0',
            timestamp: DateTime.now(),
          );
          
          final summary = consent.summary;
          final jsonData = consent.toJson();
          final gdprData = consent.toGdprExport();
          
          expect(summary, isNotNull);
          expect(jsonData, isNotNull);
          expect(gdprData, isNotNull);
        }
        
        stopwatch.stop();
        expect(stopwatch.elapsedMilliseconds, lessThan(200)); // Should be very fast
      });
      
      test('should handle high-frequency message operations efficiently', () {
        final stopwatch = Stopwatch()..start();
        
        // Simulate rapid message processing
        for (int i = 0; i < 200; i++) {
          final userMessage = ChatMessage.user('Message $i', sessionId: 'perf_test');
          final webSocketData = userMessage.toWebSocketMap();
          final sentMessage = userMessage.copyWithStatus(ChatMessageStatus.sent);
          
          expect(webSocketData, isNotNull);
          expect(sentMessage.text, equals('Message $i'));
          expect(sentMessage.status, equals(ChatMessageStatus.sent));
        }
        
        stopwatch.stop();
        expect(stopwatch.elapsedMilliseconds, lessThan(300)); // Should be very fast
      });
    });
    
    group('Data Integrity Integration', () {
      test('should maintain data consistency across serialization cycles', () {
        final originalConsent = ConsentData(
          dataProcessingConsent: true,
          healthDataConsent: true,
          marketingConsent: false,
          analyticsConsent: true,
          healthPermissionsGranted: true,
          consentVersion: '1.0',
          timestamp: DateTime.now(),
        );
        
        // Serialize to JSON and back
        final jsonData = originalConsent.toJson();
        final recreatedConsent = ConsentData.fromJson(jsonData);
        
        expect(recreatedConsent.dataProcessingConsent, equals(originalConsent.dataProcessingConsent));
        expect(recreatedConsent.healthDataConsent, equals(originalConsent.healthDataConsent));
        expect(recreatedConsent.marketingConsent, equals(originalConsent.marketingConsent));
        expect(recreatedConsent.analyticsConsent, equals(originalConsent.analyticsConsent));
        expect(recreatedConsent.healthPermissionsGranted, equals(originalConsent.healthPermissionsGranted));
        expect(recreatedConsent.consentVersion, equals(originalConsent.consentVersion));
        
        // Test that summary calculations remain consistent
        expect(recreatedConsent.summary.grantedCount, equals(originalConsent.summary.grantedCount));
        expect(recreatedConsent.summary.isComplete, equals(originalConsent.summary.isComplete));
        expect(recreatedConsent.summary.hasMinimum, equals(originalConsent.summary.hasMinimum));
      });
      
      test('should maintain message integrity across WebSocket serialization', () {
        final originalMessage = ChatMessage.ai(
          'This is a comprehensive response about mental health strategies...',
          sessionId: 'integrity_test',
          confidenceScore: 0.89,
          modelUsed: 'kaix-mental-coach-v1',
          processingTimeMs: 950,
          escalationNeeded: false,
          metadata: const {
            'category': 'mental_health',
            'techniques': ['mindfulness', 'cognitive_restructuring'],
            'urgency': 'low'
          },
        );
        
        // Convert to WebSocket format and back
        final webSocketData = originalMessage.toWebSocketMap();
        final recreatedMessage = ChatMessage.fromWebSocket(webSocketData);
        
        // Test fields that are preserved through WebSocket serialization
        expect(recreatedMessage.text, equals(originalMessage.text));
        expect(recreatedMessage.sessionId, equals(originalMessage.sessionId));
        expect(recreatedMessage.isAI, isTrue);
        expect(recreatedMessage.isUser, isFalse);
        
        // Note: toWebSocketMap() only includes basic fields (type, text, session_id, timestamp, metadata)
        // Advanced fields like confidenceScore, modelUsed, etc. are only included when receiving from backend
      });
    });
  });
}