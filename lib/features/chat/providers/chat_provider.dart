import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/chat_message.dart';
import '../services/chat_websocket_service.dart';
import '../services/guest_auth_service.dart';
import '../services/offline_fallback_engine.dart';
import '../../../core/services/connectivity_service.dart';
import '../../../core/security/token_storage_service.dart';
import '../../../core/api/secure_api_client.dart';

// --- State Class ---
class ChatState {
  final List<ChatMessage> messages;
  final ChatConnectionStatus connectionStatus;
  final bool isTyping;
  final bool isLoading;
  final String? currentChatId;
  final String? error;

  const ChatState({
    this.messages = const [],
    this.connectionStatus = ChatConnectionStatus.disconnected,
    this.isTyping = false,
    this.isLoading = false,
    this.currentChatId,
    this.error,
  });

  ChatState copyWith({
    List<ChatMessage>? messages,
    ChatConnectionStatus? connectionStatus,
    bool? isTyping,
    bool? isLoading,
    String? currentChatId,
    String? error,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      connectionStatus: connectionStatus ?? this.connectionStatus,
      isTyping: isTyping ?? this.isTyping,
      isLoading: isLoading ?? this.isLoading,
      currentChatId: currentChatId ?? this.currentChatId,
      error: error,
    );
  }
}

// --- Notifier Class ---
class ChatNotifier extends StateNotifier<ChatState> {
  final ChatWebSocketService _chatService;
  final GuestAuthService _authService;
  final TokenStorageService _tokenStorage;
  final OfflineFallbackEngine _offlineEngine;
  
  StreamSubscription? _messageSubscription;
  StreamSubscription? _connectionSubscription;
  StreamSubscription? _errorSubscription;

  ChatNotifier({
    required ChatWebSocketService chatService,
    required GuestAuthService authService,
    required TokenStorageService tokenStorage,
    required OfflineFallbackEngine offlineEngine,
  })  : _chatService = chatService,
        _authService = authService,
        _tokenStorage = tokenStorage,
        _offlineEngine = offlineEngine,
        super(const ChatState()) {
    _setupListeners();
  }

  void _setupListeners() {
    _messageSubscription = _chatService.messageStream.listen((message) {
      _handleIncomingMessage(message);
    });

    _connectionSubscription = _chatService.connectionStream.listen((status) {
      state = state.copyWith(
        connectionStatus: status,
        isLoading: status == ChatConnectionStatus.connecting, // Only loading while connecting
      );
    });

    _errorSubscription = _chatService.errorStream.listen((error) {
      state = state.copyWith(error: error.message);
    });
  }

  Future<void> connect() async {
    if (state.connectionStatus == ChatConnectionStatus.connected) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      // 1. Check/Get Token
      // Note: TokenStorageService stores 'jwt_token' but we need 'websocket_token'
      // For now we'll assume they are handled via GuestAuthService which caches internally
      
      // Check if we have a valid guest session
      final authResult = await _authService.authenticateAsGuest();
      
      if (authResult.sessionToken.isNotEmpty) {
        // 2. Connect WebSocket
        // Connect using the session ID if available to resume session
        _chatService.connect(sessionId: authResult.guestId); // Using guestId as session/user identifier context if needed, or let service handle it
        
        // 3. Add welcome message if empty
        if (state.messages.isEmpty) {
          _addWelcomeMessage(authResult.guestId);
        }
      } else {
        state = state.copyWith(
          error: 'Authentication failed',
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
        connectionStatus: ChatConnectionStatus.failed,
      );
    }
  }

  void _handleIncomingMessage(ChatMessage message) {
    if (message.type == ChatMessageType.system && message.metadata?['typing'] == true) {
      state = state.copyWith(isTyping: true);
      return;
    }

    final existingIndex = state.messages.indexWhere((m) => m.id == message.id);
    
    List<ChatMessage> updatedMessages;
    if (existingIndex != -1) {
      updatedMessages = List.from(state.messages);
      updatedMessages[existingIndex] = message;
    } else {
      updatedMessages = [...state.messages, message];
    }

    // If it's an AI message, stop typing indicator
    bool isTyping = state.isTyping;
    if (message.type == ChatMessageType.ai) {
      isTyping = false;
    }

    state = state.copyWith(
      messages: updatedMessages,
      isTyping: isTyping,
      currentChatId: message.metadata?['chat_id'] as String? ?? state.currentChatId,
    );
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final userMessage = ChatMessage.user(
      text.trim(),
      sessionId: _chatService.currentSessionId,
    );

    // Optimistic update
    state = state.copyWith(
      messages: [...state.messages, userMessage],
    );

    try {
      _chatService.sendMessage(
        text,
        clientMessageId: userMessage.id,
      );
    } catch (e) {
      // Handle error (maybe mark message as failed)
      final failedMessage = userMessage.copyWith(status: ChatMessageStatus.error);
      _handleIncomingMessage(failedMessage);
    }
  }

  void _addWelcomeMessage(String? sessionId) {
    const fullText = 'Ciao! Sono il tuo Mental Performance Coach. Sono qui per ottimizzare il tuo mindset. Come ti senti oggi?';
    
    // Create initial empty message
    final initialMessage = ChatMessage.ai(
      '',
      sessionId: sessionId,
      metadata: const {'welcome_message': true},
    );
    
    state = state.copyWith(messages: [initialMessage]);

    // Simulate streaming
    int currentIndex = 0;
    const chunkSize = 2; // Characters per tick
    
    Timer.periodic(const Duration(milliseconds: 30), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (currentIndex < fullText.length) {
        final endIndex = (currentIndex + chunkSize).clamp(0, fullText.length);
        final currentChunk = fullText.substring(0, endIndex);
        
        // Update message
        final updatedMessage = initialMessage.copyWith(
          text: currentChunk,
        );
        
        state = state.copyWith(messages: [updatedMessage]);
        currentIndex += chunkSize;
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _messageSubscription?.cancel();
    _connectionSubscription?.cancel();
    _errorSubscription?.cancel();
    _chatService.dispose();
    super.dispose();
  }
}

// --- Providers ---

final guestAuthServiceProvider = Provider<GuestAuthService>((ref) {
  return GuestAuthService();
});

final chatServiceProvider = Provider<ChatWebSocketService>((ref) {
  return ChatWebSocketService(
    guestAuthService: ref.watch(guestAuthServiceProvider),
  );
});

final tokenStorageProvider = Provider<TokenStorageService>((ref) {
  return TokenStorageService();
});

final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  return ConnectivityService();
});

final offlineEngineProvider = Provider<OfflineFallbackEngine>((ref) {
  return OfflineFallbackEngine(
    connectivityService: ref.watch(connectivityServiceProvider),
  );
});

final chatProvider = StateNotifierProvider<ChatNotifier, ChatState>((ref) {
  return ChatNotifier(
    chatService: ref.watch(chatServiceProvider),
    authService: ref.watch(guestAuthServiceProvider),
    tokenStorage: ref.watch(tokenStorageProvider),
    offlineEngine: ref.watch(offlineEngineProvider),
  );
});
