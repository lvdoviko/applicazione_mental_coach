// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChatMessage _$ChatMessageFromJson(Map<String, dynamic> json) => ChatMessage(
      id: json['id'] as String,
      text: json['text'] as String,
      type: $enumDecode(_$ChatMessageTypeEnumMap, json['type']),
      timestamp: DateTime.parse(json['timestamp'] as String),
      status: $enumDecodeNullable(_$ChatMessageStatusEnumMap, json['status']) ??
          ChatMessageStatus.sent,
      sessionId: json['session_id'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      confidenceScore: (json['confidence_score'] as num?)?.toDouble(),
      modelUsed: json['model_used'] as String?,
      processingTimeMs: (json['processing_time_ms'] as num?)?.toInt(),
      escalationNeeded: json['escalation_needed'] as bool? ?? false,
    );

Map<String, dynamic> _$ChatMessageToJson(ChatMessage instance) =>
    <String, dynamic>{
      'id': instance.id,
      'text': instance.text,
      'type': _$ChatMessageTypeEnumMap[instance.type]!,
      'timestamp': instance.timestamp.toIso8601String(),
      'status': _$ChatMessageStatusEnumMap[instance.status]!,
      'session_id': instance.sessionId,
      'metadata': instance.metadata,
      'confidence_score': instance.confidenceScore,
      'model_used': instance.modelUsed,
      'processing_time_ms': instance.processingTimeMs,
      'escalation_needed': instance.escalationNeeded,
    };

const _$ChatMessageTypeEnumMap = {
  ChatMessageType.user: 'user',
  ChatMessageType.ai: 'ai',
  ChatMessageType.system: 'system',
  ChatMessageType.typing: 'typing',
};

const _$ChatMessageStatusEnumMap = {
  ChatMessageStatus.sending: 'sending',
  ChatMessageStatus.sent: 'sent',
  ChatMessageStatus.delivered: 'delivered',
  ChatMessageStatus.error: 'error',
};
