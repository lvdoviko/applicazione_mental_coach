import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';
import '../models/chat_message.dart';
import '../services/chat_websocket_service.dart';
import '../services/offline_fallback_engine.dart';
import '../../../core/services/connectivity_service.dart';
import '../../../core/security/token_storage_service.dart';

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
  final TokenStorageService _tokenStorage;
  final OfflineFallbackEngine _offlineEngine;
  
  StreamSubscription? _messageSubscription;
  StreamSubscription? _connectionSubscription;
  StreamSubscription? _errorSubscription;

  ChatNotifier({
    required ChatWebSocketService chatService,
    required TokenStorageService tokenStorage,
    required OfflineFallbackEngine offlineEngine,
  })  : _chatService = chatService,
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

  Future<void> connect({String? welcomeMessageText}) async {
    // If already connected, check if we need to inject the welcome message
    if (state.connectionStatus == ChatConnectionStatus.connected) {
      if (welcomeMessageText != null && state.messages.isEmpty) {
        debugPrint('⚠️ Already connected, but welcome message missing. Injecting now.');
        _addWelcomeMessage(state.currentChatId, welcomeMessageText);
      }
      return;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      // 1. Get or Generate Chat ID (Persistence)
      String? chatId = await _tokenStorage.getChatId();
      
      if (chatId == null || chatId.startsWith('kaix-')) {
        // Generate new persistent chat ID (UUID v4)
        // BACKEND SPEC: Must be UUID v4, not timestamp based
        chatId = const Uuid().v4();
        await _tokenStorage.storeChatId(chatId);
        debugPrint('🆕 Generated new persistent chat_id (UUID v4): $chatId');

        // Add welcome message for new chats
        if (welcomeMessageText != null) {
          _addWelcomeMessage(chatId, welcomeMessageText);
        }
      } else {
        debugPrint('💾 Loaded persistent chat_id: $chatId');
        // If we have no messages in memory (fresh start), show welcome message
        debugPrint('🔍 Checking welcome message conditions. Messages: ${state.messages.length}, Text: $welcomeMessageText');
        if (state.messages.isEmpty && welcomeMessageText != null) {
          _addWelcomeMessage(chatId, welcomeMessageText);
        }
      }    
      // Update state with chat ID
      state = state.copyWith(currentChatId: chatId);

      // 2. Connect WebSocket with Chat ID
      await _chatService.connect(savedChatId: chatId);
      
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

    // Handle chat_joined event to persist ID
    if (message.metadata?['type'] == 'chat_joined') {
      final newChatId = message.metadata!['chat_id'] as String;
      _tokenStorage.storeChatId(newChatId);
      state = state.copyWith(currentChatId: newChatId);
      debugPrint('💾 Persisted new chat_id from server: $newChatId');
      return; // Internal event, don't show
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
      status: ChatMessageStatus.sending,
    );

    // Optimistic update
    state = state.copyWith(
      messages: [...state.messages, userMessage],
    );

    try {
      await _chatService.sendMessage(
        text,
        clientMessageId: userMessage.id,
      );
      
      // Update status to sent
      final sentMessage = userMessage.copyWith(status: ChatMessageStatus.sent);
      _updateMessage(sentMessage);
      
    } catch (e) {
      // Handle error
      final failedMessage = userMessage.copyWith(status: ChatMessageStatus.error);
      _updateMessage(failedMessage);
    }
  }

  void _updateMessage(ChatMessage updatedMessage) {
    state = state.copyWith(
      messages: state.messages.map((m) {
        return m.id == updatedMessage.id ? updatedMessage : m;
      }).toList(),
    );
  }

  void clearMessages() {
    state = state.copyWith(messages: []);
  }

  Future<void> resetChat({String? welcomeMessageText}) async {
    // 1. Clear local messages
    state = state.copyWith(messages: []);
    
    // 2. Generate new Chat ID for fresh session
    final newChatId = const Uuid().v4();
    await _tokenStorage.storeChatId(newChatId);
    state = state.copyWith(currentChatId: newChatId);
    
    debugPrint('🔄 Chat Reset. New Chat ID: $newChatId');
    
    // 3. Reconnect with new ID (Force disconnect first)
    await _chatService.disconnect();
    
    // 4. Connect and inject welcome message
    await connect(welcomeMessageText: welcomeMessageText);
  }
  bool _isAvatarLoaded = false;
  bool _isWelcomeMessagePending = false;
  String? _pendingWelcomeText;
  ChatMessage? _pendingWelcomeMessage;

  void notifyAvatarLoaded() {
    debugPrint('📢 notifyAvatarLoaded called. _isWelcomeMessagePending: $_isWelcomeMessagePending');
    _isAvatarLoaded = true;
    _tryStartWelcomeStream();
  }

  void _addWelcomeMessage(String? sessionId, String text) {
    debugPrint('➕ _addWelcomeMessage called with text: "$text"');
    // Create initial empty message
    final initialMessage = ChatMessage.ai(
      '',
      sessionId: sessionId,
      metadata: const {'welcome_message': true},
      isStreaming: true,
    );
    
    // Add initial empty message safely
    state = state.copyWith(messages: [...state.messages, initialMessage]);

    // Setup pending stream
    _isWelcomeMessagePending = true;
    _pendingWelcomeText = text;
    _pendingWelcomeMessage = initialMessage;
    
    // Try to start if avatar is already ready
    _tryStartWelcomeStream();
  }

  void _tryStartWelcomeStream() {
    debugPrint('🔄 _tryStartWelcomeStream. Pending: $_isWelcomeMessagePending, AvatarLoaded: $_isAvatarLoaded');
    
    if (_isWelcomeMessagePending && _isAvatarLoaded && _pendingWelcomeText != null && _pendingWelcomeMessage != null) {
      debugPrint('🚀 Starting Welcome Stream!');
      _isWelcomeMessagePending = false; // Prevent double start
      
      // Start streaming
      int currentIndex = 0;
      final fullText = _pendingWelcomeText!;
      final messageId = _pendingWelcomeMessage!.id;
      
      // Use a timer to stream characters
      Timer.periodic(const Duration(milliseconds: 50), (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }
        if (currentIndex < fullText.length) {
          currentIndex++;
          final currentText = fullText.substring(0, currentIndex);
          
            // Update message in state
          state = state.copyWith(
            messages: state.messages.map((m) {
              if (m.id == messageId) {
                return m.copyWith(
                  text: currentText,
                  isStreaming: true,
                );
              }
              return m;
            }).toList(),
          );
        } else {
          timer.cancel();
          // Mark as complete (not streaming)
          state = state.copyWith(
            messages: state.messages.map((m) {
              if (m.id == messageId) {
                return m.copyWith(isStreaming: false);
              }
              return m;
            }).toList(),
          );
          debugPrint('✅ Welcome Stream Complete');
        }
      });
    }
  } @override
  void dispose() {
    _messageSubscription?.cancel();
    _connectionSubscription?.cancel();
    _errorSubscription?.cancel();
    _chatService.dispose();
    super.dispose();
  }
}

// --- Providers ---

final chatServiceProvider = Provider<ChatWebSocketService>((ref) {
  return ChatWebSocketService(Dio());
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
    tokenStorage: ref.watch(tokenStorageProvider),
    offlineEngine: ref.watch(offlineEngineProvider),
  );
});
