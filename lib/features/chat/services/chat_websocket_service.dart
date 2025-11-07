import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import '../../../core/api/secure_api_client.dart';
import '../../../core/api/models/auth_response.dart';
import '../../../core/api/exceptions/api_exceptions.dart';
import '../models/chat_message.dart';

/// Service for real-time chat communication via WebSocket
/// Integrates with KAIX Backend Platform following the provided flow diagram
class ChatWebSocketService {
  static const String _wsBaseUrl = 'wss://api.kaixplatform.com/v1/chat';
  static const Duration _tokenRefreshInterval = Duration(minutes: 10); // Refresh before 15min expiry
  static const Duration _connectionTimeout = Duration(seconds: 10);
  static const Duration _reconnectDelay = Duration(seconds: 2);
  static const int _maxReconnectAttempts = 5;

  final SecureApiClient _apiClient;
  WebSocketChannel? _channel;
  WebSocketTokenResponse? _currentToken;
  Timer? _tokenRefreshTimer;
  Timer? _reconnectTimer;
  String? _currentSessionId;
  
  // Connection state
  bool _isConnecting = false;
  bool _isConnected = false;
  bool _shouldReconnect = true;
  int _reconnectAttempts = 0;
  
  // Stream controllers for events
  late final StreamController<ChatMessage> _messageController;
  late final StreamController<ChatConnectionStatus> _connectionController;
  late final StreamController<ChatError> _errorController;

  ChatWebSocketService({required SecureApiClient apiClient})
      : _apiClient = apiClient {
    _messageController = StreamController<ChatMessage>.broadcast();
    _connectionController = StreamController<ChatConnectionStatus>.broadcast();
    _errorController = StreamController<ChatError>.broadcast();
  }

  // Public streams
  Stream<ChatMessage> get messageStream => _messageController.stream;
  Stream<ChatConnectionStatus> get connectionStream => _connectionController.stream;
  Stream<ChatError> get errorStream => _errorController.stream;

  // Getters
  bool get isConnected => _isConnected;
  bool get isConnecting => _isConnecting;
  String? get currentSessionId => _currentSessionId;

  /// Connect to WebSocket chat service
  Future<void> connect({String? sessionId}) async {
    if (_isConnecting || _isConnected) {
      return;
    }

    _isConnecting = true;
    _currentSessionId = sessionId ?? _generateSessionId();
    _connectionController.add(ChatConnectionStatus.connecting);

    try {
      // Step 1: Request WebSocket token from Auth Service
      await _refreshWebSocketToken();

      // Step 2: Connect to WebSocket with token
      await _connectWebSocket();

      _isConnected = true;
      _isConnecting = false;
      _reconnectAttempts = 0;
      _connectionController.add(ChatConnectionStatus.connected);

      // Setup token auto-refresh
      _scheduleTokenRefresh();

    } catch (e) {
      _isConnecting = false;
      _handleConnectionError(e);
    }
  }

  /// Send message to chat service
  Future<void> sendMessage(String text, {Map<String, dynamic>? metadata}) async {
    if (!_isConnected || _channel == null) {
      throw const ChatException('Not connected to chat service');
    }

    final message = {
      'type': 'message',
      'text': text,
      'session_id': _currentSessionId,
      'timestamp': DateTime.now().toIso8601String(),
      'metadata': metadata ?? {},
    };

    try {
      _channel!.sink.add(json.encode(message));
    } catch (e) {
      _errorController.add(ChatError.sendFailed(e.toString()));
      rethrow;
    }
  }

  /// Send typing indicator
  Future<void> sendTyping(bool isTyping) async {
    if (!_isConnected || _channel == null) return;

    final typingMessage = {
      'type': 'typing',
      'session_id': _currentSessionId,
      'is_typing': isTyping,
    };

    try {
      _channel!.sink.add(json.encode(typingMessage));
    } catch (e) {
      // Typing indicators are non-critical, just log
      debugPrint('Failed to send typing indicator: $e');
    }
  }

  /// Disconnect from chat service
  Future<void> disconnect() async {
    _shouldReconnect = false;
    _tokenRefreshTimer?.cancel();
    _reconnectTimer?.cancel();
    
    await _channel?.sink.close(status.goingAway);
    _channel = null;
    
    _isConnected = false;
    _isConnecting = false;
    _connectionController.add(ChatConnectionStatus.disconnected);
  }

  /// Request human escalation
  Future<void> requestEscalation(String reason, {String? message}) async {
    if (!_isConnected || _channel == null) {
      throw const ChatException('Not connected to chat service');
    }

    final escalationRequest = {
      'type': 'escalation',
      'session_id': _currentSessionId,
      'reason': reason,
      'message': message,
      'timestamp': DateTime.now().toIso8601String(),
    };

    try {
      _channel!.sink.add(json.encode(escalationRequest));
    } catch (e) {
      _errorController.add(ChatError.escalationFailed(e.toString()));
      rethrow;
    }
  }

  // === Private Methods ===

  Future<void> _refreshWebSocketToken() async {
    try {
      _currentToken = await _apiClient.getWebSocketToken();
    } on ApiException {
      throw const ChatException('Failed to get WebSocket token');
    } catch (e) {
      throw const ChatException('Failed to get WebSocket token');
    }
  }

  Future<void> _connectWebSocket() async {
    if (_currentToken == null) {
      throw const ChatException('No WebSocket token available');
    }

    final uri = Uri.parse('$_wsBaseUrl?token=${_currentToken!.wsToken}');
    
    try {
      _channel = WebSocketChannel.connect(uri);
      
      // Setup message listener
      _channel!.stream.listen(
        _handleWebSocketMessage,
        onError: _handleWebSocketError,
        onDone: _handleWebSocketDone,
      );

      // Wait for connection to be established
      await _channel!.ready.timeout(_connectionTimeout);
      
    } catch (e) {
      throw const ChatException('Failed to connect to WebSocket');
    }
  }

  void _handleWebSocketMessage(dynamic data) {
    try {
      final Map<String, dynamic> messageData = json.decode(data);
      final messageType = messageData['type'] as String?;

      switch (messageType) {
        case 'message':
          _handleChatMessage(messageData);
          break;
        case 'typing':
          _handleTypingIndicator(messageData);
          break;
        case 'escalation_response':
          _handleEscalationResponse(messageData);
          break;
        case 'error':
          _handleServerError(messageData);
          break;
        case 'connection_ack':
          // Connection acknowledged by server
          break;
        default:
          debugPrint('Unknown message type: $messageType');
      }
    } catch (e) {
      _errorController.add(ChatError.messageParsingFailed(e.toString()));
    }
  }

  void _handleChatMessage(Map<String, dynamic> data) {
    try {
      final message = ChatMessage.fromWebSocket(data);
      _messageController.add(message);
    } catch (e) {
      _errorController.add(ChatError.messageParsingFailed(e.toString()));
    }
  }

  void _handleTypingIndicator(Map<String, dynamic> data) {
    // Handle typing indicator from AI coach
    // This can be used to show "AI is typing..." indicator
    final isTyping = data['is_typing'] as bool? ?? false;
    
    // Emit typing event through message stream with special type
    if (isTyping) {
      _messageController.add(ChatMessage.typing());
    }
  }

  void _handleEscalationResponse(Map<String, dynamic> data) {
    final status = data['status'] as String?;
    final message = data['message'] as String?;
    
    // Create system message about escalation status
    final escalationMessage = ChatMessage.system(
      message ?? 'Escalation request processed: $status',
      metadata: {'escalation_status': status},
    );
    
    _messageController.add(escalationMessage);
  }

  void _handleServerError(Map<String, dynamic> data) {
    final errorMessage = data['message'] as String? ?? 'Unknown server error';
    final errorCode = data['code'] as String?;
    
    _errorController.add(ChatError.serverError(errorMessage, errorCode));
  }

  void _handleWebSocketError(dynamic error) {
    debugPrint('WebSocket error: $error');
    _errorController.add(ChatError.connectionError(error.toString()));
    
    if (_shouldReconnect) {
      _scheduleReconnect();
    }
  }

  void _handleWebSocketDone() {
    debugPrint('WebSocket connection closed');
    _isConnected = false;
    _connectionController.add(ChatConnectionStatus.disconnected);
    
    if (_shouldReconnect && _reconnectAttempts < _maxReconnectAttempts) {
      _scheduleReconnect();
    } else if (_reconnectAttempts >= _maxReconnectAttempts) {
      _connectionController.add(ChatConnectionStatus.failed);
      _errorController.add(ChatError.maxReconnectAttemptsExceeded());
    }
  }

  void _handleConnectionError(dynamic error) {
    debugPrint('Connection error: $error');
    _connectionController.add(ChatConnectionStatus.failed);
    _errorController.add(ChatError.connectionError(error.toString()));
    
    if (_shouldReconnect && _reconnectAttempts < _maxReconnectAttempts) {
      _scheduleReconnect();
    }
  }

  void _scheduleReconnect() {
    if (_reconnectTimer?.isActive == true) return;
    
    _reconnectAttempts++;
    final delay = Duration(
      seconds: (_reconnectDelay.inSeconds * _reconnectAttempts).clamp(2, 30),
    );
    
    debugPrint('Scheduling reconnect in ${delay.inSeconds}s (attempt $_reconnectAttempts)');
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

  void _scheduleTokenRefresh() {
    _tokenRefreshTimer?.cancel();
    
    _tokenRefreshTimer = Timer(_tokenRefreshInterval, () async {
      if (_isConnected) {
        try {
          await _refreshWebSocketToken();
          debugPrint('WebSocket token refreshed');
        } catch (e) {
          debugPrint('Token refresh failed: $e');
          // If token refresh fails, we'll handle it on next message send
        }
      }
    });
  }

  String _generateSessionId() {
    return 'session_${DateTime.now().millisecondsSinceEpoch}_${(1000 + (9000 * (DateTime.now().millisecondsSinceEpoch % 1000) / 1000)).round()}';
  }

  /// Clean up resources
  void dispose() {
    _shouldReconnect = false;
    _tokenRefreshTimer?.cancel();
    _reconnectTimer?.cancel();
    _channel?.sink.close();
    
    _messageController.close();
    _connectionController.close();
    _errorController.close();
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

  factory ChatError.escalationFailed(String message) =>
      ChatError._(message, ChatErrorType.escalationFailed);

  factory ChatError.serverError(String message, [String? code]) =>
      ChatError._(message, ChatErrorType.serverError, code);

  factory ChatError.maxReconnectAttemptsExceeded() =>
      const ChatError._('Max reconnect attempts exceeded', ChatErrorType.maxReconnectAttemptsExceeded);

  @override
  String toString() => 'ChatError($type): $message${code != null ? ' [$code]' : ''}';
}

enum ChatErrorType {
  connection,
  sendFailed,
  messageParsingFailed,
  escalationFailed,
  serverError,
  maxReconnectAttemptsExceeded,
}