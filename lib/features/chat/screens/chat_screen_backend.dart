import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../design_system/tokens/app_colors.dart';
import '../../../design_system/tokens/app_typography.dart';
import '../../../design_system/tokens/app_spacing.dart';
import '../../../design_system/components/ios_chat_bubble.dart';
import '../../../design_system/components/ios_button.dart';
import '../../../design_system/components/message_composer.dart';
import '../../../design_system/components/quick_reply_chips.dart';
import '../../../core/services/connectivity_service.dart';
import '../../../core/api/secure_api_client.dart';
import '../../../core/security/token_storage_service.dart';
import '../services/chat_websocket_service.dart';
import '../services/offline_fallback_engine.dart';
import '../models/chat_message.dart';

/// Chat screen with full backend integration following KAIX platform flow
class ChatScreenBackend extends ConsumerStatefulWidget {
  final String? initialSessionId;

  const ChatScreenBackend({
    super.key,
    this.initialSessionId,
  });

  @override
  ConsumerState<ChatScreenBackend> createState() => _ChatScreenBackendState();
}

class _ChatScreenBackendState extends ConsumerState<ChatScreenBackend>
    with WidgetsBindingObserver {
  
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _messages = [];
  
  // Services
  late ChatWebSocketService _chatService;
  late OfflineFallbackEngine _offlineEngine;
  late ConnectivityService _connectivityService;
  late SecureApiClient _apiClient;
  late TokenStorageService _tokenStorage;
  
  // State
  bool _isLoading = false;
  bool _isTyping = false;
  bool _isOnline = true;
  ChatConnectionStatus _connectionStatus = ChatConnectionStatus.disconnected;
  
  // Subscriptions
  StreamSubscription<ChatMessage>? _messageSubscription;
  StreamSubscription<ChatConnectionStatus>? _connectionSubscription;
  StreamSubscription<ChatError>? _errorSubscription;
  StreamSubscription<ConnectivityStatus>? _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeServices();
    _setupListeners();
    _connectToChat();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cleanup();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        if (_connectionStatus == ChatConnectionStatus.disconnected) {
          _connectToChat();
        }
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.detached:
        _chatService.disconnect();
        break;
      case AppLifecycleState.hidden:
        break;
    }
  }

  void _initializeServices() {
    _tokenStorage = TokenStorageService();
    _apiClient = SecureApiClient(tokenStorage: _tokenStorage);
    _connectivityService = ConnectivityService();
    _offlineEngine = OfflineFallbackEngine(connectivityService: _connectivityService);
    _chatService = ChatWebSocketService(apiClient: _apiClient);
  }

  void _setupListeners() {
    // Listen to chat messages
    _messageSubscription = _chatService.messageStream.listen(
      _handleIncomingMessage,
      onError: _handleChatError,
    );

    // Listen to connection status
    _connectionSubscription = _chatService.connectionStream.listen(
      _handleConnectionStatusChange,
    );

    // Listen to chat errors
    _errorSubscription = _chatService.errorStream.listen(
      _handleChatError,
    );

    // Listen to connectivity changes
    _connectivitySubscription = _connectivityService.statusStream.listen(
      _handleConnectivityChange,
    );
  }

  Future<void> _connectToChat() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      // Initialize connectivity service
      await _connectivityService.initialize();
      
      // Check if we're online
      final isOnline = _connectivityService.isConnected;
      setState(() => _isOnline = isOnline);

      if (isOnline) {
        // Connect to WebSocket chat service
        await _chatService.connect(sessionId: widget.initialSessionId);
        
        // Add welcome message if this is a new session
        if (_messages.isEmpty) {
          _addWelcomeMessage();
        }
      } else {
        // Show offline mode explanation
        _addOfflineModeMessage();
      }

    } catch (e) {
      _handleChatError(ChatError.connectionError(e.toString()));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _handleIncomingMessage(ChatMessage message) {
    setState(() {
      // Handle typing indicator
      if (message.isTyping) {
        _isTyping = true;
        // Remove typing indicator after 3 seconds if no new message
        Timer(const Duration(seconds: 3), () {
          if (mounted) setState(() => _isTyping = false);
        });
        return;
      }

      _isTyping = false;
      _messages.add(message);
    });

    _scrollToBottom();
  }

  void _handleConnectionStatusChange(ChatConnectionStatus status) {
    setState(() => _connectionStatus = status);

    // Show connection status messages
    switch (status) {
      case ChatConnectionStatus.connected:
        _showStatusMessage('Connected to AI coach', isError: false);
        break;
      case ChatConnectionStatus.reconnecting:
        _showStatusMessage('Reconnecting...', isError: false);
        break;
      case ChatConnectionStatus.failed:
        _showStatusMessage('Connection failed. Trying offline mode...', isError: true);
        _addOfflineModeMessage();
        break;
      default:
        break;
    }
  }

  void _handleConnectivityChange(ConnectivityStatus status) {
    final wasOnline = _isOnline;
    final isOnline = status == ConnectivityStatus.connected;
    
    setState(() => _isOnline = isOnline);

    if (!wasOnline && isOnline) {
      // Back online - attempt to reconnect
      _showStatusMessage('Connection restored. Reconnecting...', isError: false);
      _connectToChat();
    } else if (wasOnline && !isOnline) {
      // Went offline
      _showStatusMessage('Connection lost. Switching to offline mode...', isError: true);
      _addOfflineModeMessage();
    }
  }

  void _handleChatError(dynamic error) {
    String errorMessage = 'An error occurred';
    
    if (error is ChatError) {
      switch (error.type) {
        case ChatErrorType.connection:
          errorMessage = 'Connection error. Switching to offline mode...';
          _addOfflineModeMessage();
          break;
        case ChatErrorType.sendFailed:
          errorMessage = 'Failed to send message. Please try again.';
          break;
        case ChatErrorType.serverError:
          errorMessage = 'Server error: ${error.message}';
          break;
        default:
          errorMessage = error.message;
      }
    }

    _showStatusMessage(errorMessage, isError: true);
  }

  void _addWelcomeMessage() {
    final welcomeMessage = ChatMessage.ai(
      'Hello! I\'m your AI Wellbeing Coach. I\'m here to support you on your mental wellness journey. How are you feeling today?',
      sessionId: _chatService.currentSessionId,
      metadata: const {'welcome_message': true},
    );

    setState(() => _messages.add(welcomeMessage));
    _scrollToBottom();
  }

  void _addOfflineModeMessage() {
    final offlineMessage = _offlineEngine.generateOfflineModeExplanation(
      sessionId: _chatService.currentSessionId,
    );

    setState(() => _messages.add(offlineMessage));
    _scrollToBottom();
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    // Create user message
    final userMessage = ChatMessage.user(
      text.trim(),
      sessionId: _chatService.currentSessionId,
    );

    setState(() {
      _messages.add(userMessage);
      _messageController.clear();
    });

    _scrollToBottom();

    try {
      if (_isOnline && _connectionStatus == ChatConnectionStatus.connected) {
        // Send via WebSocket
        await _chatService.sendMessage(text.trim());
        
        // Update message status to sent
        setState(() {
          final index = _messages.indexWhere((m) => m.id == userMessage.id);
          if (index != -1) {
            _messages[index] = userMessage.copyWithStatus(ChatMessageStatus.sent);
          }
        });

      } else {
        // Use offline fallback
        final offlineResponse = _offlineEngine.generateOfflineResponse(
          text.trim(),
          sessionId: _chatService.currentSessionId,
        );

        setState(() {
          _messages.add(offlineResponse);
        });

        _scrollToBottom();
      }

    } catch (e) {
      // Update message status to error
      setState(() {
        final index = _messages.indexWhere((m) => m.id == userMessage.id);
        if (index != -1) {
          _messages[index] = userMessage.copyWithStatus(ChatMessageStatus.error);
        }
      });

      _handleChatError(e);
    }
  }

  void _sendTypingIndicator(bool isTyping) {
    if (_isOnline && _connectionStatus == ChatConnectionStatus.connected) {
      _chatService.sendTyping(isTyping);
    }
  }

  Future<void> _requestEscalation() async {
    try {
      if (_isOnline && _connectionStatus == ChatConnectionStatus.connected) {
        await _chatService.requestEscalation(
          'user_requested',
          message: 'User requested human support',
        );
        _showStatusMessage('Escalation request sent. A human coach will respond soon.', isError: false);
      } else {
        _showStatusMessage('Escalation requires internet connection. Please try again when online.', isError: true);
      }
    } catch (e) {
      _showStatusMessage('Failed to send escalation request. Please try again.', isError: true);
    }
  }

  void _showStatusMessage(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : AppColors.success,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _cleanup() {
    _scrollController.dispose();
    _messageController.dispose();
    _messageSubscription?.cancel();
    _connectionSubscription?.cancel();
    _errorSubscription?.cancel();
    _connectivitySubscription?.cancel();
    _chatService.dispose();
    _connectivityService.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Column(
        children: [
          if (_connectionStatus != ChatConnectionStatus.connected)
            _buildConnectionStatusBanner(),
          Expanded(
            child: _buildMessagesList(),
          ),
          if (_isTyping)
            _buildTypingIndicator(),
          _buildQuickReplies(),
          _buildMessageComposer(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      title: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.warmGold, AppColors.warmTerracotta],
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.psychology,
              color: AppColors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI Wellbeing Coach',
                  style: AppTypography.h4,
                ),
                Text(
                  _getConnectionStatusText(),
                  style: AppTypography.caption.copyWith(
                    color: _getConnectionStatusColor(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: _requestEscalation,
          icon: const Icon(Icons.support_agent, color: AppColors.primary),
          tooltip: 'Request human coach',
        ),
        IconButton(
          onPressed: () {
            // Show chat settings or options
          },
          icon: const Icon(Icons.more_vert, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildConnectionStatusBanner() {
    if (_connectionStatus == ChatConnectionStatus.connected) {
      return const SizedBox.shrink();
    }

    Color backgroundColor;
    Color textColor;
    IconData icon;
    String text;

    switch (_connectionStatus) {
      case ChatConnectionStatus.connecting:
      case ChatConnectionStatus.reconnecting:
        backgroundColor = AppColors.warning.withValues(alpha: 0.1);
        textColor = AppColors.warning;
        icon = Icons.wifi_protected_setup;
        text = 'Connecting...';
        break;
      case ChatConnectionStatus.disconnected:
        backgroundColor = AppColors.error.withValues(alpha: 0.1);
        textColor = AppColors.error;
        icon = Icons.wifi_off;
        text = _isOnline ? 'Disconnected' : 'Offline Mode';
        break;
      case ChatConnectionStatus.failed:
        backgroundColor = AppColors.error.withValues(alpha: 0.1);
        textColor = AppColors.error;
        icon = Icons.error_outline;
        text = 'Connection Failed';
        break;
      default:
        return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      color: backgroundColor,
      child: Row(
        children: [
          Icon(icon, color: textColor, size: 16),
          const SizedBox(width: AppSpacing.sm),
          Text(
            text,
            style: AppTypography.caption.copyWith(color: textColor),
          ),
          const Spacer(),
          if (_connectionStatus == ChatConnectionStatus.failed)
            IOSButton(
              text: 'Retry',
              style: IOSButtonStyle.tertiary,
              size: IOSButtonSize.small,
              onPressed: _connectToChat,
            ),
        ],
      ),
    );
  }

  Widget _buildMessagesList() {
    if (_messages.isEmpty && _isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: IOSChatBubble(
            message: message.displayText,
            type: message.isUser ? IOSChatBubbleType.user : IOSChatBubbleType.ai,
            timestamp: message.timestamp,
            isLoading: message.isSending,
          ),
        );
      },
    );
  }

  Widget _buildTypingIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'AI is typing',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                const SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(AppColors.primary),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickReplies() {
    // Only show quick replies when connected and not typing
    if (_connectionStatus != ChatConnectionStatus.connected || _isTyping) {
      return const SizedBox.shrink();
    }

    final quickReplies = _getIntelligentQuickReplies();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: QuickReplyChips(
        replies: quickReplies,
        onReplySelected: (reply) => _sendMessage(reply),
      ),
    );
  }

  List<String> _getIntelligentQuickReplies() {
    // If no messages, show smart suggestions based on time of day
    if (_messages.isEmpty) {
      return [
        "Sto attraversando un periodo difficile",
        "Ho bisogno di supporto emotivo",
        "Mi sento sopraffatto",
        "Vorrei parlare di ansia",
      ];
    }
    
    final lastMessage = _messages.last;
    
    // Don't show suggestions after user messages
    if (lastMessage.type == ChatMessageType.user) return [];
    
    // Contextual analysis based on AI's response
    final content = lastMessage.text.toLowerCase();
    
    // Emotional support
    if (content.contains('difficult') || content.contains('struggling')) {
      return [
        "Grazie, mi aiuta molto",
        "Voglio provare questo approccio", 
        "Hai altri consigli?",
        "Come posso iniziare?",
      ];
    }
    
    // Questions about feelings
    if (content.contains('feeling') || content.contains('how are you')) {
      return [
        "Mi sento triste oggi",
        "Sono stressato dal lavoro",
        "Ho problemi di autostima", 
        "Non riesco a dormire bene",
      ];
    }
    
    // Goal and progress topics
    if (content.contains('goal') || content.contains('progress')) {
      return [
        "Voglio fissare un obiettivo",
        "Come posso migliorare?",
        "Ho raggiunto un traguardo",
        "Sto facendo progressi",
      ];
    }
    
    // Immediate help requests
    if (content.contains('help') || content.contains('support')) {
      return [
        "Ho bisogno di aiuto ora",
        "Cosa posso fare oggi?", 
        "Come gestisco questa situazione?",
        "Parliamo di strategie pratiche",
      ];
    }
    
    // Default mental health starters
    return [
      "Sì, esattamente così",
      "È proprio quello che provo",
      "Mi capisci davvero", 
      "Dimmi di più su questo",
    ];
  }

  Widget _buildMessageComposer() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: MessageComposer(
        onSendMessage: _sendMessage,
        hintText: _isOnline 
            ? 'Share what\'s on your mind...'
            : 'Limited responses available offline...',
        enabled: !_isLoading,
        supportsSpeech: _isOnline, // Voice input only when online
        onVoiceStart: () => _sendTypingIndicator(true),
        onVoiceStop: () => _sendTypingIndicator(false),
      ),
    );
  }

  String _getConnectionStatusText() {
    if (!_isOnline) return 'Offline';
    
    switch (_connectionStatus) {
      case ChatConnectionStatus.connected:
        return 'Online';
      case ChatConnectionStatus.connecting:
        return 'Connecting...';
      case ChatConnectionStatus.reconnecting:
        return 'Reconnecting...';
      case ChatConnectionStatus.disconnected:
        return 'Disconnected';
      case ChatConnectionStatus.failed:
        return 'Connection Failed';
    }
  }

  Color _getConnectionStatusColor() {
    if (!_isOnline) return AppColors.error;
    
    switch (_connectionStatus) {
      case ChatConnectionStatus.connected:
        return AppColors.success;
      case ChatConnectionStatus.connecting:
      case ChatConnectionStatus.reconnecting:
        return AppColors.warning;
      case ChatConnectionStatus.disconnected:
      case ChatConnectionStatus.failed:
        return AppColors.error;
    }
  }
}