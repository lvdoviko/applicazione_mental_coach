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

/// **Lo-Fi Minimal Chat Screen**
/// 
/// **Functional Description:**
/// Clean chat interface with smooth message bubbles, contextual suggestions,
/// and minimal input composer. Supports voice and text interactions.
/// 
/// **Visual Specifications:**
/// - Background: #FBF9F8 (paper)
/// - Messages: User #DCEEF9, Bot #FFF7EA bubbles
/// - Input: #FFFFFF persistent bottom bar
/// - Typography: Inter 16px with 1.4 line-height
/// - Animations: 350ms smooth transitions
/// 
/// **Accessibility:**
/// - Message list semantics
/// - Voice input announcements  
/// - Focus management
/// - Screen reader optimizations
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
        content: 'Hello! I\'m your AI Wellbeing Coach. I\'m here to support you on your mental wellness journey. How are you feeling today?',
        type: MessageType.bot,
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      ),
      ChatMessage(
        id: '2',
        content: 'Hi! I\'ve been feeling a bit overwhelmed with training lately.',
        type: MessageType.user,
        timestamp: DateTime.now().subtract(const Duration(minutes: 4)),
        status: MessageStatus.read,
      ),
      ChatMessage(
        id: '3',
        content: 'I understand that training can feel overwhelming sometimes. It\'s completely normal to feel this way, especially when you\'re pushing yourself to improve. Can you tell me more about what specifically feels overwhelming?',
        type: MessageType.bot,
        timestamp: DateTime.now().subtract(const Duration(minutes: 3)),
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(
            child: _buildMessagesList(),
          ),
          _buildQuickSuggestions(),
          _buildInputComposer(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.surface,
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      title: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withOpacity(0.8),
                  AppColors.secondary.withOpacity(0.6),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.psychology_outlined,
              color: AppColors.surface,
              size: 20,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'AI Coach',
                style: AppTypography.h4.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                'Always here for you',
                style: AppTypography.caption.copyWith(
                  color: AppColors.textSecondary,
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
          tooltip: 'Conversation details',
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
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withOpacity(0.8),
                  AppColors.secondary.withOpacity(0.6),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.psychology_outlined,
              color: AppColors.surface,
              size: 16,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.messageBubblePadding,
              vertical: AppSpacing.md,
            ),
            decoration: BoxDecoration(
              color: AppColors.botBubble,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
                bottomRight: Radius.circular(16),
                bottomLeft: Radius.circular(4),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.textPrimary.withOpacity(0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
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
                    color: AppColors.grey400.withOpacity(value),
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

  Widget _buildQuickSuggestions() {
    final suggestions = _getContextualSuggestions();
    
    return LoFiQuickSuggestions(
      suggestions: suggestions,
      onSuggestionTap: _sendMessage,
      isVisible: suggestions.isNotEmpty && !_isTyping,
    );
  }

  List<String> _getContextualSuggestions() {
    if (_messages.isEmpty) return QuickSuggestionPresets.general;
    
    final lastMessage = _messages.last;
    if (lastMessage.type == MessageType.user) return [];
    
    // Context-based suggestions based on AI's last message
    if (lastMessage.content.contains('overwhelming')) {
      return QuickSuggestionPresets.getContextualSuggestions('supportive');
    } else if (lastMessage.content.contains('feeling')) {
      return QuickSuggestionPresets.getContextualSuggestions('empathetic');
    } else if (lastMessage.content.contains('tell me more')) {
      return QuickSuggestionPresets.getContextualSuggestions('curious');
    }
    
    return QuickSuggestionPresets.empathetic;
  }

  Widget _buildInputComposer() {
    return LoFiInputComposer(
      onSendMessage: _sendMessage,
      hintText: 'Share what\'s on your mind...',
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

    // Auto scroll to bottom
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
    setState(() {
      final index = _messages.indexWhere((m) => m.id == message.id);
      if (index != -1) {
        _messages[index] = message.copyWith(status: MessageStatus.sending);
      }
    });
    
    // Retry sending after a delay
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        final index = _messages.indexWhere((m) => m.id == message.id);
        if (index != -1) {
          _messages[index] = message.copyWith(status: MessageStatus.sent);
        }
      });
    });
  }

  void _simulateAIResponse(String userMessage) {
    final aiResponse = _generateContextualResponse(userMessage);
    
    final aiMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: aiResponse,
      type: MessageType.bot,
      timestamp: DateTime.now(),
    );

    setState(() {
      _isTyping = false;
      _messages.add(aiMessage);
    });

    // Auto scroll to bottom
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  String _generateContextualResponse(String userMessage) {
    // Simple contextual response generation (placeholder for AI integration)
    final message = userMessage.toLowerCase();
    
    if (message.contains('stress') || message.contains('anxious')) {
      return 'It sounds like you\'re dealing with stress. That\'s completely understandable. Let\'s explore some techniques that might help you feel more grounded. Have you tried any breathing exercises recently?';
    } else if (message.contains('tired') || message.contains('fatigue')) {
      return 'Feeling tired can really impact your performance and wellbeing. Rest is just as important as training. How has your sleep been lately? Are you getting enough recovery time?';
    } else if (message.contains('motivation') || message.contains('unmotivated')) {
      return 'It\'s natural for motivation to fluctuate - even elite athletes experience this. What usually helps you reconnect with your passion for your sport?';
    } else if (message.contains('pressure')) {
      return 'Pressure can be challenging to navigate. Remember, it\'s often a sign that you care deeply about your performance. Let\'s talk about ways to channel that energy positively.';
    }
    
    return 'Thank you for sharing that with me. I\'m here to listen and support you. Can you tell me more about how this is affecting you?';
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

  ChatMessage({
    required this.id,
    required this.content,
    required this.type,
    required this.timestamp,
    this.status = MessageStatus.sent,
  });

  ChatMessage copyWith({
    String? id,
    String? content,
    MessageType? type,
    DateTime? timestamp,
    MessageStatus? status,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      content: content ?? this.content,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
    );
  }
}