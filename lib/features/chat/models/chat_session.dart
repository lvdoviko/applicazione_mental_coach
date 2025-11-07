import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'chat_session.g.dart';

/// Chat session model for tracking conversation sessions
/// Each session represents a continuous conversation with the AI coach
@HiveType(typeId: 11)
@JsonSerializable(explicitToJson: true)
class ChatSession extends Equatable {
  /// Unique session identifier
  @HiveField(0)
  final String id;

  /// When the session started
  @HiveField(1)
  final DateTime startedAt;

  /// When the session ended (null if still active)
  @HiveField(2)
  final DateTime? endedAt;

  /// Number of messages in this session
  @HiveField(3)
  final int messageCount;

  /// Preview of last message (for UI)
  @HiveField(4)
  final String? lastMessagePreview;

  /// Timestamp of last message
  @HiveField(5)
  final DateTime? lastMessageAt;

  /// Additional session metadata
  @HiveField(6)
  final Map<String, dynamic>? metadata;

  const ChatSession({
    required this.id,
    required this.startedAt,
    this.endedAt,
    this.messageCount = 0,
    this.lastMessagePreview,
    this.lastMessageAt,
    this.metadata,
  });

  /// Check if session is currently active
  bool get isActive => endedAt == null;

  /// Get session duration
  Duration get duration {
    final end = endedAt ?? DateTime.now();
    return end.difference(startedAt);
  }

  /// Copy session with updated fields
  ChatSession copyWith({
    String? id,
    DateTime? startedAt,
    DateTime? endedAt,
    int? messageCount,
    String? lastMessagePreview,
    DateTime? lastMessageAt,
    Map<String, dynamic>? metadata,
  }) {
    return ChatSession(
      id: id ?? this.id,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      messageCount: messageCount ?? this.messageCount,
      lastMessagePreview: lastMessagePreview ?? this.lastMessagePreview,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Create a new session
  factory ChatSession.create({String? id, Map<String, dynamic>? metadata}) {
    return ChatSession(
      id: id ?? 'session_${DateTime.now().millisecondsSinceEpoch}',
      startedAt: DateTime.now(),
      metadata: metadata,
    );
  }

  // === JSON Serialization ===

  factory ChatSession.fromJson(Map<String, dynamic> json) =>
      _$ChatSessionFromJson(json);

  Map<String, dynamic> toJson() => _$ChatSessionToJson(this);

  // === Equality ===

  @override
  List<Object?> get props => [
        id,
        startedAt,
        endedAt,
        messageCount,
        lastMessagePreview,
        lastMessageAt,
        metadata,
      ];

  @override
  String toString() {
    return 'ChatSession(id: $id, messageCount: $messageCount, active: $isActive)';
  }
}
