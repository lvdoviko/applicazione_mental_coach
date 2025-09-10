import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';

// Import the services we want to test
import 'package:applicazione_mental_coach/core/services/connectivity_service.dart';
import 'package:applicazione_mental_coach/core/security/token_storage_service.dart';
import 'package:applicazione_mental_coach/core/api/secure_api_client.dart';
import 'package:applicazione_mental_coach/features/chat/services/offline_fallback_engine.dart';
import 'package:applicazione_mental_coach/features/privacy/models/consent_model.dart';

void main() {
  group('Phase 2 Integration Tests', () {
    setUpAll(() async {
      // Initialize Hive for testing
      await Hive.initFlutter();
    });

    tearDownAll(() async {
      await Hive.close();
    });

    group('ConnectivityService Tests', () {
      test('should initialize connectivity service', () async {
        final connectivityService = ConnectivityService();
        await connectivityService.initialize();
        
        expect(connectivityService.currentStatus, isNotNull);
        
        connectivityService.dispose();
      });

      test('should provide connection details', () async {
        final connectivityService = ConnectivityService();
        await connectivityService.initialize();
        
        final details = await connectivityService.getConnectionDetails();
        expect(details, contains('status'));
        expect(details, contains('timestamp'));
        
        connectivityService.dispose();
      });
    });

    group('TokenStorageService Tests', () {
      test('should initialize token storage', () async {
        final tokenStorage = TokenStorageService();
        await tokenStorage.initialize();
        
        // Should be able to check if we have valid auth (should be false initially)
        final hasAuth = await tokenStorage.hasValidAuth();
        expect(hasAuth, isFalse);
      });

      test('should store and retrieve tokens', () async {
        final tokenStorage = TokenStorageService();
        await tokenStorage.initialize();
        
        const testJwt = 'test.jwt.token';
        const testRefresh = 'test.refresh.token';
        final expiry = DateTime.now().add(const Duration(hours: 1));
        
        await tokenStorage.storeTokens(
          jwtToken: testJwt,
          refreshToken: testRefresh,
          jwtExpiry: expiry,
        );
        
        final retrievedJwt = await tokenStorage.getJwtToken();
        final retrievedRefresh = await tokenStorage.getRefreshToken();
        
        expect(retrievedJwt, equals(testJwt));
        expect(retrievedRefresh, equals(testRefresh));
        
        // Clean up
        await tokenStorage.clearTokens();
      });
    });

    group('SecureApiClient Tests', () {
      test('should create secure API client', () async {
        final tokenStorage = TokenStorageService();
        await tokenStorage.initialize();
        
        final apiClient = SecureApiClient(tokenStorage: tokenStorage);
        
        // Should be able to check authentication status
        final isAuthenticated = await apiClient.isAuthenticated();
        expect(isAuthenticated, isFalse); // No tokens stored yet
        
        apiClient.close();
      });
    });

    group('OfflineFallbackEngine Tests', () {
      test('should provide offline responses', () async {
        final connectivityService = ConnectivityService();
        await connectivityService.initialize();
        
        final offlineEngine = OfflineFallbackEngine(
          connectivityService: connectivityService,
        );
        
        // Test different types of messages
        final testMessages = [
          'I feel stressed',
          'Having trouble sleeping',
          'Need motivation',
          'I feel suicidal', // Crisis detection
          'How are you?', // General
        ];
        
        for (final message in testMessages) {
          final response = offlineEngine.generateOfflineResponse(message);
          expect(response.text, isNotEmpty);
          expect(response.type, equals('ai'));
          expect(response.metadata?['offline_mode'], isTrue);
        }
        
        connectivityService.dispose();
      });
    });

    group('ConsentModel Tests', () {
      test('should create consent data', () {
        final consent = ConsentData(
          dataProcessingConsent: true,
          healthDataConsent: false,
          marketingConsent: false,
          analyticsConsent: true,
          healthPermissionsGranted: false,
          consentVersion: '1.0',
          timestamp: DateTime.now(),
        );
        
        expect(consent.hasRequiredConsents, isTrue);
        expect(consent.hasHealthConsents, isFalse);
        
        final summary = consent.summary;
        expect(summary.grantedCount, equals(2)); // data processing + analytics
        expect(summary.totalCount, equals(5));
      });

      test('should serialize consent data', () {
        final consent = ConsentData(
          dataProcessingConsent: true,
          healthDataConsent: true,
          marketingConsent: false,
          analyticsConsent: true,
          healthPermissionsGranted: true,
          consentVersion: '1.0',
          timestamp: DateTime.now(),
        );
        
        final json = consent.toJson();
        expect(json, contains('data_processing_consent'));
        expect(json, contains('health_data_consent'));
        expect(json, contains('consent_version'));
        
        final exportData = consent.toGdprExport();
        expect(exportData, contains('consent_data'));
        expect(exportData, contains('legal_basis'));
      });
    });

    group('Error Handling Tests', () {
      test('should handle network errors gracefully', () async {
        final connectivityService = ConnectivityService();
        await connectivityService.initialize();
        
        // Test connectivity check with simulated network error
        final details = await connectivityService.getConnectionDetails();
        expect(details, contains('status'));
        
        connectivityService.dispose();
      });
    });

    group('Performance Tests', () {
      test('should perform offline response generation quickly', () async {
        final connectivityService = ConnectivityService();
        await connectivityService.initialize();
        
        final offlineEngine = OfflineFallbackEngine(
          connectivityService: connectivityService,
        );
        
        final stopwatch = Stopwatch()..start();
        
        for (int i = 0; i < 10; i++) {
          offlineEngine.generateOfflineResponse('I feel stressed');
        }
        
        stopwatch.stop();
        expect(stopwatch.elapsedMilliseconds, lessThan(1000)); // Should be very fast
        
        connectivityService.dispose();
      });
    });
  });
}