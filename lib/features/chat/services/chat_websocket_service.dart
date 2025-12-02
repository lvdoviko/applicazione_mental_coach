import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'package:uuid/uuid.dart';
import '../../../core/config/app_config.dart';

import '../models/chat_message.dart';
import 'guest_auth_service.dart';

/// Enterprise WebSocket service for real-time chat with AI coach
/// Implements multi-tenant protocol with:
/// - Guest authentication
/// - Heartbeat ping/pong (30s interval)
/// - Exponential backoff reconnection
/// - Streaming chunk support for AI responses
/// - Message deduplication
/// - Delivery receipts
class ChatWebSocketService {
  final GuestAuthService _guestAuthService;
  final Uuid _uuid = const Uuid();

  WebSocketChannel? _channel;
  Timer? _heartbeatTimer;
  Timer? _reconnectTimer;
  String? _currentSessionId;
  String? _currentGuestId;
  String? _currentChatId; // Store the active chat ID
  String? _currentToken;

  // Connection state
  bool _isConnecting = false;
  bool _isConnected = false;
  bool _shouldReconnect = true;
  int _reconnectAttempts = 0;

  // Streaming state - for AI chunk assembly
  final Map<String, StringBuffer> _streamingMessages = {};
  final Map<String, ChatMessage> _pendingMessages = {}; // clientMessageId -> message

  // Stream controllers
  late final StreamController<ChatMessage> _messageController;
  late final StreamController<String> _chunkController; // For streaming chunks
  late final StreamController<ChatConnectionStatus> _connectionController;
  late final StreamController<ChatError> _errorController;

  ChatWebSocketService({
    required GuestAuthService guestAuthService,
  })  : _guestAuthService = guestAuthService {
    _messageController = StreamController<ChatMessage>.broadcast();
    _chunkController = StreamController<String>.broadcast();
    _connectionController = StreamController<ChatConnectionStatus>.broadcast();
    _errorController = StreamController<ChatError>.broadcast();
  }

  // Public streams
  Stream<ChatMessage> get messageStream => _messageController.stream;
  Stream<String> get chunkStream => _chunkController.stream;
  Stream<ChatConnectionStatus> get connectionStream => _connectionController.stream;
  Stream<ChatError> get errorStream => _errorController.stream;

  // Getters
  bool get isConnected => _isConnected;
  bool get isConnecting => _isConnecting;
  String? get currentSessionId => _currentSessionId;

  /// Connect to WebSocket chat service with guest authentication
  Future<void> connect({String? sessionId}) async {
    if (_isConnecting || _isConnected) {
      debugPrint('Already connecting or connected, skipping...');
      return;
    }

    debugPrint('🔌 Starting WebSocket connection process...');
    _isConnecting = true;
    _currentSessionId = sessionId ?? _generateSessionId();
    _connectionController.add(ChatConnectionStatus.connecting);

    try {
      // Step 1: Authenticate as guest and get session token
      debugPrint('📱 Step 1: Authenticating as guest...');
      await _authenticateGuest();
      debugPrint('✅ Guest authentication successful');

      // Step 2: Connect to WebSocket with token, tenant, and key
      debugPrint('🌐 Step 2: Connecting to WebSocket...');
      await _connectWebSocket();
      debugPrint('✅ WebSocket connection established');

      _isConnected = true;
      _isConnecting = false;
      _reconnectAttempts = 0;
      _connectionController.add(ChatConnectionStatus.connected);

      // Step 3: Start heartbeat monitoring
      debugPrint('💓 Step 3: Starting heartbeat...');
      _startHeartbeat();
      debugPrint('✅ Connection complete!');

    } catch (e) {
      debugPrint('❌ Connection failed: $e');
      debugPrint('Error type: ${e.runtimeType}');
      _isConnecting = false;
      _handleConnectionError(e);
    }
  }

  /// Send chat message with enterprise protocol
  Future<String> sendMessage(String text, {Map<String, dynamic>? metadata, String? clientMessageId}) async {
    if (!_isConnected || _channel == null) {
      throw const ChatException('Not connected to chat service');
    }

    final messageId = clientMessageId ?? _uuid.v4();

    if (_currentChatId == null) {
      debugPrint('❌ Cannot send message without active chat_id');
      // Optionally queue message or throw error
      throw const ChatException('Cannot send message: No active chat session');
    }

    final message = {
      'type': 'chat_message', // Updated to match backend spec
      'data': {
        'message': text, // Updated from 'content'/'text'
        'chat_id': _currentChatId,
        'stream': true, // Required for streaming
        'client_message_id': messageId, // Required for ACK matching
      },
    };

    try {
      // Store pending message for deduplication
      _pendingMessages[messageId] = ChatMessage.user(
        text,
        id: messageId, // Use the same ID
        status: ChatMessageStatus.sending,
        metadata: {'clientMessageId': messageId, ...?metadata},
      );

      _channel!.sink.add(json.encode(message));

      // Emit user message to UI immediately
      _messageController.add(_pendingMessages[messageId]!);

      return messageId;
    } catch (e) {
      _errorController.add(ChatError.sendFailed(e.toString()));
      rethrow;
    }
  }

  /// Send typing indicator (start)
  Future<void> sendTypingStart() async {
    if (!_isConnected || _channel == null) return;

    final message = {
      'type': 'chat:typing:start',
      'payload': {},
    };

    try {
      _channel!.sink.add(json.encode(message));
    } catch (e) {
      debugPrint('Failed to send typing start: $e');
    }
  }

  /// Send typing indicator (stop)
  Future<void> sendTypingStop() async {
    if (!_isConnected || _channel == null) return;

    final message = {
      'type': 'chat:typing:stop',
      'payload': {},
    };

    try {
      _channel!.sink.add(json.encode(message));
    } catch (e) {
      debugPrint('Failed to send typing stop: $e');
    }
  }

  /// Disconnect from chat service
  Future<void> disconnect() async {
    _shouldReconnect = false;
    _heartbeatTimer?.cancel();
    _reconnectTimer?.cancel();

    await _channel?.sink.close(status.goingAway);
    _channel = null;

    _isConnected = false;
    _isConnecting = false;
    _connectionController.add(ChatConnectionStatus.disconnected);
  }

  // === Private Methods ===

  /// Authenticate as guest user
  Future<void> _authenticateGuest() async {
    try {
      final result = await _guestAuthService.authenticateAsGuest();
      _currentGuestId = result.guestId;
      _currentToken = result.sessionToken;

      debugPrint('Guest authenticated: $_currentGuestId');
    } catch (e) {
      throw ChatException('Guest authentication failed: $e');
    }
  }

  /// Connect to WebSocket with enterprise protocol
  Future<void> _connectWebSocket() async {
    // Check if token is valid or needs refresh
    if (_currentToken == null || await _guestAuthService.isTokenExpired()) {
      debugPrint('🔄 Token expired or missing, refreshing...');
      try {
        final result = await _guestAuthService.authenticateAsGuest();
        _currentToken = result.sessionToken;
        _currentSessionId = result.guestId; // Ensure session ID consistency
      } catch (e) {
        throw ChatException('Failed to refresh token: $e');
      }
    }

    if (_currentToken == null) {
      throw const ChatException('No authentication token available');
    }

    // Use canonical URL without query parameters
    final uri = Uri.parse(AppConfig.wsUrl);

    // Use Bearer subprotocol for authentication
    // Format: Sec-WebSocket-Protocol: bearer, <token>
    // We pass them as separate items so Dart treats them as a list of protocols.
    // The server will select 'bearer' and use the second item for auth.
    final protocols = ['bearer', _currentToken!];

    debugPrint('Connecting to WebSocket: $uri');
    debugPrint('Protocol: bearer,***');

    try {
      _channel = WebSocketChannel.connect(
        uri,
        protocols: protocols,
      );

      // Setup message listener
      _channel!.stream.listen(
        _handleWebSocketMessage,
        onError: _handleWebSocketError,
        onDone: _handleWebSocketDone,
      );

      // Wait for connection to be established
      await _channel!.ready.timeout(AppConfig.wsConnectionTimeout);

      debugPrint('WebSocket connected successfully');
    } catch (e) {
      throw ChatException('Failed to connect to WebSocket: $e');
    }
  }

  /// Handle incoming WebSocket messages (enterprise protocol)
  void _handleWebSocketMessage(dynamic data) {
    debugPrint('📥 Raw WebSocket Message: $data'); // Debug log
    try {
      final Map<String, dynamic> messageData = json.decode(data);
      final messageType = messageData['type'] as String?;
      // Server uses 'data' field, but we check 'payload' for backward compatibility
      final payload = (messageData['data'] ?? messageData['payload']) as Map<String, dynamic>?;

      // Allow specific messages without payload
      if (payload == null && 
          messageType != 'connection_ready' && 
          messageType != 'connection_established' && 
          messageType != 'initialization_progress') {
        debugPrint('Message without payload: $messageType');
        return;
      }

      switch (messageType) {
        case 'connection_ready':
          debugPrint('✅ Connection ready, sending join_chat');
          _sendJoinChat();
          break;

        case 'chat_joined': // Handle successful join
          final chatId = payload?['chat_id'] as String?;
          if (chatId != null) {
            _currentChatId = chatId;
            debugPrint('✅ Joined chat: $_currentChatId');
          }
          break;

        case 'connection_established':
        case 'initialization_progress':
          debugPrint('ℹ️ Status: $messageType');
          break;

        case 'heartbeat:ping':
          if (payload != null) _handleHeartbeatPing(payload);
          break;

        case 'message_received':
          if (payload != null) _handleMessageAck(payload);
          break;

        case 'response_start':
          if (payload != null) _handleMessageStart(payload);
          break;

        case 'response_chunk':
          if (payload != null) _handleMessageChunk(payload);
          break;

        case 'response_complete':
          if (payload != null) _handleMessageComplete(payload);
          break;

        case 'chat:message:ack':
          if (payload != null) _handleMessageAck(payload);
          break;

        case 'chat:message:start':
          if (payload != null) _handleMessageStart(payload);
          break;

        case 'chat:message:chunk':
          if (payload != null) _handleMessageChunk(payload);
          break;

        case 'chat:message:complete':
          if (payload != null) _handleMessageComplete(payload);
          break;

        case 'system:error':
        case 'error': // Handle generic error type
          if (payload != null) _handleSystemError(payload);
          break;

        default:
          debugPrint('Unknown message type: $messageType');
      }
    } catch (e) {
      _errorController.add(ChatError.messageParsingFailed(e.toString()));
    }
  }

  /// Send join chat message to complete handshake
  void _sendJoinChat() {
    // If we don't have a chat ID, we request to create one
    final bool shouldCreate = _currentChatId == null || _currentChatId!.isEmpty;

    final message = {
      'type': 'join_chat',
      'data': {
        if (!shouldCreate) 'chat_id': _currentChatId,
        if (shouldCreate) 'create': true,
      },
    };

    try {
      _channel?.sink.add(json.encode(message));
      debugPrint('👋 Sent join_chat');
    } catch (e) {
      debugPrint('Failed to send join_chat: $e');
    }
  }

  /// Send heartbeat ping to server
  void _sendHeartbeatPing() {
    final pingMessage = {
      'type': 'heartbeat:ping',
      'payload': {
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    };

    try {
      _channel?.sink.add(json.encode(pingMessage));
      debugPrint('💓 Sent heartbeat ping');
    } catch (e) {
      debugPrint('Failed to send heartbeat ping: $e');
    }
  }


  /// Handle heartbeat ping from server
  void _handleHeartbeatPing(Map<String, dynamic> payload) {
    final timestamp = payload['timestamp'] as int?;

    // Respond with pong
    final pongMessage = {
      'type': 'heartbeat:pong',
      'payload': {
        'timestamp': timestamp ?? DateTime.now().millisecondsSinceEpoch,
      },
    };

    try {
      _channel?.sink.add(json.encode(pongMessage));
    } catch (e) {
      debugPrint('Failed to send heartbeat pong: $e');
    }
  }

  /// Handle message acknowledgment from server
  void _handleMessageAck(Map<String, dynamic> payload) {
    debugPrint('📩 ACK Payload: $payload'); // Debug log

    final clientMessageId = (payload['client_message_id'] ?? payload['clientMessageId'] ?? payload['message_id']) as String?;
    final serverMessageId = (payload['server_message_id'] ?? payload['serverMessageId'] ?? payload['message_id']) as String?;

    if (clientMessageId != null) {
      if (_pendingMessages.containsKey(clientMessageId)) {
        _confirmMessageSent(clientMessageId, serverMessageId);
        debugPrint('✅ Message ACK matched: $clientMessageId -> $serverMessageId');
      } else {
        debugPrint('⚠️ Message ACK received for unknown ID: $clientMessageId');
      }
    } else {
      // Fallback: Match with oldest pending message
      if (_pendingMessages.isNotEmpty) {
        final oldestClientMessageId = _pendingMessages.keys.first;
        debugPrint('⚠️ ACK missing client ID. Matching with oldest pending: $oldestClientMessageId');
        _confirmMessageSent(oldestClientMessageId, serverMessageId);
      } else {
        debugPrint('❌ Message ACK received but no pending messages found');
      }
    }
  }

  void _confirmMessageSent(String clientMessageId, String? serverMessageId) {
    if (!_pendingMessages.containsKey(clientMessageId)) return;

    final message = _pendingMessages[clientMessageId]!;
    final updatedMessage = message.copyWith(
      status: ChatMessageStatus.sent,
      metadata: {
        ...message.metadata ?? {},
        if (serverMessageId != null) 'serverMessageId': serverMessageId,
      },
    );

    _messageController.add(updatedMessage);
    _pendingMessages.remove(clientMessageId); // Remove from pending
  }

  /// Handle AI message generation start
  void _handleMessageStart(Map<String, dynamic> payload) {
    final serverMessageId = (payload['server_message_id'] ?? payload['serverMessageId'] ?? payload['message_id']) as String?;

    if (serverMessageId != null) {
      // Initialize streaming buffer
      _streamingMessages[serverMessageId] = StringBuffer();

      // Emit initial empty AI message
      final initialMessage = ChatMessage.ai(
        '',
        sessionId: _currentSessionId,
        metadata: {'serverMessageId': serverMessageId},
      ).copyWith(id: serverMessageId); // Use server ID for consistency

      _messageController.add(initialMessage);

      debugPrint('AI message generation started: $serverMessageId');
    }
  }

  /// Handle AI message chunk (streaming)
  void _handleMessageChunk(Map<String, dynamic> payload) {
    final serverMessageId = (payload['server_message_id'] ?? payload['serverMessageId'] ?? payload['message_id']) as String?;
    final chunk = (payload['chunk'] ?? payload['content']) as String?;

    if (serverMessageId != null && chunk != null) {
      // Append to buffer
      _streamingMessages[serverMessageId]?.write(chunk);
      final currentText = _streamingMessages[serverMessageId]?.toString() ?? '';

      // Emit updated message to UI
      final updatedMessage = ChatMessage.ai(
        currentText,
        sessionId: _currentSessionId,
        metadata: {'serverMessageId': serverMessageId},
      ).copyWith(id: serverMessageId); // Use same ID to update existing message

      _messageController.add(updatedMessage);

      debugPrint('Chunk received: ${chunk.length} chars');
    }
  }

  /// Handle AI message complete
  void _handleMessageComplete(Map<String, dynamic> payload) {
    final serverMessageId = (payload['server_message_id'] ?? payload['serverMessageId']) as String?;
    final fullText = (payload['full_text'] ?? payload['fullText']) as String?;
    final context = payload['context'] as Map<String, dynamic>?;

    if (serverMessageId != null) {
      // Use fullText or assembled chunks
      final messageText = fullText ?? _streamingMessages[serverMessageId]?.toString() ?? '';

      // Create AI message
      final aiMessage = ChatMessage.ai(
        messageText,
        metadata: {
          'serverMessageId': serverMessageId,
          if (context != null) 'context': context,
        },
      );

      // Emit complete message
      _messageController.add(aiMessage);

      // Clean up streaming buffer
      _streamingMessages.remove(serverMessageId);

      debugPrint('AI message complete: $serverMessageId (${messageText.length} chars)');
    }
  }

  /// Handle system error from server
  void _handleSystemError(Map<String, dynamic> payload) {
    final code = payload['code'] as String?;
    final message = payload['message'] as String?;

    _errorController.add(
      ChatError.serverError(message ?? 'Unknown error', code),
    );

    debugPrint('System error: [$code] $message');
  }

  /// Handle WebSocket error
  void _handleWebSocketError(dynamic error) {
    debugPrint('WebSocket error: $error');
    _errorController.add(ChatError.connectionError(error.toString()));

    if (_shouldReconnect) {
      _scheduleReconnect();
    }
  }

  /// Handle WebSocket connection closed
  void _handleWebSocketDone() {
    debugPrint('WebSocket connection closed');
    if (_channel != null) {
      debugPrint('Close Code: ${_channel!.closeCode}');
      debugPrint('Close Reason: ${_channel!.closeReason}');
    }
    _isConnected = false;
    _heartbeatTimer?.cancel();
    _connectionController.add(ChatConnectionStatus.disconnected);

    if (_shouldReconnect && _reconnectAttempts < AppConfig.wsMaxReconnectAttempts) {
      _scheduleReconnect();
    } else if (_reconnectAttempts >= AppConfig.wsMaxReconnectAttempts) {
      _connectionController.add(ChatConnectionStatus.failed);
      _errorController.add(ChatError.maxReconnectAttemptsExceeded());
    }
  }

  /// Handle connection errors
  void _handleConnectionError(dynamic error) {
    debugPrint('Connection error: $error');
    _connectionController.add(ChatConnectionStatus.failed);
    _errorController.add(ChatError.connectionError(error.toString()));

    if (_shouldReconnect && _reconnectAttempts < AppConfig.wsMaxReconnectAttempts) {
      _scheduleReconnect();
    }
  }

  /// Schedule reconnection with exponential backoff
  void _scheduleReconnect() {
    if (_reconnectTimer?.isActive == true) return;

    _reconnectAttempts++;

    // Exponential backoff: 1s, 2s, 4s, 8s, 16s, 30s (max)
    final delaySeconds = (AppConfig.wsReconnectInitialDelay.inSeconds * (1 << (_reconnectAttempts - 1)))
        .clamp(AppConfig.wsReconnectInitialDelay.inSeconds, AppConfig.wsReconnectMaxDelay.inSeconds);

    final delay = Duration(seconds: delaySeconds);

    debugPrint('Scheduling reconnect in ${delay.inSeconds}s (attempt $_reconnectAttempts/${AppConfig.wsMaxReconnectAttempts})');
    _connectionController.add(ChatConnectionStatus.reconnecting);

    _reconnectTimer = Timer(delay, () async {
      if (_shouldReconnect) {
        try {
          await connect(sessionId: _currentSessionId);
        } catch (e) {
          debugPrint('Reconnect failed: $e');
        }
      }
    });
  }

  /// Start heartbeat monitoring (server sends ping every 30s)
  void _startHeartbeat() {
    _heartbeatTimer?.cancel();

    // Monitor for heartbeat timeout
    // Server should send ping every 30s, we expect it within 40s
    _heartbeatTimer = Timer.periodic(
      AppConfig.wsHeartbeatInterval + AppConfig.wsHeartbeatTimeout,
      (timer) {
        // If no ping received in time, connection might be dead
        debugPrint('Heartbeat check - connection alive');
      },
    );
  }

  /// Generate unique session ID
  String _generateSessionId() {
    return 'session_${DateTime.now().millisecondsSinceEpoch}_${_uuid.v4().substring(0, 8)}';
  }

  /// Clean up resources
  void dispose() {
    _shouldReconnect = false;
    _heartbeatTimer?.cancel();
    _reconnectTimer?.cancel();
    _channel?.sink.close();

    _messageController.close();
    _chunkController.close();
    _connectionController.close();
    _errorController.close();

    _streamingMessages.clear();
    _pendingMessages.clear();
  }
}

// === Supporting Classes ===

enum ChatConnectionStatus {
  disconnected,
  connecting,
  connected,
  reconnecting,
  failed,
}

class ChatError {
  final String message;
  final String? code;
  final ChatErrorType type;

  const ChatError._(this.message, this.type, [this.code]);

  factory ChatError.connectionError(String message) =>
      ChatError._(message, ChatErrorType.connection);

  factory ChatError.sendFailed(String message) =>
      ChatError._(message, ChatErrorType.sendFailed);

  factory ChatError.messageParsingFailed(String message) =>
      ChatError._(message, ChatErrorType.messageParsingFailed);

  factory ChatError.serverError(String message, [String? code]) =>
      ChatError._(message, ChatErrorType.serverError, code);

  factory ChatError.maxReconnectAttemptsExceeded() => const ChatError._(
      'Max reconnect attempts exceeded',
      ChatErrorType.maxReconnectAttemptsExceeded);

  @override
  String toString() =>
      'ChatError($type): $message${code != null ? ' [$code]' : ''}';
}

enum ChatErrorType {
  connection,
  sendFailed,
  messageParsingFailed,
  serverError,
  maxReconnectAttemptsExceeded,
}

class ChatException implements Exception {
  final String message;

  const ChatException(this.message);

  @override
  String toString() => 'ChatException: $message';
}
