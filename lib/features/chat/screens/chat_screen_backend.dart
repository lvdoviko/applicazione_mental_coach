import 'dart:async';
import 'dart:ui'; // For ImageFilter
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart'; // For custom fonts
import 'package:applicazione_mental_coach/l10n/app_localizations.dart';
import '../../../core/routing/app_router.dart';
import '../../../design_system/tokens/app_colors.dart';
import '../../../design_system/tokens/app_typography.dart';
import '../../../design_system/tokens/app_spacing.dart';
import '../../../design_system/components/lofi_message_bubble.dart';
import '../../../design_system/components/mental_coach_response_bubble.dart';
import '../../../design_system/components/ios_button.dart';
import '../../../design_system/components/message_composer.dart';
import '../../../design_system/components/glass_drawer.dart';
import '../../../core/services/connectivity_service.dart';
import '../services/chat_websocket_service.dart';
import '../models/chat_message.dart';
import '../providers/chat_provider.dart';
import '../../avatar/widgets/avatar_viewer_3d.dart';
import '../../avatar/providers/avatar_provider.dart';
import '../../avatar/domain/models/avatar_config.dart';
import 'package:applicazione_mental_coach/features/user/providers/user_provider.dart';

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
  
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final ScrollController _scrollController = ScrollController();
  
  // State
  bool _isOnline = true;
  bool _isCrisisMode = false; // Safety Net State
  bool _isAvatarVisuallyReady = false; // Controls the initial black veil for seamless transition
  
  // Subscriptions
  StreamSubscription<ConnectivityStatus>? _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    // Connect when screen initializes (if not already connected)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Sync Avatar with User Profile
      final user = ref.read(userProvider);
      final avatarState = ref.read(avatarProvider);
      
      // Determine Coach Name for Welcome Message
      String coachName = "Atlas"; // Default
      if (user?.avatarId == 'serena') {
        coachName = "Serena";
      }
      
      // Get localized welcome message
      final welcomeText = AppLocalizations.of(context)!.welcomeMessage(coachName);

      ref.read(chatProvider.notifier).connect(welcomeMessageText: welcomeText);
      
      // ALWAYS check and load the correct avatar based on User Profile
      // The provider handles deduplication (skipping if URL matches)
      if (user?.avatarId != null && 
          avatarState is! AvatarStateDownloading && 
          avatarState is! AvatarStateLoading) {
        ref.read(avatarProvider.notifier).loadAvatarFromId(user!.avatarId!);
      }
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
    
    final avatarState = ref.watch(avatarProvider);
    final config = switch (avatarState) {
      AvatarStateLoaded(config: final c) => c,
      _ => const AvatarConfigEmpty(),
    };

    // Notify ChatProvider when Avatar is ready to receive the welcome stream
    if (avatarState is AvatarStateLoaded) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Add delay to allow avatar to visually appear before text starts
        Future.delayed(const Duration(milliseconds: 1000), () {
          if (mounted) {
             ref.read(chatProvider.notifier).notifyAvatarLoaded();
          }
        });
      });
    }

    // Auto-scroll on new messages
    ref.listen(chatProvider, (previous, next) {
      if (previous?.messages.length != next.messages.length) {
        _scrollToBottom();
      }
    });
    // Debug Avatar State
    ref.listen(avatarProvider, (previous, next) {
      // debugPrint('👤 Avatar State Changed: $next'); // Removed to prevent spam
      if (next is AvatarStateError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Avatar Error: ${next.failure.message}')),
        );
      }
    });

    // Listen for User Profile changes (e.g. Avatar switch)
    ref.listen(userProvider, (previous, next) async {
      if (next?.avatarId != null && next?.avatarId != previous?.avatarId) {
        debugPrint('👤 User changed avatar to: ${next!.avatarId}');
        
        // 1. Reload Avatar (Force reload to ensure engine updates)
        ref.read(avatarProvider.notifier).loadAvatarFromId(next.avatarId!, force: true);
        
        // 2. Prepare Welcome Message
        String coachName = "Atlas";
        if (next.avatarId == 'serena') {
          coachName = "Serena";
        }
        final welcomeText = AppLocalizations.of(context)!.welcomeMessage(coachName);

        // 3. Reset Chat Session & Inject Welcome Message
        await ref.read(chatProvider.notifier).resetChat(welcomeMessageText: welcomeText);
      }
    });

    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      color: _isCrisisMode ? AppColors.warmTerracotta.withOpacity(0.1) : AppColors.background,
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.transparent,
        drawerScrimColor: Colors.black.withOpacity(0.6), // Darken background when drawer is open
        extendBodyBehindAppBar: true,
        drawer: const GlassDrawer(), // New Glassmorphism Drawer
        body: Stack(
          children: [
            Positioned.fill(
              child: AvatarViewer3D(
                config: config,
                enableCameraControls: true,
                autoRotate: false,
                onAvatarLoaded: () {
                  if (!_isAvatarVisuallyReady) {
                    setState(() => _isAvatarVisuallyReady = true);
                  }
                },
              ),
            ),
            
            // Avatar Loading Overlay (Standard - for avatar switches)
            if ((avatarState is AvatarStateDownloading || avatarState is AvatarStateLoading) && !_isAvatarVisuallyReady)
              Container(
                color: Colors.black.withOpacity(0.7),
                child: const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(color: AppColors.primary),
                      SizedBox(height: 16),
                      Text(
                        "Downloading Avatar...",
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),

             // INITIAL LOADING VEIL (Cinematic Transition)
             // Covers everything until the avatar is fully ready
             IgnorePointer(
               ignoring: _isAvatarVisuallyReady,
               child: AnimatedOpacity(
                 duration: const Duration(milliseconds: 500),
                 opacity: _isAvatarVisuallyReady ? 0.0 : 1.0,
                 child: Container(
                   color: Colors.black, // Opaque black to match CoachSelectionScreen
                   child: const Center(
                     child: CircularProgressIndicator(color: AppColors.primary),
                   ),
                 ),
               ),
             ),

            // 2. CHAT CONTENT LAYER
            Column(
              children: [
                // Spacer for Header
                SizedBox(height: MediaQuery.of(context).padding.top + 60),
                
                // Connection Status
                _buildConnectionStatusBanner(chatState.connectionStatus),

                // Safety Net Banner
                if (_isCrisisMode) _buildSafetyNetBanner(),

                // Messages List
                Expanded(
                  child: _buildMessagesList(chatState.messages, chatState.isLoading),
                ),
                
                // Typing Indicator
                if (chatState.isTyping) _buildTypingIndicator(),
                
                // Input Bar
                _buildMessageComposer(chatState.isLoading),
              ],
            ),
            
            // 4. Floating Glass Header
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: ClipRRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                  child: Container(
                    padding: EdgeInsets.only(
                      top: MediaQuery.of(context).padding.top + 8,
                      bottom: 12,
                      left: 16,
                      right: 16,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.6),
                          Colors.black.withOpacity(0.0),
                        ],
                      ),
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.white.withOpacity(0.05),
                          width: 1,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        // 1. HAMBURGER BUTTON (Sidebar)
                        GestureDetector(
                          onTap: () => _scaffoldKey.currentState?.openDrawer(),
                          child: const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Icon(Icons.menu, color: Colors.white, size: 24),
                          ),
                        ),
                        
                        const SizedBox(width: 12),
                        
                        // 2. INFO COACH (Senza avatar tondo, solo testo)
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // NOME
                              Text(
                                "Kaix Coach",
                                style: GoogleFonts.outfit(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              // STATUS
                              Row(
                                children: [
                                    Container(
                                    width: 6,
                                    height: 6,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF4ADE80), // Green dot
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    "Mental Performance", // O "Online"
                                    style: GoogleFonts.nunito(
                                      color: Colors.white.withOpacity(0.7),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                        
                        // 3. (Optional) Right Action or Empty
                        // Removed PopupMenuButton as requested
                      ],
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
        
        if (message.type == ChatMessageType.ai) {
           return MentalCoachResponseBubble(
             key: ValueKey('${message.id}_${message.displayText.length}'),
             text: message.displayText,
             isStreaming: message.isStreaming, 
           );
        }

        return LoFiMessageBubble(
          key: ValueKey('${message.id}_${message.displayText.length}'), 
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