import 'package:json_annotation/json_annotation.dart';

part 'auth_response.g.dart';

/// Response model for authentication endpoints
@JsonSerializable()
class AuthResponse {
  @JsonKey(name: 'access_token')
  final String accessToken;
  
  @JsonKey(name: 'refresh_token')
  final String refreshToken;
  
  @JsonKey(name: 'expires_in')
  final int expiresIn; // seconds
  
  @JsonKey(name: 'token_type')
  final String tokenType;
  
  const AuthResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresIn,
    this.tokenType = 'Bearer',
  });
  
  /// Calculate expiry DateTime from expiresIn
  DateTime get expiryDateTime => DateTime.now().add(Duration(seconds: expiresIn));
  
  factory AuthResponse.fromJson(Map<String, dynamic> json) =>
      _$AuthResponseFromJson(json);

  Map<String, dynamic> toJson() => _$AuthResponseToJson(this);
}

/// WebSocket token response model
@JsonSerializable()
class WebSocketTokenResponse {
  @JsonKey(name: 'ws_token')
  final String wsToken;
  
  @JsonKey(name: 'expires_in')
  final int expiresIn; // seconds (typically 900 = 15min)
  
  const WebSocketTokenResponse({
    required this.wsToken,
    required this.expiresIn,
  });
  
  /// Calculate expiry DateTime
  DateTime get expiryDateTime => DateTime.now().add(Duration(seconds: expiresIn));
  
  factory WebSocketTokenResponse.fromJson(Map<String, dynamic> json) =>
      _$WebSocketTokenResponseFromJson(json);

  Map<String, dynamic> toJson() => _$WebSocketTokenResponseToJson(this);
}

/// Generic API error response
@JsonSerializable()
class ApiErrorResponse {
  final String message;
  final String? code;
  final Map<String, dynamic>? details;
  
  const ApiErrorResponse({
    required this.message,
    this.code,
    this.details,
  });
  
  factory ApiErrorResponse.fromJson(Map<String, dynamic> json) =>
      _$ApiErrorResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ApiErrorResponseToJson(this);
}

/// Health snapshot upload response
@JsonSerializable()
class SnapshotUploadResponse {
  @JsonKey(name: 'snapshot_id')
  final String snapshotId;
  
  @JsonKey(name: 'pinecone_id')
  final String? pineconeId;
  
  @JsonKey(name: 'processed_at')
  final String processedAt;
  
  const SnapshotUploadResponse({
    required this.snapshotId,
    this.pineconeId,
    required this.processedAt,
  });
  
  factory SnapshotUploadResponse.fromJson(Map<String, dynamic> json) =>
      _$SnapshotUploadResponseFromJson(json);

  Map<String, dynamic> toJson() => _$SnapshotUploadResponseToJson(this);
}