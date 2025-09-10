import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'consent_model.g.dart';

/// GDPR-compliant consent data model
@JsonSerializable(explicitToJson: true)
class ConsentData extends Equatable {
  /// Required: User consent for data processing
  @JsonKey(name: 'data_processing_consent')
  final bool dataProcessingConsent;
  
  /// Optional: User consent for health data processing
  @JsonKey(name: 'health_data_consent')
  final bool healthDataConsent;
  
  /// Optional: User consent for marketing communications
  @JsonKey(name: 'marketing_consent')
  final bool marketingConsent;
  
  /// Optional: User consent for analytics and improvement
  @JsonKey(name: 'analytics_consent')
  final bool analyticsConsent;
  
  /// Health permissions granted status
  @JsonKey(name: 'health_permissions_granted')
  final bool healthPermissionsGranted;
  
  /// Version of consent terms when granted
  @JsonKey(name: 'consent_version')
  final String consentVersion;
  
  /// Timestamp when consent was given
  final DateTime timestamp;
  
  /// Timestamp when consent was last updated
  @JsonKey(name: 'last_updated')
  final DateTime? lastUpdated;
  
  /// IP address when consent was given (for GDPR audit trail)
  @JsonKey(name: 'consent_ip_address')
  final String? consentIpAddress;
  
  /// User agent when consent was given
  @JsonKey(name: 'user_agent')
  final String? userAgent;

  const ConsentData({
    required this.dataProcessingConsent,
    required this.healthDataConsent,
    required this.marketingConsent,
    required this.analyticsConsent,
    required this.healthPermissionsGranted,
    required this.consentVersion,
    required this.timestamp,
    this.lastUpdated,
    this.consentIpAddress,
    this.userAgent,
  });

  /// Create default consent (all false)
  factory ConsentData.empty() {
    return ConsentData(
      dataProcessingConsent: false,
      healthDataConsent: false,
      marketingConsent: false,
      analyticsConsent: false,
      healthPermissionsGranted: false,
      consentVersion: '1.0',
      timestamp: DateTime.now(),
    );
  }

  /// Check if user has given minimum required consents
  bool get hasRequiredConsents => dataProcessingConsent;

  /// Check if user has given health-related consents
  bool get hasHealthConsents => healthDataConsent && healthPermissionsGranted;

  /// Check if all optional consents are given
  bool get hasAllOptionalConsents => marketingConsent && analyticsConsent;

  /// Get consent summary for UI display
  ConsentSummary get summary {
    int grantedCount = 0;
    int totalCount = 5; // Total number of consent types
    
    if (dataProcessingConsent) grantedCount++;
    if (healthDataConsent) grantedCount++;
    if (healthPermissionsGranted) grantedCount++;
    if (marketingConsent) grantedCount++;
    if (analyticsConsent) grantedCount++;
    
    return ConsentSummary(
      grantedCount: grantedCount,
      totalCount: totalCount,
      percentageComplete: (grantedCount / totalCount * 100).round(),
    );
  }

  /// Copy with updated values
  ConsentData copyWith({
    bool? dataProcessingConsent,
    bool? healthDataConsent,
    bool? marketingConsent,
    bool? analyticsConsent,
    bool? healthPermissionsGranted,
    String? consentVersion,
    DateTime? timestamp,
    DateTime? lastUpdated,
    String? consentIpAddress,
    String? userAgent,
  }) {
    return ConsentData(
      dataProcessingConsent: dataProcessingConsent ?? this.dataProcessingConsent,
      healthDataConsent: healthDataConsent ?? this.healthDataConsent,
      marketingConsent: marketingConsent ?? this.marketingConsent,
      analyticsConsent: analyticsConsent ?? this.analyticsConsent,
      healthPermissionsGranted: healthPermissionsGranted ?? this.healthPermissionsGranted,
      consentVersion: consentVersion ?? this.consentVersion,
      timestamp: timestamp ?? this.timestamp,
      lastUpdated: lastUpdated ?? DateTime.now(),
      consentIpAddress: consentIpAddress ?? this.consentIpAddress,
      userAgent: userAgent ?? this.userAgent,
    );
  }

  /// Convert to map for GDPR export
  Map<String, dynamic> toGdprExport() {
    return {
      'consent_data': toJson(),
      'export_timestamp': DateTime.now().toIso8601String(),
      'export_version': '1.0',
      'legal_basis': {
        'data_processing': dataProcessingConsent ? 'consent' : 'not_given',
        'health_data': healthDataConsent ? 'consent' : 'not_given',
        'marketing': marketingConsent ? 'consent' : 'not_given',
        'analytics': analyticsConsent ? 'legitimate_interest' : 'not_given',
      },
    };
  }

  factory ConsentData.fromJson(Map<String, dynamic> json) =>
      _$ConsentDataFromJson(json);

  Map<String, dynamic> toJson() => _$ConsentDataToJson(this);

  @override
  List<Object?> get props => [
    dataProcessingConsent,
    healthDataConsent,
    marketingConsent,
    analyticsConsent,
    healthPermissionsGranted,
    consentVersion,
    timestamp,
    lastUpdated,
    consentIpAddress,
    userAgent,
  ];

  @override
  String toString() {
    return 'ConsentData(data: $dataProcessingConsent, health: $healthDataConsent, '
           'marketing: $marketingConsent, analytics: $analyticsConsent, '
           'permissions: $healthPermissionsGranted, version: $consentVersion)';
  }
}

/// Summary of user consents for UI display
class ConsentSummary {
  final int grantedCount;
  final int totalCount;
  final int percentageComplete;

  const ConsentSummary({
    required this.grantedCount,
    required this.totalCount,
    required this.percentageComplete,
  });

  String get displayText => '$grantedCount of $totalCount consents granted';
  bool get isComplete => grantedCount == totalCount;
  bool get hasMinimum => grantedCount >= 1; // At least data processing consent
}

/// Consent withdrawal request model for GDPR compliance
@JsonSerializable(explicitToJson: true)
class ConsentWithdrawalRequest extends Equatable {
  final String userId;
  final List<ConsentType> consentTypes;
  final String reason;
  final DateTime requestedAt;
  final String? additionalNotes;

  const ConsentWithdrawalRequest({
    required this.userId,
    required this.consentTypes,
    required this.reason,
    required this.requestedAt,
    this.additionalNotes,
  });

  factory ConsentWithdrawalRequest.fromJson(Map<String, dynamic> json) =>
      _$ConsentWithdrawalRequestFromJson(json);

  Map<String, dynamic> toJson() => _$ConsentWithdrawalRequestToJson(this);

  @override
  List<Object?> get props => [userId, consentTypes, reason, requestedAt, additionalNotes];
}

/// Types of consent that can be withdrawn
enum ConsentType {
  @JsonValue('data_processing')
  dataProcessing,
  @JsonValue('health_data')
  healthData,
  @JsonValue('marketing')
  marketing,
  @JsonValue('analytics')
  analytics,
  @JsonValue('all')
  all,
}

extension ConsentTypeExtension on ConsentType {
  String get displayName {
    switch (this) {
      case ConsentType.dataProcessing:
        return 'Data Processing';
      case ConsentType.healthData:
        return 'Health Data';
      case ConsentType.marketing:
        return 'Marketing';
      case ConsentType.analytics:
        return 'Analytics';
      case ConsentType.all:
        return 'All Consents';
    }
  }

  String get description {
    switch (this) {
      case ConsentType.dataProcessing:
        return 'Processing of personal data for AI coaching';
      case ConsentType.healthData:
        return 'Processing of health and wellness data';
      case ConsentType.marketing:
        return 'Marketing communications and updates';
      case ConsentType.analytics:
        return 'Analytics for app improvement';
      case ConsentType.all:
        return 'Withdrawal of all consents and account deletion';
    }
  }

  bool get isRequired {
    return this == ConsentType.dataProcessing;
  }
}