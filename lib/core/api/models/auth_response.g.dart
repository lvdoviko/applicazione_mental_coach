// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AuthResponse _$AuthResponseFromJson(Map<String, dynamic> json) => AuthResponse(
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String,
      expiresIn: (json['expires_in'] as num).toInt(),
      tokenType: json['token_type'] as String? ?? 'Bearer',
    );

Map<String, dynamic> _$AuthResponseToJson(AuthResponse instance) =>
    <String, dynamic>{
      'access_token': instance.accessToken,
      'refresh_token': instance.refreshToken,
      'expires_in': instance.expiresIn,
      'token_type': instance.tokenType,
    };

WebSocketTokenResponse _$WebSocketTokenResponseFromJson(
        Map<String, dynamic> json) =>
    WebSocketTokenResponse(
      wsToken: json['ws_token'] as String,
      expiresIn: (json['expires_in'] as num).toInt(),
    );

Map<String, dynamic> _$WebSocketTokenResponseToJson(
        WebSocketTokenResponse instance) =>
    <String, dynamic>{
      'ws_token': instance.wsToken,
      'expires_in': instance.expiresIn,
    };

ApiErrorResponse _$ApiErrorResponseFromJson(Map<String, dynamic> json) =>
    ApiErrorResponse(
      message: json['message'] as String,
      code: json['code'] as String?,
      details: json['details'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$ApiErrorResponseToJson(ApiErrorResponse instance) =>
    <String, dynamic>{
      'message': instance.message,
      'code': instance.code,
      'details': instance.details,
    };

SnapshotUploadResponse _$SnapshotUploadResponseFromJson(
        Map<String, dynamic> json) =>
    SnapshotUploadResponse(
      snapshotId: json['snapshot_id'] as String,
      pineconeId: json['pinecone_id'] as String?,
      processedAt: json['processed_at'] as String,
    );

Map<String, dynamic> _$SnapshotUploadResponseToJson(
        SnapshotUploadResponse instance) =>
    <String, dynamic>{
      'snapshot_id': instance.snapshotId,
      'pinecone_id': instance.pineconeId,
      'processed_at': instance.processedAt,
    };
