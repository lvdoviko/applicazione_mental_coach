import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'chat_message.g.dart';

/// Chat message model for WebSocket communication with KAIX Backend Platform
@JsonSerializable(explicitToJson: true)
class ChatMessage extends Equatable {
  /// Unique message identifier
  final String id;
  
  /// Message content text
  final String text;
  
  /// Message type (user, ai, system, typing)
  final ChatMessageType type;
  
  /// Message timestamp
  final DateTime timestamp;
  
  /// Message status (sending, sent, delivered, error)
  final ChatMessageStatus status;
  
  /// Session ID this message belongs to
  @JsonKey(name: 'session_id')
  final String? sessionId;
  
  /// Additional metadata
  final Map<String, dynamic>? metadata;
  
  /// AI response confidence score (0.0 - 1.0)
  @JsonKey(name: 'confidence_score')
  final double? confidenceScore;
  
  /// Model used for AI response
  @JsonKey(name: 'model_used')
  final String? modelUsed;
  
  /// Processing time in milliseconds
  @JsonKey(name: 'processing_time_ms')
  final int? processingTimeMs;
  
  /// Whether escalation is needed/recommended
  @JsonKey(name: 'escalation_needed')
  final bool escalationNeeded;

  /// RAG Citation source
  final String? citation;

  const ChatMessage({
    required this.id,
    required this.text,
    required this.type,
    required this.timestamp,
    this.status = ChatMessageStatus.sent,
    this.sessionId,
    this.metadata,
    this.confidenceScore,
    this.modelUsed,
    this.processingTimeMs,
    this.escalationNeeded = false,
    this.citation,
  });

  // === Factory Constructors ===

  /// Create user message
  factory ChatMessage.user(
    String text, {
    String? sessionId,
    Map<String, dynamic>? metadata,
    ChatMessageStatus status = ChatMessageStatus.sending,
  }) {
    return ChatMessage(
      id: _generateId(),
      text: text,
      type: ChatMessageType.user,
      timestamp: DateTime.now(),
      status: status,
      sessionId: sessionId,
      metadata: metadata,
    );
  }

  /// Create AI response message
  factory ChatMessage.ai(
    String text, {
    String? sessionId,
    Map<String, dynamic>? metadata,
    double? confidenceScore,
    String? modelUsed,
    int? processingTimeMs,
    bool escalationNeeded = false,
    String? citation,
  }) {
    return ChatMessage(
      id: _generateId(),
      text: text,
      type: ChatMessageType.ai,
      timestamp: DateTime.now(),
      status: ChatMessageStatus.delivered,
      sessionId: sessionId,
      metadata: metadata,
      confidenceScore: confidenceScore,
      modelUsed: modelUsed,
      processingTimeMs: processingTimeMs,
      escalationNeeded: escalationNeeded,
      citation: citation,
    );
  }

  /// Create system message
  factory ChatMessage.system(
    String text, {
    String? sessionId,
    Map<String, dynamic>? metadata,
  }) {
    return ChatMessage(
      id: _generateId(),
      text: text,
      type: ChatMessageType.system,
      timestamp: DateTime.now(),
      status: ChatMessageStatus.delivered,
      sessionId: sessionId,
      metadata: metadata,
    );
  }

  /// Create typing indicator message
  factory ChatMessage.typing({String? sessionId}) {
    return ChatMessage(
      id: _generateId(),
      text: '',
      type: ChatMessageType.typing,
      timestamp: DateTime.now(),
      status: ChatMessageStatus.delivered,
      sessionId: sessionId,
    );
  }

  /// Create error message
  factory ChatMessage.error(
    String errorText, {
    String? sessionId,
    Map<String, dynamic>? metadata,
  }) {
    return ChatMessage(
      id: _generateId(),
      text: errorText,
      type: ChatMessageType.system,
      timestamp: DateTime.now(),
      status: ChatMessageStatus.error,
      sessionId: sessionId,
      metadata: {'error': true, ...?metadata},
    );
  }

  /// Create message from WebSocket data
  factory ChatMessage.fromWebSocket(Map<String, dynamic> data) {
    final messageType = _parseMessageType(data['type'] as String? ?? 'ai');
    final timestamp = data['timestamp'] != null 
        ? DateTime.parse(data['timestamp']) 
        : DateTime.now();

    return ChatMessage(
      id: data['id'] as String? ?? _generateId(),
      text: data['text'] as String? ?? '',
      type: messageType,
      timestamp: timestamp,
      status: ChatMessageStatus.delivered,
      sessionId: data['session_id'] as String?,
      metadata: data['metadata'] as Map<String, dynamic>?,
      confidenceScore: (data['confidence_score'] as num?)?.toDouble(),
      modelUsed: data['model_used'] as String?,
      processingTimeMs: data['processing_time_ms'] as int?,
      escalationNeeded: data['escalation_needed'] as bool? ?? false,
      citation: data['citation'] as String?,
    );
  }

  // === Methods ===

  /// Copy message with updated fields
  ChatMessage copyWith({
    String? id,
    String? text,
    ChatMessageType? type,
    DateTime? timestamp,
    ChatMessageStatus? status,
    String? sessionId,
    Map<String, dynamic>? metadata,
    double? confidenceScore,
    String? modelUsed,
    int? processingTimeMs,
    bool? escalationNeeded,
    String? citation,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      text: text ?? this.text,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
      sessionId: sessionId ?? this.sessionId,
      metadata: metadata ?? this.metadata,
      confidenceScore: confidenceScore ?? this.confidenceScore,
      modelUsed: modelUsed ?? this.modelUsed,
      processingTimeMs: processingTimeMs ?? this.processingTimeMs,
      escalationNeeded: escalationNeeded ?? this.escalationNeeded,
      citation: citation ?? this.citation,
    );
  }

  /// Copy message with updated status
  ChatMessage copyWithStatus(ChatMessageStatus newStatus) {
    return copyWith(status: newStatus);
  }

  /// Check if message is from user
  bool get isUser => type == ChatMessageType.user;
  
  /// Check if message is from AI
  bool get isAI => type == ChatMessageType.ai;
  
  /// Check if message is system message
  bool get isSystem => type == ChatMessageType.system;
  
  /// Check if message is typing indicator
  bool get isTyping => type == ChatMessageType.typing;
  
  /// Check if message failed to send/receive
  bool get isError => status == ChatMessageStatus.error;
  
  /// Check if message is still being sent
  bool get isSending => status == ChatMessageStatus.sending;
  
  /// Get display text for UI
  String get displayText {
    if (isTyping) return 'AI is typing...';
    return text;
  }

  /// Get metadata value
  T? getMetadata<T>(String key) {
    return metadata?[key] as T?;
  }

  /// Convert to map for WebSocket sending
  Map<String, dynamic> toWebSocketMap() {
    return {
      'type': type.name,
      'text': text,
      'session_id': sessionId,
      'timestamp': timestamp.toIso8601String(),
      if (metadata != null) 'metadata': metadata,
      if (citation != null) 'citation': citation,
    };
  }

  // === JSON Serialization ===

  factory ChatMessage.fromJson(Map<String, dynamic> json) =>
      _$ChatMessageFromJson(json);

  Map<String, dynamic> toJson() => _$ChatMessageToJson(this);

  // === Equality ===

  @override
  List<Object?> get props => [
    id, text, type, timestamp, status, sessionId, metadata,
    confidenceScore, modelUsed, processingTimeMs, escalationNeeded, citation,
  ];

  // === Private Helpers ===

  static String _generateId() {
    final now = DateTime.now();
    return 'msg_${now.millisecondsSinceEpoch}_${(now.microsecond % 1000).toString().padLeft(3, '0')}';
  }

  static ChatMessageType _parseMessageType(String typeString) {
    switch (typeString.toLowerCase()) {
      case 'user':
        return ChatMessageType.user;
      case 'ai':
      case 'assistant':
        return ChatMessageType.ai;
      case 'system':
        return ChatMessageType.system;
      case 'typing':
        return ChatMessageType.typing;
      default:
        return ChatMessageType.ai;
    }
  }

  @override
  String toString() {
    return 'ChatMessage(id: $id, type: $type, text: "${text.length > 50 ? '${text.substring(0, 50)}...' : text}", status: $status, citation: $citation)';
  }
}

// === Enums ===

enum ChatMessageType {
  user,
  ai,
  system,
  typing,
}

enum ChatMessageStatus {
  sending,
  sent,
  delivered,
  error,
}