import 'package:hive_flutter/hive_flutter.dart';
import '../../../core/config/app_config.dart';
import '../models/chat_message.dart';
import '../models/chat_session.dart';

/// Service for persisting chat messages and sessions locally with Hive
/// Features:
/// - Message persistence with pagination
/// - Session management
/// - Automatic cache cleanup
/// - Search and filtering capabilities
class ChatStorageService {
  static const String _messagesBoxName = 'chat_messages';
  static const String _sessionsBoxName = 'chat_sessions';
  static const String _metadataBoxName = 'chat_metadata';

  Box<ChatMessage>? _messagesBox;
  Box<ChatSession>? _sessionsBox;
  Box<dynamic>? _metadataBox;

  bool _isInitialized = false;

  /// Initialize storage boxes
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Open boxes (adapters must be registered in main.dart)
      _messagesBox = await Hive.openBox<ChatMessage>(_messagesBoxName);
      _sessionsBox = await Hive.openBox<ChatSession>(_sessionsBoxName);
      _metadataBox = await Hive.openBox<dynamic>(_metadataBoxName);

      _isInitialized = true;

      // Schedule cleanup on init
      _scheduleCacheCleanup();
    } catch (e) {
      throw ChatStorageException('Failed to initialize storage: $e');
    }
  }

  /// Ensure storage is initialized
  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      await initialize();
    }
  }

  // === Message Operations ===

  /// Save a single message
  Future<void> saveMessage(ChatMessage message) async {
    await _ensureInitialized();

    try {
      // Use message ID as key for fast lookups
      await _messagesBox!.put(message.id, message);

      // Update session metadata
      if (message.sessionId != null) {
        await _updateSessionMetadata(message.sessionId!, message);
      }
    } catch (e) {
      throw ChatStorageException('Failed to save message: $e');
    }
  }

  /// Save multiple messages in batch
  Future<void> saveMessages(List<ChatMessage> messages) async {
    await _ensureInitialized();

    try {
      final messageMap = {for (var msg in messages) msg.id: msg};
      await _messagesBox!.putAll(messageMap);

      // Update session metadata for affected sessions
      final sessionIds = messages
          .where((m) => m.sessionId != null)
          .map((m) => m.sessionId!)
          .toSet();

      for (final sessionId in sessionIds) {
        final sessionMessages = messages.where((m) => m.sessionId == sessionId);
        if (sessionMessages.isNotEmpty) {
          await _updateSessionMetadata(sessionId, sessionMessages.last);
        }
      }
    } catch (e) {
      throw ChatStorageException('Failed to save messages: $e');
    }
  }

  /// Get message by ID
  Future<ChatMessage?> getMessage(String messageId) async {
    await _ensureInitialized();
    return _messagesBox!.get(messageId);
  }

  /// Load messages for a session with pagination
  Future<List<ChatMessage>> loadMessages({
    required String sessionId,
    int limit = 50,
    int offset = 0,
  }) async {
    await _ensureInitialized();

    try {
      final allMessages = _messagesBox!.values
          .where((msg) => msg.sessionId == sessionId)
          .toList()
        ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

      // Apply pagination
      final startIndex = offset;
      final endIndex = (offset + limit).clamp(0, allMessages.length);

      if (startIndex >= allMessages.length) {
        return [];
      }

      return allMessages.sublist(startIndex, endIndex);
    } catch (e) {
      throw ChatStorageException('Failed to load messages: $e');
    }
  }

  /// Load all messages for a session (no pagination)
  Future<List<ChatMessage>> loadAllMessages(String sessionId) async {
    await _ensureInitialized();

    return _messagesBox!.values
        .where((msg) => msg.sessionId == sessionId)
        .toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
  }

  /// Get most recent messages across all sessions
  Future<List<ChatMessage>> getRecentMessages({int limit = 20}) async {
    await _ensureInitialized();

    final allMessages = _messagesBox!.values.toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    return allMessages.take(limit).toList();
  }

  /// Delete a message
  Future<void> deleteMessage(String messageId) async {
    await _ensureInitialized();
    await _messagesBox!.delete(messageId);
  }

  /// Delete all messages for a session
  Future<void> deleteSessionMessages(String sessionId) async {
    await _ensureInitialized();

    final sessionMessageIds = _messagesBox!.values
        .where((msg) => msg.sessionId == sessionId)
        .map((msg) => msg.id)
        .toList();

    await _messagesBox!.deleteAll(sessionMessageIds);
  }

  /// Count messages in a session
  Future<int> getMessageCount(String sessionId) async {
    await _ensureInitialized();

    return _messagesBox!.values
        .where((msg) => msg.sessionId == sessionId)
        .length;
  }

  // === Session Operations ===

  /// Create or update a session
  Future<void> saveSession(ChatSession session) async {
    await _ensureInitialized();

    try {
      await _sessionsBox!.put(session.id, session);
    } catch (e) {
      throw ChatStorageException('Failed to save session: $e');
    }
  }

  /// Get session by ID
  Future<ChatSession?> getSession(String sessionId) async {
    await _ensureInitialized();
    return _sessionsBox!.get(sessionId);
  }

  /// Load all sessions
  Future<List<ChatSession>> loadAllSessions() async {
    await _ensureInitialized();

    return _sessionsBox!.values.toList()
      ..sort((a, b) => b.startedAt.compareTo(a.startedAt));
  }

  /// Get most recent session
  Future<ChatSession?> getLastSession() async {
    await _ensureInitialized();

    final sessions = await loadAllSessions();
    return sessions.isNotEmpty ? sessions.first : null;
  }

  /// Delete a session and its messages
  Future<void> deleteSession(String sessionId) async {
    await _ensureInitialized();

    // Delete messages first
    await deleteSessionMessages(sessionId);

    // Delete session
    await _sessionsBox!.delete(sessionId);
  }

  /// Update session metadata when new message arrives
  Future<void> _updateSessionMetadata(
    String sessionId,
    ChatMessage lastMessage,
  ) async {
    var session = await getSession(sessionId);

    if (session == null) {
      // Create new session
      session = ChatSession(
        id: sessionId,
        startedAt: lastMessage.timestamp,
        messageCount: 1,
        lastMessagePreview: lastMessage.text,
        lastMessageAt: lastMessage.timestamp,
      );
    } else {
      // Update existing session
      final messageCount = await getMessageCount(sessionId);
      session = session.copyWith(
        messageCount: messageCount,
        lastMessagePreview: lastMessage.text,
        lastMessageAt: lastMessage.timestamp,
      );
    }

    await saveSession(session);
  }

  /// End a session
  Future<void> endSession(String sessionId) async {
    final session = await getSession(sessionId);
    if (session != null && session.endedAt == null) {
      final updatedSession = session.copyWith(
        endedAt: DateTime.now(),
      );
      await saveSession(updatedSession);
    }
  }

  // === Search Operations ===

  /// Search messages by text content
  Future<List<ChatMessage>> searchMessages(String query, {String? sessionId}) async {
    await _ensureInitialized();

    final lowerQuery = query.toLowerCase();

    var messages = _messagesBox!.values.where((msg) {
      // Filter by session if provided
      if (sessionId != null && msg.sessionId != sessionId) {
        return false;
      }

      // Search in message text
      return msg.text.toLowerCase().contains(lowerQuery);
    }).toList();

    // Sort by timestamp (newest first)
    messages.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    return messages;
  }

  // === Maintenance Operations ===

  /// Clear old messages based on retention policy
  Future<void> clearOldMessages() async {
    await _ensureInitialized();

    try {
      final cutoffDate = DateTime.now().subtract(AppConfig.dataRetentionPeriod);

      // Find messages older than retention period
      final oldMessageIds = _messagesBox!.values
          .where((msg) => msg.timestamp.isBefore(cutoffDate))
          .map((msg) => msg.id)
          .toList();

      // Delete old messages
      if (oldMessageIds.isNotEmpty) {
        await _messagesBox!.deleteAll(oldMessageIds);
        print('Deleted ${oldMessageIds.length} old messages');
      }

      // Clean up empty sessions
      await _cleanupEmptySessions();
    } catch (e) {
      print('Error clearing old messages: $e');
    }
  }

  /// Clean up sessions with no messages
  Future<void> _cleanupEmptySessions() async {
    final sessions = await loadAllSessions();

    for (final session in sessions) {
      final messageCount = await getMessageCount(session.id);
      if (messageCount == 0) {
        await _sessionsBox!.delete(session.id);
      }
    }
  }

  /// Enforce cache size limit
  Future<void> enforceCacheLimit() async {
    await _ensureInitialized();

    final messageCount = _messagesBox!.length;

    if (messageCount > AppConfig.maxCachedMessages) {
      // Delete oldest messages to stay under limit
      final excessCount = messageCount - AppConfig.maxCachedMessages;

      final allMessages = _messagesBox!.values.toList()
        ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

      final messagesToDelete = allMessages.take(excessCount).map((m) => m.id);

      await _messagesBox!.deleteAll(messagesToDelete);

      print('Deleted $excessCount messages to enforce cache limit');
    }
  }

  /// Schedule automatic cache cleanup
  void _scheduleCacheCleanup() {
    // Cleanup runs on app start - periodic cleanup can be added if needed
    Future.delayed(const Duration(seconds: 5), () async {
      await clearOldMessages();
      await enforceCacheLimit();
    });
  }

  // === Stats Operations ===

  /// Get storage statistics
  Future<Map<String, dynamic>> getStats() async {
    await _ensureInitialized();

    final messageCount = _messagesBox!.length;
    final sessionCount = _sessionsBox!.length;
    final oldestMessage = _messagesBox!.values.isNotEmpty
        ? _messagesBox!.values.reduce((a, b) => a.timestamp.isBefore(b.timestamp) ? a : b)
        : null;
    final newestMessage = _messagesBox!.values.isNotEmpty
        ? _messagesBox!.values.reduce((a, b) => a.timestamp.isAfter(b.timestamp) ? a : b)
        : null;

    return {
      'totalMessages': messageCount,
      'totalSessions': sessionCount,
      'oldestMessageDate': oldestMessage?.timestamp.toIso8601String(),
      'newestMessageDate': newestMessage?.timestamp.toIso8601String(),
      'cacheLimit': AppConfig.maxCachedMessages,
      'cacheUsage': messageCount / AppConfig.maxCachedMessages,
    };
  }

  // === Utility Methods ===

  /// Clear all data (for testing or reset)
  Future<void> clearAll() async {
    await _ensureInitialized();

    await _messagesBox!.clear();
    await _sessionsBox!.clear();
    await _metadataBox!.clear();
  }

  /// Close all boxes
  Future<void> close() async {
    await _messagesBox?.close();
    await _sessionsBox?.close();
    await _metadataBox?.close();

    _isInitialized = false;
  }
}

/// Exception thrown by storage operations
class ChatStorageException implements Exception {
  final String message;

  ChatStorageException(this.message);

  @override
  String toString() => 'ChatStorageException: $message';
}
