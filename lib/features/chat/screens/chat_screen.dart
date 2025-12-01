import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:applicazione_mental_coach/design_system/tokens/app_colors.dart';
import 'package:applicazione_mental_coach/design_system/tokens/app_typography.dart';
import 'package:applicazione_mental_coach/design_system/tokens/app_spacing.dart';
import 'package:applicazione_mental_coach/design_system/tokens/app_animations.dart';
import 'package:applicazione_mental_coach/design_system/components/lofi_message_bubble.dart';
import 'package:applicazione_mental_coach/design_system/components/lofi_input_composer.dart';
import 'package:applicazione_mental_coach/design_system/components/lofi_quick_suggestions.dart';
import 'package:applicazione_mental_coach/l10n/app_localizations.dart';
import 'package:applicazione_mental_coach/features/avatar/widgets/avatar_viewer_3d.dart';

import 'package:applicazione_mental_coach/features/avatar/providers/avatar_provider.dart';
import 'package:applicazione_mental_coach/features/avatar/domain/models/avatar_config.dart';

/// **Performance Chat Screen**
///
/// **Functional Description:**
/// High-performance chat interface with RAG transparency and Safety Net protocols.
class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isTyping = false;
  bool _isRecording = false;
  bool _isCrisisMode = false; // Safety Net State

  @override
  void initState() {
    super.initState();
    _initializeDemoMessages();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _initializeDemoMessages() {
    _messages.addAll([
      ChatMessage(
        id: '1',
        content: 'Ciao! Sono il tuo Mental Performance Coach. Sono qui per ottimizzare il tuo mindset. Come ti senti oggi?',
        type: MessageType.bot,
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final avatarState = ref.watch(avatarProvider);
    final avatarConfig = switch (avatarState) {
      AvatarStateLoaded(config: final c) => c,
      _ => const AvatarConfigEmpty(),
    };

    return Scaffold(
      extendBodyBehindAppBar: true, // Estende il corpo dietro l'AppBar trasparente
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          // 0. BACKGROUND: Immersive Gradient (Deep Blue)
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(0.0, -0.3), // Center behind avatar chest
                  radius: 1.2,
                  colors: [
                    Color(0xFF1A2A3A), // Deep Blue (Center)
                    Color(0xFF000000), // Black (Edges)
                  ],
                  stops: [0.0, 1.0],
                ),
              ),
            ),
          ),

          // 1. AVATAR LAYER: Transparent 3D Viewer
          // 1. AVATAR LAYER: Transparent 3D Viewer (Aligned to Bottom)
          // 1. AVATAR LAYER: Simple Bottom Positioning
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 400,
            child: Hero(
              tag: 'coach_avatar',
              child: AvatarViewer3D(
                config: avatarConfig,
              ),
            ),
          ),

          // 2. OVERLAY: Gradient for text readability
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.0),
                    Colors.black.withOpacity(0.6),
                    Colors.black.withOpacity(0.9),
                  ],
                  stops: const [0.0, 0.5, 0.8, 1.0],
                ),
              ),
            ),
          ),

          // 3. FOREGROUND: Chat Content
          Column(
            children: [
              if (_isCrisisMode) _buildSafetyNetBanner(),
              Expanded(
                child: _buildMessagesList(),
              ),
              _buildInputComposer(),
            ],
          ),
        ],
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
              // TODO: Call human coach
            },
            child: const Text('CHIAMA', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent, // Trasparente per mostrare l'avatar
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.light,
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
                _isCrisisMode ? 'Safety Mode' : 'Online',
                style: AppTypography.caption.copyWith(
                  color: _isCrisisMode ? AppColors.warmTerracotta : AppColors.success,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: () {
            // TODO: Implement conversation details
          },
          icon: const Icon(
            Icons.info_outline,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildMessagesList() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenPadding,
        vertical: AppSpacing.lg,
      ),
      itemCount: _messages.length + (_isTyping ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _messages.length && _isTyping) {
          return _buildTypingIndicator();
        }

        final message = _messages[index];
        return LoFiMessageBubble(
          message: message.content,
          type: message.type,
          timestamp: message.timestamp,
          status: message.status,
          isAnimated: index == _messages.length - 1,
          citation: message.citation, // Pass citation
          onRetry: message.status == MessageStatus.error
              ? () => _retryMessage(message)
              : null,
        );
      },
    );
  }

  Widget _buildTypingIndicator() {
    return Container(
      margin: const EdgeInsets.only(
        right: AppSpacing.massive,
        bottom: AppSpacing.messageBubbleMargin,
      ),
      child: Row(
        children: [
          /*
          Container(
            width: 28,
            height: 28,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.auto_awesome,
              color: AppColors.surface,
              size: 16,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          */
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.messageBubblePadding,
              vertical: AppSpacing.md,
            ),
            decoration: const BoxDecoration(
              color: AppColors.botBubble,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
                bottomRight: Radius.circular(16),
                bottomLeft: Radius.circular(4),
              ),
            ),
            child: _buildAnimatedDots(),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedDots() {
    return SizedBox(
      width: 40,
      height: 20,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(3, (index) {
          return TweenAnimationBuilder<double>(
            duration: Duration(milliseconds: 600 + (index * 200)),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Transform.scale(
                scale: 0.5 + (0.5 * value),
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: AppColors.textSecondary.withOpacity(value),
                    shape: BoxShape.circle,
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }



  Widget _buildInputComposer() {
    return LoFiInputComposer(
      onSendMessage: _sendMessage,
      hintText: 'Scrivi o parla...',
      isRecording: _isRecording,
      onVoiceStart: () {
        setState(() {
          _isRecording = true;
        });
        // TODO: Implement voice recording start
      },
      onVoiceStop: () {
        setState(() {
          _isRecording = false;
        });
        // TODO: Implement voice recording stop
      },
    );
  }

  void _sendMessage(String message) {
    if (message.trim().isEmpty) return;

    final userMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: message.trim(),
      type: MessageType.user,
      timestamp: DateTime.now(),
      status: MessageStatus.sending,
    );

    setState(() {
      _messages.add(userMessage);
      _isTyping = true;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });

    // Simulate message delivery
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        final index = _messages.indexWhere((m) => m.id == userMessage.id);
        if (index != -1) {
          _messages[index] = userMessage.copyWith(status: MessageStatus.delivered);
        }
      });
    });

    // Simulate AI response
    Future.delayed(const Duration(seconds: 2), () {
      _simulateAIResponse(message);
    });
  }

  void _retryMessage(ChatMessage message) {
    // Retry logic
  }

  void _simulateAIResponse(String userMessage) {
    String content;
    String? citation;
    bool triggerCrisis = false;

    final msg = userMessage.toLowerCase();

    if (msg.contains('panico') || msg.contains('aiuto') || msg.contains('non ce la faccio')) {
      content = 'Sento che sei in difficoltà. Sono qui con te. Vuoi che contatti lo psicologo del team o preferisci un esercizio di respirazione guidata?';
      triggerCrisis = true;
    } else if (msg.contains('focus') || msg.contains('concentrazione')) {
      content = 'La visualizzazione guidata può aumentare la concentrazione del 30% prima della gara. Vuoi provare il protocollo "Tunnel Vision"?';
      citation = 'Fonte: Journal of Sports Psychology, 2023';
    } else {
      content = 'Capisco. Raccontami di più su come questo influisce sulla tua performance.';
    }

    final aiMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      type: MessageType.bot,
      timestamp: DateTime.now(),
      citation: citation,
    );

    setState(() {
      _isTyping = false;
      _messages.add(aiMessage);
      if (triggerCrisis) _isCrisisMode = true;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: AppAnimations.medium,
        curve: AppAnimations.easeOut,
      );
    }
  }
}

class ChatMessage {
  final String id;
  final String content;
  final MessageType type;
  final DateTime timestamp;
  final MessageStatus status;
  final String? citation; // RAG Citation
  final bool isCrisis; // Safety Net Trigger

  ChatMessage({
    required this.id,
    required this.content,
    required this.type,
    required this.timestamp,
    this.status = MessageStatus.sent,
    this.citation,
    this.isCrisis = false,
  });

  ChatMessage copyWith({
    String? id,
    String? content,
    MessageType? type,
    DateTime? timestamp,
    MessageStatus? status,
    String? citation,
    bool? isCrisis,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      content: content ?? this.content,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
      citation: citation ?? this.citation,
      isCrisis: isCrisis ?? this.isCrisis,
    );
  }
}