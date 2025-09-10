import 'package:flutter_test/flutter_test.dart';

// Import only models and logic without platform dependencies
import 'package:applicazione_mental_coach/features/privacy/models/consent_model.dart';
import 'package:applicazione_mental_coach/features/chat/models/chat_message.dart';

void main() {
  group('Phase 2 Logic Tests', () {
    
    group('ConsentModel Tests', () {
      test('should create and validate consent data', () {
        final consent = ConsentData(
          dataProcessingConsent: true,
          healthDataConsent: false,
          marketingConsent: true,
          analyticsConsent: false,
          healthPermissionsGranted: false,
          consentVersion: '1.0',
          timestamp: DateTime.now(),
        );
        
        expect(consent.hasRequiredConsents, isTrue);
        expect(consent.hasHealthConsents, isFalse);
        expect(consent.hasAllOptionalConsents, isFalse);
        
        final summary = consent.summary;
        expect(summary.grantedCount, equals(2)); // data + marketing
        expect(summary.totalCount, equals(5));
        expect(summary.isComplete, isFalse);
        expect(summary.hasMinimum, isTrue);
      });

      test('should handle consent withdrawal correctly', () {
        final initialConsent = ConsentData(
          dataProcessingConsent: true,
          healthDataConsent: true,
          marketingConsent: true,
          analyticsConsent: true,
          healthPermissionsGranted: true,
          consentVersion: '1.0',
          timestamp: DateTime.now(),
        );
        
        expect(initialConsent.summary.isComplete, isTrue);
        
        // Withdraw some consents
        final updatedConsent = initialConsent.copyWith(
          marketingConsent: false,
          analyticsConsent: false,
        );
        
        expect(updatedConsent.marketingConsent, isFalse);
        expect(updatedConsent.analyticsConsent, isFalse);
        expect(updatedConsent.dataProcessingConsent, isTrue); // Should remain
        expect(updatedConsent.summary.grantedCount, equals(3));
        expect(updatedConsent.lastUpdated, isNotNull);
      });

      test('should serialize and deserialize correctly', () {
        final consent = ConsentData(
          dataProcessingConsent: true,
          healthDataConsent: true,
          marketingConsent: false,
          analyticsConsent: true,
          healthPermissionsGranted: false,
          consentVersion: '1.0',
          timestamp: DateTime.now(),
        );
        
        final json = consent.toJson();
        expect(json, contains('data_processing_consent'));
        expect(json['data_processing_consent'], isTrue);
        expect(json['health_data_consent'], isTrue);
        expect(json['marketing_consent'], isFalse);
        expect(json['analytics_consent'], isTrue);
        expect(json['consent_version'], equals('1.0'));
        
        final recreatedConsent = ConsentData.fromJson(json);
        expect(recreatedConsent.dataProcessingConsent, equals(consent.dataProcessingConsent));
        expect(recreatedConsent.healthDataConsent, equals(consent.healthDataConsent));
        expect(recreatedConsent.marketingConsent, equals(consent.marketingConsent));
        expect(recreatedConsent.analyticsConsent, equals(consent.analyticsConsent));
      });

      test('should generate GDPR export correctly', () {
        final consent = ConsentData(
          dataProcessingConsent: true,
          healthDataConsent: false,
          marketingConsent: true,
          analyticsConsent: false,
          healthPermissionsGranted: false,
          consentVersion: '1.0',
          timestamp: DateTime.now(),
        );
        
        final gdprExport = consent.toGdprExport();
        expect(gdprExport, contains('consent_data'));
        expect(gdprExport, contains('export_timestamp'));
        expect(gdprExport, contains('legal_basis'));
        
        final legalBasis = gdprExport['legal_basis'] as Map<String, dynamic>;
        expect(legalBasis['data_processing'], equals('consent'));
        expect(legalBasis['health_data'], equals('not_given'));
        expect(legalBasis['marketing'], equals('consent'));
      });
    });

    group('ChatMessage Tests', () {
      test('should create user messages correctly', () {
        final message = ChatMessage.user(
          'Hello, I need help',
          sessionId: 'test_session',
        );
        
        expect(message.isUser, isTrue);
        expect(message.isAI, isFalse);
        expect(message.text, equals('Hello, I need help'));
        expect(message.sessionId, equals('test_session'));
        expect(message.status, equals(ChatMessageStatus.sending));
        expect(message.displayText, equals('Hello, I need help'));
      });

      test('should create AI messages correctly', () {
        final message = ChatMessage.ai(
          'I understand. How can I help you today?',
          sessionId: 'test_session',
          confidenceScore: 0.85,
          modelUsed: 'gpt-4',
          processingTimeMs: 1200,
        );
        
        expect(message.isAI, isTrue);
        expect(message.isUser, isFalse);
        expect(message.text, equals('I understand. How can I help you today?'));
        expect(message.confidenceScore, equals(0.85));
        expect(message.modelUsed, equals('gpt-4'));
        expect(message.processingTimeMs, equals(1200));
        expect(message.status, equals(ChatMessageStatus.delivered));
      });

      test('should create system messages correctly', () {
        final message = ChatMessage.system(
          'Session started',
          sessionId: 'test_session',
          metadata: {'type': 'session_start'},
        );
        
        expect(message.isSystem, isTrue);
        expect(message.isUser, isFalse);
        expect(message.isAI, isFalse);
        expect(message.text, equals('Session started'));
        expect(message.getMetadata<String>('type'), equals('session_start'));
      });

      test('should handle typing indicators', () {
        final typingMessage = ChatMessage.typing(sessionId: 'test_session');
        
        expect(typingMessage.isTyping, isTrue);
        expect(typingMessage.displayText, equals('AI is typing...'));
        expect(typingMessage.text, isEmpty);
      });

      test('should update message status correctly', () {
        final originalMessage = ChatMessage.user('Test message');
        expect(originalMessage.status, equals(ChatMessageStatus.sending));
        expect(originalMessage.isSending, isTrue);
        expect(originalMessage.isError, isFalse);
        
        final sentMessage = originalMessage.copyWithStatus(ChatMessageStatus.sent);
        expect(sentMessage.status, equals(ChatMessageStatus.sent));
        expect(sentMessage.isSending, isFalse);
        expect(sentMessage.id, equals(originalMessage.id)); // Should keep same ID
        
        final errorMessage = originalMessage.copyWithStatus(ChatMessageStatus.error);
        expect(errorMessage.status, equals(ChatMessageStatus.error));
        expect(errorMessage.isError, isTrue);
      });

      test('should serialize for WebSocket correctly', () {
        final message = ChatMessage.user(
          'Test message',
          sessionId: 'test_session',
        );
        
        final webSocketMap = message.toWebSocketMap();
        expect(webSocketMap, contains('type'));
        expect(webSocketMap, contains('text'));
        expect(webSocketMap, contains('session_id'));
        expect(webSocketMap, contains('timestamp'));
        expect(webSocketMap['type'], equals('user'));
        expect(webSocketMap['text'], equals('Test message'));
        expect(webSocketMap['session_id'], equals('test_session'));
      });

      test('should parse from WebSocket data correctly', () {
        final webSocketData = {
          'id': 'msg_123',
          'type': 'ai',
          'text': 'AI response',
          'session_id': 'test_session',
          'timestamp': DateTime.now().toIso8601String(),
          'confidence_score': 0.9,
          'model_used': 'gpt-4',
          'processing_time_ms': 800,
          'escalation_needed': false,
        };
        
        final message = ChatMessage.fromWebSocket(webSocketData);
        expect(message.id, equals('msg_123'));
        expect(message.isAI, isTrue);
        expect(message.text, equals('AI response'));
        expect(message.sessionId, equals('test_session'));
        expect(message.confidenceScore, equals(0.9));
        expect(message.modelUsed, equals('gpt-4'));
        expect(message.processingTimeMs, equals(800));
        expect(message.escalationNeeded, isFalse);
      });
    });

    group('ConsentType Enum Tests', () {
      test('should have correct display names', () {
        expect(ConsentType.dataProcessing.displayName, equals('Data Processing'));
        expect(ConsentType.healthData.displayName, equals('Health Data'));
        expect(ConsentType.marketing.displayName, equals('Marketing'));
        expect(ConsentType.analytics.displayName, equals('Analytics'));
        expect(ConsentType.all.displayName, equals('All Consents'));
      });

      test('should identify required consents', () {
        expect(ConsentType.dataProcessing.isRequired, isTrue);
        expect(ConsentType.healthData.isRequired, isFalse);
        expect(ConsentType.marketing.isRequired, isFalse);
        expect(ConsentType.analytics.isRequired, isFalse);
        expect(ConsentType.all.isRequired, isFalse);
      });

      test('should have proper descriptions', () {
        expect(ConsentType.dataProcessing.description, contains('personal data'));
        expect(ConsentType.healthData.description, contains('health'));
        expect(ConsentType.marketing.description.toLowerCase(), contains('marketing'));
        expect(ConsentType.analytics.description.toLowerCase(), contains('analytics'));
      });
    });

    group('Performance Tests', () {
      test('consent operations should be fast', () {
        final stopwatch = Stopwatch()..start();
        
        for (int i = 0; i < 1000; i++) {
          final consent = ConsentData(
            dataProcessingConsent: i % 2 == 0,
            healthDataConsent: i % 3 == 0,
            marketingConsent: i % 4 == 0,
            analyticsConsent: i % 5 == 0,
            healthPermissionsGranted: i % 6 == 0,
            consentVersion: '1.0',
            timestamp: DateTime.now(),
          );
          
          final _ = consent.summary;
          final __ = consent.toJson();
        }
        
        stopwatch.stop();
        expect(stopwatch.elapsedMilliseconds, lessThan(100));
      });

      test('chat message operations should be fast', () {
        final stopwatch = Stopwatch()..start();
        
        for (int i = 0; i < 1000; i++) {
          final message = ChatMessage.user('Test message $i');
          final _ = message.displayText;
          final __ = message.toWebSocketMap();
          final ___ = message.copyWithStatus(ChatMessageStatus.sent);
        }
        
        stopwatch.stop();
        expect(stopwatch.elapsedMilliseconds, lessThan(50));
      });
    });
  });
}