import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';

// Import core services that don't depend on complex models
import 'package:applicazione_mental_coach/core/services/connectivity_service.dart';
import 'package:applicazione_mental_coach/core/security/token_storage_service.dart';
import 'package:applicazione_mental_coach/features/chat/services/offline_fallback_engine.dart';
import 'package:applicazione_mental_coach/features/privacy/models/consent_model.dart';

void main() {
  group('Phase 2 Simple Tests', () {
    setUpAll(() async {
      await Hive.initFlutter();
    });

    tearDownAll(() async {
      await Hive.close();
    });

    test('ConnectivityService - Should initialize and provide status', () async {
      final service = ConnectivityService();
      await service.initialize();
      
      expect(service.currentStatus, isNotNull);
      expect(['connected', 'disconnected', 'unknown'], contains(service.currentStatus.name));
      
      final details = await service.getConnectionDetails();
      expect(details, contains('status'));
      expect(details, contains('timestamp'));
      
      service.dispose();
    });

    test('TokenStorageService - Should handle token operations', () async {
      final tokenStorage = TokenStorageService();
      await tokenStorage.initialize();
      
      // Initially should have no auth
      expect(await tokenStorage.hasValidAuth(), isFalse);
      
      // Store test tokens
      const testJwt = 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.test.token';
      const testRefresh = 'refresh.token.test';
      final expiry = DateTime.now().add(const Duration(hours: 1));
      
      await tokenStorage.storeTokens(
        jwtToken: testJwt,
        refreshToken: testRefresh,
        jwtExpiry: expiry,
      );
      
      // Should now have tokens
      expect(await tokenStorage.getJwtToken(), equals(testJwt));
      expect(await tokenStorage.getRefreshToken(), equals(testRefresh));
      expect(await tokenStorage.isJwtExpired(), isFalse);
      
      // Clear tokens
      await tokenStorage.clearTokens();
      expect(await tokenStorage.hasValidAuth(), isFalse);
    });

    test('OfflineFallbackEngine - Should generate appropriate responses', () async {
      final connectivityService = ConnectivityService();
      await connectivityService.initialize();
      
      final offlineEngine = OfflineFallbackEngine(
        connectivityService: connectivityService,
      );
      
      // Test stress response
      final stressResponse = offlineEngine.generateOfflineResponse('I feel stressed');
      expect(stressResponse.text, isNotEmpty);
      expect(stressResponse.text.toLowerCase(), contains('stress'));
      expect(stressResponse.metadata?['offline_mode'], isTrue);
      
      // Test sleep response
      final sleepResponse = offlineEngine.generateOfflineResponse('I can\'t sleep');
      expect(sleepResponse.text, isNotEmpty);
      expect(sleepResponse.text.toLowerCase(), anyOf([
        contains('sleep'),
        contains('rest'),
        contains('bedtime'),
      ]));
      
      // Test general response
      final generalResponse = offlineEngine.generateOfflineResponse('Hello');
      expect(generalResponse.text, isNotEmpty);
      expect(generalResponse.metadata?['offline_mode'], isTrue);
      
      connectivityService.dispose();
    });

    test('ConsentModel - Should handle GDPR consent data', () {
      final consent = ConsentData(
        dataProcessingConsent: true,
        healthDataConsent: false,
        marketingConsent: false,
        analyticsConsent: true,
        healthPermissionsGranted: false,
        consentVersion: '1.0',
        timestamp: DateTime.now(),
      );
      
      // Test consent validation
      expect(consent.hasRequiredConsents, isTrue);
      expect(consent.hasHealthConsents, isFalse);
      expect(consent.hasAllOptionalConsents, isFalse);
      
      // Test consent summary
      final summary = consent.summary;
      expect(summary.grantedCount, equals(2)); // data + analytics
      expect(summary.totalCount, equals(5));
      expect(summary.percentageComplete, equals(40));
      
      // Test serialization
      final json = consent.toJson();
      expect(json, contains('data_processing_consent'));
      expect(json['data_processing_consent'], isTrue);
      expect(json['health_data_consent'], isFalse);
      
      // Test GDPR export
      final gdprExport = consent.toGdprExport();
      expect(gdprExport, contains('consent_data'));
      expect(gdprExport, contains('legal_basis'));
      expect(gdprExport['legal_basis']['data_processing'], equals('consent'));
      expect(gdprExport['legal_basis']['health_data'], equals('not_given'));
    });

    test('ConsentModel - Should handle consent withdrawal', () {
      final initialConsent = ConsentData(
        dataProcessingConsent: true,
        healthDataConsent: true,
        marketingConsent: true,
        analyticsConsent: true,
        healthPermissionsGranted: true,
        consentVersion: '1.0',
        timestamp: DateTime.now(),
      );
      
      expect(initialConsent.summary.grantedCount, equals(5));
      
      // Test copying with withdrawal
      final withdrawnConsent = initialConsent.copyWith(
        marketingConsent: false,
        analyticsConsent: false,
      );
      
      expect(withdrawnConsent.marketingConsent, isFalse);
      expect(withdrawnConsent.analyticsConsent, isFalse);
      expect(withdrawnConsent.dataProcessingConsent, isTrue); // Should remain
      expect(withdrawnConsent.summary.grantedCount, equals(3));
    });

    test('Performance - Offline responses should be fast', () async {
      final connectivityService = ConnectivityService();
      await connectivityService.initialize();
      
      final offlineEngine = OfflineFallbackEngine(
        connectivityService: connectivityService,
      );
      
      final stopwatch = Stopwatch()..start();
      
      // Generate 20 responses
      for (int i = 0; i < 20; i++) {
        final response = offlineEngine.generateOfflineResponse('Test message $i');
        expect(response.text, isNotEmpty);
      }
      
      stopwatch.stop();
      
      // Should be very fast (under 100ms for 20 responses)
      expect(stopwatch.elapsedMilliseconds, lessThan(100));
      
      connectivityService.dispose();
    });

    test('Error Handling - Services should handle errors gracefully', () async {
      // Test connectivity service error handling
      final connectivityService = ConnectivityService();
      await connectivityService.initialize();
      
      // Should not throw when getting connection details
      final details = await connectivityService.getConnectionDetails();
      expect(details, isA<Map<String, dynamic>>());
      expect(details, contains('status'));
      
      connectivityService.dispose();
      
      // Test token storage with invalid data
      final tokenStorage = TokenStorageService();
      await tokenStorage.initialize();
      
      // Should handle missing tokens gracefully
      expect(await tokenStorage.getJwtToken(), isNull);
      expect(await tokenStorage.getRefreshToken(), isNull);
      expect(await tokenStorage.isJwtExpired(), isTrue); // No token = expired
    });
  });
}