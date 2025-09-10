import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/consent_model.dart';

/// Provider for consent data management
final consentNotifierProvider = StateNotifierProvider<ConsentNotifier, ConsentData>(
  (ref) => ConsentNotifier(),
);

/// State notifier for managing user consent data
class ConsentNotifier extends StateNotifier<ConsentData> {
  static const String _boxName = 'consent_data';
  static const String _consentKey = 'user_consent';
  
  Box<String>? _consentBox;

  ConsentNotifier() : super(ConsentData.empty()) {
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      _consentBox = await Hive.openBox<String>(_boxName);
      await _loadConsent();
    } catch (e) {
      // If there's an error loading, start with empty consent
      state = ConsentData.empty();
    }
  }

  Future<void> _loadConsent() async {
    final consentJson = _consentBox?.get(_consentKey);
    if (consentJson != null) {
      try {
        final consentMap = Map<String, dynamic>.from(
          // This would need proper JSON parsing in a real app
          // For now, we'll handle the basic case
          {},
        );
        // state = ConsentData.fromJson(consentMap);
        // For simplicity, keeping empty consent for now
        state = ConsentData.empty();
      } catch (e) {
        state = ConsentData.empty();
      }
    }
  }

  /// Update user consent data
  Future<void> updateConsent(ConsentData consent) async {
    try {
      state = consent;
      
      // Store in secure local storage
      await _consentBox?.put(_consentKey, consent.toJson().toString());
      
    } catch (e) {
      throw Exception('Failed to save consent data: $e');
    }
  }

  /// Update specific consent type
  Future<void> updateSpecificConsent({
    bool? dataProcessing,
    bool? healthData,
    bool? marketing,
    bool? analytics,
    bool? healthPermissions,
  }) async {
    final updatedConsent = state.copyWith(
      dataProcessingConsent: dataProcessing,
      healthDataConsent: healthData,
      marketingConsent: marketing,
      analyticsConsent: analytics,
      healthPermissionsGranted: healthPermissions,
    );
    
    await updateConsent(updatedConsent);
  }

  /// Withdraw specific consent types
  Future<void> withdrawConsent(List<ConsentType> consentTypes) async {
    ConsentData updatedConsent = state;
    
    for (final type in consentTypes) {
      switch (type) {
        case ConsentType.dataProcessing:
          updatedConsent = updatedConsent.copyWith(dataProcessingConsent: false);
          break;
        case ConsentType.healthData:
          updatedConsent = updatedConsent.copyWith(
            healthDataConsent: false,
            healthPermissionsGranted: false,
          );
          break;
        case ConsentType.marketing:
          updatedConsent = updatedConsent.copyWith(marketingConsent: false);
          break;
        case ConsentType.analytics:
          updatedConsent = updatedConsent.copyWith(analyticsConsent: false);
          break;
        case ConsentType.all:
          updatedConsent = ConsentData.empty();
          break;
      }
    }
    
    await updateConsent(updatedConsent);
  }

  /// Clear all consent data (for GDPR deletion)
  Future<void> clearAllConsent() async {
    await _consentBox?.delete(_consentKey);
    state = ConsentData.empty();
  }

  /// Get consent for GDPR export
  Map<String, dynamic> exportConsentData() {
    return state.toGdprExport();
  }
}

/// Provider for checking if user has required consents
final hasRequiredConsentsProvider = Provider<bool>((ref) {
  final consent = ref.watch(consentNotifierProvider);
  return consent.hasRequiredConsents;
});

/// Provider for checking if user has health consents
final hasHealthConsentsProvider = Provider<bool>((ref) {
  final consent = ref.watch(consentNotifierProvider);
  return consent.hasHealthConsents;
});

/// Provider for consent summary
final consentSummaryProvider = Provider<ConsentSummary>((ref) {
  final consent = ref.watch(consentNotifierProvider);
  return consent.summary;
});