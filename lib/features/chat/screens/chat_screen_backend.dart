import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../design_system/tokens/app_colors.dart';
import '../../../design_system/tokens/app_typography.dart';
import '../../../design_system/tokens/app_spacing.dart';
import '../../../design_system/components/lofi_message_bubble.dart';
import '../../../design_system/components/ios_button.dart';
import '../../../design_system/components/message_composer.dart';
import '../../../core/services/connectivity_service.dart';
import '../services/chat_websocket_service.dart';
import '../models/chat_message.dart';
import '../providers/chat_provider.dart';

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
  
  // State
  bool _isOnline = true;
  bool _isCrisisMode = false; // Safety Net State
  
  // Subscriptions
  StreamSubscription<ConnectivityStatus>? _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    // Connect when screen initializes (if not already connected)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(chatProvider.notifier).connect();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scrollController.dispose();
    _connectivitySubscription?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        // Reconnect logic handled by provider or service usually, 
        // but we can trigger a check here if needed.
        ref.read(chatProvider.notifier).connect();
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        break;
    }
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

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatProvider);
    
    // Auto-scroll on new messages
    ref.listen(chatProvider, (previous, next) {
      if (previous?.messages.length != next.messages.length) {
        _scrollToBottom();
      }
    });

    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      color: _isCrisisMode ? AppColors.warmTerracotta.withOpacity(0.1) : AppColors.background,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: _buildAppBar(chatState.connectionStatus),
        body: Column(
          children: [
            if (_isCrisisMode) _buildSafetyNetBanner(),
            if (chatState.connectionStatus != ChatConnectionStatus.connected)
              _buildConnectionStatusBanner(chatState.connectionStatus),
            Expanded(
              child: _buildMessagesList(chatState.messages, chatState.isLoading),
            ),
            if (chatState.isTyping)
              _buildTypingIndicator(),
            _buildMessageComposer(chatState.isLoading),
          ],
        ),
      ),
    );
  }

  Widget _buildSafetyNetBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      color: AppColors.warmTerracotta.withOpacity(0.2),
      child: Row(
        children: [
          const Icon(Icons.shield, color: AppColors.warmTerracotta),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              'Protocollo di Sicurezza Attivo. Vuoi parlare con un umano?',
              style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          TextButton(
            onPressed: () {
               ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Human support request noted.')),
              );
            },
            child: const Text('CHIAMA', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(ChatConnectionStatus status) {
    return AppBar(
      backgroundColor: _isCrisisMode ? AppColors.warmTerracotta.withOpacity(0.1) : AppColors.background,
      elevation: 0,
      title: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.5),
                  blurRadius: 10,
                ),
              ],
            ),
            child: const Icon(
              Icons.auto_awesome,
              color: AppColors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Kaix Coach',
                style: AppTypography.h4.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                _isCrisisMode ? 'Safety Mode' : _getConnectionStatusText(status),
                style: AppTypography.caption.copyWith(
                  color: _isCrisisMode ? AppColors.warmTerracotta : _getConnectionStatusColor(status),
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: () {
            // Show chat settings or options
          },
          icon: const Icon(Icons.more_vert, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildConnectionStatusBanner(ChatConnectionStatus status) {
    if (status == ChatConnectionStatus.connected) {
      return const SizedBox.shrink();
    }

    Color backgroundColor;
    Color textColor;
    IconData icon;
    String text;

    switch (status) {
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
          if (status == ChatConnectionStatus.failed)
            IOSButton(
              text: 'Retry',
              style: IOSButtonStyle.tertiary,
              size: IOSButtonSize.small,
              onPressed: () => ref.read(chatProvider.notifier).connect(),
            ),
        ],
      ),
    );
  }

  Widget _buildMessagesList(List<ChatMessage> messages, bool isLoading) {
    if (messages.isEmpty && isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        return LoFiMessageBubble(
          message: message.displayText,
          type: _mapMessageType(message.type),
          timestamp: message.timestamp,
          status: _mapMessageStatus(message.status),
          citation: message.citation,
          onRetry: message.isError ? () => ref.read(chatProvider.notifier).sendMessage(message.text) : null,
        );
      },
    );
  }

  MessageType _mapMessageType(ChatMessageType type) {
    switch (type) {
      case ChatMessageType.user:
        return MessageType.user;
      case ChatMessageType.ai:
        return MessageType.bot;
      case ChatMessageType.system:
        return MessageType.system;
      default:
        return MessageType.bot;
    }
  }

  MessageStatus _mapMessageStatus(ChatMessageStatus status) {
    switch (status) {
      case ChatMessageStatus.sending:
        return MessageStatus.sending;
      case ChatMessageStatus.sent:
        return MessageStatus.sent;
      case ChatMessageStatus.delivered:
        return MessageStatus.delivered;
      case ChatMessageStatus.error:
        return MessageStatus.error;
    }
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

  Widget _buildMessageComposer(bool isLoading) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: MessageComposer(
        onSendMessage: (text) => ref.read(chatProvider.notifier).sendMessage(text),
        hintText: _isOnline 
            ? 'Scrivi o parla...'
            : 'Risposte limitate offline...',
        enabled: !isLoading,
        supportsSpeech: false, // Removed mic button
      ),
    );
  }

  String _getConnectionStatusText(ChatConnectionStatus status) {
    if (!_isOnline) return 'Offline';
    
    switch (status) {
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

  Color _getConnectionStatusColor(ChatConnectionStatus status) {
    if (!_isOnline) return AppColors.error;
    
    switch (status) {
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