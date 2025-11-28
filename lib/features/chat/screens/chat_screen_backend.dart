import 'dart:async';
import 'dart:ui'; // For ImageFilter
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart'; // For custom fonts
import '../../../core/routing/app_router.dart';
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
import '../../avatar/widgets/avatar_viewer_3d.dart';
import '../../avatar/providers/avatar_provider.dart';
import '../../avatar/domain/models/avatar_config.dart';

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
          0.0, // For reverse list, 0.0 is the bottom
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
        extendBodyBehindAppBar: true, // Allow body to extend behind the header
        // appBar: Removed standard AppBar
        body: Stack(
          children: [
            // 1. Avatar (Full Screen Background)
            Positioned.fill(
              child: Consumer(
                builder: (context, ref, child) {
                  final avatarState = ref.watch(avatarProvider);
                  
                  // Always show AvatarViewer3D to ensure background is visible
                  // It handles empty/error states internally now
                  AvatarConfig config;
                  if (avatarState is AvatarStateLoaded) {
                    config = avatarState.config;
                  } else {
                    config = const AvatarConfigEmpty();
                  }

                  return AvatarViewer3D(
                    config: config,
                    enableCameraControls: true,
                    autoRotate: false,
                  );
                },
              ),
            ),
            
            // 2. Gradient Overlay (For Text Readability)
            Positioned(
              bottom: 0, 
              left: 0, 
              right: 0, 
              height: 500,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter, 
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(0.9),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 1.0],
                  ),
                ),
              ),
            ),
            
            // 3. Chat UI (Foreground)
            Column(
              children: [
                if (_isCrisisMode) _buildSafetyNetBanner(),
                if (chatState.connectionStatus != ChatConnectionStatus.connected)
                  _buildConnectionStatusBanner(chatState.connectionStatus),
                
                const Spacer(), // Push chat down (Dynamic Stage Rule 1)

                // Dynamic Stage: Limit height & Fade out
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.55, // Max 55% height
                  child: ShaderMask(
                    shaderCallback: (Rect bounds) {
                      return const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent, // Fade out at top
                          Colors.transparent, 
                          Colors.black,       // Visible
                          Colors.black        // Visible at bottom
                        ],
                        stops: [0.0, 0.1, 0.3, 1.0], // Smooth fade
                      ).createShader(bounds);
                    },
                    blendMode: BlendMode.dstIn,
                    child: _buildMessagesList(chatState.messages, chatState.isLoading),
                  ),
                ),
                
                if (chatState.isTyping)
                  _buildTypingIndicator(),
                _buildMessageComposer(chatState.isLoading),
              ],
            ),

            // 4. Floating Glass Header (New Premium Header)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: ClipRRect(
                // Nessun bordo arrotondato in alto, sfuma con lo schermo
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0), // Sfocatura vetro
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      // Gradiente dall'alto per leggere bene batteria/orario e titolo
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.8), // Più scuro in alto (status bar)
                          Colors.black.withOpacity(0.0), // Svanisce verso il basso
                        ],
                      ),
                    ),
                    child: SafeArea(
                      bottom: false, // Non aggiungere padding sotto
                      child: Row(
                        children: [
                          // 1. BACK BUTTON (Stilizzato)
                          GestureDetector(
                            onTap: () {
                              if (context.canPop()) {
                                context.pop();
                              } else {
                                context.go(AppRoute.dashboard.path);
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withOpacity(0.1), // Bottone vetro
                              ),
                              child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                            ),
                          ),
                          
                          const SizedBox(width: 16),
                          
                          // 2. INFO COACH (Senza avatar tondo, solo testo)
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // NOME
                                Text(
                                  "Kaix Coach",
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    shadows: [const Shadow(color: Colors.black45, blurRadius: 4)],
                                  ),
                                ),
                                // STATUS
                                Row(
                                  children: [
                                    // Pallino verde
                                    Container(
                                      width: 8, height: 8,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF4ADE80), // Verde brillante
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(color: const Color(0xFF4ADE80).withOpacity(0.6), blurRadius: 6, spreadRadius: 1)
                                        ]
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      "Mental Performance", // O "Online"
                                      style: GoogleFonts.nunito(
                                        color: Colors.white70,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                          
                          // 3. MENU / SETTINGS
                          PopupMenuButton<AppRoute>(
                            icon: const Icon(Icons.more_vert, color: Colors.white70),
                            onSelected: (route) => context.push(route.path),
                            color: const Color(0xFF1A1A1A), // Dark background for menu
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                value: AppRoute.dashboard,
                                child: Row(
                                  children: [
                                    const Icon(Icons.dashboard_outlined, color: Colors.white70),
                                    const SizedBox(width: 8),
                                    Text('Dashboard', style: GoogleFonts.nunito(color: Colors.white)),
                                  ],
                                ),
                              ),
                              PopupMenuItem(
                                value: AppRoute.avatar,
                                child: Row(
                                  children: [
                                    const Icon(Icons.face_outlined, color: Colors.white70),
                                    const SizedBox(width: 8),
                                    Text('Avatar', style: GoogleFonts.nunito(color: Colors.white)),
                                  ],
                                ),
                              ),
                              PopupMenuItem(
                                value: AppRoute.settings,
                                child: Row(
                                  children: [
                                    const Icon(Icons.settings_outlined, color: Colors.white70),
                                    const SizedBox(width: 8),
                                    Text('Settings', style: GoogleFonts.nunito(color: Colors.white)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
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
      reverse: true, // Dynamic Stage Rule 3: Anchor to bottom
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        // Since list is reversed (bottom-up), we need to access messages from end to start
        // messages list is [oldest, ..., newest]
        // index 0 (bottom) should be newest -> messages.length - 1
        final message = messages[messages.length - 1 - index];
        
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
      // Padding removed to let MessageComposer handle its own floating margins
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