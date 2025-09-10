// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'consent_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ConsentData _$ConsentDataFromJson(Map<String, dynamic> json) => ConsentData(
      dataProcessingConsent: json['data_processing_consent'] as bool,
      healthDataConsent: json['health_data_consent'] as bool,
      marketingConsent: json['marketing_consent'] as bool,
      analyticsConsent: json['analytics_consent'] as bool,
      healthPermissionsGranted: json['health_permissions_granted'] as bool,
      consentVersion: json['consent_version'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      lastUpdated: json['last_updated'] == null
          ? null
          : DateTime.parse(json['last_updated'] as String),
      consentIpAddress: json['consent_ip_address'] as String?,
      userAgent: json['user_agent'] as String?,
    );

Map<String, dynamic> _$ConsentDataToJson(ConsentData instance) =>
    <String, dynamic>{
      'data_processing_consent': instance.dataProcessingConsent,
      'health_data_consent': instance.healthDataConsent,
      'marketing_consent': instance.marketingConsent,
      'analytics_consent': instance.analyticsConsent,
      'health_permissions_granted': instance.healthPermissionsGranted,
      'consent_version': instance.consentVersion,
      'timestamp': instance.timestamp.toIso8601String(),
      'last_updated': instance.lastUpdated?.toIso8601String(),
      'consent_ip_address': instance.consentIpAddress,
      'user_agent': instance.userAgent,
    };

ConsentWithdrawalRequest _$ConsentWithdrawalRequestFromJson(
        Map<String, dynamic> json) =>
    ConsentWithdrawalRequest(
      userId: json['userId'] as String,
      consentTypes: (json['consentTypes'] as List<dynamic>)
          .map((e) => $enumDecode(_$ConsentTypeEnumMap, e))
          .toList(),
      reason: json['reason'] as String,
      requestedAt: DateTime.parse(json['requestedAt'] as String),
      additionalNotes: json['additionalNotes'] as String?,
    );

Map<String, dynamic> _$ConsentWithdrawalRequestToJson(
        ConsentWithdrawalRequest instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'consentTypes':
          instance.consentTypes.map((e) => _$ConsentTypeEnumMap[e]!).toList(),
      'reason': instance.reason,
      'requestedAt': instance.requestedAt.toIso8601String(),
      'additionalNotes': instance.additionalNotes,
    };

const _$ConsentTypeEnumMap = {
  ConsentType.dataProcessing: 'data_processing',
  ConsentType.healthData: 'health_data',
  ConsentType.marketing: 'marketing',
  ConsentType.analytics: 'analytics',
  ConsentType.all: 'all',
};
