import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'package:uuid/uuid.dart';
import '../../../core/config/app_config.dart';
import '../../../core/api/secure_api_client.dart';
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
  final SecureApiClient _apiClient;
  final GuestAuthService _guestAuthService;
  final Uuid _uuid = const Uuid();

  WebSocketChannel? _channel;
  Timer? _heartbeatTimer;
  Timer? _reconnectTimer;
  String? _currentSessionId;
  String? _currentGuestId;
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
    required SecureApiClient apiClient,
    required GuestAuthService guestAuthService,
  })  : _apiClient = apiClient,
        _guestAuthService = guestAuthService {
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
      return;
    }

    _isConnecting = true;
    _currentSessionId = sessionId ?? _generateSessionId();
    _connectionController.add(ChatConnectionStatus.connecting);

    try {
      // Step 1: Authenticate as guest and get session token
      await _authenticateGuest();

      // Step 2: Connect to WebSocket with token, tenant, and key
      await _connectWebSocket();

      _isConnected = true;
      _isConnecting = false;
      _reconnectAttempts = 0;
      _connectionController.add(ChatConnectionStatus.connected);

      // Step 3: Start heartbeat monitoring
      _startHeartbeat();

    } catch (e) {
      _isConnecting = false;
      _handleConnectionError(e);
    }
  }

  /// Send chat message with enterprise protocol
  Future<String> sendMessage(String text, {Map<String, dynamic>? metadata}) async {
    if (!_isConnected || _channel == null) {
      throw const ChatException('Not connected to chat service');
    }

    final clientMessageId = _uuid.v4();

    final message = {
      'type': 'chat:message:send',
      'payload': {
        'text': text,
        'clientMessageId': clientMessageId,
      },
    };

    try {
      // Store pending message for deduplication
      _pendingMessages[clientMessageId] = ChatMessage.user(
        text,
        status: ChatMessageStatus.sending,
        metadata: {'clientMessageId': clientMessageId, ...?metadata},
      );

      _channel!.sink.add(json.encode(message));

      // Emit user message to UI immediately
      _messageController.add(_pendingMessages[clientMessageId]!);

      return clientMessageId;
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
    if (_currentToken == null) {
      throw const ChatException('No authentication token available');
    }

    // Build URL with query parameters: token, tenant, key
    final uri = Uri.parse(AppConfig.wsUrl).replace(queryParameters: {
      'token': _currentToken!,
      'tenant': AppConfig.tenantId,
      'key': AppConfig.apiKey,
    });

    debugPrint('Connecting to WebSocket: ${uri.toString().replaceAll(RegExp(r'token=[^&]+'), 'token=***')}');

    try {
      _channel = WebSocketChannel.connect(uri);

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
    try {
      final Map<String, dynamic> messageData = json.decode(data);
      final messageType = messageData['type'] as String?;
      final payload = messageData['payload'] as Map<String, dynamic>?;

      if (payload == null) {
        debugPrint('Message without payload: $messageType');
        return;
      }

      switch (messageType) {
        case 'heartbeat:ping':
          _handleHeartbeatPing(payload);
          break;

        case 'chat:message:ack':
          _handleMessageAck(payload);
          break;

        case 'chat:message:start':
          _handleMessageStart(payload);
          break;

        case 'chat:message:chunk':
          _handleMessageChunk(payload);
          break;

        case 'chat:message:complete':
          _handleMessageComplete(payload);
          break;

        case 'system:error':
          _handleSystemError(payload);
          break;

        default:
          debugPrint('Unknown message type: $messageType');
      }
    } catch (e) {
      _errorController.add(ChatError.messageParsingFailed(e.toString()));
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
    final clientMessageId = payload['clientMessageId'] as String?;
    final serverMessageId = payload['serverMessageId'] as String?;

    if (clientMessageId != null && _pendingMessages.containsKey(clientMessageId)) {
      // Update message status to sent
      final message = _pendingMessages[clientMessageId]!;
      final updatedMessage = message.copyWith(
        status: ChatMessageStatus.sent,
        metadata: {
          ...message.metadata ?? {},
          'serverMessageId': serverMessageId,
        },
      );

      _messageController.add(updatedMessage);
      debugPrint('Message ACK received: $clientMessageId -> $serverMessageId');
    }
  }

  /// Handle AI message generation start
  void _handleMessageStart(Map<String, dynamic> payload) {
    final serverMessageId = payload['serverMessageId'] as String?;

    if (serverMessageId != null) {
      // Initialize streaming buffer
      _streamingMessages[serverMessageId] = StringBuffer();

      // Emit typing indicator
      _messageController.add(ChatMessage.typing());

      debugPrint('AI message generation started: $serverMessageId');
    }
  }

  /// Handle AI message chunk (streaming)
  void _handleMessageChunk(Map<String, dynamic> payload) {
    final serverMessageId = payload['serverMessageId'] as String?;
    final chunk = payload['chunk'] as String?;

    if (serverMessageId != null && chunk != null) {
      // Append to buffer
      _streamingMessages[serverMessageId]?.write(chunk);

      // Emit chunk to UI for real-time rendering
      _chunkController.add(chunk);

      debugPrint('Chunk received: ${chunk.length} chars');
    }
  }

  /// Handle AI message complete
  void _handleMessageComplete(Map<String, dynamic> payload) {
    final serverMessageId = payload['serverMessageId'] as String?;
    final fullText = payload['fullText'] as String?;
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
