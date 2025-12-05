import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import '../../../core/config/app_config.dart';
import '../models/chat_message.dart';

/// Enterprise WebSocket service for real-time chat with AI coach
/// Implements JWT-based authentication flow:
/// 1. POST /api/auth/session -> Get JWT
/// 2. Connect WSS with protocols: ['bearer', jwt]
/// 3. Send join_chat -> Get chat_joined
/// 4. Send chat_message -> Get response_chunk
class ChatWebSocketService {
  final Dio _dio;
  final Uuid _uuid = const Uuid();

  WebSocketChannel? _channel;
  
  // Connection state
  bool _isConnecting = false;
  bool _isConnected = false;
  String? _currentChatId;
  String? _currentSessionId;

  // Stream controllers
  final _messageController = StreamController<ChatMessage>.broadcast();
  final _connectionController = StreamController<ChatConnectionStatus>.broadcast();
  final _errorController = StreamController<ChatError>.broadcast();

  // Streaming buffer for AI responses
  final Map<String, StringBuffer> _streamingMessages = {};

  ChatWebSocketService(this._dio);

  // Public streams
  Stream<ChatMessage> get messageStream => _messageController.stream;
  Stream<ChatConnectionStatus> get connectionStream => _connectionController.stream;
  Stream<ChatError> get errorStream => _errorController.stream;

  // Getters
  bool get isConnected => _isConnected;
  bool get isConnecting => _isConnecting;
  String? get currentSessionId => _currentSessionId;
  String? get currentChatId => _currentChatId;

  /// STEP 1: Get JWT Token via HTTP
  Future<String> _getWebSocketToken() async {
    try {
      debugPrint('🔐 [Auth] Requesting JWT Session...');
      
      final response = await _dio.post(
        '${AppConfig.baseUrl}/api/auth/session',
        options: Options(
          headers: {
            'Authorization': 'ApiKey ${AppConfig.apiKey}',
            'Content-Type': 'application/json',
          },
        ),
        data: {
          'tenant_id': AppConfig.tenantId,
        },
      );

      if (response.statusCode == 200) {
        final token = response.data['websocket_token'];
        debugPrint('🎫 [Auth] JWT Obtained: ${token.toString().substring(0, 10)}...');
        return token;
      } else {
        throw ChatException('Failed to get JWT: ${response.statusCode} - ${response.data}');
      }
    } catch (e) {
      debugPrint('❌ [Auth] HTTP Error: $e');
      throw ChatException('Auth Failed: $e');
    }
  }

  /// Disconnect current session
  Future<void> disconnect() async {
    if (_channel != null) {
      debugPrint('🔌 [WS] Disconnecting...');
      await _channel!.sink.close(status.normalClosure);
      _channel = null;
    }
    _isConnected = false;
    _isConnecting = false;
    _connectionController.add(ChatConnectionStatus.disconnected);
  }

  /// STEP 2: Connect WebSocket
  Future<void> connect({String? savedChatId, bool forceReconnect = false}) async {
    if (forceReconnect) {
      await disconnect();
    }

    if (_isConnecting || _isConnected) return;

    _isConnecting = true;
    _connectionController.add(ChatConnectionStatus.connecting);

    try {
      // 1. Get Token
      final jwt = await _getWebSocketToken();
      // ... rest of the function

      debugPrint('🌐 [WS] Connecting with Token...');

      // 2. Connect using IOWebSocketChannel with Protocols
      // CRITICAL: protocols must be a list of strings ['bearer', jwt]
      _channel = IOWebSocketChannel.connect(
        Uri.parse(AppConfig.wsUrl),
        protocols: ['bearer', jwt],
        pingInterval: const Duration(seconds: 30),
      );

      // 3. Listen
      _channel!.stream.listen(
        _handleWebSocketMessage,
        onError: _handleWebSocketError,
        onDone: _handleWebSocketDone,
      );

      // Wait for connection ready (optional, but good for safety)
      await _channel!.ready.timeout(AppConfig.wsConnectionTimeout);

      debugPrint('✅ [WS] Connected. Joining chat...');
      _isConnected = true;
      _isConnecting = false;
      _connectionController.add(ChatConnectionStatus.connected);

      // 4. Join Chat
      _joinChat(savedChatId);

    } catch (e) {
      debugPrint('❌ [WS] Connection Failed: $e');
      _isConnecting = false;
      _handleConnectionError(e);
      rethrow;
    }
  }

  /// STEP 3: Join Chat
  void _joinChat(String? savedChatId) {
    // BACKEND SPEC: Use UUID v4, not timestamps
    _currentChatId = savedChatId ?? _uuid.v4();
    _currentSessionId = _currentChatId; // Use chat_id as session_id for simplicity
    
    if (savedChatId == null) {
      debugPrint('🆕 Generated UUID v4: $_currentChatId');
    } else {
      debugPrint('💾 Resuming Chat UUID: $_currentChatId');
    }

    final payload = jsonEncode({
      'type': 'join_chat',
      'data': {
        'tenant_id': AppConfig.tenantId,
        'chat_id': _currentChatId,
        'create': true,
      }
    });

    _channel?.sink.add(payload);
  }

  /// STEP 4: Send Message
  Future<void> sendMessage(String text, {String? clientMessageId}) async {
    if (!_isConnected || _currentChatId == null) {
      throw const ChatException('Not connected');
    }

    final payload = jsonEncode({
      'type': 'chat_message',
      'data': {
        'message': text,
        'stream': true,
        'chat_id': _currentChatId,
      }
    });

    debugPrint('📤 Sending Payload: $payload');
    _channel?.sink.add(payload);
  }

  /// Handle incoming messages
  void _handleWebSocketMessage(dynamic rawMessage) {
    try {
      final Map<String, dynamic> decoded = jsonDecode(rawMessage);
      final type = decoded['type'];
      final data = decoded['data'] ?? {};

      // Log important events
      if (type != 'message_chunk' && type != 'response_chunk') {
        debugPrint('📥 [WS] Received: $type');
      }

      switch (type) {
        case 'connection_established':
          debugPrint('✅ Connection Established Event');
          break;

        case 'chat_joined':
          final chatId = data['chat_id'];
          debugPrint('✅ Joined Chat: $chatId');
          // Emit a special system message or just let the provider handle the ID save
          // We'll use a custom metadata message to notify provider
          _messageController.add(ChatMessage.system(
            'Connected to chat', 
            metadata: {'type': 'chat_joined', 'chat_id': chatId}
          ));
          break;

        case 'message_chunk':
        case 'response_chunk':
          _handleMessageChunk(data);
          break;

        case 'response_complete':
        case 'message_complete':
          _handleMessageComplete(data);
          break;

        case 'error':
          _handleSystemError(data);
          break;
          
        case 'ping':
          debugPrint('🏓 [WS] Ping received, sending Pong');
          _channel?.sink.add(jsonEncode({'type': 'pong'}));
          break;

        default:
          debugPrint('ℹ️ Unhandled message type: $type');
      }
    } catch (e) {
      debugPrint('⚠️ Parse Error: $e');
      _errorController.add(ChatError.messageParsingFailed(e.toString()));
    }
  }

  void _handleMessageChunk(Map<String, dynamic> data) {
    // Backend sends 'content' in chunk
    final content = data['content'] as String?;
    // Server might not send ID in chunk, assuming single stream for now or ID in data
    // If server doesn't send ID, we assume it's the current active response
    final serverMessageId = data['message_id'] ?? 'current_response';

    if (content != null) {
      _streamingMessages.putIfAbsent(serverMessageId, () => StringBuffer());
      _streamingMessages[serverMessageId]!.write(content);

      final currentText = _streamingMessages[serverMessageId]!.toString();
      
      // Emit updated AI message
      _messageController.add(ChatMessage.ai(
        currentText,
        sessionId: _currentSessionId,
        metadata: {'streaming': true},
      ).copyWith(id: serverMessageId));
    }
  }

  void _handleMessageComplete(Map<String, dynamic> data) {
    final serverMessageId = data['message_id'] ?? 'current_response';
    final fullText = _streamingMessages[serverMessageId]?.toString() ?? '';
    
    _streamingMessages.remove(serverMessageId);
    
    debugPrint('✅ AI Response Complete: ${fullText.length} chars');
    
    _messageController.add(ChatMessage.ai(
      fullText,
      sessionId: _currentSessionId,
      metadata: {'streaming': false},
    ).copyWith(id: serverMessageId));
  }

  void _handleSystemError(Map<String, dynamic> data) {
    debugPrint('❌ Server Error Payload: $data'); // Print full payload
    final message = data['message'] ?? 'Unknown error';
    // Check for details
    final details = data['details'] ?? data['error'] ?? '';
    debugPrint('❌ Server Error: $message $details');
    _errorController.add(ChatError.serverError('$message $details'));
  }

  void _handleWebSocketError(dynamic error) {
    debugPrint('🔥 [WS] Error: $error');
    _errorController.add(ChatError.connectionError(error.toString()));
    _isConnected = false;
    _connectionController.add(ChatConnectionStatus.disconnected);
  }

  void _handleWebSocketDone() {
    debugPrint('🔌 [WS] Closed');
    _isConnected = false;
    _connectionController.add(ChatConnectionStatus.disconnected);
  }

  void _handleConnectionError(dynamic error) {
    _errorController.add(ChatError.connectionError(error.toString()));
    _connectionController.add(ChatConnectionStatus.failed);
  }

  void dispose() {
    _channel?.sink.close(status.goingAway);
    _messageController.close();
    _connectionController.close();
    _errorController.close();
  }
}

// Supporting classes (kept from previous version)
enum ChatConnectionStatus { disconnected, connecting, connected, reconnecting, failed }

class ChatError {
  final String message;
  final String? code;
  final ChatErrorType type;
  const ChatError._(this.message, this.type, [this.code]);
  factory ChatError.connectionError(String message) => ChatError._(message, ChatErrorType.connection);
  factory ChatError.messageParsingFailed(String message) => ChatError._(message, ChatErrorType.messageParsingFailed);
  factory ChatError.serverError(String message, [String? code]) => ChatError._(message, ChatErrorType.serverError, code);
  @override
  String toString() => 'ChatError($type): $message';
}

enum ChatErrorType { connection, sendFailed, messageParsingFailed, serverError, maxReconnectAttemptsExceeded }

class ChatException implements Exception {
  final String message;
  const ChatException(this.message);
  @override
  String toString() => 'ChatException: $message';
}
